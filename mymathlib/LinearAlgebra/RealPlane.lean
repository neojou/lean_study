import LinearAlgebra.InnerProduct

/-!
# The standard real plane

The Cartesian plane `ℝ × ℝ` is a concrete two-dimensional real vector space.
Its standard dot product is the sum of coordinate-wise products. This file
checks directly that the dot product satisfies the inner-product properties,
so the abstract theorem from `LinearAlgebra.InnerProduct` applies to it.
-/

def realPlaneInner : RealInnerProductSpace (ℝ × ℝ) where
  inner u v := u.1 * v.1 + u.2 * v.2
  symmetry := by
    intro u v
    ring
  add_left := by
    intro u v w
    change (u.1 + v.1) * w.1 + (u.2 + v.2) * w.2 =
      u.1 * w.1 + u.2 * w.2 + (v.1 * w.1 + v.2 * w.2)
    ring
  smul_left := by
    intro c u v
    change (c * u.1) * v.1 + (c * u.2) * v.2 =
      c * (u.1 * v.1 + u.2 * v.2)
    ring
  nonneg := by
    intro u
    nlinarith [sq_nonneg u.1, sq_nonneg u.2]
  eq_zero_iff := by
    intro u
    constructor
    · intro h
      have hx : u.1 ^ 2 = 0 := by
        nlinarith [sq_nonneg u.1, sq_nonneg u.2]
      have hy : u.2 ^ 2 = 0 := by
        nlinarith [sq_nonneg u.1, sq_nonneg u.2]
      apply Prod.ext
      · exact sq_eq_zero_iff.mp hx
      · exact sq_eq_zero_iff.mp hy
    · intro h
      subst u
      norm_num