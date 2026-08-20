#' Convert Glycan Structures to GlyTouCan Accessions
#'
#' Match glycan structures to accessions in the bundled [glydb_data].
#'
#' @param strucs A [glyrepr::glycan_structure()] vector or a character vector
#'   of IUPAC-condensed glycan structures.
#'
#' @returns A character vector of GlyTouCan accessions. Structures without a
#'   bundled match are returned as `NA` values in their original positions, and
#'   a warning is emitted.
#' @details Missing anomeric positions are filled with
#'   [glyrepr::fill_anomer_pos()] in both the input and bundled structures before
#'   matching. When multiple bundled rows normalize to the same structure, the
#'   accession from the first row is returned.
#' @examples
#' struc_to_glytoucan(glydb_data$glycan_structure[1])
#' @export
struc_to_glytoucan <- function(strucs) {
  strucs <- .ensure_glycan_structure(strucs)

  if (length(strucs) == 0) {
    return(character())
  }

  strucs <- glyrepr::fill_anomer_pos(strucs)
  lookup_position <- match(as.character(strucs), names(struc_glytoucan_lookup))
  failed <- !is.na(strucs) & is.na(lookup_position)

  if (any(failed)) {
    cli::cli_warn(c(
      "No bundled GlyTouCan accession for {sum(failed)} glycan structure{?s}.",
      "x" = "Unmatched input positions: {paste(which(failed), collapse = ', ')}"
    ))
  }

  unname(struc_glytoucan_lookup[lookup_position])
}

#' Ensure input is a glycan structure vector
#'
#' @param strucs Input structures.
#' @returns A [glyrepr::glycan_structure()] vector.
#' @noRd
.ensure_glycan_structure <- function(strucs) {
  if (is.character(strucs)) {
    return(glyrepr::as_glycan_structure(strucs))
  }

  if (glyrepr::is_glycan_structure(strucs)) {
    return(strucs)
  }

  cli::cli_abort(c(
    "{.arg strucs} must be a character vector or a {.fn glyrepr::glycan_structure} vector.",
    "x" = "Got {.cls {class(strucs)}}."
  ))
}
