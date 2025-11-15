devtools::load_all()
library(tidyverse)
library(glyrepr)

#' Combine species names separated by semicolons
#'
#' Input: c("Homo sapiens;Mus musculus", "Mus musculus;Rattus norvegicus")
#' Output: "Homo sapiens;Mus musculus;Rattus norvegicus"
#'
#' @param species A character vector of species names separated by semicolons.
#' @returns A character vector of species names.
#' @noRd
combine_species <- function(species) {
  species <- species[!is.na(species)]
  if (length(species) == 0) {
    return(NA_character_)
  }
  res <- unique(unlist(strsplit(species, ";")))
  res <- res[!is.na(res)]
  paste(res, collapse = ";")
}

concrete_comps <- glydb_data |>
  summarise(species = combine_species(species), .by = glycan_composition)

generic_comps <- glydb_data |>
  mutate(glycan_composition = convert_to_generic(glycan_composition)) |>
  summarise(species = combine_species(species), .by = glycan_composition)

intact_strucs <- glydb_data |>
  select(glycan_structure, species)

topological_strucs <- glydb_data |>
  mutate(glycan_structure = remove_linkages(glycan_structure)) |>
  summarise(species = combine_species(species), .by = glycan_structure)

basic_strucs <- glydb_data |>
  mutate(
    glycan_structure = convert_to_generic(glycan_structure),
    glycan_structure = remove_linkages(glycan_structure)
  ) |>
  summarise(species = combine_species(species), .by = glycan_structure)

usethis::use_data(
  concrete_comps,
  generic_comps,
  intact_strucs,
  topological_strucs,
  basic_strucs,
  internal = TRUE
)
