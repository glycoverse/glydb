# Run from the package root after regenerating indexes.
# Results include raw paired timings, parity signatures, and session metadata.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0L) {
  devtools::load_all(quiet = TRUE)
} else {
  # Supply an isolated installed-library directory to include lazy-data behavior.
  library(glydb, lib.loc = args[[1]])
}
baseline_commit <- "31204ef2696a0dcbb76f020feee1c09522cd1cc7"
output_dir <- "data-raw/benchmark-results/indexes"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
legacy_file <- tempfile(fileext = ".R")
legacy_source <- system2(
  "git",
  c("show", paste0(baseline_commit, ":R/getter.R")),
  stdout = TRUE
)
stopifnot(is.null(attr(legacy_source, "status")))
writeLines(legacy_source, legacy_file)
legacy <- new.env(parent = asNamespace("glydb"))
sys.source(legacy_file, envir = legacy)
unlink(legacy_file)

filters <- list(
  default = list(),
  species = list(species = "Homo sapiens", glycan_type = "N"),
  range = list(mono_range = list(Hex = c(3L, 10L), HexNAc = c(2L, 10L)))
)
signature <- function(x) {
  list(keys = as.character(x), confidence = attr(x, "confidence"))
}
timings <- list()
signatures <- list()
set.seed(20260929)
for (mono_type in c("concrete", "generic")) {
  for (level in c("composition", "intact", "topological")) {
    is_composition <- level == "composition"
    getter <- if (is_composition) glydb_compositions else glydb_structures
    index_getter <- if (is_composition) {
      glydb_composition_index
    } else {
      glydb_structure_index
    }
    old_getter <- if (is_composition) {
      legacy$glydb_compositions
    } else {
      legacy$glydb_structures
    }
    args <- list(mono_type = mono_type)
    if (!is_composition) {
      args$structure_level <- level
    }
    for (case in names(filters)) {
      query <- c(args, filters[[case]])
      case_name <- paste(mono_type, level, case, sep = "/")
      message(case_name)
      expected <- signature(do.call(old_getter, query))
      actual <- signature(do.call(getter, query))
      index <- do.call(index_getter, query)
      stopifnot(
        identical(expected, actual),
        identical(expected, signature(index$glycans[index$active_ids]))
      )
      signatures[[case_name]] <- expected
      functions <- list(
        baseline = old_getter,
        getter = getter,
        index = index_getter
      )
      for (iteration in seq_len(3)) {
        for (implementation in sample(names(functions))) {
          gc()
          elapsed <- system.time(do.call(functions[[implementation]], query))[[
            "elapsed"
          ]]
          timings[[length(timings) + 1L]] <- data.frame(
            case = case_name,
            iteration = iteration,
            implementation = implementation,
            seconds = elapsed
          )
        }
      }
    }
  }
}
timings <- do.call(rbind, timings)
write.csv(timings, file.path(output_dir, "timings.csv"), row.names = FALSE)
saveRDS(signatures, file.path(output_dir, "parity-signatures.rds"))
metadata <- list(
  baseline_commit = baseline_commit,
  current_commit = system2("git", c("rev-parse", "HEAD"), stdout = TRUE),
  source_md5 = tools::md5sum(c("R/index.R", "R/getter.R", "R/sysdata.rda")),
  seed = 20260929L,
  session = utils::sessionInfo(),
  system = Sys.info()[c("sysname", "release", "machine")]
)
saveRDS(metadata, file.path(output_dir, "metadata.rds"))
summary <- aggregate(seconds ~ case + implementation, timings, median)
write.csv(summary, file.path(output_dir, "medians.csv"), row.names = FALSE)
print(summary, row.names = FALSE)
