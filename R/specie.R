#' Get Supported Species From Glydb Data
#'
#' Get a character vector of supported species from [glydb_data].
#'
#' @returns A character vector of supported species.
#' @examples
#' glydb_species()
#' @export
glydb_species <- function() {
  res <- unique(unlist(strsplit(glydb_data$species, ";")))
  res <- res[!is.na(res)]
  res
}