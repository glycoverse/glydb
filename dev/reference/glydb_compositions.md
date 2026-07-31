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

  A string of glycan types. Can be "HMO", "N", "GSL", "GAG", "O",
  "O-GalNAc", "O-GlcNAc", "O-Man", "O-Fuc", "O-Glc", or "GPI". When "O",
  all O-linked glycans are included. Specific O-glycan types only
  include that subtype. Default is NULL, which means glycans of all
  types are included.

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

The `confidence` attribute is preserved by vector operations that
subset, reorder, repeat, combine, or replace glycans. When vectors
containing the same glycan with different confidence values are
combined, the maximum confidence is used for every occurrence of that
glycan.

## Examples

``` r
glydb_compositions()
#> <glydb_composition[1287]>
#> [1] Glc(1)Gal(1)Neu5Gc(2)
#> [2] Man(3)Gal(3)GlcNAc(5)Neu5Ac(1)
#> [3] Glc(3)
#> [4] Glc(4)
#> [5] Man(3)GlcNAc(1)
#> [6] Man(4)GlcNAc(3)
#> [7] Man(3)Gal(5)GlcNAc(5)Fuc(1)Neu5Ac(1)
#> [8] Gal(1)GlcNAc(1)GalNAc(2)Fuc(1)Neu5Gc(1)
#> [9] Gal(1)GalNAc(1)
#> [10] Gal(1)GlcNAc(1)GalNAc(1)
#> ... (1277 more not shown)
glydb_compositions(mono_type = "generic")
#> <glydb_composition[791]>
#> [1] Hex(2)NeuGc(2)
#> [2] Hex(6)HexNAc(5)NeuAc(1)
#> [3] Hex(3)
#> [4] Hex(4)
#> [5] Hex(3)HexNAc(1)
#> [6] Hex(4)HexNAc(3)
#> [7] Hex(8)HexNAc(5)dHex(1)NeuAc(1)
#> [8] Hex(1)HexNAc(3)dHex(1)NeuGc(1)
#> [9] Hex(1)HexNAc(1)
#> [10] Hex(1)HexNAc(2)
#> ... (781 more not shown)
glydb_compositions(species = "Homo sapiens")
#> <glydb_composition[744]>
#> [1] Glc(1)Gal(1)Neu5Gc(2)
#> [2] Man(3)Gal(3)GlcNAc(5)Neu5Ac(1)
#> [3] Glc(4)
#> [4] Man(3)GlcNAc(1)
#> [5] Man(4)GlcNAc(3)
#> [6] Man(3)Gal(5)GlcNAc(5)Fuc(1)Neu5Ac(1)
#> [7] Gal(1)GalNAc(1)
#> [8] Gal(1)GlcNAc(1)GalNAc(1)
#> [9] GlcNAc(1)GalNAc(1)
#> [10] GlcNAc(2)GalNAc(1)
#> ... (734 more not shown)
glydb_compositions(glycan_type = "N")
#> <glydb_composition[644]>
#> [1] Man(3)Gal(3)GlcNAc(5)Neu5Ac(1)
#> [2] Man(3)GlcNAc(1)
#> [3] Man(4)GlcNAc(3)
#> [4] Man(3)Gal(5)GlcNAc(5)Fuc(1)Neu5Ac(1)
#> [5] Man(3)Gal(3)GlcNAc(5)Fuc(1)
#> [6] Man(3)Gal(1)GlcNAc(3)Fuc(1)Neu5Ac(1)
#> [7] Man(2)GlcNAc(2)
#> [8] Man(3)Gal(2)GlcNAc(5)GalNAc(1)Fuc(1)
#> [9] Man(3)GlcNAc(6)Fuc(1)
#> [10] Man(3)Gal(3)GlcNAc(4)Fuc(1)
#> ... (634 more not shown)
glydb_compositions(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#> <glydb_composition[0]>
glydb_compositions(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#> <glydb_composition[108]>
#> [1] Man(4)GlcNAc(3)
#> [2] Glc(1)Gal(2)GlcNAc(1)GalNAc(1)
#> [3] Man(5)Gal(1)GlcNAc(4)
#> [4] Glc(1)Gal(4)GlcNAc(2)
#> [5] Man(3)GlcNAc(5)GalNAc(1)
#> [6] Man(5)Gal(1)GlcNAc(3)
#> [7] Glc(1)Gal(3)GlcNAc(1)GalNAc(1)
#> [8] Man(6)GlcNAc(2)
#> [9] Glc(1)Gal(4)GlcNAc(3)
#> [10] Man(6)GlcNAc(3)
#> ... (98 more not shown)
```
