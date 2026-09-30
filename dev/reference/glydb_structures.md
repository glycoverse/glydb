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
  mono_range = NULL,
  mono_type = "concrete"
)
```

## Arguments

- structure_level:

  Either "intact" or "topological". Default is "intact". See
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

- mono_type:

  Either "generic" or "concrete". Default is "concrete". See
  [`glyrepr::get_mono_type()`](https://glycoverse.github.io/glyrepr/reference/get_mono_type.html)
  for details.

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
#> <glydb_structure[8573]>
#> [1] Glc(b1-3)Glc(b1-3)Glc(b1-
#> [2] Glc(b1-4)Glc(b1-4)Glc(b1-4)Glc(b1-
#> [3] Fuc(a1-2)Gal(b1-4)GlcNAc(b1-6)[Fuc(a1-2)Gal(b1-3)]GalNAc(b1-
#> [4] Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-
#> [5] Galf(a1-2)Galf(a1-4)Gal(b1-
#> [6] Fuc(a1-2)[GalNAc(a1-3)]Gal(b1-4)GlcNAc(b1-3)[Neu5Gc(a2-6)]GalNAc(a1-
#> [7] Gal(b1-3)GalNAc(a1-
#> [8] Gal(b1-3)[GlcNAc(b1-6)]GalNAc(a1-
#> [9] GlcNAc(b1-3)GalNAc(a1-
#> [10] GlcNAc(b1-3)[GlcNAc(b1-6)]GalNAc(a1-
#> ... (8563 more not shown)
#> # Unique structures: 8573
glydb_structures(structure_level = "topological")
#> <glydb_structure[8263]>
#> [1] Neu5Gc(??-?)Neu5Gc(??-?)Gal(??-?)Glc(??-
#> [2] Neu5Ac(??-?)Gal(??-?)GlcNAc(??-?)Man(??-?)[Gal(??-?)GlcNAc(??-?)[Gal(??-?)GlcNAc(??-?)]Man(??-?)]Man(??-?)GlcNAc(??-?)GlcNAc(??-
#> [3] Fuc(??-?)Gal(??-?)GlcNAc(??-?)Gal(??-?)GlcNAc(??-
#> [4] GalNAc(??-?)Gal(??-?)Gal(??-?)Glc(??-
#> [5] {Gal(??-?)[Fuc(??-?)]GlcNAc(??-?)|10,11,12,13,14,15}{Gal(??-?)GlcNAc(??-?)|10,11,12,13,14,15}{Neu5Ac(??-?)Gal(??-?)[Fuc(??-?)]GlcNAc(??-?)|10,11,12,13,14,15}Man(??-?)[Man(??-?)]Man(??-?)GlcNAc(??-?)[Fuc(??-?)]GlcNAc(??-
#> [6] Gal(??-?)Gal(??-?)Gal(??-?)Glc(??-
#> [7] GalNAc(??-?)GlcNAc(??-?)Man(??-?)Glc(??-
#> [8] GlcNAc(??-?)Man(??-?)Man(??-?)Glc(??-
#> [9] Gal(??-?)Gal(??-
#> [10] GalNAc4S(??-?)GlcNAc(??-?)Man(??-?)[Man(??-?)]Man(??-?)GlcNAc(??-?)GlcNAc(??-
#> ... (8253 more not shown)
#> # Unique structures: 8263
glydb_structures(mono_type = "generic")
#> <glydb_structure[7665]>
#> [1] Hex(b1-3)Hex(b1-3)Hex(b1-
#> [2] Hex(b1-4)Hex(b1-4)Hex(b1-4)Hex(b1-
#> [3] dHex(a1-2)Hex(b1-4)HexNAc(b1-6)[dHex(a1-2)Hex(b1-3)]HexNAc(b1-
#> [4] Hex(a1-3)[Hex(a1-6)]Hex(b1-4)HexNAc(b1-
#> [5] Hex(a1-2)Hex(a1-4)Hex(b1-
#> [6] dHex(a1-2)[HexNAc(a1-3)]Hex(b1-4)HexNAc(b1-3)[NeuGc(a2-6)]HexNAc(a1-
#> [7] Hex(b1-3)HexNAc(a1-
#> [8] Hex(b1-3)[HexNAc(b1-6)]HexNAc(a1-
#> [9] HexNAc(b1-3)HexNAc(a1-
#> [10] HexNAc(b1-3)[HexNAc(b1-6)]HexNAc(a1-
#> ... (7655 more not shown)
#> # Unique structures: 7665
glydb_structures(structure_level = "topological", mono_type = "generic")
#> <glydb_structure[7667]>
#> [1] NeuGc(??-?)NeuGc(??-?)Hex(??-?)Hex(??-
#> [2] NeuAc(??-?)Hex(??-?)HexNAc(??-?)Hex(??-?)[Hex(??-?)HexNAc(??-?)[Hex(??-?)HexNAc(??-?)]Hex(??-?)]Hex(??-?)HexNAc(??-?)HexNAc(??-
#> [3] dHex(??-?)Hex(??-?)HexNAc(??-?)Hex(??-?)HexNAc(??-
#> [4] HexNAc(??-?)Hex(??-?)Hex(??-?)Hex(??-
#> [5] {Hex(??-?)[dHex(??-?)]HexNAc(??-?)|10,11,12,13,14,15}{Hex(??-?)HexNAc(??-?)|10,11,12,13,14,15}{NeuAc(??-?)Hex(??-?)[dHex(??-?)]HexNAc(??-?)|10,11,12,13,14,15}Hex(??-?)[Hex(??-?)]Hex(??-?)HexNAc(??-?)[dHex(??-?)]HexNAc(??-
#> [6] Hex(??-?)Hex(??-?)Hex(??-?)Hex(??-
#> [7] HexNAc(??-?)HexNAc(??-?)Hex(??-?)Hex(??-
#> [8] Hex(??-?)Hex(??-
#> [9] HexNAc4S(??-?)HexNAc(??-?)Hex(??-?)[Hex(??-?)]Hex(??-?)HexNAc(??-?)HexNAc(??-
#> [10] HexA(??-?)HexNAc(??-?)HexA(??-?)HexNAc(??-
#> ... (7657 more not shown)
#> # Unique structures: 7667
glydb_structures(species = "Homo sapiens")
#> <glydb_structure[1722]>
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
#> ... (1712 more not shown)
#> # Unique structures: 1722
glydb_structures(glycan_type = "N")
#> <glydb_structure[3567]>
#> [1] Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-
#> [2] {Neu5Ac(a2-3)Gal(b1-4)GlcNAc(b1-2)}Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [3] {Neu5Ac(a2-3)}Gal(b1-4)GlcNAc(b1-2)Man(a1-3)[Gal(b1-4)GlcNAc(b1-2)[Gal(b1-4)GlcNAc(b1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [4] GlcNAc(b1-2)[GlcNAc(b1-4)]Man(a1-3)[GlcNAc(b1-2)[GlcNAc(b1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [5] Man(a1-3)Man(a1-6)[Man(a1-3)]Man(b1-4)GlcNAc(a1-
#> [6] Fuc(a1-3)[Gal(b1-4)]GlcNAc(b1-4)Man(a1-3)Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> [7] Neu5Ac(a2-3)Gal(b1-3)[Neu5Ac(a2-6)]GlcNAc(b1-2)Man(a1-3)[Neu5Ac(a2-3)Gal(b1-3)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [8] Man(a1-2)Man(a1-2)Man(a1-6)[Man(a1-2)Man(a1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [9] Man(a1-2)Man(a1-3)[GlcNAc(b1-4)][Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(a1-
#> [10] Neu5Gc(a2-3)Gal(b1-4)GlcNAc(b1-4)[Gal(b1-4)GlcNAc(b1-2)]Man(a1-3)[Gal(b1-4)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> ... (3557 more not shown)
#> # Unique structures: 3567
glydb_structures(glycan_type = "N", mono_range = list(Hex = c(5L, 10L)))
#> <glydb_structure[0]>
#> # Unique structures: 0
glydb_structures(mono_range = list(Hex = c(3L, 9L), HexNAc = c(2L, 6L)))
#> <glydb_structure[1133]>
#> [1] GlcNAc(a1-3)GalNAc(b1-3)Gal(a1-4)Gal(b1-4)Glc(b1-
#> [2] Man(a1-2)Man(a1-2)Man(a1-6)[Man(a1-2)Man(a1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [3] Man(a1-2)Man(a1-3)[GlcNAc(b1-4)][Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(a1-
#> [4] Man(a1-3)Man(a1-6)[Man(b1-3)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [5] {Gal(b1-4)|3,4,6,7,8}{Gal(b1-4)|3,4,6,7,8}GlcNAc(b1-2)[GlcNAc(b1-4)]Man(a1-3)[GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [6] Gal(b1-4)GlcNAc(b1-3)[Gal(b1-4)GlcNAc(b1-6)]Gal(b1-4)GlcNAc(b1-3)[Gal(b1-4)GlcNAc(b1-6)]Gal(b1-4)GlcNAc(b1-
#> [7] Man(a1-2)Man(a1-3)[Man(a1-3)[Man(a1-6)]Man(a1-6)]Man(a1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [8] Man(a1-6)Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [9] Man(a1-4)Man(a1-4)Man(a1-3)[Man(a1-4)Man(a1-3)[Man(a1-4)Man(a1-6)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> [10] Glc(b1-3)Man(a1-2)Man(a1-2)Man(a1-3)[Man(a1-2)Man(a1-6)[Man(a1-3)]Man(a1-6)]Man(b1-4)GlcNAc(b1-4)GlcNAc(b1-
#> ... (1123 more not shown)
#> # Unique structures: 1133
```
