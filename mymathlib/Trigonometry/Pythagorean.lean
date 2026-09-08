import Trigonometry.CosineLaw

/-!
# The trigonometric proof of the Pythagorean theorem

The sides of a right triangle meet at `π / 2`. Applying the cosine law at
that angle turns the general relation into `c² = a² + b²`, because the
parallel projection is zero and hence `cos (π / 2) = 0`.
-/

theorem trigonometric_pythagorean
    (a b c A B : ℝ)
    (h : ProjectionRelations a b c A B (Real.pi / 2)) :
    c ^ 2 = a ^ 2 + b ^ 2 := by
  exact cosine_law_right_angle a b c A B h
