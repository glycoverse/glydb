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

test_that("glydb_compositions filters by mono_range", {
  # Get all compositions first
  all_comps <- glydb_compositions()

  # Filter for N-glycans with specific Hex range
  result <- glydb_compositions(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
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
