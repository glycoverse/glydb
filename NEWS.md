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
