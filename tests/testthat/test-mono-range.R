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
