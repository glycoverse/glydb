# glytoucan_to_struc returns NA for accessions without a match

    Code
      result <- glytoucan_to_struc(accessions)
    Condition
      Warning:
      No bundled glycan structure for 2 GlyTouCan accessions.
      x Unmatched: G_NOT_IN_GLYDB, G_NOT_IN_GLYDB

# glytoucan_to_struc validates accessions

    Code
      glytoucan_to_struc(1)
    Condition
      Error in `glytoucan_to_struc()`:
      ! Assertion on 'glytoucan_ac' failed: Must be of type 'character', not 'double'.

---

    Code
      glytoucan_to_struc(NA_character_)
    Condition
      Error in `glytoucan_to_struc()`:
      ! Assertion on 'glytoucan_ac' failed: Contains missing values (element 1).

