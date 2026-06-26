library(tidyverse)
library(glyparse)
library(glyrepr)

iupac <- read_csv("data-raw/glycan_sequences_iupac_condensed_v2_11_1.csv")
species <- read_csv("data-raw/glycan_species_v2_11_1.csv")
citations <- read_csv("data-raw/glycan_citations_glytoucan_v2_11_1.csv")

iupac_prepared <- iupac |>
  mutate(
    glycan_structure = parse_iupac_condensed(
      sequence_iupac_condensed,
      on_failure = "na"
    )
  ) |>
  filter(!is.na(glycan_structure)) |>
  mutate(glycan_composition = as_glycan_composition(glycan_structure)) |>
  select(glytoucan_ac, glycan_structure, glycan_composition)

species_prepared <- species |>
  select(glytoucan_ac, species = tax_name) |>
  summarise(
    species = str_c(unique(species), collapse = ";"),
    .by = glytoucan_ac
  )

confidence <- citations |>
  summarise(confidence = log(n()), .by = glytoucan_ac)

get_glycan_type <- function(glycan_structure) {
  motifs <- c(
    "N" = "Man(??-?)GlcNAc(??-?)GlcNAc(??-",
    "O-GalNAc" = "GalNAc(??-",
    "O-GlcNAc" = "GlcNAc(??-",
    "O-Man" = "Man(??-",
    "O-Fuc" = "Fuc(??-",
    "O-Glc" = "Xyl(??-?)Glc(??-"
  )
  motif_mat <- glymotif::have_motifs(
    glycan_structure,
    motifs,
    alignment = "core"
  )
  res <- dplyr::case_when(
    motif_mat[, "N"] ~ "N",
    motif_mat[, "O-GalNAc"] ~ "O-GalNAc",
    motif_mat[, "O-GlcNAc"] ~ "O-GlcNAc",
    motif_mat[, "O-Man"] ~ "O-Man",
    motif_mat[, "O-Fuc"] ~ "O-Fuc",
    motif_mat[, "O-Glc"] ~ "O-Glc",
    .default = NA_character_
  )
  factor(
    res,
    levels = c("N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc")
  )
}

glydb_data <- iupac_prepared |>
  left_join(species_prepared, by = "glytoucan_ac") |>
  left_join(confidence, by = "glytoucan_ac") |>
  mutate(confidence = if_else(is.na(confidence), -1, confidence)) |>
  mutate(glycan_type = get_glycan_type(glycan_structure))

usethis::use_data(glydb_data, overwrite = TRUE)

# Remember to rerun internal_data.R as well.
