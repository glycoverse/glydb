#' Get Precomputed Glycan Database Indexes
#'
#' @description
#' These two functions are mainly used by the `glyanno` package.
#' If you're directly using `glydb`,
#' use [glydb_compositions()] or [glydb_structures()] instead.
#'
#' Retrieve bundled composition or structure indexes without parsing database
#' structures, converting their resolution, counting components, or rebuilding
#' candidate maps. All database features are computed during data generation.
#'
#' @inheritParams glydb_compositions
#' @param structure_level Either `"intact"` or `"topological"`.
#' @param exclude_floating Whether to exclude structures with unresolved floating
#'   parts or substituents from `active_ids`. Defaults to `FALSE`.
#'
#' @returns A list with class `glydb_composition_index` or
#'   `glydb_structure_index`, also inheriting from `glydb_index`.
#'   **Filters change only `active_ids`. All other fields describe the full
#'   selected database view**, in original database order:
#'   - `schema_version`: Integer version of the index format, currently 1.
#'   - `data_version`: Content fingerprint of the precomputed view. Record IDs
#'     are valid only for the same `view` and `data_version`.
#'   - `view`: Name identifying the composition/structure resolution.
#'   - `key_collation`: The `LC_COLLATE` used to generate structure keys (`"C"`).
#'   - `glyrepr_version`: Version used when generating the index.
#'   - `mono_type`, `structure_level`: Resolution of the view; the latter is
#'     `NULL` for composition indexes.
#'   - `record_id`: Integer row IDs, starting at 1.
#'   - `active_ids`: IDs retained by the requested filters, in database order.
#'   - `glycans`: Full [glydb_compositions()] or [glydb_structures()] vector,
#'     including its confidence attribute.
#'   - `composition`: A plain [glyrepr::glycan_composition()] vector aligned
#'     with records. Structures sharing a composition remain separate records.
#'   - `confidence`: Numeric confidence per record, aggregated before filtering
#'     using the same maximum-confidence rule as the existing getters.
#'   - `best_rank`: Integer priority per record, with smaller values preferred.
#'     Missing confidence ranks last; ties retain database order. Select the
#'     smallest rank among eligible candidates, not among the full view.
#'   - `composition_keys`, `composition_maps`: Named lists with `exact` and
#'     `generic` entries. Keys are character vectors aligned with records;
#'     maps are named lists from keys to integer record IDs in database order.
#'   - `counts`, `generic_counts`: Integer matrices with one row per record and
#'     named columns for monosaccharides and substituents. `counts` uses the
#'     view's resolution; `generic_counts` uses generic monosaccharides.
#'     Columns cover components observed anywhere in the full view. Within
#'     those columns, absent components have zero counts; missing compositions
#'     have `NA` rows. Components absent from the entire view have no column.
#'   - `components`, `generic_components`: Logical matrices with the same
#'     dimensions as the count matrices, recording component-name presence.
#'     These preserve the getters' exclusion of unspecified components even
#'     when a stored component has a zero count.
#'   - `species`, `glycan_type`: Original semicolon-separated metadata vectors.
#'   - `filter_ids`: Named lists `species` and `glycan_type`, mapping supported
#'     filter values to record IDs. The `"O"` entry includes O-linked subtypes.
#'
#'   Structure indexes additionally contain:
#'   - `structure_keys`, `structure_maps`: Named lists with `exact`, `generic`,
#'     `topological`, and `generic_topological` entries. Converted keys do not
#'     merge records or alter their confidence. Maps use the full view's IDs.
#'     All structure keys are canonicalized under `key_collation`; even `exact`
#'     keys can differ in branch order from the original `glycans` strings.
#'   - `has_floating_parts`, `has_floating_substituents`: Logical flags per
#'     record, with `NA` for missing structures.
#'
#' @details
#' Intersect candidate-map IDs with `active_ids` before retrieving results.
#' Generic composition keys identify candidate groups, not proof of mixed
#' composition compatibility; use concrete counts to check input constraints.
#' Structure keys encode resolution conversions, not arbitrary partial-structure
#' matching. Further matching may be needed for partially specified inputs.
#'
#' Structure key comparisons require the same canonicalization and collation
#' as the index. After converting an input to the desired resolution, generate
#' its key with `glyrepr::canonicalize_glycan_graphs(as.list(input))$iupac`
#' under `LC_COLLATE = "C"`, restoring the previous locale afterwards. This
#' function is available in the `glyrepr` version recorded by the index.
#' Canonicalize only query inputs at runtime, not the database.
#'
#' Treat indexes as read-only values. Modifying a returned list does not update
#' the bundled database. The index contains no mass dictionary or mass values.
#'
#' @examples
#' index <- glydb_composition_index(species = "Homo sapiens", glycan_type = "N")
#' index$glycans[index$active_ids[1:3]]
#'
#' index <- glydb_structure_index(exclude_floating = TRUE)
#' key <- index$composition_keys$generic[index$active_ids[1]]
#' ids <- intersect(index$composition_maps$generic[[key]], index$active_ids)
#' index$glycans[ids]
#' index$glycans[ids[which.min(index$best_rank[ids])]]
#' @export
glydb_composition_index <- function(
  mono_type = "concrete",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL
) {
  checkmate::assert_choice(mono_type, c("generic", "concrete"))
  index <- switch(
    mono_type,
    concrete = concrete_composition_index,
    generic = generic_composition_index
  )
  filter_glydb_index(index, species, glycan_type, mono_range)
}

