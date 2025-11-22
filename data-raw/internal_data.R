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

concrete_comps <- glydb_data |>
  summarise(
    species = combine_terms(species),
    glycan_type = combine_terms(glycan_type),
    .by = glycan_composition
  )

generic_comps <- glydb_data |>
  mutate(glycan_composition = convert_to_generic(glycan_composition)) |>
  summarise(
    species = combine_terms(species),
    glycan_type = combine_terms(glycan_type),
    .by = glycan_composition
  )

intact_strucs <- glydb_data |>
  select(glycan_structure, species, glycan_type)

topological_strucs <- glydb_data |>
  mutate(glycan_structure = remove_linkages(glycan_structure)) |>
  summarise(
    species = combine_terms(species),
    glycan_type = combine_terms(glycan_type),
    .by = glycan_structure
  )

basic_strucs <- glydb_data |>
  mutate(
    glycan_structure = convert_to_generic(glycan_structure),
    glycan_structure = remove_linkages(glycan_structure)
  ) |>
  summarise(
    species = combine_terms(species),
    glycan_type = combine_terms(glycan_type),
    .by = glycan_structure
  )

usethis::use_data(
  concrete_comps,
  generic_comps,
  intact_strucs,
  topological_strucs,
  basic_strucs,
  internal = TRUE,
  overwrite = TRUE
)
