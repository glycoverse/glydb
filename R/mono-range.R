#' Validate Mono Range Parameter
#'
#' Validates a mono_range parameter for filtering glycan compositions.
#'
#' @param mono_range A named list where each element is an integer vector of length 2
#'   specifying the minimum and maximum count for a monosaccharide.
#'   Names must be valid monosaccharide names from [glyrepr::available_monosaccharides()].
#'   Use `NULL` for no filtering.
#'
#' @returns Invisible `NULL` on success. Aborts with an error message on invalid input.
#'
#' @examples
#' validate_mono_range(list(Hex = c(3L, 9L)))
#' validate_mono_range(list(Hex = c(0L, Inf), HexNAc = c(2L, 6L)))
#' validate_mono_range(NULL)
#'
#' @noRd
validate_mono_range <- function(mono_range) {
  # NULL is valid (no filtering)
  if (is.null(mono_range)) {
    return(invisible(NULL))
  }

  # Check that mono_range is a list
  checkmate::assert_list(mono_range)

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
    is_special_case <- is.infinite(max_val) && is.double(min_val) && min_val == as.integer(min_val)

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
#' @returns Filtered vector of same type as input
#' @noRd
filter_by_mono_range <- function(x, mono_range) {
  if (is.null(mono_range)) {
    return(x)
  }

  # Start with all TRUE
  keep <- rep(TRUE, length(x))

  # For each mono in mono_range, check if count is within range
  for (mono in names(mono_range)) {
    range <- mono_range[[mono]]
    min_val <- range[1]
    max_val <- range[2]

    counts <- glyrepr::count_mono(x, mono)

    # NA counts should be treated as 0 (no such mono)
    counts[is.na(counts)] <- 0L

    keep <- keep & counts >= min_val & counts <= max_val
  }

  # For generic monos NOT in mono_range, ensure count is 0
  # Only check generic monos since concrete monos are covered by their generic counterparts
  all_generic_monos <- glyrepr::available_monosaccharides("generic")
  # Get generic equivalents of specified monos
  specified_generics <- character()
  for (mono in names(mono_range)) {
    mono_type <- glyrepr::get_mono_type(mono)
    if (mono_type == "generic") {
      specified_generics <- c(specified_generics, mono)
    } else if (mono_type == "concrete") {
      # Convert concrete to generic using glyrepr's internal mapping
      # We can use convert_to_generic on a composition with just this mono
      temp_comp <- glyrepr::glycan_composition(stats::setNames(1L, mono))
      generic_comp <- glyrepr::convert_to_generic(temp_comp)
      generic_name <- names(vctrs::vec_data(generic_comp)[[1]])
      specified_generics <- c(specified_generics, generic_name)
    }
  }
  excluded_generics <- setdiff(all_generic_monos, specified_generics)

  for (mono in excluded_generics) {
    counts <- glyrepr::count_mono(x, mono)
    counts[is.na(counts)] <- 0L
    keep <- keep & counts == 0L
  }

  x[keep]
}
