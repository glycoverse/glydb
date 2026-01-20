# Get Structures From Glydb Data

Get unique glycan structures from
[glydb_data](https://glycoverse.github.io/glydb/reference/glydb_data.md)
as a
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
vector.

## Usage

``` r
glydb_structures(
  structure_level = "intact",
  species = NULL,
  glycan_type = NULL
)
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

- glycan_type:

  A string of glycan types. Can be "N", "O-GalNAc", "O-GlcNAc", "O-Man",
  "O-Fuc", "O-Glc". Default is NULL, which means glycans of all types
  are included.

## Value

A
[`glyrepr::glycan_structure()`](https://glycoverse.github.io/glyrepr/reference/glycan_structure.html)
vector.

## Examples

``` r
glydb_structures()
#> Error in vctrs::new_vctr(x, graphs = list(), class = class(to)): `.data` can't be a data frame.
glydb_structures(structure_level = "topological")
#> Error in vctrs::new_vctr(x, graphs = list(), class = class(to)): `.data` can't be a data frame.
glydb_structures(structure_level = "basic")
#> Error in vctrs::new_vctr(x, graphs = list(), class = class(to)): `.data` can't be a data frame.
glydb_structures(species = "Homo sapiens")
#> Error in vctrs::new_vctr(x, graphs = list(), class = class(to)): `.data` can't be a data frame.
glydb_structures(glycan_type = "N")
#> Error in vctrs::new_vctr(x, graphs = list(), class = class(to)): `.data` can't be a data frame.
```
