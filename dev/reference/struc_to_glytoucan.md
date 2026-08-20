# Convert Glycan Structures to GlyTouCan Accessions

Match glycan structures to accessions in the bundled
[glydb_data](https://glycoverse.github.io/glydb/dev/reference/glydb_data.md).

## Usage

``` r
struc_to_glytoucan(strucs)
```

## Arguments

- strucs:

  A
  [`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
  vector or a character vector of IUPAC-condensed glycan structures.

## Value

A character vector of GlyTouCan accessions. Structures without a bundled
match are returned as `NA` values in their original positions, and a
warning is emitted.

## Details

Missing anomeric positions are filled with
[`glyrepr::fill_anomer_pos()`](https://glycoverse.github.io/glyrepr/reference/fill_anomer_pos.html)
in both the input and bundled structures before matching. When multiple
bundled rows normalize to the same structure, the accession from the
first row is returned.

## Examples

``` r
struc_to_glytoucan(glydb_data$glycan_structure[1])
#> [1] "G00002CF"
```
