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
