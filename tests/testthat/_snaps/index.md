# index validation rejects invalid resolutions and flags

    Code
      glydb_composition_index(mono_type = "mixed")
    Condition
      Error in `glydb_composition_index()`:
      ! Assertion on 'mono_type' failed: Must be element of set {'generic','concrete'}, but is 'mixed'.

---

    Code
      glydb_structure_index(structure_level = "partial")
    Condition
      Error in `glydb_structure_index()`:
      ! Assertion on 'structure_level' failed: Must be element of set {'intact','topological'}, but is 'partial'.

---

    Code
      glydb_structure_index(exclude_floating = NA)
    Condition
      Error in `glydb_structure_index()`:
      ! Assertion on 'exclude_floating' failed: May not be NA.

# index printing summarizes the selected view

    Code
      print(glydb_composition_index())
    Output
      <glydb_composition_index> composition_concrete
      Records: 1678 active / 1678 total
      Schema: 1

---

    Code
      print(glydb_structure_index(mono_range = list(Hex = c(100000L, Inf))))
    Output
      <glydb_structure_index> structure_intact_concrete
      Records: 0 active / 8573 total
      Schema: 1
