test_that("glytoucan_to_struc returns bundled structures in input order", {
  positions <- c(2L, 1L, 2L)

  result <- glytoucan_to_struc(glydb_data$glytoucan_ac[positions])

  expect_s3_class(result, "glyrepr_structure")
  expect_equal(result, glydb_data$glycan_structure[positions])
})

test_that("glytoucan_to_struc returns NA for accessions without a match", {
  accessions <- c(
    glydb_data$glytoucan_ac[[1]],
    "G_NOT_IN_GLYDB",
    glydb_data$glytoucan_ac[[2]],
    "G_NOT_IN_GLYDB"
  )

  expect_snapshot(result <- glytoucan_to_struc(accessions))

  expect_s3_class(result, "glyrepr_structure")
  expect_equal(result[c(1, 3)], glydb_data$glycan_structure[1:2])
  expect_equal(which(is.na(result)), c(2L, 4L))
})

test_that("glytoucan_to_struc supports empty input", {
  result <- glytoucan_to_struc(character())

  expect_s3_class(result, "glyrepr_structure")
  expect_length(result, 0L)
})

test_that("glytoucan_to_struc validates accessions", {
  expect_snapshot(error = TRUE, glytoucan_to_struc(1))
  expect_snapshot(error = TRUE, glytoucan_to_struc(NA_character_))
})
