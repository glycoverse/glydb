# Get Structures From Glydb Data

Get unique glycan structures from
[glydb_data](https://glycoverse.github.io/glydb/reference/glydb_data.md)
as a
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
vector.

## Usage

``` r
glydb_structures(structure_level = "intact", species = NULL)
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

## Value

A
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
vector.

## Examples

``` r
glydb_structures()
#> <glycan_structure[6853]>
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
#> ... (6843 more not shown)
#> # Unique structures: 6853
glydb_structures(structure_level = "topological")
#> <glycan_structure[2780]>
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
#> ... (2770 more not shown)
#> # Unique structures: 2780
glydb_structures(structure_level = "basic")
#> <glycan_structure[2391]>
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
#> ... (2381 more not shown)
#> # Unique structures: 2391
glydb_structures(species = "Homo sapiens")
#> <glycan_structure[1198]>
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
#> ... (1188 more not shown)
#> # Unique structures: 1198
```
