# glydb

The goal of glydb is to provide a comprehensive database of glycan
structures, including common glycan structures and their modifications.
The database is updated periodically and is used by the glycoverse
ecosystem. Only fully defined glycan structures are included.

## Installation

You can install the latest release of glydb from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("glycoverse/glydb@*release")
```

Or install the development version:

``` r
remotes::install_github("glycoverse/glydb")
```

## Example

Get all data from `glydb`:

``` r
library(glydb)
#> Loading required package: glyrepr
glydb_data
#> # A data frame: 6,960 × 4
#>    glytoucan_ac glycan_structure                      glycan_composition species
#>    <chr>        <struct>                              <comp>             <chr>  
#>  1 G00024MO     Glc(b1-3)Glc(b1-3)Glc(b1-             Glc(3)             Saccha…
#>  2 G00025MO     Glc(b1-4)Glc(b1-4)Glc(b1-4)Glc(b1-    Glc(4)             <NA>   
#>  3 G00027MO     Man(a1-3)[Man(a1-6)]Man(b1-4)GlcNAc(… Man(3)GlcNAc(1)    Mus mu…
#>  4 G00030VN     Fuc(a1-2)[GalNAc(a1-3)]Gal(b1-4)GlcN… Gal(1)GlcNAc(1)Ga… Bos ta…
#>  5 G00031MO     Gal(b1-3)GalNAc(a1-                   Gal(1)GalNAc(1)    Bos ta…
#>  6 G00033MO     Gal(b1-3)[GlcNAc(b1-6)]GalNAc(a1-     Gal(1)GlcNAc(1)Ga… Bos ta…
#>  7 G00035MO     GlcNAc(b1-3)GalNAc(a1-                GlcNAc(1)GalNAc(1) Bos ta…
#>  8 G00037MO     GlcNAc(b1-3)[GlcNAc(b1-6)]GalNAc(a1-  GlcNAc(2)GalNAc(1) Bos ta…
#>  9 G00039MO     GalNAc(a1-3)GalNAc(a1-                GalNAc(2)          Bos ta…
#> 10 G00041MO     GlcNAc(b1-6)GalNAc(a1-                GlcNAc(1)GalNAc(1) Bos ta…
#> # ℹ 6,950 more rows
```

Or use the getter functions to get specific data:

``` r
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
```

``` r
glydb_structures(structure_level = "topological", species = "Homo sapiens")
#> <glycan_structure[833]>
#> [1] Gal(??-?)GalNAc(??-
#> [2] GlcNAc(??-?)[Gal(??-?)]GalNAc(??-
#> [3] GlcNAc(??-?)GalNAc(??-
#> [4] GlcNAc(??-?)[GlcNAc(??-?)]GalNAc(??-
#> [5] GalNAc(??-?)GalNAc(??-
#> [6] Fuc(??-?)Gal(??-?)[Fuc(??-?)]GlcNAc(??-
#> [7] Gal(??-?)GlcNAc(??-?)Gal(??-?)Glc(??-
#> [8] Fuc(??-?)Gal(??-?)GlcNAc(??-?)Gal(??-?)Glc(??-
#> [9] Gal(??-?)[Fuc(??-?)]GlcNAc(??-
#> [10] Neu5Ac(??-?)Gal(??-?)[Fuc(??-?)]GlcNAc(??-
#> ... (823 more not shown)
#> # Unique structures: 833
```
