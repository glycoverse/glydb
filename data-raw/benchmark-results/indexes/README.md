# Precomputed annotation indexes: validation and timings

Date: 2026-09-29. Implementation: `01324c6c5f689b06b22f5ffbf8f4123d7c0ad3a6`.
Baseline getter implementation: `31204ef2696a0dcbb76f020feee1c09522cd1cc7`.

## Validation

- `R CMD check` completed with status OK: zero errors, warnings, or notes.
  Its test run passed 1,060 expectations, with no failures, warnings, or skips.
  The check used `cran = FALSE` and `--no-manual`.
  See [check.log](check.log) and [tests.log](tests.log).
- All 18 combinations of resolution and filter scenario retained the baseline
  candidate strings, order, and confidence values. Selecting `active_ids` from
  each index also reproduced the corresponding getter output.
- All six original internal tables retained their glycan strings and metadata;
  see [table-parity.csv](table-parity.csv).
- All 32,168 structure records across four views retained their graph edges,
  direction, vertex attributes, edge attributes, and graph attributes. See
  [graph-parity.csv](graph-parity.csv). Graph environments and external pointers
  were excluded from comparisons.
- Tests independently checked component counts, candidate maps, confidence
  ranks, canonical structure keys, floating flags, and filtering. They also
  replaced database-conversion/counting functions with errors to verify that
  index and getter queries do not call them.
- Structure keys use canonicalization under `LC_COLLATE = "C"`. Original
  returned structure strings and record order are preserved.

## Repeated calls

The old getter bodies and new APIs ran against the same unchanged bundled
tables and installed dependencies. Each query first passed parity checks,
which also warmed the data. Three repetitions interleaved the implementations
in seeded random order, with garbage collection before each measurement.
The candidate package was loaded from an isolated installed library.

The range scenario uses:

```r
mono_range = list(Hex = c(3L, 10L), HexNAc = c(2L, 10L))
```

Selected median elapsed times:

| View and scenario | Old getter | New getter | New index API |
|---|---:|---:|---:|
| Concrete compositions, range | 1.126 s | 0.008 s | <0.001 s |
| Concrete intact structures, range | 7.439 s | 0.021 s | 0.002 s |
| Concrete topological structures, range | 7.867 s | 0.020 s | 0.001 s |
| Generic intact structures, range | 1.791 s | 0.019 s | 0.002 s |
| Generic topological structures, range | 1.603 s | 0.018 s | 0.001 s |

Index timings return the full precomputed view plus selected record IDs;
getter timings include producing the filtered glycan vector. Index timings
exclude subsequently materializing that filtered vector. Zero-valued readings
in the raw measurements indicate the timer's millisecond resolution.

Small species-only composition queries measured 6 to 9 ms for concrete
compositions and 4 to 7 ms for generic compositions (old to new getter).
Full results are in [medians.csv](medians.csv), with all 162 individual
measurements in [timings.csv](timings.csv).

## First call in a fresh R process

Three fresh processes per implementation and scenario were run in seeded
random order against separate baseline and candidate installations. Package
loading and the first query were timed separately. R process startup was
excluded, and OS filesystem caches were not cleared.

Median query times, including the first lazy load of the selected view:

| Concrete intact query | Old getter | New getter | New index API | Selected records |
|---|---:|---:|---:|---:|
| Default | 0.291 s | 0.386 s | 0.386 s | 8,573 |
| Range | 7.477 s | 0.499 s | 0.425 s | 1,297 |

Median package loading took approximately 0.24 s in each group, in addition
to the query times. The new default query loads more prepared data and took
about 95 ms longer on its first call. See all 18 observations in
[cold-timings.csv](cold-timings.csv).

These measurements cover glydb database access only. Integration with glyanno
and end-to-end annotation timing remain future work. The indexes add about
4 MB to the installed package (approximately 31 MB to 34.9 MB).

## Reproduction

Install the implementation and baseline revisions above in separate R
libraries while keeping dependencies matched. Use the companion scripts from
this checkout. The recorded run used
glyrepr 1.1.0.9000. [metadata.rds](metadata.rds) records the session, seed,
commits, and candidate source/data MD5 checksums.

From the package root, run:

```sh
Rscript data-raw/benchmark-indexes.R /path/to/candidate-library
Rscript data-raw/benchmark-index-cold.R /path/to/baseline-library baseline range
Rscript data-raw/benchmark-index-cold.R /path/to/candidate-library getter range
Rscript data-raw/benchmark-index-cold.R /path/to/candidate-library index range
Rscript data-raw/audit-index-graphs.R /path/to/baseline/R/sysdata.rda /path/to/candidate-library
```

For cold measurements, also use `default` in place of `range`, repeating each
combination three times in the order recorded in the CSV. The warm benchmark
automatically records all repetitions. [parity-signatures.rds](parity-signatures.rds)
preserves candidate strings and confidence vectors for each tested query.

Regenerate bundled indexes separately with
`Rscript data-raw/annotation-indexes.R`. This offline generation is not run
during package installation, loading, or queries.
