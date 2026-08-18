test_that("glydb_species works", {
  res <- glydb_species()
  expect_type(res, "character")
  expect_true(length(res) > 0)
})

test_that("glydb_compositions works", {
  res <- glydb_compositions()
  expect_s3_class(res, "glyrepr_composition")
  expect_true(length(res) > 0)
})

test_that("glydb_structures works", {
  res <- glydb_structures()
  expect_s3_class(res, "glyrepr_structure")
  expect_true(length(res) > 0)
})

test_that("glydb_structures separates structure level and mono type", {
  cases <- list(
    list(structure_level = "intact", mono_type = "concrete"),
    list(structure_level = "intact", mono_type = "generic"),
    list(structure_level = "topological", mono_type = "concrete"),
    list(structure_level = "topological", mono_type = "generic")
  )

  for (case in cases) {
    result <- do.call(glydb_structures, case)
    expect_s3_class(result, "glyrepr_structure")
    expect_true(length(result) > 0)
    expect_true(all(
      glyrepr::get_structure_level(result) == case$structure_level
    ))
    expect_true(all(glyrepr::get_mono_type(result) == case$mono_type))
    if (case$structure_level == "intact") {
      expect_true(all(glyrepr::has_linkages(result, strict = TRUE)))
    } else {
      expect_false(any(glyrepr::has_linkages(result)))
    }
  }
})

test_that("glydb_structures rejects obsolete structure levels", {
  expect_error(
    glydb_structures(structure_level = "partial"),
    "Must be element of set"
  )
  expect_error(
    glydb_structures(structure_level = "basic"),
    "Must be element of set"
  )
})

test_that("glydb_compositions filters by glycan_type", {
  # Test with a known glycan type
  res <- glydb_compositions(glycan_type = "N")
  expect_s3_class(res, "glyrepr_composition")
  expect_true(length(res) > 0)

  # Test with NULL (default)
  res_all <- glydb_compositions()
  expect_true(length(res_all) >= length(res))
})

test_that("glydb_structures filters by glycan_type", {
  # Test with a known glycan type
  res <- glydb_structures(glycan_type = "N")
  expect_s3_class(res, "glyrepr_structure")
  expect_true(length(res) > 0)

  # Test with NULL (default)
  res_all <- glydb_structures()
  expect_true(length(res_all) >= length(res))
})

test_that("getters filter by GlyGen classification classes", {
  comps <- glydb_compositions(glycan_type = "HMO")
  expect_s3_class(comps, "glyrepr_composition")
  expect_true(length(comps) > 0)

  structs <- glydb_structures(glycan_type = "GSL")
  expect_s3_class(structs, "glyrepr_structure")
  expect_true(length(structs) > 0)

  expect_error(glydb_compositions(glycan_type = "C"), "set")
  expect_error(glydb_structures(glycan_type = "C"), "set")
})

test_that("O glycan type includes all O-linked subtypes", {
  broad_comps <- glydb_compositions(glycan_type = "O")
  glcnac_comps <- glydb_compositions(glycan_type = "O-GlcNAc")
  galnac_comps <- glydb_compositions(glycan_type = "O-GalNAc")

  expect_gt(length(broad_comps), length(glcnac_comps))
  expect_gt(length(broad_comps), length(galnac_comps))

  broad_structs <- glydb_structures(glycan_type = "O")
  glcnac_structs <- glydb_structures(glycan_type = "O-GlcNAc")
  galnac_structs <- glydb_structures(glycan_type = "O-GalNAc")

  expect_gt(length(broad_structs), length(glcnac_structs))
  expect_gt(length(broad_structs), length(galnac_structs))
})

test_that("glydb_compositions filters by mono_range", {
  # Get all compositions first
  all_comps <- glydb_compositions()

  # Filter for N-glycans with specific Hex range
  result <- glydb_compositions(
    glycan_type = "N",
    mono_range = list(Hex = c(5L, 10L))
  )
  expect_s3_class(result, "glyrepr_composition")
  expect_true(length(result) <= length(all_comps))

  # Verify all results have Hex in range
  hex_counts <- glyrepr::count_mono(result, "Hex")
  expect_true(all(hex_counts >= 5 & hex_counts <= 10, na.rm = TRUE))
})

test_that("glydb_compositions mono_range excludes unspecified monos", {
  # Only allow Hex and HexNAc, no Fuc
  result <- glydb_compositions(
    glycan_type = "N",
    mono_range = list(Hex = c(3L, 10L), HexNAc = c(2L, 10L))
  )

  # All results should have 0 Fuc
  fuc_counts <- glyrepr::count_mono(result, "Fuc")
  expect_true(all(fuc_counts == 0, na.rm = TRUE))
})

test_that("glydb_compositions validates mono_range", {
  expect_error(glydb_compositions(mono_range = "invalid"), "list")
  expect_error(glydb_compositions(mono_range = list(Hex = c(3L, 2L))), "min")
})

test_that("glydb_structures filters by mono_range", {
  # Get all structures first
  all_structs <- glydb_structures()

  # Filter for N-glycans with specific Hex range
  result <- glydb_structures(
    glycan_type = "N",
    mono_range = list(Hex = c(5L, 10L))
  )
  expect_s3_class(result, "glyrepr_structure")
  expect_true(length(result) <= length(all_structs))

  # Verify all results have Hex in range
  hex_counts <- glyrepr::count_mono(result, "Hex")
  expect_true(all(hex_counts >= 5 & hex_counts <= 10, na.rm = TRUE))
})

test_that("glydb_structures filters generic structures by mono_range", {
  result <- glydb_structures(
    mono_type = "generic",
    mono_range = list(Hex = c(3L, 10L))
  )
  expect_s3_class(result, "glyrepr_structure")
  expect_true(all(glyrepr::get_mono_type(result) == "generic"))
  hex_counts <- glyrepr::count_mono(result, "Hex")
  expect_true(all(hex_counts >= 3 & hex_counts <= 10, na.rm = TRUE))
})

test_that("glydb_structures mono_range excludes unspecified monos", {
  # Only allow Hex and HexNAc, no Fuc
  result <- glydb_structures(
    glycan_type = "N",
    mono_range = list(Hex = c(3L, 10L), HexNAc = c(2L, 10L))
  )

  # All results should have 0 Fuc
  fuc_counts <- glyrepr::count_mono(result, "Fuc")
  expect_true(all(fuc_counts == 0, na.rm = TRUE))
})

test_that("glydb_structures validates mono_range", {
  expect_error(glydb_structures(mono_range = "invalid"), "list")
  expect_error(glydb_structures(mono_range = list(Hex = c(3L, 2L))), "min")
})

test_that("glydb_compositions returns vectors with confidence", {
  res <- glydb_compositions()
  conf <- attr(res, "confidence")
  expect_type(conf, "double")
  expect_length(conf, length(res))
})

test_that("glydb_compositions mono_range returns vectors with confidence of correct length", {
  res <- glydb_compositions(mono_range = list(Hex = c(3L, 10L)))
  conf <- attr(res, "confidence")
  expect_type(conf, "double")
  expect_length(conf, length(res))
})

test_that("glydb_structures returns vectors with confidence", {
  res <- glydb_structures()
  conf <- attr(res, "confidence")
  expect_type(conf, "double")
  expect_length(conf, length(res))
})
