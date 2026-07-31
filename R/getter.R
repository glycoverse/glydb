utils::globalVariables(c(
  "glydb_data",
  "concrete_comps",
  "generic_comps",
  "intact_strucs",
  "topological_strucs",
  "basic_strucs"
))

#' Get supported glycan type labels
#'
#' Returns the glycan type labels accepted by glydb getter filters.
#'
#' @returns A character vector of glycan type labels.
#' @noRd
glycan_type_choices <- function() {
  c(
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
}

#' Match glycan type labels
#'
#' Matches one requested glycan type against semicolon-separated stored labels.
#' The broad "O" type matches "O" and all specific O-linked subtypes.
#'
#' @param glycan_types A character vector of glycan type labels for one record.
#' @param glycan_type A requested glycan type label.
#' @returns A logical scalar.
#' @noRd
match_glycan_type <- function(glycan_types, glycan_type) {
  if (identical(glycan_type, "O")) {
    return(any(glycan_types == "O" | stringr::str_starts(glycan_types, "O-")))
  }

  glycan_type %in% glycan_types
}

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
#' @section Confidence:
#' The returned value has a `confidence` attribute:
#' a numeric vector of the same length as the result containing log-transformed
#' citation counts for each glycan in `glydb_data`.
#' When multiple glycans are aggregated into lower-resolution structures or compositions,
#' the maximum confidence score is retained.
#'
#' The `confidence` attribute is preserved by vector operations that subset,
#' reorder, repeat, combine, or replace glycans. When vectors containing the
#' same glycan with different confidence values are combined, the maximum
#' confidence is used for every occurrence of that glycan.
#'
#' @param mono_type Either "generic" or "concrete". Default is "concrete".
#'   See [glyrepr::get_mono_type()] for details.
#' @param species A string of specie names. See [glydb_species()] for available specie names.
#'   Default is NULL, which means glycans from all species are included.
#' @param glycan_type A string of glycan types.
#'   Can be "HMO", "N", "GSL", "GAG", "O", "O-GalNAc", "O-GlcNAc",
#'   "O-Man", "O-Fuc", "O-Glc", or "GPI".
#'   When "O", all O-linked glycans are included.
#'   Specific O-glycan types only include that subtype.
#'   Default is NULL, which means glycans of all types are included.
#' @param mono_range A named list for filtering compositions by monosaccharide counts.
#'   Each element should be an integer vector of length 2 specifying the minimum and maximum
#'   count for that monosaccharide. Monosaccharides not specified will be excluded (count = 0).
#'   Use `NULL` for no filtering. See examples for usage.
#'
#' @returns A [glyrepr::glycan_composition()] vector, with a `confidence` attribute as a
#'   numeric vector with the same length.
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
    glycan_type_choices(),
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
    right_type <- purrr::map_lgl(types_list, match_glycan_type, glycan_type)
    right_type[is.na(right_type)] <- FALSE
    data <- data[right_type, ]
  }

  result <- data$glycan_composition
  confidence <- data$confidence

  if (!is.null(mono_range)) {
    mask <- filter_by_mono_range(result, mono_range, mono_type)
    result <- result[mask]
    confidence <- confidence[mask]
  }

  new_glydb_composition(result, confidence)
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
#'   Can be "HMO", "N", "GSL", "GAG", "O", "O-GalNAc", "O-GlcNAc",
#'   "O-Man", "O-Fuc", "O-Glc", or "GPI".
#'   When "O", all O-linked glycans are included.
#'   Specific O-glycan types only include that subtype.
#'   Default is NULL, which means glycans of all types are included.
#' @param mono_range A named list for filtering structures by monosaccharide counts.
#'   Each element should be an integer vector of length 2 specifying the minimum and maximum
#'   count for that monosaccharide. Monosaccharides not specified will be excluded (count = 0).
#'   Use `NULL` for no filtering. See examples for usage.
#'
#' @inheritSection glydb_compositions Confidence
#'
#' @returns A [glyrepr::glycan_structure()] vector, with a `confidence` attribute as a
#'   numeric vector with the same length.
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
    glycan_type_choices(),
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
    right_type <- purrr::map_lgl(types_list, match_glycan_type, glycan_type)
    right_type[is.na(right_type)] <- FALSE
    data <- data[right_type, ]
  }

  result <- data$glycan_structure
  confidence <- data$confidence

  if (!is.null(mono_range)) {
    mask <- filter_by_mono_range(result, mono_range, mono_type)
    result <- result[mask]
    confidence <- confidence[mask]
  }

  new_glydb_structure(result, confidence)
}
