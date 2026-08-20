# struc_to_glytoucan preserves NA and warns for unmatched structures

    Code
      result <- struc_to_glytoucan(strucs)
    Condition
      Warning:
      No bundled GlyTouCan accession for 1 glycan structure.
      x Unmatched input positions: 3

# struc_to_glytoucan validates input

    Code
      struc_to_glytoucan(1)
    Condition
      Error in `.ensure_glycan_structure()`:
      ! `strucs` must be a character vector or a `glyrepr::glycan_structure()` vector.
      x Got <numeric>.
