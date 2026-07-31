test_that("getter vectors preserve confidence when sliced and repeated", {
  structures <- glydb_structures()[1:4]
  compositions <- glydb_compositions()[1:4]

  structure_confidence <- attr(structures, "confidence")
  composition_confidence <- attr(compositions, "confidence")

  structure_subset <- structures[c(4, 2, 2)]
  composition_subset <- compositions[c(4, 2, 2)]

  expect_s3_class(structure_subset, "glydb_structure")
  expect_s3_class(composition_subset, "glydb_composition")
  expect_identical(
    attr(structure_subset, "confidence"),
    structure_confidence[c(4, 2, 2)]
  )
  expect_identical(
    attr(composition_subset, "confidence"),
    composition_confidence[c(4, 2, 2)]
  )
  expect_identical(
    attr(rep(structures[1:2], 2), "confidence"),
    rep(structure_confidence[1:2], 2)
  )
  expect_identical(
    attr(rep(compositions[1:2], 2), "confidence"),
    rep(composition_confidence[1:2], 2)
  )
})

test_that("named and vctrs slicing preserve confidence", {
  structures <- glydb_structures()[1:4]
  names(structures) <- letters[1:4]
  confidence <- attr(structures, "confidence")

  named_subset <- structures[c("d", "b")]
  vctrs_subset <- vctrs::vec_slice(structures, c(3, 1))

  expect_identical(names(named_subset), c("d", "b"))
  expect_identical(
    attr(named_subset, "confidence"),
    confidence[c(4, 2)]
  )
  expect_identical(
    attr(vctrs_subset, "confidence"),
    confidence[c(3, 1)]
  )
})

test_that("combining identical glycans retains maximum confidence", {
  structure <- strip_glydb_class(glydb_structures()[1])
  composition <- strip_glydb_class(glydb_compositions()[1])

  low_structure <- new_glydb_structure(structure, 1)
  high_structure <- new_glydb_structure(structure, 3)
  low_composition <- new_glydb_composition(composition, 2)
  high_composition <- new_glydb_composition(composition, 4)

  combined_structures <- c(low_structure, high_structure)
  combined_compositions <- c(low_composition, high_composition)

  expect_identical(attr(combined_structures, "confidence"), c(3, 3))
  expect_identical(attr(combined_compositions, "confidence"), c(4, 4))
  expect_identical(attr(unique(combined_structures), "confidence"), 3)
  expect_identical(attr(unique(combined_compositions), "confidence"), 4)

  attr(low_structure, "confidence") <- 5
  expect_identical(
    attr(c(low_structure, high_structure), "confidence"),
    c(5, 5)
  )
})

test_that("combining plain glyrepr vectors uses available confidence", {
  structures <- glydb_structures()[1:2]
  compositions <- glydb_compositions()[1:2]
  plain_structure <- strip_glydb_class(structures[2])
  plain_composition <- strip_glydb_class(compositions[2])

  combined_structures <- c(structures[1], plain_structure)
  combined_compositions <- c(compositions[1], plain_composition)

  expect_s3_class(combined_structures, "glydb_structure")
  expect_s3_class(combined_compositions, "glydb_composition")
  expect_identical(
    attr(combined_structures, "confidence"),
    c(attr(structures, "confidence")[1], NA_real_)
  )
  expect_identical(
    attr(combined_compositions, "confidence"),
    c(attr(compositions, "confidence")[1], NA_real_)
  )
})

test_that("replacement and empty slices preserve confidence classes", {
  structures <- glydb_structures()[1:3]
  compositions <- glydb_compositions()[1:3]
  structure_confidence <- attr(structures, "confidence")
  composition_confidence <- attr(compositions, "confidence")

  replaced_structures <- structures[1:2]
  replaced_structures[1] <- structures[3]
  replaced_compositions <- compositions[1:2]
  replaced_compositions[1] <- compositions[3]

  expect_identical(
    attr(replaced_structures, "confidence"),
    structure_confidence[c(3, 2)]
  )
  expect_identical(
    attr(replaced_compositions, "confidence"),
    composition_confidence[c(3, 2)]
  )

  empty_structures <- structures[0]
  empty_compositions <- compositions[0]

  expect_s3_class(empty_structures, "glydb_structure")
  expect_s3_class(empty_compositions, "glydb_composition")
  expect_length(attr(empty_structures, "confidence"), 0)
  expect_length(attr(empty_compositions, "confidence"), 0)
})

test_that("ordering and missing replacement keep confidence aligned", {
  structures <- glydb_structures()[1:4]
  compositions <- glydb_compositions()[1:4]

  sorted_structures <- sort(structures)
  sorted_compositions <- sort(compositions)

  structure_locations <- match(
    as.character(sorted_structures),
    as.character(structures)
  )
  composition_locations <- match(
    as.character(sorted_compositions),
    as.character(compositions)
  )

  expect_identical(
    attr(sorted_structures, "confidence"),
    attr(structures, "confidence")[structure_locations]
  )
  expect_identical(
    attr(sorted_compositions, "confidence"),
    attr(compositions, "confidence")[composition_locations]
  )

  structures[1] <- NA
  compositions[1] <- NA
  expect_identical(attr(structures, "confidence")[1], NA_real_)
  expect_identical(attr(compositions, "confidence")[1], NA_real_)
})

test_that("glydb subclasses remain compatible with glyrepr operations", {
  structures <- glydb_structures()[1:3]
  compositions <- glydb_compositions()[1:3]

  expect_equal(
    glyrepr::count_mono(structures, "Hex"),
    glyrepr::count_mono(strip_glydb_class(structures), "Hex")
  )
  expect_equal(
    glyrepr::count_mono(compositions, "Hex"),
    glyrepr::count_mono(strip_glydb_class(compositions), "Hex")
  )
})
