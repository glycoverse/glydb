test_that("glydb_species works", {
  res <- glydb_species()
  expect_type(res, "character")
  expect_true(length(res) > 0)
})