# Run each measurement in a fresh R process:
# Rscript data-raw/benchmark-index-cold.R /path/to/library index range
# Modes: baseline (old getter), getter (new getter), index (new index API).
# Cases: default, range. R process startup is excluded from both timings.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 3L)
lib <- args[[1]]
mode <- match.arg(args[[2]], c("baseline", "getter", "index"))
case <- match.arg(args[[3]], c("default", "range"))
query <- if (case == "range") {
  list(mono_range = list(Hex = c(3L, 10L), HexNAc = c(2L, 10L)))
} else {
  list()
}
load_seconds <- system.time(library(glydb, lib.loc = lib))[["elapsed"]]
fun <- if (mode == "index") glydb_structure_index else glydb_structures
call_seconds <- system.time(result <- do.call(fun, query))[["elapsed"]]
records <- if (mode == "index") length(result$active_ids) else length(result)
cat(
  paste(mode, case, load_seconds, call_seconds, records, sep = ","),
  "\n",
  sep = ""
)
