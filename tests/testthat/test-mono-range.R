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
  # Create test compositions using generic monos: Hex3, Hex3, Hex6
  comps <- glyrepr::glycan_composition(
    c(Hex = 3L), c(Hex = 3L), c(Hex = 6L)
  )

  # Filter for Hex between 2 and 4
  result <- filter_by_mono_range(comps, list(Hex = c(2L, 4L)))
  expect_length(result, 2)  # Hex3, Hex3 pass; Hex6 fails
})

test_that("filter_by_mono_range defaults missing monos to 0", {
  # Create compositions with Hex and dHex
  comps <- glyrepr::glycan_composition(
    c(Hex = 3L), c(Hex = 3L, dHex = 1L)
  )

  # Filter for dHex = c(0, 0) - should exclude glycans with dHex
  # Also need to allow Hex since some glycans have Hex
  result <- filter_by_mono_range(comps, list(dHex = c(0L, 0L), Hex = c(0L, Inf)))
  expect_length(result, 1)
  expect_true(all(glyrepr::count_mono(result, "dHex") == 0))
})

test_that("filter_by_mono_range works with structures", {
  # Create structures with only Hex (no other monos)
  # Two Man structures: one with 2 Hex, one with 3 Hex
  structs <- glyrepr::as_glycan_structure(c("Man(a1-3)Man(a1-", "Man(a1-3)Man(a1-3)Man(a1-"))
  # Filter for exactly 2 Hex - should only match the first
  result <- filter_by_mono_range(structs, list(Hex = c(2L, 2L)))
  expect_length(result, 1)
})

test_that("filter_by_mono_range returns all when mono_range is NULL", {
  comps <- glyrepr::glycan_composition(c(Hex = 3L))
  result <- filter_by_mono_range(comps, NULL)
  expect_length(result, 1)
})
