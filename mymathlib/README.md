# mymathlib

A Lean 4 + Mathlib development that separates the linear-algebraic theory of
real inner-product spaces from its classical plane-geometry application.

## Structure

- `LinearAlgebra/InnerProduct.lean`: abstract real inner-product space, squared norm, orthogonality, and the abstract Pythagorean theorem.
- `LinearAlgebra/RealPlane.lean`: standard dot product on `ℝ × ℝ`.
- `LinearAlgebra/All.lean`: public linear-algebra umbrella module.
- `Trigonometry/Projection.lean`: trigonometric components and the projection theorem.
- `Trigonometry/CosineLaw.lean`: the cosine law derived from projections.
- `Trigonometry/Pythagorean.lean`: the trigonometric proof of the Pythagorean theorem.
- `Trigonometry/All.lean`: public trigonometry umbrella module.
- `Pythagorean/Classical.lean`: classical plane points, squared distance, and the geometric application of the theorem.
- `Pythagorean/All.lean`: public Pythagorean umbrella module.
- `Main.lean`: executable entry point.

## Build and run

```sh
lake build
lake exe mymathlib
```

The theorem is proved from inner-product linearity, symmetry, and orthogonality. No coordinate-distance definition assumes the Pythagorean conclusion.
