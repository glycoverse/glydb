test_that("composition indexes contain aligned precomputed data", {
  for (mono_type in c("concrete", "generic")) {
    index <- glydb_composition_index(mono_type)
    data <- if (mono_type == "concrete") concrete_comps else generic_comps
    expect_s3_class(index, "glydb_composition_index")
    expect_identical(index$schema_version, 1L)
    expect_identical(index$key_collation, "C")
    expect_match(index$data_version, "^[[:xdigit:]]{32}$")
    expect_identical(index$record_id, seq_len(nrow(data)))
    expect_identical(index$active_ids, index$record_id)
    expect_identical(index$composition, data$glycan_composition)
    expect_identical(index$confidence, data$confidence)
    expect_identical(attr(index$glycans, "confidence"), data$confidence)
    expect_identical(
      as.character(index$glycans),
      as.character(data$glycan_composition)
    )
    expect_identical(
      index$composition_keys$exact,
      as.character(data$glycan_composition)
    )
    expect_identical(
      index$composition_keys$generic,
      as.character(glyrepr::convert_to_generic(data$glycan_composition))
    )
    best_order <- order(-replace(data$confidence, is.na(data$confidence), -Inf))
    expect_identical(order(index$best_rank), best_order)
    for (resolution in names(index$composition_maps)) {
      groups <- index$composition_maps[[resolution]]
      keys <- index$composition_keys[[resolution]]
      expect_identical(sort(unlist(groups, use.names = FALSE)), index$record_id)
      expect_identical(
        keys[unlist(groups, use.names = FALSE)],
        rep(names(groups), lengths(groups))
      )
      expect_identical(
        vapply(groups, is.unsorted, logical(1)),
        setNames(rep(FALSE, length(groups)), names(groups))
      )
    }
  }
})

test_that("structure indexes preserve records across resolution conversions", {
  for (level in c("intact", "topological")) {
    for (mono_type in c("concrete", "generic")) {
      index <- glydb_structure_index(level, mono_type)
      data <- get(paste(level, mono_type, "strucs", sep = "_"))
      expect_s3_class(index, "glydb_structure_index")
      expect_identical(index$key_collation, "C")
      expect_identical(index$record_id, seq_len(nrow(data)))
      expect_identical(index$confidence, data$confidence)
      expect_identical(
        as.character(index$glycans),
        as.character(data$glycan_structure)
      )
      ids <- unique(as.integer(seq(1, nrow(data), length.out = 12)))
      strucs <- data$glycan_structure[ids]
      generic <- glyrepr::convert_to_generic(strucs)
      structure_key <- function(x) {
        unname(glyrepr::canonicalize_glycan_graphs(as.list(x))$iupac)
      }
      expected_keys <- list(
        exact = structure_key(strucs),
        generic = structure_key(generic),
        topological = structure_key(glyrepr::remove_linkages(strucs)),
        generic_topological = structure_key(glyrepr::remove_linkages(generic))
      )
      expect_identical(
        index$composition[ids],
        glyrepr::as_glycan_composition(strucs)
      )
      expect_identical(
        index$has_floating_parts[ids],
        glyrepr::has_floating_parts(strucs)
      )
      expect_identical(
        index$has_floating_substituents[ids],
        glyrepr::has_floating_substituents(strucs)
      )
      for (resolution in names(expected_keys)) {
        keys <- index$structure_keys[[resolution]]
        groups <- index$structure_maps[[resolution]]
        expect_identical(keys[ids], expected_keys[[resolution]])
        expect_identical(
          sort(unlist(groups, use.names = FALSE)),
          index$record_id
        )
        expect_identical(
          keys[unlist(groups, use.names = FALSE)],
          rep(names(groups), lengths(groups))
        )
      }
      for (resolution in names(index$composition_maps)) {
        keys <- index$composition_keys[[resolution]]
        groups <- index$composition_maps[[resolution]]
        expect_identical(
          sort(unlist(groups, use.names = FALSE)),
          index$record_id
        )
        expect_identical(
          keys[unlist(groups, use.names = FALSE)],
          rep(names(groups), lengths(groups))
        )
      }
      expect_identical(
        index$composition_keys$exact,
        as.character(index$composition)
      )
      expect_identical(
        index$composition_keys$generic,
        as.character(glyrepr::convert_to_generic(index$composition))
      )
      expect_identical(
        order(index$best_rank),
        order(-replace(data$confidence, is.na(data$confidence), -Inf))
      )
    }
  }
})

test_that("count matrices include native and generic substituent counts", {
  indexes <- list(
    glydb_composition_index(),
    glydb_composition_index("generic"),
    glydb_structure_index(),
    glydb_structure_index(mono_type = "generic"),
    glydb_structure_index("topological"),
    glydb_structure_index("topological", "generic")
  )
  for (index in indexes) {
    for (generic in c(FALSE, TRUE)) {
      counts <- if (generic) index$generic_counts else index$counts
      present <- if (generic) index$generic_components else index$components
      composition <- if (generic) {
        glyrepr::convert_to_generic(index$composition)
      } else {
        index$composition
      }
      values <- as.list(composition)
      expect_type(counts, "integer")
      expect_type(present, "logical")
      expect_identical(dim(counts), dim(present))
      expect_identical(nrow(counts), length(index$record_id))
      for (component in colnames(counts)) {
        expected <- vapply(
          values,
          function(x) {
            if (component %in% names(x)) as.integer(x[[component]]) else 0L
          },
          integer(1)
        )
        expect_identical(unname(counts[, component]), expected)
        expect_identical(
          unname(present[, component]),
          vapply(values, function(x) component %in% names(x), logical(1))
        )
      }
    }
  }
})

