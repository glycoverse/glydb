test_that("validate_mono_range works with valid input", {
  expect_no_error(validate_mono_range(list(Hex = c(3L, 9L))))
  expect_no_error(validate_mono_range(list(Hex = c(0L, Inf))))
  expect_no_error(validate_mono_range(NULL))
})

test_that("validate_mono_range errors on duplicate names", {
  expect_error(validate_mono_range(list(Hex = c(3L, 9L), Hex = c(2L, 6L))), "duplicated")
})

test_that("validate_mono_range errors on invalid min/max", {
  expect_error(validate_mono_range(list(Hex = c(-1L, 5L))), "min")
  expect_error(validate_mono_range(list(Hex = c(3L, 2L))), "max.*min")
  expect_error(validate_mono_range(list(Hex = c(Inf, 5L))), "min.*Inf")
})

test_that("validate_mono_range errors on non-integer values", {
  expect_error(validate_mono_range(list(Hex = c(3, 9))), "integer")
})

test_that("validate_mono_range errors on invalid monosaccharide names", {
  expect_error(validate_mono_range(list(InvalidMono = c(3L, 9L))), "known")
})

test_that("filter_by_mono_range works with compositions", {
  # Create test compositions: Gal2Man1, Gal1Man2, Gal3Man3
  comps <- glyrepr::glycan_composition(
    c(Gal = 2L, Man = 1L), c(Gal = 1L, Man = 2L), c(Gal = 3L, Man = 3L)
  )

  # Filter for Hex between 2 and 4 (Gal + Man = Hex)
  result <- filter_by_mono_range(comps, list(Hex = c(2L, 4L)))
  expect_length(result, 2)  # Gal2Man1=3, Gal1Man2=3 pass; Gal3Man3=6 fails
})

test_that("filter_by_mono_range defaults missing monos to 0", {
  comps <- glyrepr::glycan_composition(
    c(Gal = 2L, Man = 1L), c(Gal = 1L, Man = 2L, Fuc = 1L)
  )

  # Filter for Fuc = c(0, 0) - should exclude glycans with Fuc
  result <- filter_by_mono_range(comps, list(Fuc = c(0L, 0L)))
  expect_length(result, 1)
  expect_true(all(glyrepr::count_mono(result, "Fuc") == 0))
})

test_that("filter_by_mono_range works with structures", {
  structs <- glyrepr::as_glycan_structure(c("Gal(b1-4)Glc(b1-", "Gal(b1-4)Fuc(a1-"))
  result <- filter_by_mono_range(structs, list(Hex = c(2L, 2L)))
  expect_length(result, 1)  # Only Gal-Glc has 2 Hex
})

test_that("filter_by_mono_range returns all when mono_range is NULL", {
  comps <- glyrepr::glycan_composition(c(Gal = 2L, Man = 1L))
  result <- filter_by_mono_range(comps, NULL)
  expect_length(result, 1)
})
