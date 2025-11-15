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