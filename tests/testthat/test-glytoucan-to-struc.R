test_that("glytoucan_to_struc returns parsed glycan structures in input order", {
  local_mocked_bindings(
    glygen_glycan_detail = function(glytoucan_ac) {
      switch(
        glytoucan_ac,
        G00001AA = list(iupac = "alpha-D-Manp-(1->"),
        G00002BB = list(iupac = "beta-D-GlcpNAc-(1->")
      )
    },
    .package = "glydb"
  )

  res <- glytoucan_to_struc(c("G00001AA", "G00002BB"))

  expect_s3_class(res, "glyrepr_structure")
  expect_equal(vctrs::vec_data(res), c("Man(a1-", "GlcNAc(b1-"))
})

test_that("glytoucan_to_struc returns NA and warns for unparseable glycans", {
  local_mocked_bindings(
    glygen_glycan_detail = function(glytoucan_ac) {
      switch(
        glytoucan_ac,
        G00001AA = list(iupac = "alpha-D-Manp-(1->"),
        G00002BB = list(iupac = "not-iupac"),
        G00003CC = list(iupac = "beta-D-GlcpNAc-(1->")
      )
    },
    .package = "glydb"
  )

  expect_warning(
    res <- glytoucan_to_struc(c("G00001AA", "G00002BB", "G00003CC")),
    "Failed to parse 1 GlyTouCan accession"
  )

  expect_s3_class(res, "glyrepr_structure")
  expect_equal(
    vctrs::vec_data(res),
    c("Man(a1-", NA_character_, "GlcNAc(b1-")
  )
})

test_that("glytoucan_to_struc returns NA and warns for API failures", {
  local_mocked_bindings(
    glygen_glycan_detail = function(glytoucan_ac) {
      if (identical(glytoucan_ac, "G00002BB")) {
        stop("not found")
      }

      list(iupac = "alpha-D-Manp-(1->")
    },
    .package = "glydb"
  )

  expect_warning(
    res <- glytoucan_to_struc(c("G00001AA", "G00002BB")),
    "Failed to parse 1 GlyTouCan accession"
  )

  expect_equal(vctrs::vec_data(res), c("Man(a1-", NA_character_))
})

test_that("glytoucan_to_struc validates accessions", {
  expect_error(glytoucan_to_struc(1), "character")
  expect_error(glytoucan_to_struc(c("G00001AA", NA_character_)), "missing")
})
