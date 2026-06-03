# Get Compositions From Glydb Data

Get unique glycan compositions from
[glydb_data](https://glycoverse.github.io/glydb/dev/reference/glydb_data.md)
as a
[`glyrepr::glycan_composition()`](https://glycoverse.github.io/glyrepr/reference/glycan_composition.html)
vector.

## Usage

``` r
glydb_compositions(
  mono_type = "concrete",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL
)
```

## Arguments

- mono_type:

  Either "generic" or "concrete". Default is "concrete". See
  [`glyrepr::get_mono_type()`](https://glycoverse.github.io/glyrepr/reference/get_mono_type.html)
  for details.

- species:

  A string of specie names. See
  [`glydb_species()`](https://glycoverse.github.io/glydb/dev/reference/glydb_species.md)
  for available specie names. Default is NULL, which means glycans from
  all species are included.

- glycan_type:

  A string of glycan types. Can be "N", "O-GalNAc", "O-GlcNAc", "O-Man",
  "O-Fuc", "O-Glc". Default is NULL, which means glycans of all types
  are included.

- mono_range:

  A named list for filtering compositions by monosaccharide counts. Each
  element should be an integer vector of length 2 specifying the minimum
  and maximum count for that monosaccharide. Monosaccharides not
  specified will be excluded (count = 0). Use `NULL` for no filtering.
  See examples for usage.

## Value

A
[`glyrepr::glycan_composition()`](https://glycoverse.github.io/glyrepr/reference/glycan_composition.html)
vector, with a `confidence` attribute as a numeric vector with the same
length.

## Confidence

The returned value has a `confidence` attribute: a numeric vector of the
same length as the result containing log-transformed citation counts for
each glycan in `glydb_data`. When multiple glycans are aggregated into
lower-resolution structures or compositions, the maximum confidence
score is retained.

Note that the `confidence` attribute will be lost after any vector
operation like subsetting. Therefore, if used with `glyanno`, the
returned value should not be modified manually.

## Examples

``` r
glydb_compositions()
#> <glycan_composition[1073]>
#> [1] Glc(3)
#> [2] Glc(4)
#> [3] Man(3)GlcNAc(1)
#> [4] Gal(1)GlcNAc(1)GalNAc(2)Fuc(1)Neu5Gc(1)
#> [5] Gal(1)GalNAc(1)
#> [6] Gal(1)GlcNAc(1)GalNAc(1)
#> [7] GlcNAc(1)GalNAc(1)
#> [8] GlcNAc(2)GalNAc(1)
#> [9] GalNAc(2)
#> [10] Gal(1)GlcNAc(1)Fuc(2)
#> ... (1063 more not shown)
glydb_compositions(mono_type = "generic")
#> <glycan_composition[653]>
#> [1] Hex(3)
#> [2] Hex(4)
#> [3] Hex(3)HexNAc(1)
#> [4] Hex(1)HexNAc(3)dHex(1)NeuGc(1)
#> [5] Hex(1)HexNAc(1)
#> [6] Hex(1)HexNAc(2)
#> [7] HexNAc(2)
#> [8] HexNAc(3)
#> [9] Hex(1)HexNAc(1)dHex(2)
#> [10] Hex(3)HexNAc(1)dHex(1)
#> ... (643 more not shown)
glydb_compositions(species = "Homo sapiens")
#> <glycan_composition[537]>
#> [1] Glc(4)
#> [2] Man(3)GlcNAc(1)
#> [3] Gal(1)GalNAc(1)
#> [4] Gal(1)GlcNAc(1)GalNAc(1)
#> [5] GlcNAc(1)GalNAc(1)
#> [6] GlcNAc(2)GalNAc(1)
#> [7] GalNAc(2)
#> [8] Gal(1)GlcNAc(1)Fuc(2)
#> [9] Glc(1)Gal(2)GlcNAc(1)
#> [10] Glc(1)Gal(2)GlcNAc(1)Fuc(1)
#> ... (527 more not shown)
glydb_compositions(glycan_type = "N")
#> <glycan_composition[476]>
#> [1] Man(3)GlcNAc(6)Fuc(1)
#> [2] Man(2)Gal(1)GlcNAc(3)Fuc(2)
#> [3] Man(3)Gal(2)GlcNAc(4)Neu5Ac(3)
#> [4] Man(6)GlcNAc(2)
#> [5] Man(6)GlcNAc(3)
#> [6] Man(3)Gal(3)GlcNAc(5)Fuc(1)Neu5Gc(1)
#> [7] Man(2)GlcNAc(2)Fuc(1)
#> [8] Man(3)Gal(3)GlcNAc(5)Neu5Ac(2)
#> [9] Man(2)GlcNAc(3)
#> [10] Man(3)GlcNAc(7)Fuc(1)
#> ... (466 more not shown)
glydb_compositions(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#> <glycan_composition[0]>
glydb_compositions(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#> <glycan_composition[105]>
#> [1] Glc(1)Gal(2)GlcNAc(1)GalNAc(1)
#> [2] Man(6)GlcNAc(2)
#> [3] Man(6)GlcNAc(3)
#> [4] Man(4)GlcNAc(2)
#> [5] Gal(5)GlcNAc(5)
#> [6] Man(9)GlcNAc(2)
#> [7] Glc(1)Man(8)GlcNAc(2)
#> [8] Man(3)Gal(2)GlcNAc(4)
#> [9] Man(2)Gal(2)GlcNAc(2)
#> [10] Man(3)GlcNAc(5)
#> ... (95 more not shown)
```
