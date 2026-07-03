test_that("glydb_data is available", {
  expect_true(tibble::is_tibble(glydb_data))
})

test_that("glydb_data uses GlyGen classification classes", {
  glycan_types <- glydb_data$glycan_type |>
    as.character() |>
    stringr::str_split(";") |>
    unlist(use.names = FALSE) |>
    stats::na.omit()

  expect_true(all(c("HMO", "N", "GSL", "GAG", "GPI") %in% glycan_types))
  expect_false("C" %in% glycan_types)
  expect_true(any(
    glycan_types %in% c("O", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc")
  ))
})
