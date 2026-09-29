# Compare bundled graph contents with a frozen baseline sysdata.rda.
# Rscript data-raw/audit-index-graphs.R baseline/R/sysdata.rda /installed/library
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 2L)
library(glydb, lib.loc = args[[2]])
baseline <- new.env(parent = emptyenv())
load(args[[1]], envir = baseline)
check_table <- function(original, index, column) {
  stopifnot(
    identical(as.character(original[[column]]), as.character(index$glycans)),
    identical(original$confidence, index$confidence),
    identical(original$species, index$species),
    identical(original$glycan_type, index$glycan_type)
  )
  data.frame(
    view = index$view,
    records = nrow(original),
    matched = nrow(original)
  )
}
tables <- list()
for (mono_type in c("concrete", "generic")) {
  index <- glydb_composition_index(mono_type)
  tables[[index$view]] <- check_table(
    baseline[[paste0(mono_type, "_comps")]],
    index,
    "glycan_composition"
  )
}
graph_signature <- function(graph) {
  list(
    edges = igraph::as_edgelist(graph, names = FALSE),
    directed = igraph::is_directed(graph),
    vertex_attributes = igraph::vertex_attr(graph),
    edge_attributes = igraph::edge_attr(graph),
    graph_attributes = igraph::graph_attr(graph)
  )
}
results <- list()
for (level in c("intact", "topological")) {
  for (mono_type in c("concrete", "generic")) {
    name <- paste(level, mono_type, "strucs", sep = "_")
    original <- baseline[[name]]
    index <- glydb_structure_index(level, mono_type)
    tables[[index$view]] <- check_table(original, index, "glycan_structure")
    before <- as.list(original$glycan_structure)
    after <- as.list(index$glycans)
    equal <- vapply(
      seq_along(before),
      function(i) {
        identical(graph_signature(before[[i]]), graph_signature(after[[i]]))
      },
      logical(1)
    )
    stopifnot(all(equal))
    results[[name]] <- data.frame(
      view = index$view,
      records = length(equal),
      matched = sum(equal)
    )
  }
}
results <- do.call(rbind, results)
output_dir <- "data-raw/benchmark-results/indexes"
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
write.csv(results, file.path(output_dir, "graph-parity.csv"), row.names = FALSE)
write.csv(
  do.call(rbind, tables),
  file.path(output_dir, "table-parity.csv"),
  row.names = FALSE
)
print(results, row.names = FALSE)
