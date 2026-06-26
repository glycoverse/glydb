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
    confidence = max(confidence),
    .by = glycan_composition
  )

generic_comps <- glydb_data |>
  mutate(glycan_composition = convert_to_generic(glycan_composition)) |>
  summarise(
    species = combine_terms(species),
    glycan_type = combine_terms(glycan_type),
    confidence = max(confidence),
    .by = glycan_composition
  )

fully_determined <- read_csv("data-raw/glycan_fully_determined_v2_11_1.csv")
intact_strucs <- glydb_data |>
  semi_join(fully_determined, by = join_by(glytoucan_ac)) |>
  select(glycan_structure, species, glycan_type, confidence)

topological_strucs <- glydb_data |>
  mutate(
    glycan_structure = reduce_structure_level(glycan_structure, "topological")
  ) |>
  summarise(
    species = combine_terms(species),
    glycan_type = combine_terms(glycan_type),
    confidence = max(confidence),
    .by = glycan_structure
  )

basic_strucs <- glydb_data |>
  mutate(
    glycan_structure = reduce_structure_level(glycan_structure, "basic")
  ) |>
  summarise(
    species = combine_terms(species),
    glycan_type = combine_terms(glycan_type),
    confidence = max(confidence),
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
