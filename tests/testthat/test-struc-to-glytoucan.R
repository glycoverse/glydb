test_that("struc_to_glytoucan returns bundled accessions in input order", {
  positions <- c(2L, 1L, 2L)
  strucs <- glydb_data$glycan_structure[positions]

  result <- struc_to_glytoucan(strucs)

  expect_type(result, "character")
  expect_equal(result, glydb_data$glytoucan_ac[positions])
})

test_that("struc_to_glytoucan accepts character structures", {
  struc <- glydb_data$glycan_structure[[1]]

  result <- struc_to_glytoucan(as.character(struc))

  expect_equal(result, glydb_data$glytoucan_ac[[1]])
})

test_that("struc_to_glytoucan normalizes bundled structures before matching", {
  position <- match("G00009BX", glydb_data$glytoucan_ac)
  struc <- glydb_data$glycan_structure[position]

  expect_equal(struc_to_glytoucan(struc), "G00009BX")
})

test_that("struc_to_glytoucan preserves NA and warns for unmatched structures", {
  strucs <- c(
    glydb_data$glycan_structure[1],
    glyrepr::glycan_structure(NA),
    glyrepr::as_glycan_structure("Neu5Ac(a2-8)Neu5Ac(a2-8)Neu5Ac(a2-"),
    glydb_data$glycan_structure[2]
  )

  expect_snapshot(result <- struc_to_glytoucan(strucs))

  expect_equal(
    result[c(1, 4)],
    glydb_data$glytoucan_ac[1:2]
  )
  expect_true(is.na(result[2]))
  expect_true(is.na(result[3]))
})

test_that("struc_to_glytoucan supports empty input", {
  expect_identical(struc_to_glytoucan(glyrepr::glycan_structure()), character())
})

test_that("struc_to_glytoucan validates input", {
  expect_snapshot(error = TRUE, struc_to_glytoucan(1))
})