test_that("filters retain full indexes and the existing getter semantics", {
  for (mono_type in c("concrete", "generic")) {
    for (level in c("composition", "intact", "topological")) {
      composition <- level == "composition"
      fun <- if (composition) glydb_composition_index else glydb_structure_index
      getter <- if (composition) glydb_compositions else glydb_structures
      args <- list(mono_type = mono_type)
      if (!composition) {
        args$structure_level <- level
      }
      full <- do.call(fun, args)
      for (type in c("N", "O", "O-GalNAc")) {
        filters <- list(species = "Homo sapiens", glycan_type = type)
        index <- do.call(fun, c(args, filters))
        species <- strsplit(full$species, ";", fixed = TRUE)
        types <- strsplit(full$glycan_type, ";", fixed = TRUE)
        expected <- which(
          vapply(species, function(x) "Homo sapiens" %in% x, logical(1)) &
            vapply(types, match_glycan_type, logical(1), glycan_type = type)
        )
        expect_identical(index$active_ids, expected)
        expect_identical(index$glycans, full$glycans)
        expect_identical(index$composition_maps, full$composition_maps)
        expect_identical(index$data_version, full$data_version)
        ranges <- list(Hex = c(3L, 10L), HexNAc = c(2L, 10L))
        reference <- full$glycans[expected]
        mask <- filter_by_mono_range(reference, ranges, mono_type)
        filtered <- do.call(fun, c(args, filters, list(mono_range = ranges)))
        expect_identical(filtered$active_ids, expected[mask])
        expect_identical(
          do.call(getter, c(args, filters, list(mono_range = ranges))),
          reference[mask]
        )
      }
    }
  }
})

test_that("native ranges and impossible ranges preserve matrix dimensions", {
  index <- glydb_composition_index(
    mono_range = list(Glc = c(0L, 10L), Gal = c(0L, 10L))
  )
  full <- glydb_composition_index()
  mask <- filter_by_mono_range(
    full$glycans,
    list(Glc = c(0L, 10L), Gal = c(0L, 10L)),
    "concrete"
  )
  expect_identical(index$active_ids, full$record_id[mask])
  empty <- glydb_structure_index(mono_range = list(Hex = c(100000L, Inf)))
  expect_identical(empty$active_ids, integer())
  expect_identical(dim(empty$counts), dim(glydb_structure_index()$counts))
  expect_length(empty$glycans[empty$active_ids], 0L)
})

test_that("floating exclusion uses stored flags and preserves full records", {
  for (level in c("intact", "topological")) {
    full <- glydb_structure_index(level)
    filtered <- glydb_structure_index(level, exclude_floating = TRUE)
    floating <- full$has_floating_parts | full$has_floating_substituents
    floating[is.na(floating)] <- FALSE
    expect_identical(filtered$active_ids, full$record_id[!floating])
    expect_identical(filtered$glycans, full$glycans)
  }
})

test_that("index getters do not recompute database features", {
  fail <- function(...) stop("Database feature recomputed at query time")
  local_mocked_bindings(
    convert_to_generic = fail,
    as_glycan_composition = fail,
    count_mono = fail,
    remove_linkages = fail,
    canonicalize_glycan_graphs = fail,
    has_floating_parts = fail,
    has_floating_substituents = fail,
    .package = "glyrepr"
  )
  for (mono_type in c("concrete", "generic")) {
    args <- list(
      mono_type = mono_type,
      species = "Homo sapiens",
      glycan_type = "N",
      mono_range = list(Hex = c(3L, 10L), HexNAc = c(2L, 10L))
    )
    expect_gt(length(do.call(glydb_composition_index, args)$active_ids), 0L)
    expect_gt(length(do.call(glydb_compositions, args)), 0L)
    for (level in c("intact", "topological")) {
      structure_args <- c(list(structure_level = level), args)
      index <- do.call(
        glydb_structure_index,
        c(structure_args, list(exclude_floating = TRUE))
      )
      expect_gt(length(index$active_ids), 0L)
      expect_gt(length(do.call(glydb_structures, structure_args)), 0L)
    }
  }
})

test_that("index validation rejects invalid resolutions and flags", {
  expect_snapshot(error = TRUE, glydb_composition_index(mono_type = "mixed"))
  expect_snapshot(
    error = TRUE,
    glydb_structure_index(structure_level = "partial")
  )
  expect_snapshot(error = TRUE, glydb_structure_index(exclude_floating = NA))
})

test_that("index printing summarizes the selected view", {
  expect_snapshot(print(glydb_composition_index()))
  expect_snapshot(print(glydb_structure_index(
    mono_range = list(Hex = c(100000L, Inf))
  )))
})
