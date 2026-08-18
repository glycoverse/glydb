library(tidyverse)
library(glyparse)
library(glyrepr)

wurcs <- read_csv("data-raw/glycan_sequences_wurcs_v2_11_1.csv")
species <- read_csv("data-raw/glycan_species_v2_11_1.csv")
citations <- read_csv("data-raw/glycan_citations_glytoucan_v2_11_1.csv")
classification <- read_csv("data-raw/glycan_classification_v2_11_1.csv")

wurcs_prepared <- wurcs |>
  mutate(glycan_structure = parse_wurcs(sequence_wurcs, on_failure = "na", progress = TRUE)) |>
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

glycan_type_abbr <- c(
  "Human Milk Oligosaccharide" = "HMO",
  "N-linked" = "N",
  "Glycosphingolipid" = "GSL",
  "GAG" = "GAG",
  "O-linked" = "O",
  "GPI anchor" = "GPI"
)

glycan_type_levels <- c(
  "HMO",
  "N",
  "GSL",
  "GAG",
  "O",
  "O-GalNAc",
  "O-GlcNAc",
  "O-Man",
  "O-Fuc",
  "O-Glc",
  "GPI"
)

#' Classify O-glycan structures with reducing-end motif rules
#'
#' Uses the legacy reducing-end motif rules to assign specific O-glycan subtypes.
#'
#' @param glycan_structure A `glyrepr::glycan_structure()` vector.
#' @returns A character vector of O-glycan subtype labels.
#' @noRd
get_o_glycan_type <- function(glycan_structure) {
  last_mono <- glyrepr::smap_chr(
    glycan_structure,
    \(graph) igraph::vertex_attr(graph, "mono")[[igraph::vcount(graph)]]
  )
  res <- case_when(
    last_mono == "GalNAc" ~ "O-GalNAc",
    last_mono == "GlcNAc" ~ "O-GlcNAc",
    last_mono == "Man" ~ "O-Man",
    last_mono == "Fuc" ~ "O-Fuc",
    last_mono == "Glc" ~ "O-Glc",
    .default = NA_character_
  )
  factor(res, levels = glycan_type_levels)
}

classification_with_structures <- classification |>
  filter(glycan_type != "C-linked") |>
  select(glytoucan_ac, glycan_type) |>
  mutate(
    glycan_type = dplyr::recode(
      .data$glycan_type,
      !!!glycan_type_abbr,
      .default = NA_character_
    )
  ) |>
  filter(!is.na(.data$glycan_type)) |>
  distinct(.data$glytoucan_ac, .data$glycan_type) |>
  inner_join(
    select(wurcs_prepared, glytoucan_ac, glycan_structure),
    by = "glytoucan_ac"
  )

classification_prepared <- bind_rows(
  classification_with_structures |>
    filter(.data$glycan_type != "O"),
  classification_with_structures |>
    filter(.data$glycan_type == "O") |>
    mutate(
      glycan_type = coalesce(
        as.character(get_o_glycan_type(.data$glycan_structure)),
        "O"
      )
    )
) |>
  mutate(
    glycan_type = factor(.data$glycan_type, levels = glycan_type_levels)
  ) |>
  distinct(.data$glytoucan_ac, .data$glycan_type) |>
  arrange(.data$glytoucan_ac, .data$glycan_type) |>
  summarise(
    glycan_type = str_c(as.character(.data$glycan_type), collapse = ";"),
    .by = glytoucan_ac
  )

glydb_data <- wurcs_prepared |>
  left_join(species_prepared, by = "glytoucan_ac") |>
  left_join(confidence, by = "glytoucan_ac") |>
  mutate(confidence = if_else(is.na(confidence), -1, confidence)) |>
  left_join(classification_prepared, by = "glytoucan_ac")

usethis::use_data(glydb_data, overwrite = TRUE)

# Remember to rerun internal_data.R as well.
