# Convert GlyTouCan Accessions to Glycan Structures

Look up GlyTouCan accessions from
[glydb_data](https://glycoverse.github.io/glydb/dev/reference/glydb_data.md),
then fetch missing accessions from the GlyGen API and parse the returned
IUPAC strings as
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
values.

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
vector. Accessions that cannot be fetched or parsed are returned as `NA`
values in their original positions, and a warning is emitted.

## Examples

``` r
if (FALSE) { # interactive()
glytoucan_to_struc("G17689DH")
}
```
