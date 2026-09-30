# Get Precomputed Glycan Database Indexes

These two functions are mainly used by the `glyanno` package. If you're
directly using `glydb`, use
[`glydb_compositions()`](https://glycoverse.github.io/glydb/dev/reference/glydb_compositions.md)
or
[`glydb_structures()`](https://glycoverse.github.io/glydb/dev/reference/glydb_structures.md)
instead.

Retrieve bundled composition or structure indexes without parsing
database structures, converting their resolution, counting components,
or rebuilding candidate maps. All database features are computed during
data generation.

## Usage

``` r
glydb_composition_index(
  mono_type = "concrete",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL
)

glydb_structure_index(
  structure_level = "intact",
  mono_type = "concrete",
  species = NULL,
  glycan_type = NULL,
  mono_range = NULL,
  exclude_floating = FALSE
)
```

## Arguments

- mono_type:

  Either "generic" or "concrete". Default is "concrete". See
  [`glyrepr::get_mono_type()`](https://glycoverse.github.io/glyrepr/reference/get_mono_type.html)
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

  A named list for filtering compositions by monosaccharide counts. Each
  element should be an integer vector of length 2 specifying the minimum
  and maximum count for that monosaccharide. Monosaccharides not
  specified will be excluded (count = 0). Use `NULL` for no filtering.
  See examples for usage.

- structure_level:

  Either `"intact"` or `"topological"`.

- exclude_floating:

  Whether to exclude structures with unresolved floating parts or
  substituents from `active_ids`. Defaults to `FALSE`.

## Value

A list with class `glydb_composition_index` or `glydb_structure_index`,
also inheriting from `glydb_index`. **Filters change only `active_ids`.
All other fields describe the full selected database view**, in original
database order:

- `schema_version`: Integer version of the index format, currently 1.

- `data_version`: Content fingerprint of the precomputed view. Record
  IDs are valid only for the same `view` and `data_version`.

- `view`: Name identifying the composition/structure resolution.

- `key_collation`: The `LC_COLLATE` used to generate structure keys
  (`"C"`).

- `glyrepr_version`: Version used when generating the index.

- `mono_type`, `structure_level`: Resolution of the view; the latter is
  `NULL` for composition indexes.

- `record_id`: Integer row IDs, starting at 1.

- `active_ids`: IDs retained by the requested filters, in database
  order.

- `glycans`: Full
  [`glydb_compositions()`](https://glycoverse.github.io/glydb/dev/reference/glydb_compositions.md)
  or
  [`glydb_structures()`](https://glycoverse.github.io/glydb/dev/reference/glydb_structures.md)
  vector, including its confidence attribute.

- `composition`: A plain
  [`glyrepr::glycan_composition()`](https://glycoverse.github.io/glyrepr/reference/glycan_composition.html)
  vector aligned with records. Structures sharing a composition remain
  separate records.

- `confidence`: Numeric confidence per record, aggregated before
  filtering using the same maximum-confidence rule as the existing
  getters.

- `best_rank`: Integer priority per record, with smaller values
  preferred. Missing confidence ranks last; ties retain database order.
  Select the smallest rank among eligible candidates, not among the full
  view.

- `composition_keys`, `composition_maps`: Named lists with `exact` and
  `generic` entries. Keys are character vectors aligned with records;
  maps are named lists from keys to integer record IDs in database
  order.

- `counts`, `generic_counts`: Integer matrices with one row per record
  and named columns for monosaccharides and substituents. `counts` uses
  the view's resolution; `generic_counts` uses generic monosaccharides.
  Columns cover components observed anywhere in the full view. Within
  those columns, absent components have zero counts; missing
  compositions have `NA` rows. Components absent from the entire view
  have no column.

- `components`, `generic_components`: Logical matrices with the same
  dimensions as the count matrices, recording component-name presence.
  These preserve the getters' exclusion of unspecified components even
  when a stored component has a zero count.

- `species`, `glycan_type`: Original semicolon-separated metadata
  vectors.

- `filter_ids`: Named lists `species` and `glycan_type`, mapping
  supported filter values to record IDs. The `"O"` entry includes
  O-linked subtypes.

Structure indexes additionally contain:

- `structure_keys`, `structure_maps`: Named lists with `exact`,
  `generic`, `topological`, and `generic_topological` entries. Converted
  keys do not merge records or alter their confidence. Maps use the full
  view's IDs. All structure keys are canonicalized under
  `key_collation`; even `exact` keys can differ in branch order from the
  original `glycans` strings.

- `has_floating_parts`, `has_floating_substituents`: Logical flags per
  record, with `NA` for missing structures.

## Details

Intersect candidate-map IDs with `active_ids` before retrieving results.
Generic composition keys identify candidate groups, not proof of mixed
composition compatibility; use concrete counts to check input
constraints. Structure keys encode resolution conversions, not arbitrary
partial-structure matching. Further matching may be needed for partially
specified inputs.

Structure key comparisons require the same canonicalization and
collation as the index. After converting an input to the desired
resolution, generate its key with
`glyrepr::canonicalize_glycan_graphs(as.list(input))$iupac` under
`LC_COLLATE = "C"`, restoring the previous locale afterwards. This
function is available in the `glyrepr` version recorded by the index.
Canonicalize only query inputs at runtime, not the database.

Treat indexes as read-only values. Modifying a returned list does not
update the bundled database. The index contains no mass dictionary or
mass values.

## Examples

``` r
index <- glydb_composition_index(species = "Homo sapiens", glycan_type = "N")
index$glycans[index$active_ids[1:3]]
#> <glydb_composition[3]>
#> [1] Man(3)Gal(3)GlcNAc(5)Neu5Ac(1)
#> [2] Man(3)Gal(3)GlcNAc(5)Fuc(3)Neu5Ac(1)
#> [3] Man(3)GlcNAc(3)GalNAc(1)S(1)

index <- glydb_structure_index(exclude_floating = TRUE)
key <- index$composition_keys$generic[index$active_ids[1]]
ids <- intersect(index$composition_maps$generic[[key]], index$active_ids)
index$glycans[ids]
#> <glydb_structure[321]>
#> [1] Glc(b1-3)Glc(b1-3)Glc(b1-
#> [2] Galf(a1-2)Galf(a1-4)Gal(b1-
#> [3] Gal(a1-4)Gal(b1-4)Glc(b1-
#> [4] Gal(b1-2)Gal(b1-2)Gal(b1-
#> [5] Glc(a1-4)Glc(a1-4)Glc(b1-
#> [6] Man(a1-3)[Man(a1-6)]Man(a1-
#> [7] Glc(a1-6)Glc(a1-6)Glcf(b1-
#> [8] Man(b1-2)Man(b1-2)Man(b1-
#> [9] Gal(b1-4)Glc(a1-4)Glc(a1-
#> [10] Man(a1-2)[Man(a1-4)]Man(a1-
#> ... (311 more not shown)
#> # Unique structures: 321
index$glycans[ids[which.min(index$best_rank[ids])]]
#> <glydb_structure[1]>
#> [1] Gal(a1-4)Gal(b1-4)Glc(b1-
#> # Unique structures: 1
```
