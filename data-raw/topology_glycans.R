library(tidyverse)
library(glyrepr)
load_all()

#' Combine species names into a single string
#' @param specie_str A character vector of species names separated by semicolons
#' @returns A character scalar of combined species names
#' @examples
#' combine_species(c("Homo sapiens;Mus musculus", "Mus musculus;Rattus norvegicus"))
#' # "Homo sapiens;Mus musculus;Rattus norvegicus"
combine_species <- function(specie_str) {
  specie_str |>
    str_split(";") |>
    unlist() |>
    unique() |>
    str_c(collapse = ";")
}

topology_glycans <- fully_determined_glycans |>
  mutate(glycan_structure = remove_linkages(glycan_structure)) |>
  summarise(species = combine_species(species), .by = c(glycan_structure, glycan_composition))

usethis::use_data(topology_glycans, overwrite = TRUE)
