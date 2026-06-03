#' Convert GlyTouCan Accessions to Glycan Structures
#'
#' Fetch GlyTouCan accessions from the GlyGen API and parse the returned IUPAC
#' strings as [glyrepr::glycan_structure()] values.
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

  results <- purrr::map(glytoucan_ac, glytoucan_to_struc_safely)
  failed <- purrr::map_lgl(results, "failed")

  if (any(failed)) {
    failed_accessions <- glytoucan_ac[failed]
    cli::cli_warn(c(
      "Failed to parse {sum(failed)} GlyTouCan accession{?s}.",
      "x" = "Failed accession{?s}: {paste(failed_accessions, collapse = ', ')}"
    ))
  }

  strucs <- purrr::map(results, "struc")
  vctrs::vec_c(!!!strucs)
}

#' Convert one GlyTouCan accession to a glycan structure
#'
#' Fetch one GlyTouCan detail record from GlyGen and parse its `iupac` field.
#'
#' @param glytoucan_ac A single GlyTouCan accession.
#'
#' @returns A scalar [glyrepr::glycan_structure()] vector.
#' @noRd
glytoucan_to_struc_one <- function(glytoucan_ac) {
  detail <- glygen_glycan_detail(glytoucan_ac)
  iupac <- detail$iupac

  checkmate::assert_string(iupac, min.chars = 1)
  parse_glygen_iupac(iupac)
}

#' Convert one GlyTouCan accession without raising errors
#'
#' Wrap `glytoucan_to_struc_one()` so vector conversion can retain failed
#' positions as missing glycan structures.
#'
#' @param glytoucan_ac A single GlyTouCan accession.
#'
#' @returns A list with `struc` and `failed` fields.
#' @noRd
glytoucan_to_struc_safely <- function(glytoucan_ac) {
  tryCatch(
    list(struc = glytoucan_to_struc_one(glytoucan_ac), failed = FALSE),
    error = function(error) {
      list(struc = glyrepr::glycan_structure(NA), failed = TRUE)
    }
  )
}

#' Fetch a GlyGen glycan detail record
#'
#' Submit a POST request to the GlyGen glycan detail endpoint.
#'
#' @param glytoucan_ac A single GlyTouCan accession.
#'
#' @returns A list parsed from the GlyGen JSON response.
#' @noRd
glygen_glycan_detail <- function(glytoucan_ac) {
  url <- paste0("https://api.glygen.org/glycan/detail/", glytoucan_ac, "/")

  httr2::request(url) |>
    httr2::req_method("POST") |>
    httr2::req_perform() |>
    httr2::resp_body_json(simplifyVector = TRUE)
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
