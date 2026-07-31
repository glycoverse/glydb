.confidence_lookup_attr <- ".glydb_confidence_lookup"

new_confidence_lookup <- function(keys, confidence) {
  confidence <- as.double(confidence)

  if (length(keys) != length(confidence)) {
    cli::cli_abort(
      "Internal confidence data must match the glycan vector length."
    )
  }

  unique_keys <- unique(keys)
  if (length(unique_keys) == 0) {
    return(list(key = character(), confidence = double()))
  }

  groups <- match(keys, unique_keys)
  grouped_confidence <- split(confidence, groups)
  maximum_confidence <- vapply(
    grouped_confidence,
    function(values) {
      if (all(is.na(values))) {
        return(NA_real_)
      }
      max(values, na.rm = TRUE)
    },
    double(1)
  )

  list(
    key = unique_keys,
    confidence = unname(maximum_confidence)
  )
}

merge_confidence_lookups <- function(...) {
  lookups <- list(...)
  keys <- unlist(lapply(lookups, `[[`, "key"), use.names = FALSE)
  confidence <- unlist(
    lapply(lookups, `[[`, "confidence"),
    use.names = FALSE
  )
  new_confidence_lookup(keys, confidence)
}

subset_confidence_lookup <- function(lookup, keys) {
  if (length(keys) == 0) {
    return(new_confidence_lookup(character(), double()))
  }

  keep <- lookup$key %in% keys
  list(
    key = lookup$key[keep],
    confidence = lookup$confidence[keep]
  )
}

confidence_from_lookup <- function(lookup, keys) {
  locations <- match(keys, lookup$key)
  confidence <- lookup$confidence[locations]
  confidence[is.na(locations)] <- NA_real_
  unname(confidence)
}

strip_glydb_class <- function(x) {
  class(x) <- setdiff(
    class(x),
    c("glydb_structure", "glydb_composition")
  )
  attr(x, "confidence") <- NULL
  attr(x, .confidence_lookup_attr) <- NULL
  x
}

glydb_confidence_keys <- function(x) {
  unname(as.character(strip_glydb_class(x)))
}

confidence_lookup <- function(x) {
  confidence <- attr(x, "confidence", exact = TRUE)
  if (length(x) > 0 && !is.null(confidence)) {
    return(
      new_confidence_lookup(glydb_confidence_keys(x), confidence)
    )
  }

  lookup <- attr(x, .confidence_lookup_attr, exact = TRUE)
  if (!is.null(lookup)) {
    return(lookup)
  }

  if (is.null(confidence)) {
    confidence <- rep(NA_real_, length(x))
  }
  new_confidence_lookup(glydb_confidence_keys(x), confidence)
}

new_glydb_vector <- function(x, confidence, lookup, subclass) {
  x <- strip_glydb_class(x)
  keys <- glydb_confidence_keys(x)

  if (missing(lookup) || is.null(lookup)) {
    lookup <- new_confidence_lookup(keys, confidence)
  } else {
    lookup <- merge_confidence_lookups(
      lookup,
      new_confidence_lookup(keys, confidence)
    )
  }

  attr(x, "confidence") <- confidence_from_lookup(lookup, keys)
  attr(x, .confidence_lookup_attr) <- lookup
  class(x) <- c(subclass, class(x))
  x
}

new_glydb_structure <- function(x, confidence, lookup = NULL) {
  if (!inherits(x, "glyrepr_structure")) {
    cli::cli_abort(
      "Internal structure data must be a glyrepr structure vector."
    )
  }
  new_glydb_vector(x, confidence, lookup, "glydb_structure")
}

new_glydb_composition <- function(x, confidence, lookup = NULL) {
  if (!inherits(x, "glyrepr_composition")) {
    cli::cli_abort(
      "Internal composition data must be a glyrepr composition vector."
    )
  }
  new_glydb_vector(x, confidence, lookup, "glydb_composition")
}

restore_glydb_vector <- function(x, to, constructor) {
  out <- vctrs::vec_restore(x, strip_glydb_class(to))
  keys <- glydb_confidence_keys(out)
  lookup <- subset_confidence_lookup(confidence_lookup(to), keys)
  constructor(out, confidence_from_lookup(lookup, keys), lookup)
}

ptype_glydb_vector <- function(x, constructor, ...) {
  out <- vctrs::vec_ptype(strip_glydb_class(x), ...)
  constructor(out, double(), confidence_lookup(x))
}

ptype2_glydb_vector <- function(x, y, constructor, ...) {
  out <- vctrs::vec_ptype2(
    strip_glydb_class(x),
    strip_glydb_class(y),
    ...
  )
  lookup <- merge_confidence_lookups(
    confidence_lookup(x),
    confidence_lookup(y)
  )
  constructor(out, double(), lookup)
}

cast_to_glydb_vector <- function(x, to, constructor, ...) {
  out <- vctrs::vec_cast(
    strip_glydb_class(x),
    strip_glydb_class(to),
    ...
  )
  lookup <- merge_confidence_lookups(
    confidence_lookup(to),
    confidence_lookup(x)
  )
  keys <- glydb_confidence_keys(out)
  lookup <- subset_confidence_lookup(lookup, keys)
  constructor(out, confidence_from_lookup(lookup, keys), lookup)
}

