glygen_test_response <- function(iupac) {
  httr2::response(
    method = "POST",
    headers = list("Content-Type" = "application/json"),
    body = charToRaw(sprintf('{"iupac":"%s"}', iupac))
  )
}

glygen_test_raw_response <- function(body, status_code = 200) {
  httr2::response(
    status_code = status_code,
    method = "POST",
    headers = list("Content-Type" = "application/json"),
    body = charToRaw(body)
  )
}

test_that("glytoucan_to_struc returns parsed glycan structures in input order", {
  local_mocked_bindings(
    req_perform_parallel = function(reqs, on_error, progress, ...) {
      list(
        glygen_test_response("alpha-D-Manp-(1->"),
        glygen_test_response("beta-D-GlcpNAc-(1->")
      )
    },
    .package = "httr2"
  )

  res <- glytoucan_to_struc(c("G00001AA", "G00002BB"))

  expect_s3_class(res, "glyrepr_structure")
  expect_equal(vctrs::vec_data(res), c("Man(a1-", "GlcNAc(b1-"))
})

test_that("glytoucan_to_struc performs GlyGen detail requests in parallel", {
  parallel_call_count <- 0L
  request_urls <- character()
  request_methods <- character()

  local_mocked_bindings(
    req_perform_parallel = function(reqs, on_error, progress, ...) {
      parallel_call_count <<- parallel_call_count + 1L
      request_urls <<- purrr::map_chr(reqs, "url")
      request_methods <<- purrr::map_chr(reqs, "method")

      expect_equal(on_error, "continue")
      expect_false(progress)

      list(
        glygen_test_response("alpha-D-Manp-(1->"),
        glygen_test_response("beta-D-GlcpNAc-(1->")
      )
    },
    .package = "httr2"
  )

  res <- glytoucan_to_struc(c("G00001AA", "G00002BB"))

  expect_equal(parallel_call_count, 1L)
  expect_equal(request_methods, c("POST", "POST"))
  expect_equal(
    request_urls,
    c(
      "https://api.glygen.org/glycan/detail/G00001AA/",
      "https://api.glygen.org/glycan/detail/G00002BB/"
    )
  )
  expect_equal(vctrs::vec_data(res), c("Man(a1-", "GlcNAc(b1-"))
})

test_that("glytoucan_to_struc uses glydb_data before GlyGen fallback", {
  local_accession <- glydb_data$glytoucan_ac[[1]]
  local_structure <- glydb_data$glycan_structure[1]
  parallel_call_count <- 0L
  request_urls <- character()

  local_mocked_bindings(
    req_perform_parallel = function(reqs, on_error, progress, ...) {
      parallel_call_count <<- parallel_call_count + 1L
      request_urls <<- purrr::map_chr(reqs, "url")

      purrr::map(reqs, ~ glygen_test_response("alpha-D-Manp-(1->"))
    },
    .package = "httr2"
  )

  res <- glytoucan_to_struc(c("G00001AA", local_accession))

  expect_equal(parallel_call_count, 1L)
  expect_equal(
    request_urls,
    "https://api.glygen.org/glycan/detail/G00001AA/"
  )
  expect_equal(vctrs::vec_data(res[1]), "Man(a1-")
  expect_equal(res[2], local_structure)
})

test_that("glytoucan_to_struc does not request accessions present in glydb_data", {
  local_accessions <- glydb_data$glytoucan_ac[1:2]
  parallel_call_count <- 0L

  local_mocked_bindings(
    req_perform_parallel = function(reqs, on_error, progress, ...) {
      parallel_call_count <<- parallel_call_count + 1L
      purrr::map(reqs, ~ glygen_test_response("alpha-D-Manp-(1->"))
    },
    .package = "httr2"
  )

  res <- glytoucan_to_struc(local_accessions)

  expect_equal(parallel_call_count, 0L)
  expect_equal(res, glydb_data$glycan_structure[1:2])
})

test_that("glytoucan_to_struc returns NA and warns for unparseable glycans", {
  local_mocked_bindings(
    req_perform_parallel = function(reqs, on_error, progress, ...) {
      list(
        glygen_test_response("alpha-D-Manp-(1->"),
        glygen_test_response("not-iupac"),
        glygen_test_response("beta-D-GlcpNAc-(1->")
      )
    },
    .package = "httr2"
  )

  expect_warning(
    res <- glytoucan_to_struc(c("G00001AA", "G00002BB", "G00003CC")),
    "Failed to fetch or parse 1 GlyTouCan accession"
  )

  expect_s3_class(res, "glyrepr_structure")
  expect_equal(
    vctrs::vec_data(res),
    c("Man(a1-", NA_character_, "GlcNAc(b1-")
  )
})

test_that("glytoucan_to_struc returns NA and warns for API failures", {
  local_mocked_bindings(
    req_perform_parallel = function(reqs, on_error, progress, ...) {
      expect_equal(on_error, "continue")

      list(
        glygen_test_response("alpha-D-Manp-(1->"),
        errorCondition("not found"),
        glygen_test_response("beta-D-GlcpNAc-(1->")
      )
    },
    .package = "httr2"
  )

  expect_warning(
    res <- glytoucan_to_struc(c("G00001AA", "G00002BB", "G00003CC")),
    "Failed to fetch or parse 1 GlyTouCan accession"
  )

  expect_equal(
    vctrs::vec_data(res),
    c("Man(a1-", NA_character_, "GlcNAc(b1-")
  )
})

test_that("glytoucan_to_struc preserves positions for HTTP and JSON response failures", {
  local_mocked_bindings(
    req_perform_parallel = function(reqs, on_error, progress, ...) {
      list(
        glygen_test_response("alpha-D-Manp-(1->"),
        glygen_test_raw_response("server error", status_code = 500),
        glygen_test_raw_response("{invalid json"),
        glygen_test_response("beta-D-GlcpNAc-(1->")
      )
    },
    .package = "httr2"
  )

  expect_warning(
    res <- glytoucan_to_struc(c(
      "G00001AA",
      "G00002BB",
      "G00003CC",
      "G00004DD"
    )),
    "Failed to fetch or parse 2 GlyTouCan accessions"
  )

  expect_equal(
    vctrs::vec_data(res),
    c("Man(a1-", NA_character_, NA_character_, "GlcNAc(b1-")
  )
})

test_that("glytoucan_to_struc validates accessions", {
  expect_error(glytoucan_to_struc(1), "character")
  expect_error(glytoucan_to_struc(c("G00001AA", NA_character_)), "missing")
})
