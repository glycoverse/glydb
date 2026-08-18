devtools::load_all()
library(tidyverse)
library(glyrepr)

#' Combine terms separated by semicolons
#'
#' Input: c("Homo sapiens;Mus musculus", "Mus musculus;Rattus norvegicus")
#' Output: "Homo sapiens;Mus musculus;Rattus norvegicus"
#'
#' @param x A character vector of terms separated by semicolons.
#' @returns A character vector of terms.
#' @noRd
combine_terms <- function(x) {
  x <- as.character(x)
  x <- x[!is.na(x)]
  if (length(x) == 0) {
    return(NA_character_)
  }
  res <- unique(unlist(strsplit(x, ";")))
  res <- res[!is.na(res)]
  paste(res, collapse = ";")
}

#' Summarise metadata for unique glycans
#'
#' Uses glydb vector semantics to retain the maximum confidence when multiple
#' records contain the same glycan.
#'
#' @param glycan A glydb-compatible glycan vector.
#' @param species A character vector of species labels.
#' @param glycan_type A character vector of glycan type labels.
#' @param confidence A numeric vector of confidence values.
#' @returns A tibble with unique glycans and their aggregated metadata.
#' @noRd
summarise_glycans <- function(glycan, species, glycan_type, confidence) {
  glycan <- if (inherits(glycan, "glyrepr_structure")) {
    new_glydb_structure(glycan, confidence)
  } else {
    new_glydb_composition(glycan, confidence)
  }

  result <- tibble(glycan, species, glycan_type) |>
    summarise(
      species = combine_terms(species),
      glycan_type = combine_terms(glycan_type),
      .by = glycan
    )
  confidence <- attr(result$glycan, "confidence")
  result$glycan <- strip_glydb_class(result$glycan)
  result$confidence <- confidence
  result
}

concrete_comps <- summarise_glycans(
  glydb_data$glycan_composition,
  glydb_data$species,
  glydb_data$glycan_type,
  glydb_data$confidence
) |>
  rename(glycan_composition = glycan)

generic_comps <- summarise_glycans(
  convert_to_generic(glydb_data$glycan_composition),
  glydb_data$species,
  glydb_data$glycan_type,
  glydb_data$confidence
) |>
  rename(glycan_composition = glycan)

structure_levels <- get_structure_level(glydb_data$glycan_structure)
intact <- structure_levels == "intact"

intact_concrete_strucs <- summarise_glycans(
  glydb_data$glycan_structure[intact],
  glydb_data$species[intact],
  glydb_data$glycan_type[intact],
  glydb_data$confidence[intact]
) |>
  rename(glycan_structure = glycan)

topological_concrete_strucs <- summarise_glycans(
  remove_linkages(glydb_data$glycan_structure),
  glydb_data$species,
  glydb_data$glycan_type,
  glydb_data$confidence
) |>
  rename(glycan_structure = glycan)

generic_structures <- convert_to_generic(glydb_data$glycan_structure)

intact_generic_strucs <- summarise_glycans(
  generic_structures[intact],
  glydb_data$species[intact],
  glydb_data$glycan_type[intact],
  glydb_data$confidence[intact]
) |>
  rename(glycan_structure = glycan)

topological_generic_strucs <- summarise_glycans(
  remove_linkages(generic_structures),
  glydb_data$species,
  glydb_data$glycan_type,
  glydb_data$confidence
) |>
  rename(glycan_structure = glycan)

usethis::use_data(
  concrete_comps,
  generic_comps,
  intact_concrete_strucs,
  topological_concrete_strucs,
  intact_generic_strucs,
  topological_generic_strucs,
  internal = TRUE,
  overwrite = TRUE
)