assign_glydb_vector <- function(x, i, value, constructor) {
  x_data <- strip_glydb_class(x)
  value_data <- strip_glydb_class(value)
  ptype <- vctrs::vec_ptype2(x_data, value_data)
  out_proxy <- vctrs::vec_assign(
    vctrs::vec_proxy(x_data),
    i,
    vctrs::vec_proxy(value_data)
  )
  out <- vctrs::vec_restore(out_proxy, ptype)
  lookup <- merge_confidence_lookups(
    confidence_lookup(x),
    confidence_lookup(value)
  )
  keys <- glydb_confidence_keys(out)
  lookup <- subset_confidence_lookup(lookup, keys)
  constructor(out, confidence_from_lookup(lookup, keys), lookup)
}

#' @export
#' @noRd
`[.glydb_structure` <- function(x, i, ...) {
  if (missing(i)) {
    return(x)
  }
  vctrs::vec_slice(x, i)
}

#' @export
#' @noRd
`[<-.glydb_structure` <- function(x, i, value) {
  if (missing(i)) {
    i <- seq_along(x)
  }
  assign_glydb_vector(x, i, value, new_glydb_structure)
}

#' @export
#' @noRd
`[<-.glydb_composition` <- function(x, i, value) {
  if (missing(i)) {
    i <- seq_along(x)
  }
  assign_glydb_vector(x, i, value, new_glydb_composition)
}

#' @export
#' @noRd
`[.glydb_composition` <- function(x, i, ...) {
  if (missing(i)) {
    return(x)
  }
  vctrs::vec_slice(x, i)
}

#' @exportS3Method vctrs::vec_restore
#' @noRd
vec_restore.glydb_structure <- function(x, to, ...) {
  restore_glydb_vector(x, to, new_glydb_structure)
}

#' @exportS3Method vctrs::vec_restore
#' @noRd
vec_restore.glydb_composition <- function(x, to, ...) {
  restore_glydb_vector(x, to, new_glydb_composition)
}

#' @exportS3Method vctrs::vec_ptype
#' @noRd
vec_ptype.glydb_structure <- function(x, ...) {
  ptype_glydb_vector(x, new_glydb_structure, ...)
}

#' @exportS3Method vctrs::vec_ptype
#' @noRd
vec_ptype.glydb_composition <- function(x, ...) {
  ptype_glydb_vector(x, new_glydb_composition, ...)
}

#' @exportS3Method vctrs::vec_ptype2
#' @noRd
vec_ptype2.glydb_structure.glydb_structure <- function(x, y, ...) {
  ptype2_glydb_vector(x, y, new_glydb_structure, ...)
}

#' @exportS3Method vctrs::vec_ptype2
#' @noRd
vec_ptype2.glydb_composition.glydb_composition <- function(x, y, ...) {
  ptype2_glydb_vector(x, y, new_glydb_composition, ...)
}

#' @exportS3Method vctrs::vec_ptype2
#' @noRd
vec_ptype2.glydb_structure.glyrepr_structure <- function(x, y, ...) {
  ptype2_glydb_vector(x, y, new_glydb_structure, ...)
}

#' @exportS3Method vctrs::vec_ptype2
#' @noRd
vec_ptype2.glyrepr_structure.glydb_structure <- function(x, y, ...) {
  ptype2_glydb_vector(x, y, new_glydb_structure, ...)
}

#' @exportS3Method vctrs::vec_ptype2
#' @noRd
vec_ptype2.glydb_composition.glyrepr_composition <- function(x, y, ...) {
  ptype2_glydb_vector(x, y, new_glydb_composition, ...)
}

#' @exportS3Method vctrs::vec_ptype2
#' @noRd
vec_ptype2.glyrepr_composition.glydb_composition <- function(x, y, ...) {
  ptype2_glydb_vector(x, y, new_glydb_composition, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.glydb_structure.glydb_structure <- function(x, to, ...) {
  cast_to_glydb_vector(x, to, new_glydb_structure, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.glydb_composition.glydb_composition <- function(x, to, ...) {
  cast_to_glydb_vector(x, to, new_glydb_composition, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.glydb_structure.glyrepr_structure <- function(x, to, ...) {
  cast_to_glydb_vector(x, to, new_glydb_structure, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.glydb_composition.glyrepr_composition <- function(x, to, ...) {
  cast_to_glydb_vector(x, to, new_glydb_composition, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.glyrepr_structure.glydb_structure <- function(x, to, ...) {
  vctrs::vec_cast(strip_glydb_class(x), to, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.glyrepr_composition.glydb_composition <- function(x, to, ...) {
  vctrs::vec_cast(strip_glydb_class(x), to, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.glyrepr_composition.glydb_structure <- function(x, to, ...) {
  vctrs::vec_cast(strip_glydb_class(x), to, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.character.glydb_structure <- function(x, to, ...) {
  vctrs::vec_cast(strip_glydb_class(x), to, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.character.glydb_composition <- function(x, to, ...) {
  vctrs::vec_cast(strip_glydb_class(x), to, ...)
}

#' @exportS3Method vctrs::vec_cast
#' @noRd
vec_cast.logical.glydb_composition <- function(x, to, ...) {
  vctrs::vec_cast(strip_glydb_class(x), to, ...)
}
