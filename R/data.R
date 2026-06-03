#' Fully Determined GlyTouCan Glycan Data
#'
#' A curated dataset of fully determined glycans from GlyTouCan.
#' "Fully determined" means that all linkages, substituents, anomers,
#' and monosaccharides are fully specified.
#' The dataset is derived from the GlyTouCan v2.11.1 release,
#' with 7,125 glycan structures currently available.
#'
#' @format A tibble with 7,125 rows and 5 variables:
#' - `glytoucan_ac`: GlyTouCan accession.
#' - `glycan_structure`: Glycan structure (glyrepr::glycan_structure()).
#' - `glycan_composition`: Glycan composition (glyrepr::glycan_composition()).
#' - `species`: Specie names, separated by semicolons. Unknown species are NAs.
#' - `glycan_type`: Glycan type, one of "N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc".
#' @source <https://data.glygen.org>
"glydb_data"
