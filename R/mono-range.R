#' Validate Mono Range Parameter
#'
#' Validates a mono_range parameter for filtering glycan compositions.
#'
#' @param mono_range A named list where each element is an integer vector of length 2
#'   specifying the minimum and maximum count for a monosaccharide.
#'   Names must be valid monosaccharide names from [glyrepr::available_monosaccharides()].
#'   Use `NULL` for no filtering.
#' @param mono_type The `mono_type` parameter passed to [glydb_compositions()] or [glydb_structures()].
#'
#' @returns Invisible `NULL` on success. Aborts with an error message on invalid input.
#'
#' @examples
#' validate_mono_range(list(Hex = c(3L, 9L)))
#' validate_mono_range(list(Hex = c(0L, Inf), HexNAc = c(2L, 6L)))
#' validate_mono_range(NULL)
#'
#' @noRd
validate_mono_range <- function(mono_range, mono_type) {
  # NULL is valid (no filtering)
  if (is.null(mono_range)) {
    return(invisible(NULL))
  }

  # Check that mono_range is a non-empty list
  checkmate::assert_list(mono_range)
  if (length(mono_range) == 0L) {
    cli::cli_abort(c(
      "{.arg mono_range} must contain at least one named monosaccharide range.",
      "i" = "Provide one or more named entries, e.g. {.code list(Hex = c(3L, 9L))}, or use {.code NULL} for no filtering."
    ))
  }

  # Check for duplicate names
  names_list <- names(mono_range)
  if (is.null(names_list) || any(names_list == "")) {
    cli::cli_abort(c(
      "All elements in {.arg mono_range} must be named.",
      "i" = "Use named list entries like {.code list(Hex = c(3L, 9L))}."
    ))
  }

  dup_names <- names_list[duplicated(names_list)]
  if (length(dup_names) > 0) {
    cli::cli_abort(c(
      "Monosaccharide names in {.arg mono_range} must not be duplicated.",
      "x" = "Duplicated name{?s}: {.val {unique(dup_names)}}."
    ))
  }

  # Check that all names are valid monosaccharides
  valid_monos <- glyrepr::available_monosaccharides()
  invalid_monos <- setdiff(names_list, valid_monos)
  if (length(invalid_monos) > 0) {
    cli::cli_abort(c(
      "All monosaccharide names in {.arg mono_range} must be known.",
      "x" = "Unknown name{?s}: {.val {invalid_monos}}."
    ))
  }

  # Check that all names are of the same mono_type
  range_mono_types <- glyrepr::get_mono_type(names_list)
  if (length(unique(range_mono_types)) != 1) {
    cli::cli_abort(c(
      "All monosaccharide names in {.arg mono_range} must be of the same type (generic or concrete).",
      "x" = "Found both types."
    ))
  }

  # Special case: When `mono_type` is generic, mono type of the range names must be generic.
  range_mono_type <- glyrepr::get_mono_type(names(mono_range)[[1]])
  if (mono_type == "generic" && range_mono_type == "concrete") {
    cli::cli_abort(c(
      "Monosaccharide names in {.arg mono_range} must be {.val generic} (e.g. 'Hex') when {.arg mono_type} is {.val generic}."
    ))
  }

  # Validate each range element
  for (mono_name in names_list) {
    range_val <- mono_range[[mono_name]]

    # Check that element is a numeric vector of length 2
    if (!checkmate::test_numeric(range_val, len = 2)) {
      cli::cli_abort(c(
        "Each element in {.arg mono_range} must be a numeric vector of length 2.",
        "x" = "{.val {mono_name}} is not a valid numeric vector of length 2."
      ))
    }

    min_val <- range_val[1]
    max_val <- range_val[2]

    # Check that min is an integer (not double, not Inf)
    # Special case: c(0L, Inf) creates a double vector due to R's type coercion
    # We allow this when max is Inf and min is a whole number
    is_special_case <- is.infinite(max_val) &&
      is.double(min_val) &&
      min_val == as.integer(min_val)

    if (is.infinite(min_val)) {
      cli::cli_abort(c(
        "Minimum value in {.arg mono_range} must be an integer.",
        "x" = "{.val {mono_name}} has non-integer minimum value {.val {min_val}}.",
        "i" = "Use integer literals like {.code 3L} instead of {.code 3}."
      ))
    }

    if (!is.integer(min_val) && !is_special_case) {
      cli::cli_abort(c(
        "Minimum value in {.arg mono_range} must be an integer.",
        "x" = "{.val {mono_name}} has non-integer minimum value {.val {min_val}}.",
        "i" = "Use integer literals like {.code 3L} instead of {.code 3}."
      ))
    }

    # Check that max is either an integer or Inf
    is_valid_max <- is.infinite(max_val) || is.integer(max_val)
    if (!is_valid_max) {
      cli::cli_abort(c(
        "Maximum value in {.arg mono_range} must be an integer or {.val {Inf}}.",
        "x" = "{.val {mono_name}} has invalid maximum value {.val {max_val}}.",
        "i" = "Use integer literals like {.code 3L} instead of {.code 3}."
      ))
    }

    # Check min constraints: must be >= 0
    if (min_val < 0L) {
      cli::cli_abort(c(
        "Minimum value in {.arg mono_range} must be non-negative.",
        "x" = "{.val {mono_name}} has minimum value {.val {min_val}}."
      ))
    }

    # Check max constraints: must be >= 0 (Inf is allowed)
    if (max_val < 0L) {
      cli::cli_abort(c(
        "Maximum value in {.arg mono_range} must be non-negative.",
        "x" = "{.val {mono_name}} has maximum value {.val {max_val}}."
      ))
    }

    # Check that max >= min
    if (max_val < min_val) {
      cli::cli_abort(c(
        "Maximum value must be greater than or equal to minimum value in {.arg mono_range}.",
        "x" = "{.val {mono_name}} has max ({.val {max_val}}) < min ({.val {min_val}})."
      ))
    }
  }

  invisible(NULL)
}

#' Filter Glycans by Monosaccharide Range
#'
#' @param x A glycan composition or structure vector
#' @param mono_range A validated named list or NULL
#' @param mono_type Monosaccharide type of `x`
#' @returns Filtered vector of same type as input
#' @noRd
filter_by_mono_range <- function(x, mono_range, mono_type) {
  if (is.null(mono_range)) {
    return(x)
  }

  if (glyrepr::is_glycan_structure(x)) {
    comps <- glyrepr::as_glycan_composition(x)
  } else {
    # must be glycan compositions
    comps <- x
  }

  range_mono_type <- glyrepr::get_mono_type(names(mono_range)[[1]])
  if (range_mono_type == "generic" && mono_type == "concrete") {
    comps <- glyrepr::convert_to_generic(comps)
  }

  # 1. Check if within `mono_range`
  check_one_mono_range <- function(mono, range, comps) {
    # Checks one range in `mono_range`.
    # Returns a logical vector with the same length of `comps`, whether to keep.
    min_ <- range[[1]]
    max_ <- range[[2]]
    mono_counts <- glyrepr::count_mono(comps, mono)
    (mono_counts >= min_) & (mono_counts <= max_)
  }

  check_results <- purrr::map2(
    names(mono_range),
    mono_range,
    ~ check_one_mono_range(.x, .y, comps)
  )
  check_result_1 <- purrr::reduce(check_results, `&`)

  # 2. Check if other monos do not exist
  mono_names <- purrr::map(vctrs::field(comps, "data"), names)
  check_result_2 <- purrr::map_lgl(
    mono_names,
    ~ length(setdiff(.x, names(mono_range))) == 0
  )

  x[check_result_1 & check_result_2]
}
