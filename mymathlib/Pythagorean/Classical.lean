import LinearAlgebra.RealPlane

/-!
# Classical geometry in the real plane

Classical plane geometry describes points by coordinates and measures a
segment by the squared Euclidean distance between its endpoints. The vector
from `p` to `q` is `q - p`; thus the squared distance is the squared norm of
that difference vector.

The theorem below models a right triangle by two perpendicular side vectors.
The third side is their vector sum, so its squared length is obtained from the
abstract real inner-product theorem rather than assumed as a coordinate
formula.
-/

abbrev Point := ℝ × ℝ

/-! The squared Euclidean distance between two classical plane points. -/
def classicalDistanceSq (p q : Point) : ℝ :=
  normSq realPlaneInner (q - p)

/-! Two vectors forming the legs of a classical right triangle. -/
def ClassicalRightTriangle (leg₁ leg₂ : Point) : Prop :=
  Orthogonal realPlaneInner leg₁ leg₂

/-!
The classical Pythagorean theorem: if two vectors from the origin are
perpendicular, then the squared distance to their sum is the sum of the two
squared distances to the leg endpoints.

The equalities below unfold the classical distance definition only at the
last step. The mathematical content still comes from the abstract theorem
about an arbitrary real inner-product space.
-/
theorem classical_pythagorean (leg₁ leg₂ : Point)
    (htriangle : ClassicalRightTriangle leg₁ leg₂) :
    classicalDistanceSq (0 : Point) (leg₁ + leg₂) =
      classicalDistanceSq (0 : Point) leg₁ +
        classicalDistanceSq (0 : Point) leg₂ := by
  simpa [classicalDistanceSq] using
    (real_inner_pythagorean realPlaneInner leg₁ leg₂ htriangle)
