import Trigonometry.Projection

/-!
# The cosine law by algebraic elimination

For a triangle with side lengths `a`, `b`, and `c`, the three elementary
projection relations are

* `a = b * cos C + c * cos B`,
* `b = a * cos C + c * cos A`, and
* `c = a * cos B + b * cos A`.

They express each side as the sum of the projections of the other two sides
onto it. They are geometric projection facts and do not use the Pythagorean
theorem. The cosine law follows by multiplying these equations by `a`, `b`,
and `c`, respectively, then adding the first two and subtracting the third.
The terms `a * c * cos B` and `b * c * cos A` cancel, leaving only the term
`2 * a * b * cos C`.
-/

/-! The three projection equations associated with a triangle. -/
structure ProjectionRelations (a b c A B C : ℝ) : Prop where
  /-- Projection of sides `b` and `c` onto side `a`. -/
  side_a : a = b * Real.cos C + c * Real.cos B
  /-- Projection of sides `a` and `c` onto side `b`. -/
  side_b : b = a * Real.cos C + c * Real.cos A
  /-- Projection of sides `a` and `b` onto side `c`. -/
  side_c : c = a * Real.cos B + b * Real.cos A

/-!
Cosine law from the projection equations alone.

The three hypotheses are multiplied by their corresponding side lengths. The
first two resulting equations are added, and the third is subtracted. This is
the complete algebraic elimination argument; no squared projection identity
and no Pythagorean theorem is used.
-/
theorem cosine_law_from_projections
    (a b c A B C : ℝ) (h : ProjectionRelations a b c A B C) :
    c ^ 2 = a ^ 2 + b ^ 2 - 2 * a * b * Real.cos C := by
  have ha := congrArg (fun x : ℝ => a * x) h.side_a
  have hb := congrArg (fun x : ℝ => b * x) h.side_b
  have hc := congrArg (fun x : ℝ => c * x) h.side_c
  have hcancel : a ^ 2 + b ^ 2 - c ^ 2 =
      2 * a * b * Real.cos C := by
    nlinarith [ha, hb, hc]
  nlinarith [hcancel]

/-!
At a right angle `C = π / 2`, the cosine term vanishes. Thus the cosine law
specializes to the Pythagorean theorem.
-/
theorem cosine_law_right_angle
    (a b c A B : ℝ)
    (h : ProjectionRelations a b c A B (Real.pi / 2)) :
    c ^ 2 = a ^ 2 + b ^ 2 := by
  simpa [Real.cos_pi_div_two] using
    (cosine_law_from_projections a b c A B (Real.pi / 2) h)
