# Get Compositions From Glydb Data

Get unique glycan compositions from
[glydb_data](https://glycoverse.github.io/glydb/reference/glydb_data.md)
as a
[`glyrepr::glycan_composition()`](https://glycoverse.github.io/glyrepr/reference/glycan_composition.html)
vector.

## Usage

``` r
glydb_compositions(mono_type = "concrete", species = NULL)
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

## Value

A
[`glyrepr::glycan_composition()`](https://glycoverse.github.io/glyrepr/reference/glycan_composition.html)
vector.

## Examples

``` r
glydb_compositions()
#> <glycan_composition[1183]>
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
#> ... (1173 more not shown)
glydb_compositions(mono_type = "generic")
#> <glycan_composition[756]>
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
#> ... (746 more not shown)
glydb_compositions(species = "Homo sapiens")
#> <glycan_composition[578]>
#> [1] Glc(4)
#> [2] Gal(1)GalNAc(1)
#> [3] Gal(1)GlcNAc(1)GalNAc(1)
#> [4] GlcNAc(1)GalNAc(1)
#> [5] GlcNAc(2)GalNAc(1)
#> [6] GalNAc(2)
#> [7] Gal(1)GlcNAc(1)Fuc(2)
#> [8] Glc(1)Gal(2)GlcNAc(1)
#> [9] Glc(1)Gal(2)GlcNAc(1)Fuc(1)
#> [10] Gal(1)GlcNAc(1)Fuc(1)
#> ... (568 more not shown)
```
