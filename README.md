
<!-- README.md is generated from README.Rmd. Please edit that file -->

# glydb <a href="https://glycoverse.github.io/glydb/"><img src="man/figures/logo.png" align="right" height="138" /></a>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/glydb)](https://CRAN.R-project.org/package=glydb)
[![R-CMD-check](https://github.com/glycoverse/glydb/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/glycoverse/glydb/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/glycoverse/glydb/graph/badge.svg)](https://app.codecov.io/gh/glycoverse/glydb)
<!-- badges: end -->

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

In glydb, we have two datasets.

The first one is `fully_determined_glycans`, which contains a curated
list of fully determined glycan structures from GlyTouCan.

``` r
library(glydb)
library(glyrepr)

fully_determined_glycans
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

The second one is `topology_glycans`, derived from
`fully_determined_glycans`, removing all linkage information.

``` r
topology_glycans
#> # A tibble: 2,955 × 3
#>    glycan_structure                                   glycan_composition species
#>    <struct>                                           <comp>             <chr>  
#>  1 Glc(??-?)Glc(??-?)Glc(??-                          Glc(3)             <NA>   
#>  2 Glc(??-?)Glc(??-?)Glc(??-?)Glc(??-                 Glc(4)             <NA>   
#>  3 Man(??-?)[Man(??-?)]Man(??-?)GlcNAc(??-            Man(3)GlcNAc(1)    <NA>   
#>  4 Fuc(??-?)[GalNAc(??-?)]Gal(??-?)GlcNAc(??-?)[Neu5… Gal(1)GlcNAc(1)Ga… Bos ta…
#>  5 Gal(??-?)GalNAc(??-                                Gal(1)GalNAc(1)    <NA>   
#>  6 Gal(??-?)[GlcNAc(??-?)]GalNAc(??-                  Gal(1)GlcNAc(1)Ga… <NA>   
#>  7 GlcNAc(??-?)GalNAc(??-                             GlcNAc(1)GalNAc(1) <NA>   
#>  8 GlcNAc(??-?)[GlcNAc(??-?)]GalNAc(??-               GlcNAc(2)GalNAc(1) <NA>   
#>  9 GalNAc(??-?)GalNAc(??-                             GalNAc(2)          <NA>   
#> 10 Fuc(??-?)Gal(??-?)[Fuc(??-?)]GlcNAc(??-            Gal(1)GlcNAc(1)Fu… <NA>   
#> # ℹ 2,945 more rows
```
