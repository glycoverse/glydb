test_that("glydb_data is available", {
  expect_true(tibble::is_tibble(glydb_data))
})
