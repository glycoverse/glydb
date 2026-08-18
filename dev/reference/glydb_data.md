# GlyGen Glycan Data

A curated dataset glycan structures from GlyGen Data v2.11.1, with
49,019 glycan structures currently available.

## Usage

``` r
glydb_data
```

## Format

A tibble with 49,019 rows and 6 variables:

- `glytoucan_ac`: GlyTouCan accession.

- `glycan_structure`: Glycan structure (glyrepr::glycan_structure()).

- `glycan_composition`: Glycan composition
  (glyrepr::glycan_composition()).

- `species`: Specie names, separated by semicolons. Unknown species are
  NAs.

- `glycan_type`: Glycan type, such as "HMO", "N", "GSL", "GAG", "O",
  "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc", or "GPI".

- `confidence`: Confidence score used to rank glycans.

## Source

<https://data.glygen.org>
