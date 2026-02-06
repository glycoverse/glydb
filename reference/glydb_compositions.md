# Get Compositions From Glydb Data

Get unique glycan compositions from
[glydb_data](https://glycoverse.github.io/glydb/reference/glydb_data.md)
as a
[`glyrepr::glycan_composition()`](https://glycoverse.github.io/glyrepr/reference/glycan_composition.html)
vector.

## Usage

``` r
glydb_compositions(mono_type = "concrete", species = NULL, glycan_type = NULL)
```

## Arguments

- mono_type:

  Either "generic" or "concrete". Default is "concrete". See
  [`glyrepr::get_mono_type()`](https://glycoverse.github.io/glyrepr/reference/get_mono_type.html)
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

## Value

A
[`glyrepr::glycan_composition()`](https://glycoverse.github.io/glyrepr/reference/glycan_composition.html)
vector.

## Examples

``` r
glydb_compositions()
#> <glycan_composition[1070]>
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
#> ... (1060 more not shown)
glydb_compositions(mono_type = "generic")
#> <glycan_composition[652]>
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
#> ... (642 more not shown)
glydb_compositions(species = "Homo sapiens")
#> <glycan_composition[536]>
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
#> ... (526 more not shown)
glydb_compositions(glycan_type = "N")
#> <glycan_composition[473]>
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
#> ... (463 more not shown)
```
