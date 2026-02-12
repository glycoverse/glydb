utils::globalVariables(c(
  "glydb_data",
  "concrete_comps",
  "generic_comps",
  "intact_strucs",
  "topological_strucs",
  "basic_strucs"
))

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
#' @param glycan_type A string of glycan types.
#'   Can be "N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc".
#'   Default is NULL, which means glycans of all types are included.
#' @param mono_range A named list for filtering compositions by monosaccharide counts.
#'   Each element should be an integer vector of length 2 specifying the minimum and maximum
#'   count for that monosaccharide. Monosaccharides not specified will be excluded (count = 0).
#'   Use `NULL` for no filtering. See examples for usage.
#'
#' @returns A [glyrepr::glycan_composition()] vector.
#' @examples
#' glydb_compositions()
#' glydb_compositions(mono_type = "generic")
#' glydb_compositions(species = "Homo sapiens")
#' glydb_compositions(glycan_type = "N")
#' glydb_compositions(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#' glydb_compositions(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#' @export
glydb_compositions <- function(
  mono_type = "concrete",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL
) {
  checkmate::assert_choice(mono_type, c("generic", "concrete"))
  checkmate::assert_choice(species, glydb_species(), null.ok = TRUE)
  checkmate::assert_choice(
    glycan_type,
    c("N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc"),
    null.ok = TRUE
  )
  validate_mono_range(mono_range, mono_type)
  data <- switch(mono_type, concrete = concrete_comps, generic = generic_comps)

  if (!is.null(species)) {
    species_list <- stringr::str_split(data$species, ";")
    right_specie <- purrr::map_lgl(species_list, ~ species %in% .x)
    right_specie[is.na(right_specie)] <- FALSE
    data <- data[right_specie, ]
  }

  if (!is.null(glycan_type)) {
    types_list <- stringr::str_split(data$glycan_type, ";")
    right_type <- purrr::map_lgl(types_list, ~ glycan_type %in% .x)
    right_type[is.na(right_type)] <- FALSE
    data <- data[right_type, ]
  }

  result <- unique(data$glycan_composition)
  filter_by_mono_range(result, mono_range, mono_type)
}

#' Get Structures From Glydb Data
#'
#' Get unique glycan structures from [glydb_data] as a [glyrepr::glycan_structure()] vector.
#'
#' @param structure_level Either "intact", "topological", or "basic". Default is "intact".
#'   See [glyrepr::get_structure_level()] for details.
#' @param species A string of specie names. See [glydb_species()] for available specie names.
#'   Default is NULL, which means glycans from all species are included.
#' @param glycan_type A string of glycan types.
#'   Can be "N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc".
#'   Default is NULL, which means glycans of all types are included.
#' @param mono_range A named list for filtering structures by monosaccharide counts.
#'   Each element should be an integer vector of length 2 specifying the minimum and maximum
#'   count for that monosaccharide. Monosaccharides not specified will be excluded (count = 0).
#'   Use `NULL` for no filtering. See examples for usage.
#'
#' @returns A [glyrepr::glycan_structure()] vector.
#' @examples
#' glydb_structures()
#' glydb_structures(structure_level = "topological")
#' glydb_structures(structure_level = "basic")
#' glydb_structures(species = "Homo sapiens")
#' glydb_structures(glycan_type = "N")
#' glydb_structures(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#' glydb_structures(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#' @export
glydb_structures <- function(
  structure_level = "intact",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL
) {
  checkmate::assert_choice(structure_level, c("intact", "topological", "basic"))
  checkmate::assert_choice(species, glydb_species(), null.ok = TRUE)
  checkmate::assert_choice(
    glycan_type,
    c("N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc"),
    null.ok = TRUE
  )
  mono_type <- ifelse(structure_level == "basic", "generic", "concrete")
  validate_mono_range(mono_range, mono_type)
  data <- switch(
    structure_level,
    intact = intact_strucs,
    topological = topological_strucs,
    basic = basic_strucs
  )

  if (!is.null(species)) {
    species_list <- stringr::str_split(data$species, ";")
    right_specie <- purrr::map_lgl(species_list, ~ species %in% .x)
    right_specie[is.na(right_specie)] <- FALSE
    data <- data[right_specie, ]
  }

  if (!is.null(glycan_type)) {
    types_list <- stringr::str_split(data$glycan_type, ";")
    right_type <- purrr::map_lgl(types_list, ~ glycan_type %in% .x)
    right_type[is.na(right_type)] <- FALSE
    data <- data[right_type, ]
  }

  result <- unique(data$glycan_structure)
  filter_by_mono_range(result, mono_range, mono_type)
}
