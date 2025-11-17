utils::globalVariables(c("glydb_data", "concrete_comps", "generic_comps", "intact_strucs", "topological_strucs", "basic_strucs"))

#' Get Supported Species From Glydb Data
#'
#' Get a character vector of supported species from [glydb_data].
#'
#' @returns A character vector of supported species.
#' @examples
#' glydb_species()
#' @export
glydb_species <- function() {
  c(
    "Saccharomyces cerevisiae",
    "Mus musculus",
    "Rattus",
    "Rattus norvegicus",
    "Bos taurus",
    "Gallus gallus",
    "Drosophila melanogaster",
    "Cricetulus griseus",
    "Homo sapiens",
    "Sus scrofa",
    "Sus scrofa domesticus",
    "Severe acute respiratory syndrome coronavirus 2",
    "Danio rerio",
    "Arabidopsis thaliana",
    "Dictyostelium discoideum"
  )
}

#' Get Compositions From Glydb Data
#'
#' Get unique glycan compositions from [glydb_data] as a [glyrepr::glycan_composition()] vector.
#'
#' @param mono_type Either "generic" or "concrete". Default is "concrete".
#'   See [glyrepr::get_mono_type()] for details.
#' @param species A string of specie names. See [glydb_species()] for available specie names.
#'   Default is NULL, which means glycans from all species are included.
#'
#' @returns A [glyrepr::glycan_composition()] vector.
#' @examples
#' glydb_compositions()
#' glydb_compositions(mono_type = "generic")
#' glydb_compositions(species = "Homo sapiens")
#' @export
glydb_compositions <- function(mono_type = "concrete", species = NULL) {
  checkmate::assert_choice(mono_type, c("generic", "concrete"))
  checkmate::assert_choice(species, glydb_species(), null.ok = TRUE)
  data <- switch(mono_type, concrete = concrete_comps, generic = generic_comps)
  if (is.null(species)) {
    comps <- data$glycan_composition
  } else {
    right_specie <- stringr::str_detect(data$species, species)
    right_specie[is.na(right_specie)] <- FALSE
    comps <- data$glycan_composition[right_specie]
  }
  unique(comps)
}

#' Get Structures From Glydb Data
#'
#' Get unique glycan structures from [glydb_data] as a [glyrepr::glycan_structure()] vector.
#'
#' @param structure_level Either "intact", "topological", or "basic". Default is "intact".
#'   See [glyrepr::get_structure_level()] for details.
#' @param species A string of specie names. See [glydb_species()] for available specie names.
#'   Default is NULL, which means glycans from all species are included.
#'
#' @returns A [glyrepr::glycan_structure()] vector.
#' @examples
#' glydb_structures()
#' glydb_structures(structure_level = "topological")
#' glydb_structures(structure_level = "basic")
#' glydb_structures(species = "Homo sapiens")
#' @export
glydb_structures <- function(structure_level = "intact", species = NULL) {
  checkmate::assert_choice(structure_level, c("intact", "topological", "basic"))
  checkmate::assert_choice(species, glydb_species(), null.ok = TRUE)
  data <- switch(structure_level,
    intact = intact_strucs,
    topological = topological_strucs,
    basic = basic_strucs
  )
  if (is.null(species)) {
    strucs <- data$glycan_structure
  } else {
    right_specie <- stringr::str_detect(data$species, species)
    right_specie[is.na(right_specie)] <- FALSE
    strucs <- data$glycan_structure[right_specie]
  }
  unique(strucs)
}