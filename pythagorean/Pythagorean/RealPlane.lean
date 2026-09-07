import Pythagorean.InnerProduct

/-! The standard dot product gives a concrete real inner-product space on ℝ². -/

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

theorem real_plane_pythagorean (u v : ℝ × ℝ)
    (horth : realPlaneInner.inner u v = 0) :
    normSq realPlaneInner (u + v) =
      normSq realPlaneInner u + normSq realPlaneInner v := by
  exact real_inner_pythagorean realPlaneInner u v horth
