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

fully_determined <- read_csv("data-raw/glycan_fully_determined_v2_11_1.csv")
intact_strucs <- glydb_data |>
  semi_join(fully_determined, by = join_by(glytoucan_ac)) |>
  select(glycan_structure, species, glycan_type, confidence)

topological_strucs <- summarise_glycans(
  reduce_structure_level(glydb_data$glycan_structure, "topological"),
  glydb_data$species,
  glydb_data$glycan_type,
  glydb_data$confidence
) |>
  rename(glycan_structure = glycan)

basic_strucs <- summarise_glycans(
  reduce_structure_level(glydb_data$glycan_structure, "basic"),
  glydb_data$species,
  glydb_data$glycan_type,
  glydb_data$confidence
) |>
  rename(glycan_structure = glycan)

usethis::use_data(
  concrete_comps,
  generic_comps,
  intact_strucs,
  topological_strucs,
  basic_strucs,
  internal = TRUE,
  overwrite = TRUE
)
