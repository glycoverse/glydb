#' Fully Determined GlyTouCan Glycan Data
#'
#' A curated dataset of fully determined glycans from GlyTouCan.
#' "Fully determined" means that all linkages, substituents, anomers,
#' and monosaccharides are fully specified.
#' The dataset is derived from the GlyTouCan v2.9.1 release,
#' with 6960 glycan structures currently available.
#'
#' @details
#' # Duplicate Glycan Structures
#'
#' There are duplicate glycan structures in the dataset,
#' due to the presence of rare monosaccharides in some glycans.
#' For example, Fuc has L configuration in most cases,
#' but in some situations it can have D configuration.
#' `glyparse` and `glyrepr` doesn't support this kind of ambiguity for now,
#' so we keep them all in the dataset.
#' However, this situation is rare, and we have 6853 unique glycan structures in the dataset.
#' If you need the detailed information, you can use the `glytoucan_ac` (GlyTouCan accession)
#' to query the original data.
#'
#' @format A tibble with 6960 rows and 4 variables:
#' - `glytoucan_ac`: GlyTouCan accession.
#' - `glycan_structure`: Glycan structure (glyrepr::glycan_structure()).
#' - `glycan_composition`: Glycan composition (glyrepr::glycan_composition()).
#' - `species`: Specie names, separated by semicolons. Unknown species are NAs.
#' @source <https://data.glygen.org>
"glydb_data"
