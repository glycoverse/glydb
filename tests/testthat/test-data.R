test_that("fully_determined_glycans is available", {
  expect_true(tibble::is_tibble(fully_determined_glycans))
})

test_that("topology_glycans is available", {
  expect_true(tibble::is_tibble(topology_glycans))
})