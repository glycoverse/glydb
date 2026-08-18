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
#> <glydb_composition[1678]>
#> [1] Glc(1)Gal(1)Neu5Gc(2)
#> [2] Man(3)Gal(3)GlcNAc(5)Neu5Ac(1)
#> [3] Gal(2)GlcNAc(2)Fuc(1)
#> [4] Glc(1)Gal(2)GalNAc(1)
#> [5] Man(3)Gal(3)GlcNAc(5)Fuc(3)Neu5Ac(1)
#> [6] Glc(1)Gal(3)
#> [7] Glc(1)Man(1)GlcNAc(1)GalNAc(1)
#> [8] Glc(1)Man(2)GlcNAc(1)
#> [9] Gal(2)
#> [10] Man(3)GlcNAc(3)GalNAc(1)S(1)
#> ... (1668 more not shown)
glydb_compositions(mono_type = "generic")
#> <glydb_composition[1061]>
#> [1] Hex(2)NeuGc(2)
#> [2] Hex(6)HexNAc(5)NeuAc(1)
#> [3] Hex(2)HexNAc(2)dHex(1)
#> [4] Hex(3)HexNAc(1)
#> [5] Hex(6)HexNAc(5)dHex(3)NeuAc(1)
#> [6] Hex(4)
#> [7] Hex(2)HexNAc(2)
#> [8] Hex(2)
#> [9] Hex(3)HexNAc(4)S(1)
#> [10] HexNAc(2)HexA(2)
#> ... (1051 more not shown)
glydb_compositions(species = "Homo sapiens")
#> <glydb_composition[1042]>
#> [1] Glc(1)Gal(1)Neu5Gc(2)
#> [2] Man(3)Gal(3)GlcNAc(5)Neu5Ac(1)
#> [3] Gal(2)GlcNAc(2)Fuc(1)
#> [4] Glc(1)Gal(2)GalNAc(1)
#> [5] Man(3)Gal(3)GlcNAc(5)Fuc(3)Neu5Ac(1)
#> [6] Gal(2)
#> [7] Man(3)GlcNAc(3)GalNAc(1)S(1)
#> [8] GlcNAc(2)GlcA(2)
#> [9] Glc(3)
#> [10] Glc(1)Gal(1)Fuc(1)
#> ... (1032 more not shown)
glydb_compositions(glycan_type = "N")
#> <glydb_composition[803]>
#> [1] Man(3)Gal(3)GlcNAc(5)Neu5Ac(1)
#> [2] Man(3)Gal(3)GlcNAc(5)Fuc(3)Neu5Ac(1)
#> [3] Man(3)GlcNAc(3)GalNAc(1)S(1)
#> [4] Man(3)Gal(2)GlcNAc(4)Fuc(1)Neu5Ac(1)
#> [5] Man(3)Gal(2)GlcNAc(5)Fuc(1)
#> [6] Man(3)GlcNAc(2)
#> [7] Man(3)GlcNAc(1)
#> [8] Man(5)GlcNAc(2)
#> [9] Man(4)GlcNAc(3)
#> [10] Man(3)Gal(5)GlcNAc(5)Fuc(1)Neu5Ac(1)
#> ... (793 more not shown)
glydb_compositions(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#> <glydb_composition[0]>
glydb_compositions(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#> <glydb_composition[115]>
#> [1] Man(3)GlcNAc(2)
#> [2] Man(5)GlcNAc(2)
#> [3] Man(4)GlcNAc(3)
#> [4] Man(3)GlcNAc(4)
#> [5] Gal(3)GlcNAc(2)GalNAc(1)
#> [6] Glc(1)Gal(2)GlcNAc(1)GalNAc(1)
#> [7] Gal(3)GlcNAc(3)GalNAc(2)
#> [8] Man(5)Gal(1)GlcNAc(4)
#> [9] Man(3)Gal(3)GlcNAc(6)
#> [10] Man(9)GlcNAc(2)
#> ... (105 more not shown)
```
