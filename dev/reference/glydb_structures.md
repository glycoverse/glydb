# Get Structures From Glydb Data

Get unique glycan structures from
[glydb_data](https://glycoverse.github.io/glydb/dev/reference/glydb_data.md)
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

The `confidence` attribute is preserved by vector operations that
subset, reorder, repeat, combine, or replace glycans. When vectors
containing the same glycan with different confidence values are
combined, the maximum confidence is used for every occurrence of that
glycan.

## Examples

``` r
glydb_structures()
#> <glydb_structure[7125]>
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
#> ... (7115 more not shown)
#> # Unique structures: 7125
glydb_structures(structure_level = "topological")
#> <glydb_structure[3811]>
#> [1] Neu5Gc(??-?)Neu5Gc(??-?)Gal(??-?)Glc(??-
#> [2] Neu5Ac(??-?)Gal(??-?)GlcNAc(??-?)Man(??-?)[Gal(??-?)GlcNAc(??-?)[Gal(??-?)GlcNAc(??-?)]Man(??-?)]Man(??-?)GlcNAc(??-?)GlcNAc(??-
#> [3] Glc(??-?)Glc(??-?)Glc(??-
#> [4] Glc(??-?)Glc(??-?)Glc(??-?)Glc(??-
#> [5] Man(??-?)[Man(??-?)]Man(??-?)GlcNAc(??-
#> [6] Man(??-?)Man(??-?)[GlcNAc(??-?)Man(??-?)]Man(??-?)GlcNAc(??-?)GlcNAc(??-
#> [7] Neu5Ac(??-?)Gal(??-?)GlcNAc(??-?)Man(??-?)[Gal(??-?)Gal(??-?)GlcNAc(??-?)[Gal(??-?)Gal(??-?)GlcNAc(??-?)]Man(??-?)]Man(??-?)GlcNAc(??-?)[Fuc(??-?)]GlcNAc(??-
#> [8] GalNAc(??-?)[Fuc(??-?)]Gal(??-?)GlcNAc(??-?)[Neu5Gc(??-?)]GalNAc(??-
#> [9] Gal(??-?)GalNAc(??-
#> [10] GlcNAc(??-?)[Gal(??-?)]GalNAc(??-
#> ... (3801 more not shown)
#> # Unique structures: 3811
glydb_structures(structure_level = "basic")
#> <glydb_structure[3309]>
#> [1] NeuGc(??-?)NeuGc(??-?)Hex(??-?)Hex(??-
#> [2] NeuAc(??-?)Hex(??-?)HexNAc(??-?)Hex(??-?)[Hex(??-?)HexNAc(??-?)[Hex(??-?)HexNAc(??-?)]Hex(??-?)]Hex(??-?)HexNAc(??-?)HexNAc(??-
#> [3] Hex(??-?)Hex(??-?)Hex(??-
#> [4] Hex(??-?)Hex(??-?)Hex(??-?)Hex(??-
#> [5] Hex(??-?)[Hex(??-?)]Hex(??-?)HexNAc(??-
#> [6] HexNAc(??-?)Hex(??-?)[Hex(??-?)Hex(??-?)]Hex(??-?)HexNAc(??-?)HexNAc(??-
#> [7] NeuAc(??-?)Hex(??-?)HexNAc(??-?)Hex(??-?)[Hex(??-?)Hex(??-?)HexNAc(??-?)[Hex(??-?)Hex(??-?)HexNAc(??-?)]Hex(??-?)]Hex(??-?)HexNAc(??-?)[dHex(??-?)]HexNAc(??-
#> [8] HexNAc(??-?)[dHex(??-?)]Hex(??-?)HexNAc(??-?)[NeuGc(??-?)]HexNAc(??-
#> [9] Hex(??-?)HexNAc(??-
#> [10] HexNAc(??-?)[Hex(??-?)]HexNAc(??-
#> ... (3299 more not shown)
#> # Unique structures: 3309
glydb_structures(species = "Homo sapiens")
#> <glydb_structure[1367]>
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
#> ... (1357 more not shown)
#> # Unique structures: 1367
glydb_structures(glycan_type = "N")
#> <glydb_structure[2780]>
#> [1] Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-
#> [2] GlcNAc(b1-2)[GlcNAc(b1-4)]Man(a1-3)[GlcNAc(b1-2)[GlcNAc(b1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [3] Man(a1-3)Man(a1-6)[Man(a1-3)]Man(b1-4)GlcNAc(a1-
#> [4] Fuc(a1-3)[Gal(b1-4)]GlcNAc(b1-4)Man(a1-3)Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [5] Neu5Ac(a2-3)Gal(b1-3)[Neu5Ac(a2-6)]GlcNAc(b1-2)Man(a1-3)[Neu5Ac(a2-3)Gal(b1-3)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [6] Man(a1-2)Man(a1-2)Man(a1-6)[Man(a1-2)Man(a1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [7] Man(a1-2)Man(a1-3)[GlcNAc(b1-4)][Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(a1-
#> [8] Neu5Gc(a2-3)Gal(b1-4)GlcNAc(b1-4)[Gal(b1-4)GlcNAc(b1-2)]Man(a1-3)[Gal(b1-4)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [9] Man(a1-6)Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [10] Neu5Ac(a2-6)Gal(b1-4)GlcNAc(b1-2)[Neu5Ac(a2-6)Gal(b1-4)GlcNAc(b1-4)]Man(a1-3)[Gal(b1-4)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> ... (2770 more not shown)
#> # Unique structures: 2780
glydb_structures(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#> <glydb_structure[0]>
#> # Unique structures: 0
glydb_structures(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#> <glydb_structure[1031]>
#> [1] GlcNAc(a1-3)GalNAc(b1-3)Gal(a1-4)Gal(b1-4)Glc(b1-
#> [2] Man(a1-2)Man(a1-2)Man(a1-6)[Man(a1-2)Man(a1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [3] Man(a1-2)Man(a1-3)[GlcNAc(b1-4)][Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(a1-
#> [4] Man(a1-3)Man(a1-6)[Man(b1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [5] Gal(b1-4)GlcNAc(b1-3)[Gal(b1-4)GlcNAc(b1-6)]Gal(b1-4)GlcNAc(b1-3)[Gal(b1-4)GlcNAc(b1-6)]Gal(b1-4)GlcNAc(b1-
#> [6] Man(a1-2)Man(a1-3)[Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(a1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [7] Man(a1-6)Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [8] Man(a1-4)Man(a1-4)Man(a1-3)[Man(a1-4)Man(a1-3)[Man(a1-4)Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [9] Glc(b1-3)Man(a1-2)Man(a1-2)Man(a1-3)[Man(a1-2)Man(a1-6)[Man(a1-3)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [10] Gal(b1-4)GlcNAc(b1-4)Man(a1-3)[Gal(b1-4)GlcNAc(b1-4)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> ... (1021 more not shown)
#> # Unique structures: 1031
```
