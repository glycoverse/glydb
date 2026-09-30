# Build-time helpers only: public getters never compute database features.
index_candidate_map <- function(keys) {
  split(seq_along(keys), factor(keys, levels = unique(keys)))
}

index_component_data <- function(composition) {
  values <- as.list(composition)
  columns <- sort(unique(unlist(lapply(values, names), use.names = FALSE)))
  counts <- matrix(
    0L,
    nrow = length(values),
    ncol = length(columns),
    dimnames = list(NULL, columns)
  )
  present <- counts != 0L
  for (i in seq_along(values)) {
    if (is.null(values[[i]])) {
      counts[i, ] <- NA_integer_
    } else {
      columns_i <- match(names(values[[i]]), columns)
      counts[i, columns_i] <- as.integer(values[[i]])
      present[i, columns_i] <- TRUE
    }
  }
  list(counts = counts, present = present)
}

build_glydb_index <- function(data, mono_type, structure_level = NULL) {
  old_collation <- Sys.getlocale("LC_COLLATE")
  on.exit(Sys.setlocale("LC_COLLATE", old_collation), add = TRUE)
  Sys.setlocale("LC_COLLATE", "C")
  message(
    "Building ",
    paste(c(structure_level, mono_type), collapse = " "),
    " index"
  )
  is_structure <- !is.null(structure_level)
  glycan <- if (is_structure) data$glycan_structure else data$glycan_composition
  composition <- if (is_structure) {
    glyrepr::as_glycan_composition(glycan)
  } else {
    glycan
  }
  generic_composition <- glyrepr::convert_to_generic(composition)
  native <- index_component_data(composition)
  generic <- index_component_data(generic_composition)
  species <- strsplit(data$species, ";", fixed = TRUE)
  types <- strsplit(data$glycan_type, ";", fixed = TRUE)
  species_ids <- lapply(glydb_species(), function(value) {
    which(vapply(species, function(x) value %in% x, logical(1)))
  })
  names(species_ids) <- glydb_species()
  type_ids <- lapply(glycan_type_choices(), function(value) {
    which(vapply(types, match_glycan_type, logical(1), glycan_type = value))
  })
  names(type_ids) <- glycan_type_choices()
  ids <- seq_along(glycan)
  confidence <- data$confidence
  best_order <- order(
    replace(confidence, is.na(confidence), -Inf),
    decreasing = TRUE,
    method = "radix"
  )
  keys <- list(
    exact = unname(as.character(composition)),
    generic = unname(as.character(generic_composition))
  )
  index <- list(
    schema_version = 1L,
    key_collation = "C",
    glyrepr_version = as.character(utils::packageVersion("glyrepr")),
    view = paste(
      c(
        if (is_structure) "structure" else "composition",
        structure_level,
        mono_type
      ),
      collapse = "_"
    ),
    mono_type = mono_type,
    structure_level = structure_level,
    record_id = ids,
    active_ids = ids,
    confidence = confidence,
    best_rank = match(ids, best_order),
    composition_keys = keys,
    composition_maps = lapply(keys, index_candidate_map),
    counts = native$counts,
    generic_counts = generic$counts,
    components = native$present,
    generic_components = generic$present,
    species = data$species,
    glycan_type = data$glycan_type,
    filter_ids = list(species = species_ids, glycan_type = type_ids)
  )
  if (is_structure) {
    structure_key <- function(x) {
      unname(glyrepr::canonicalize_glycan_graphs(as.list(x))$iupac)
    }
    generic_structure <- glyrepr::convert_to_generic(glycan)
    index$structure_keys <- list(
      exact = structure_key(glycan),
      generic = structure_key(generic_structure),
      topological = structure_key(glyrepr::remove_linkages(glycan)),
      generic_topological = structure_key(glyrepr::remove_linkages(
        generic_structure
      ))
    )
    index$structure_maps <- lapply(index$structure_keys, index_candidate_map)
    index$has_floating_parts <- glyrepr::has_floating_parts(glycan)
    index$has_floating_substituents <- glyrepr::has_floating_substituents(
      glycan
    )
  }
  # Hash plain data, excluding graph environments and external pointers.
  fingerprint_file <- tempfile(fileext = ".rds")
  on.exit(unlink(fingerprint_file), add = TRUE)
  saveRDS(index, fingerprint_file, compress = FALSE, version = 3)
  index$data_version <- unname(tools::md5sum(fingerprint_file))
  index$glycans <- if (is_structure) {
    new_glydb_structure(glycan, confidence)
  } else {
    new_glydb_composition(glycan, confidence)
  }
  index$composition <- composition
  class(index) <- c(
    if (is_structure) "glydb_structure_index" else "glydb_composition_index",
    "glydb_index"
  )
  index
}

build_glydb_indexes <- function() {
  composition_indexes <- list(
    concrete = build_glydb_index(concrete_comps, "concrete"),
    generic = build_glydb_index(generic_comps, "generic")
  )
  structure_indexes <- list(
    intact = list(
      concrete = build_glydb_index(
        intact_concrete_strucs,
        "concrete",
        "intact"
      ),
      generic = build_glydb_index(intact_generic_strucs, "generic", "intact")
    ),
    topological = list(
      concrete = build_glydb_index(
        topological_concrete_strucs,
        "concrete",
        "topological"
      ),
      generic = build_glydb_index(
        topological_generic_strucs,
        "generic",
        "topological"
      )
    )
  )
  list(composition = composition_indexes, structure = structure_indexes)
}
