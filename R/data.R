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
#' - `species`: Specie names. Unknown species are NAs.
#' @source <https://data.glygen.org>
"fully_determined_glycans"

#' GlyTouCan Glycan Structures with Only Topology Information
#'
#' This is a simplified version of `fully_determined_glycans`,
#' removing all linkage information,
#' e.g. "Fuc(??-?)Gal(??-?)[Fuc(??-?)]GlcNAc(??-".
#' The dataset is derived from the GlyTouCan v2.9.1 release,
#' with 2955 glycan structures currently available.
#'
#' @format A tibble with 2955 rows and 4 variables:
#' - `glycan_structure`: Glycan structure (glyrepr::glycan_structure()).
#' - `glycan_composition`: Glycan composition (glyrepr::glycan_composition()).
#' - `species`: Specie names. Unknown species are NAs.
#' @source <https://data.glygen.org>
"topology_glycans"
