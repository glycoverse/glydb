library(tidyverse)
library(glyparse)
library(glyrepr)

accessions <- read_csv("data-raw/glycan_fully_determined_v2_10_1.csv")
iupac <- read_csv("data-raw/glycan_sequences_iupac_condensed_v2_10_1.csv")
species <- read_csv("data-raw/glycan_species_v2_10_1.csv")

iupac_temp <- iupac |>
  semi_join(accessions, by = "glytoucan_ac") |>
  filter(!str_ends(sequence_iupac_condensed, "ol")) |>
  filter(!str_detect(sequence_iupac_condensed, "f"))

# dry_try_parse <- function(x) {
#   safe_parse <- purrr::possibly(parse_iupac_condensed, NA)
#   result <- purrr::map(x, safe_parse)
#   n_total <- length(x)
#   n_success <- sum(!is.na(result))
#   cli::cli_inform("Parsed {n_success} out of {n_total} glycans")
#   !is.na(result)
# }
# good_iupac <- dry_try_parse(iupac_temp$sequence_iupac_condensed)

iupac_prepared <- iupac_temp |>
  mutate(
    glycan_structure = as_glycan_structure(sequence_iupac_condensed),
    glycan_composition = as_glycan_composition(glycan_structure),
    .keep = "unused"
  )

species_prepared <- species |>
  select(glytoucan_ac, species = tax_name) |>
  summarise(species = str_c(unique(species), collapse = ";"), .by = glytoucan_ac)

get_glycan_type <- function(glycan_structure) {
  motifs <- c(
    "N" = "Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-",
    "O-GalNAc" = "GalNAc(a1-",
    "O-GlcNAc" = "GlcNAc(b1-",
    "O-Man" = "Man(a1-",
    "O-Fuc" = "Fuc(a1-",
    "O-Glc" = "Glc(b1-"
  )
  motif_mat <- glymotif::have_motifs(glycan_structure, motifs, alignment = "core")
  res <- dplyr::case_when(
    motif_mat[, "N"] ~ "N",
    motif_mat[, "O-GalNAc"] ~ "O-GalNAc",
    motif_mat[, "O-GlcNAc"] ~ "O-GlcNAc",
    motif_mat[, "O-Man"] ~ "O-Man",
    motif_mat[, "O-Fuc"] ~ "O-Fuc",
    motif_mat[, "O-Glc"] ~ "O-Glc",
    .default = NA_character_
  )
  factor(res, levels = c("N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc"))
}

glydb_data <- iupac_prepared |>
  left_join(species_prepared, by = "glytoucan_ac") |>
  mutate(glycan_type = get_glycan_type(glycan_structure))

usethis::use_data(glydb_data, overwrite = TRUE)
