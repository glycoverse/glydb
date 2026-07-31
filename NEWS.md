# glydb (development version)

## New features

* `glydb_compositions()` and `glydb_structures()` now preserve their `confidence` attributes through vector operations. When identical glycans with different confidence values are combined, the maximum value is used.

# glydb 0.6.0

## New features

* `glydb_data` now contains 19,436 GlyGen glycan structures, including non-intact glycans (#9).

## Minor improvements and bug fixes

* Bundled `glydb_data` and internal structure indexes are regenerated for compatibility with `glyrepr` 0.13.0 (#13).
* `glytoucan_to_struc()` now looks up accessions from `glydb_data` first and only falls back to the online GlyGen API for missing accessions. (#10)
* `glycan_type` values now use GlyGen classifications, including HMO, GSL, GAG, GPI, and reducing-end O-linked subtypes (#12).

# glydb 0.5.0

## New features

* Add `glytoucan_to_struc()` to fetch GlyTouCan accessions from the GlyGen API and parse returned IUPAC strings into glycan structures (#7).

## Minor improvements and bug fixes

* Update internal data to use the GlyTouCan v2.11.1 release.

# glydb 0.4.1

## Minor improvements and bug fixes

* Update documentation to correctly reflect data version.

# glydb 0.4.0

## New features

* Add a `mono_range` parameter to `glydb_compositions()` and `glydb_structures()`.
* `glydb_compositions()` and `glydb_structures()` now return a vector with a `confidence` attribute, readily used by the `glyanno` package to rank the results.
* `glydb_data` now has new `confidence` column.

# glydb 0.3.3

## Minor improvements and bug fixes

* Update internal data to use GlyGen Datasets v2.10.1.

# glydb 0.3.2

## Minor improvements and bug fixes

* Adapt to glyrepr 0.10.0.

# glydb 0.3.1

## Minor improvements and bug fixes

* glydb now depends on CRAN version of glyrepr 0.9.0.

# glydb 0.3.0

## New features

* Add a `glycan_type` column to `glydb_data`. Can be "N", "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc".
* Add a `glycan_type` parameter to `glydb_compositions()` and `glydb_structures()`. 

# glydb 0.2.1

## Minor improvements and bug fixes

* Fix the bug that `glydb_species()` fails when the package is used via `glydb::fun` and not attached with `library(glydb)`.

# glydb 0.2.0

## Breaking changes

* Remove the `topology_glycans` dataset.
* Rename the `fully_determined_glycans` dataset to `glydb_data`.

## New features

* Add `glydb_species()` to get the species names from `glydb_data`.
* Add `glydb_compositions()` to get the glycan compositions from `glydb_data` with different monosaccharide types.
* Add `glydb_structures()` to get the glycan structures from `glydb_data` with different structure levels.

## Minor improvements and bug fixes

* Update the documentation of `glydb_data` to explain the duplicate glycan structures in the dataset.

# glydb 0.1.1

## Minor improvements and bug fixes

* Update the `topology_glycans` dataset to remove some duplicates.

# glydb 0.1.0

* Initial Github release.