#' @rdname glydb_composition_index
#' @export
glydb_structure_index <- function(
  structure_level = "intact",
  mono_type = "concrete",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL,
  exclude_floating = FALSE
) {
  checkmate::assert_choice(structure_level, c("intact", "topological"))
  checkmate::assert_choice(mono_type, c("generic", "concrete"))
  checkmate::assert_flag(exclude_floating)
  index <- switch(
    mono_type,
    concrete = switch(
      structure_level,
      intact = intact_concrete_structure_index,
      topological = topological_concrete_structure_index
    ),
    generic = switch(
      structure_level,
      intact = intact_generic_structure_index,
      topological = topological_generic_structure_index
    )
  )
  index <- filter_glydb_index(index, species, glycan_type, mono_range)
  if (exclude_floating) {
    floating <- index$has_floating_parts | index$has_floating_substituents
    floating[is.na(floating)] <- FALSE
    index$active_ids <- index$active_ids[!floating[index$active_ids]]
  }
  index
}

filter_glydb_index <- function(index, species, glycan_type, mono_range) {
  checkmate::assert_choice(species, glydb_species(), null.ok = TRUE)
  checkmate::assert_choice(glycan_type, glycan_type_choices(), null.ok = TRUE)
  validate_mono_range(mono_range, index$mono_type)
  ids <- index$record_id
  if (!is.null(species)) {
    ids <- ids[ids %in% index$filter_ids$species[[species]]]
  }
  if (!is.null(glycan_type)) {
    ids <- ids[ids %in% index$filter_ids$glycan_type[[glycan_type]]]
  }
  if (!is.null(mono_range) && length(ids) > 0L) {
    generic <- glyrepr::get_mono_type(names(mono_range)[[1]]) == "generic"
    counts <- if (generic) index$generic_counts else index$counts
    components <- if (generic) index$generic_components else index$components
    keep <- rep(TRUE, length(ids))
    for (mono in names(mono_range)) {
      n <- if (mono %in% colnames(counts)) {
        counts[ids, mono]
      } else {
        rep(0L, length(ids))
      }
      bounds <- mono_range[[mono]]
      keep <- keep & n >= bounds[[1]] & n <= bounds[[2]]
    }
    other <- setdiff(colnames(components), names(mono_range))
    keep <- keep & rowSums(components[ids, other, drop = FALSE]) == 0L
    ids <- ids[keep]
  }
  index$active_ids <- ids
  index
}

#' @export
#' @noRd
print.glydb_index <- function(x, ...) {
  cat("<", class(x)[[1]], "> ", x$view, "\n", sep = "")
  cat(
    "Records:",
    length(x$active_ids),
    "active /",
    length(x$record_id),
    "total\n"
  )
  cat("Schema: ", x$schema_version, "\n", sep = "")
  invisible(x)
}

utils::globalVariables(c(
  "concrete_composition_index",
  "generic_composition_index",
  "intact_concrete_structure_index",
  "intact_generic_structure_index",
  "topological_concrete_structure_index",
  "topological_generic_structure_index"
))
