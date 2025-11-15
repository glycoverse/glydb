# Changelog

## glydb (development version)

## glydb 0.2.0

### Breaking changes

- Remove the `topology_glycans` dataset.
- Rename the `fully_determined_glycans` dataset to `glydb_data`.

### New features

- Add
  [`glydb_species()`](https://glycoverse.github.io/glydb/reference/glydb_species.md)
  to get the species names from `glydb_data`.
- Add
  [`glydb_compositions()`](https://glycoverse.github.io/glydb/reference/glydb_compositions.md)
  to get the glycan compositions from `glydb_data` with different
  monosaccharide types.
- Add
  [`glydb_structures()`](https://glycoverse.github.io/glydb/reference/glydb_structures.md)
  to get the glycan structures from `glydb_data` with different
  structure levels.

### Minor improvements and bug fixes

- Update the documentation of `glydb_data` to explain the duplicate
  glycan structures in the dataset.

## glydb 0.1.1

### Minor improvements and bug fixes

- Update the `topology_glycans` dataset to remove some duplicates.

## glydb 0.1.0

- Initial Github release.
