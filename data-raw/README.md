# GlyGen source data

The bundled data are built from the fixed GlyGen **2.12.1** release, downloaded
on 2026-10-13 from:

https://data.glygen.org/ln2data/releases/data/v-2.12.1/reviewed/

Do not use the mutable `current` directory when reproducing this build. Download
the following files into `data-raw/` using the local filenames below. Raw CSVs
remain untracked, as configured in `.gitignore`.

| Remote filename | Local filename | Rows | SHA-256 |
| --- | --- | ---: | --- |
| `glycan_sequences_wurcs.csv` | `glycan_sequences_wurcs_v2_12_1.csv` | 59,994 | `084f1efa9bb1623629250e7c9c07f045505c0d1ccaed0ac7c4bb8e42852933b3` |
| `glycan_species.csv` | `glycan_species_v2_12_1.csv` | 242,803 | `1640f1e98c8430a46f42f5525631cd7bf7b2008134e975f5a43477c814d71fd0` |
| `glycan_citations_glytoucan.csv` | `glycan_citations_glytoucan_v2_12_1.csv` | 27,857 | `0ec6a0da5b451d78cfa5932a514bb7b7a6121c37851eaa864c67b8e02bc78f6f` |
| `glycan_classification.csv` | `glycan_classification_v2_12_1.csv` | 110,401 | `84d7e8e6ff16383f6275e0fc9b7cbdb483f201787cbf8e909117e0b495aa5fbd` |

Run `source("data-raw/glydb_data.R")` from the package root, then run
`source("data-raw/internal_data.R")` to regenerate both the public data and all
internal indexes. Update the dataset documentation and run the package tests
and `R CMD check` after rebuilding.

The preparation rules are unchanged: WURCS parse failures are omitted, species
are combined per accession, confidence is the logarithm of the number of raw
citation rows (or -1 when absent), and GlyGen classifications use the existing
O-glycan reducing-end subtype rules. C-linked classifications are excluded.

## Build environment

This update was rebuilt with R 4.5.0, dplyr 1.2.1, vctrs 0.7.3,
and the following dependency commits:

- glyrepr 1.1.0.9000: `2d928e2a64ee4631622219fb97d698134900311a`
- glyparse 0.8.1.9000: `17b604ac1134b5af0cc22ee142318370f52d3ad4`

The source-data release and parser versions are recorded separately because
parser changes can affect which WURCS sequences are retained.

## Data checks for 2.12.1

- 59,994 WURCS input rows yielded 49,728 retained structures; 10,266 parse
  failures were omitted by the existing `on_failure = "na"` rule.
- All 49,019 previously bundled accessions were retained, and 709 were added.
- Among retained old accessions, 77 structure strings changed. All 77 also have
  changed WURCS sequences in the fixed 2.11.1 versus 2.12.1 source files; their
  compositions are unchanged. Species changed for 1,458 old accessions,
  confidence for 390, and classification for 2,085.
- Retained data have unique, nonmissing accessions and no missing parsed
  structures or compositions. Confidence values match the source citation-row
  counts exactly. Species are missing for 22,912 rows and classification for
  8,898 rows; these are allowed missing metadata, not missing accessions.
- The parser emitted its existing warning that non-root alditol residues are
  parsed as regular residues; the build uses the parser's default behavior.
