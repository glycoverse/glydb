# Get Structures From Glydb Data

Get unique glycan structures from
[glydb_data](https://glycoverse.github.io/glydb/reference/glydb_data.md)
as a
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
vector.

## Usage

``` r
glydb_structures(
  structure_level = "intact",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL
)
```

## Arguments

- structure_level:

  Either "intact", "topological", or "basic". Default is "intact". See
  [`glyrepr::get_structure_level()`](https://glycoverse.github.io/glyrepr/reference/get_structure_level.html)
  for details.

- species:

  A string of specie names. See
  [`glydb_species()`](https://glycoverse.github.io/glydb/reference/glydb_species.md)
  for available specie names. Default is NULL, which means glycans from
  all species are included.

- glycan_type:

  A string of glycan types. Can be "N", "O-GalNAc", "O-GlcNAc", "O-Man",
  "O-Fuc", "O-Glc". Default is NULL, which means glycans of all types
  are included.

- mono_range:

  A named list for filtering structures by monosaccharide counts. Each
  element should be an integer vector of length 2 specifying the minimum
  and maximum count for that monosaccharide. Monosaccharides not
  specified will be excluded (count = 0). Use `NULL` for no filtering.
  See examples for usage.

## Value

A
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
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
glydb_structures()
#> <glycan_structure[7074]>
#> [1] Glc(b1-3)Glc(b1-3)Glc(b1-
#> [2] Glc(b1-4)Glc(b1-4)Glc(b1-4)Glc(b1-
#> [3] Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-
#> [4] Fuc(a1-2)[GalNAc(a1-3)]Gal(b1-4)GlcNAc(b1-3)[Neu5Gc(a2-6)]GalNAc(a1-
#> [5] Gal(b1-3)GalNAc(a1-
#> [6] Gal(b1-3)[GlcNAc(b1-6)]GalNAc(a1-
#> [7] GlcNAc(b1-3)GalNAc(a1-
#> [8] GlcNAc(b1-3)[GlcNAc(b1-6)]GalNAc(a1-
#> [9] GalNAc(a1-3)GalNAc(a1-
#> [10] GlcNAc(b1-6)GalNAc(a1-
#> ... (7064 more not shown)
#> # Unique structures: 7074
glydb_structures(structure_level = "topological")
#> <glycan_structure[2675]>
#> [1] Glc(??-?)Glc(??-?)Glc(??-
#> [2] Glc(??-?)Glc(??-?)Glc(??-?)Glc(??-
#> [3] Man(??-?)[Man(??-?)]Man(??-?)GlcNAc(??-
#> [4] GalNAc(??-?)[Fuc(??-?)]Gal(??-?)GlcNAc(??-?)[Neu5Gc(??-?)]GalNAc(??-
#> [5] Gal(??-?)GalNAc(??-
#> [6] GlcNAc(??-?)[Gal(??-?)]GalNAc(??-
#> [7] GlcNAc(??-?)GalNAc(??-
#> [8] GlcNAc(??-?)[GlcNAc(??-?)]GalNAc(??-
#> [9] GalNAc(??-?)GalNAc(??-
#> [10] Fuc(??-?)Gal(??-?)[Fuc(??-?)]GlcNAc(??-
#> ... (2665 more not shown)
#> # Unique structures: 2675
glydb_structures(structure_level = "basic")
#> <glycan_structure[2278]>
#> [1] Hex(??-?)Hex(??-?)Hex(??-
#> [2] Hex(??-?)Hex(??-?)Hex(??-?)Hex(??-
#> [3] Hex(??-?)[Hex(??-?)]Hex(??-?)HexNAc(??-
#> [4] HexNAc(??-?)[dHex(??-?)]Hex(??-?)HexNAc(??-?)[NeuGc(??-?)]HexNAc(??-
#> [5] Hex(??-?)HexNAc(??-
#> [6] HexNAc(??-?)[Hex(??-?)]HexNAc(??-
#> [7] HexNAc(??-?)HexNAc(??-
#> [8] HexNAc(??-?)[HexNAc(??-?)]HexNAc(??-
#> [9] dHex(??-?)Hex(??-?)[dHex(??-?)]HexNAc(??-
#> [10] Hex(??-?)HexNAc(??-?)Hex(??-?)Hex(??-
#> ... (2268 more not shown)
#> # Unique structures: 2278
glydb_structures(species = "Homo sapiens")
#> <glycan_structure[1363]>
#> [1] Gal(b1-3)GalNAc(a1-
#> [2] Gal(b1-3)[GlcNAc(b1-6)]GalNAc(a1-
#> [3] GlcNAc(b1-3)GalNAc(a1-
#> [4] GlcNAc(b1-3)[GlcNAc(b1-6)]GalNAc(a1-
#> [5] GalNAc(a1-3)GalNAc(a1-
#> [6] GlcNAc(b1-6)GalNAc(a1-
#> [7] Fuc(a1-2)Gal(b1-3)[Fuc(a1-4)]GlcNAc(b1-
#> [8] Gal(b1-3)GlcNAc(b1-3)Gal(b1-4)Glc(b1-
#> [9] Fuc(a1-2)Gal(b1-3)GlcNAc(b1-3)Gal(b1-4)Glc(b1-
#> [10] Fuc(a1-3)[Gal(b1-4)]GlcNAc(b1-
#> ... (1353 more not shown)
#> # Unique structures: 1363
glydb_structures(glycan_type = "N")
#> <glycan_structure[2573]>
#> [1] GlcNAc(b1-2)[GlcNAc(b1-4)]Man(a1-3)[GlcNAc(b1-2)[GlcNAc(b1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [2] Fuc(a1-3)[Gal(b1-4)]GlcNAc(b1-4)Man(a1-3)Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [3] Neu5Ac(a2-3)Gal(b1-3)[Neu5Ac(a2-6)]GlcNAc(b1-2)Man(a1-3)[Neu5Ac(a2-3)Gal(b1-3)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [4] Man(a1-2)Man(a1-2)Man(a1-6)[Man(a1-2)Man(a1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [5] Neu5Gc(a2-3)Gal(b1-4)GlcNAc(b1-4)[Gal(b1-4)GlcNAc(b1-2)]Man(a1-3)[Gal(b1-4)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [6] Man(a1-6)Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [7] Neu5Ac(a2-6)Gal(b1-4)GlcNAc(b1-2)[Neu5Ac(a2-6)Gal(b1-4)GlcNAc(b1-4)]Man(a1-3)[Gal(b1-4)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [8] GlcNAc(b1-3)Man(a1-6)Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [9] GlcNAc(b1-2)[GlcNAc(b1-6)]Man(a1-3)[GlcNAc(b1-4)][GlcNAc(b1-2)[GlcNAc(b1-4)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [10] GlcNAc(b1-2)[GlcNAc(b1-4)]Man(a1-3)[GlcNAc(b1-2)[GlcNAc(b1-4)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-3)]GlcNAc(b1-
#> ... (2563 more not shown)
#> # Unique structures: 2573
glydb_structures(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#> <glycan_structure[0]>
#> # Unique structures: 0
glydb_structures(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#> <glycan_structure[1028]>
#> [1] GlcNAc(a1-3)GalNAc(b1-3)Gal(a1-4)Gal(b1-4)Glc(b1-
#> [2] Man(a1-2)Man(a1-2)Man(a1-6)[Man(a1-2)Man(a1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [3] Man(a1-2)Man(a1-3)[GlcNAc(b1-4)][Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(a1-
#> [4] Man(a1-3)Man(a1-6)[Man(b1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [5] Gal(b1-4)GlcNAc(b1-3)[Gal(b1-4)GlcNAc(b1-6)]Gal(b1-4)GlcNAc(b1-3)[Gal(b1-4)GlcNAc(b1-6)]Gal(b1-4)GlcNAc(b1-
#> [6] Man(a1-2)Man(a1-3)[Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(a1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [7] Man(a1-6)Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [8] Glc(b1-3)Man(a1-2)Man(a1-2)Man(a1-3)[Man(a1-2)Man(a1-6)[Man(a1-3)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [9] Gal(b1-4)GlcNAc(b1-4)Man(a1-3)[Gal(b1-4)GlcNAc(b1-4)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [10] Gal(b1-4)GlcNAc(b1-3)Gal(b1-4)GlcNAc(b1-6)Man(a1-6)Man(b1-
#> ... (1018 more not shown)
#> # Unique structures: 1028
```
