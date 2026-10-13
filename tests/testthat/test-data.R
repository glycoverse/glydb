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

test_that("glydb_data has complete, unique accessions and valid parsed data", {
  expect_named(
    glydb_data,
    c(
      "glytoucan_ac",
      "glycan_structure",
      "glycan_composition",
      "species",
      "confidence",
      "glycan_type"
    )
  )
  expect_false(anyNA(glydb_data$glytoucan_ac))
  expect_true(all(nzchar(glydb_data$glytoucan_ac)))
  expect_identical(anyDuplicated(glydb_data$glytoucan_ac), 0L)
  expect_false(anyNA(glydb_data$glycan_structure))
  expect_false(anyNA(glydb_data$glycan_composition))
  expect_true(all(is.finite(glydb_data$confidence)))
  expect_true(all(glydb_data$confidence >= -1))
})
