#' Convert GlyTouCan Accessions to Glycan Structures
#'
#' Look up GlyTouCan accessions from [glydb_data], then fetch missing
#' accessions from the GlyGen API and parse the returned IUPAC strings as
#' [glyrepr::glycan_structure()] values.
#'
#' @param glytoucan_ac A character vector of GlyTouCan accessions.
#'
#' @returns A [glyrepr::glycan_structure()] vector. Accessions that cannot be
#'   fetched or parsed are returned as `NA` values in their original positions,
#'   and a warning is emitted.
#' @examplesIf interactive()
#' glytoucan_to_struc("G17689DH")
#' @export
glytoucan_to_struc <- function(glytoucan_ac) {
  checkmate::assert_character(glytoucan_ac, any.missing = FALSE)

  if (length(glytoucan_ac) == 0) {
    return(glyrepr::glycan_structure())
  }

  results <- local_glytoucan_struc_results(glytoucan_ac)
  missing <- purrr::map_lgl(results, is.null)

  if (any(missing)) {
    details <- glygen_glycan_details(glytoucan_ac[missing])
    results[missing] <- purrr::map(details, glytoucan_detail_to_struc_safely)
  }

  failed <- purrr::map_lgl(results, "failed")

  if (any(failed)) {
    failed_accessions <- glytoucan_ac[failed]
    cli::cli_warn(c(
      "Failed to fetch or parse {sum(failed)} GlyTouCan accession{?s}.",
      "x" = "Failed accession{?s}: {paste(failed_accessions, collapse = ', ')}"
    ))
  }

  strucs <- purrr::map(results, "struc")
  vctrs::vec_c(!!!strucs)
}

#' Look up GlyTouCan accessions from glydb data
#'
#' Match GlyTouCan accessions to bundled `glydb_data` structures while
#' preserving input order and unresolved positions.
#'
#' @param glytoucan_ac A character vector of GlyTouCan accessions.
#'
#' @returns A list of conversion result records or `NULL` for accessions that
#'   are not available in `glydb_data`.
#' @noRd
local_glytoucan_struc_results <- function(glytoucan_ac) {
  data_position <- match(glytoucan_ac, glydb_data$glytoucan_ac)

  purrr::map(data_position, function(position) {
    if (is.na(position)) {
      return(NULL)
    }

    list(struc = glydb_data$glycan_structure[position], failed = FALSE)
  })
}

#' Convert one GlyGen detail record to a glycan structure
#'
#' Parse the `iupac` field from one GlyGen detail record.
#'
#' @param detail A GlyGen detail record or request error.
#'
#' @returns A scalar [glyrepr::glycan_structure()] vector.
#' @noRd
glytoucan_detail_to_struc <- function(detail) {
  if (inherits(detail, "error")) {
    stop(detail)
  }

  iupac <- detail$iupac

  checkmate::assert_string(iupac, min.chars = 1)
  parse_glygen_iupac(iupac)
}

#' Convert one GlyTouCan accession without raising errors
#'
#' Wrap `glytoucan_detail_to_struc()` so vector conversion can retain failed
#' positions as missing glycan structures.
#'
#' @param detail A GlyGen detail record or request error.
#'
#' @returns A list with `struc` and `failed` fields.
#' @noRd
glytoucan_detail_to_struc_safely <- function(detail) {
  tryCatch(
    list(struc = glytoucan_detail_to_struc(detail), failed = FALSE),
    error = function(error) {
      list(struc = glyrepr::glycan_structure(NA), failed = TRUE)
    }
  )
}

#' Fetch GlyGen glycan detail records
#'
#' Submit POST requests to the GlyGen glycan detail endpoint in parallel.
#'
#' @param glytoucan_ac A character vector of GlyTouCan accessions.
#'
#' @returns A list of parsed GlyGen JSON responses or request errors.
#' @noRd
glygen_glycan_details <- function(glytoucan_ac) {
  requests <- purrr::map(glytoucan_ac, glygen_glycan_detail_request)
  responses <- httr2::req_perform_parallel(
    requests,
    on_error = "return",
    progress = FALSE
  )

  purrr::map(responses, glygen_glycan_detail_body)
}

#' Build a GlyGen glycan detail request
#'
#' Create one POST request for the GlyGen glycan detail endpoint.
#'
#' @param glytoucan_ac A single GlyTouCan accession.
#'
#' @returns An [httr2::request()] object.
#' @noRd
glygen_glycan_detail_request <- function(glytoucan_ac) {
  url <- paste0("https://api.glygen.org/glycan/detail/", glytoucan_ac, "/")

  httr2::request(url) |>
    httr2::req_method("POST") |>
    httr2::req_throttle(capacity = 30) |>
    httr2::req_retry(max_tries = 3)
}

#' Parse a GlyGen glycan detail response
#'
#' Parse one response body, preserving request errors for downstream handling.
#'
#' @param response An [httr2::response()] object or request error.
#'
#' @returns A parsed GlyGen JSON response or request error.
#' @noRd
glygen_glycan_detail_body <- function(response) {
  if (inherits(response, "error")) {
    return(response)
  }

  if (httr2::resp_is_error(response)) {
    return(errorCondition(
      message = paste0(
        "GlyGen returned HTTP ",
        httr2::resp_status(response),
        "."
      )
    ))
  }

  tryCatch(
    httr2::resp_body_json(response, simplifyVector = TRUE),
    error = function(error) error
  )
}

#' Parse a GlyGen IUPAC string
#'
#' Parse an IUPAC extended string into a glycan structure.
#'
#' @param iupac A scalar IUPAC extended string from GlyGen.
#'
#' @returns A scalar [glyrepr::glycan_structure()] vector.
#' @noRd
parse_glygen_iupac <- function(iupac) {
  struc <- glyparse::parse_iupac_extended(iupac, on_failure = "error")

  if (!inherits(struc, "glyrepr_structure") || length(struc) != 1) {
    cli::cli_abort(
      "Parsed GlyGen IUPAC data must produce one glycan structure."
    )
  }

  struc
}
