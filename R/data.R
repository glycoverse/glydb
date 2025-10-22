#' Fully Determined GlyTouCan Glycan Structures
#'
#' A curated dataset of fully determined glycan structures from GlyTouCan.
#' "Fully determined" means that all linkages, substituents, anomers,
#' and monosaccharides are fully specified.
#' The dataset is derived from the GlyTouCan v2.9.1 release,
#' with 6960 glycan structures currently available.
#'
#' @format A tibble with 6960 rows and 4 variables:
#' - `glytoucan_ac`: GlyTouCan accession.
#' - `glycan_structure`: Glycan structure (glyrepr::glycan_structure()).
#' - `glycan_composition`: Glycan composition (glyrepr::glycan_composition()).
#' - `species`: Species name. Unknown species are NAs.
#' @source <https://data.glygen.org>
"glytoucan_glycans"