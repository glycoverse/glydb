library(tidyverse)
library(glyparse)
library(glyrepr)

accessions <- read_csv("data-raw/glycan_fully_determined_v2_9_1.csv")
iupac <- read_csv("data-raw/glycan_sequences_iupac_extended_v2_9_1.csv")
species <- read_csv("data-raw/glycan_species_v2_9_1.csv")

iupac_temp <- iupac |>
  semi_join(accessions, by = "glytoucan_ac") |>
  filter(!str_ends(sequence_iupac_extended, "ol")) |>
  filter(!str_detect(sequence_iupac_extended, "f"))

dry_try_parse <- function(x) {
  safe_parse <- purrr::possibly(parse_iupac_extended, NA)
  result <- purrr::map(x, safe_parse)
  n_total <- length(x)
  n_success <- sum(!is.na(result))
  cli::cli_inform("Parsed {n_success} out of {n_total} glycans")
  !is.na(result)
}

good_iupac <- dry_try_parse(iupac_temp$sequence_iupac_extended)
iupac_prepared <- iupac_temp[good_iupac, ] |>
  mutate(
    glycan_structure = parse_iupac_extended(sequence_iupac_extended),
    glycan_composition = as_glycan_composition(glycan_structure),
    .keep = "unused"
  )

species_prepared <- species |>
  select(glytoucan_ac, species = tax_name) |>
  summarise(species = str_c(unique(species), collapse = ";"), .by = glytoucan_ac)

fully_determined_glycans <- iupac_prepared |>
  left_join(species_prepared, by = "glytoucan_ac")

usethis::use_data(fully_determined_glycans, overwrite = TRUE)
