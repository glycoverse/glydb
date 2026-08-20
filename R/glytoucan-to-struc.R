#' Convert GlyTouCan Accessions to Glycan Structures
#'
#' Look up GlyTouCan accessions in the bundled [glydb_data].
#'
#' @param glytoucan_ac A character vector of GlyTouCan accessions.
#'
#' @returns A [glyrepr::glycan_structure()] vector. Accessions without a bundled
#'   match are returned as `NA` values in their original positions, and a
#'   warning is emitted.
#' @examples
#' glytoucan_to_struc("G17689DH")
#' @export
glytoucan_to_struc <- function(glytoucan_ac) {
  checkmate::assert_character(glytoucan_ac, any.missing = FALSE)

  if (length(glytoucan_ac) == 0) {
    return(glyrepr::glycan_structure())
  }

  data_position <- match(glytoucan_ac, glydb_data$glytoucan_ac)
  failed <- is.na(data_position)

  if (any(failed)) {
    failed_accessions <- glytoucan_ac[failed]
    cli::cli_warn(c(
      "No bundled glycan structure for {sum(failed)} GlyTouCan accession{?s}.",
      "x" = "Unmatched: {paste(failed_accessions, collapse = ', ')}"
    ))
  }

  glydb_data$glycan_structure[data_position]
}
