import Mathlib

/-!
# Trigonometric projections

For a segment of length `r` making an angle `θ` with a reference direction,
`r * cos θ` is its parallel projection and `r * sin θ` is its perpendicular
projection. The identity `sin² θ + cos² θ = 1` says that these two components
recover the original squared length.
-/

/-! The parallel (horizontal) component of a length at an angle. -/
noncomputable def parallelProjection (r θ : ℝ) : ℝ :=
  r * Real.cos θ

/-! The perpendicular (vertical) component of a length at an angle. -/
noncomputable def perpendicularProjection (r θ : ℝ) : ℝ :=
  r * Real.sin θ

/-!
Projection theorem: the squared parallel and perpendicular components add up
to the squared length. This is the trigonometric form of the unit-circle
identity. The cosine law in `CosineLaw.lean` is proved independently from
three geometric projection equations by algebraic elimination.
-/
theorem projection_squared_sum (r θ : ℝ) :
    parallelProjection r θ ^ 2 + perpendicularProjection r θ ^ 2 = r ^ 2 := by
  rw [parallelProjection, perpendicularProjection]
  nlinarith [Real.sin_sq_add_cos_sq θ]
