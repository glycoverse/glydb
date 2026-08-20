# Convert GlyTouCan Accessions to Glycan Structures

Look up GlyTouCan accessions in the bundled
[glydb_data](https://glycoverse.github.io/glydb/dev/reference/glydb_data.md).

## Usage

``` r
glytoucan_to_struc(glytoucan_ac)
```

## Arguments

- glytoucan_ac:

  A character vector of GlyTouCan accessions.

## Value

A
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
vector. Accessions without a bundled match are returned as `NA` values
in their original positions, and a warning is emitted.

## Examples

``` r
glytoucan_to_struc("G17689DH")
#> <glycan_structure[1]>
#> [1] Neu5Ac(a2-3)Gal(b1-4)GlcNAc(b1-2)Man(a1-3)[Neu5Ac(a2-3)Gal(b1-4)GlcNAc(b1-2)Man(a1-6)]Man(b1-4)GlcNAc(b1-4)[Fuc(a1-6)]GlcNAc(b1-
#> # Unique structures: 1
```
