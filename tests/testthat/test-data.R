test_that("glytoucan_glycans is available", {
  expect_true(tibble::is_tibble(glytoucan_glycans))
})