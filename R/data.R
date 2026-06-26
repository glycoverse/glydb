#' GlyGen Glycan Data
#'
#' A curated dataset glycan structures from GlyGen Data v2.11.1,
#' with 19,436 glycan structures currently available.
#'
#' @inheritSection glydb_compositions Confidence
#'
#' @format A tibble with 19,436 rows and 6 variables:
#' - `glytoucan_ac`: GlyTouCan accession.
#' - `glycan_structure`: Glycan structure (glyrepr::glycan_structure()).
#' - `glycan_composition`: Glycan composition (glyrepr::glycan_composition()).
#' - `species`: Specie names, separated by semicolons. Unknown species are NAs.
#' - `glycan_type`: Glycan type, one of "N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc".
#' - `confidence`: Confidence score used to rank glycans.
#' @source <https://data.glygen.org>
"glydb_data"
