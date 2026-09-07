# Pythagorean

A Lean 4 + Mathlib development of the Pythagorean theorem from the axioms of a real inner-product space.

## Structure

- `Pythagorean/InnerProduct.lean`: abstract real inner-product space, squared norm, orthogonality, and the abstract Pythagorean theorem.
- `Pythagorean/RealPlane.lean`: standard dot product on `ℝ × ℝ` and its concrete Pythagorean theorem.
- `Pythagorean/All.lean`: public umbrella module.
- `Main.lean`: executable entry point.

## Build and run

```sh
lake build
lake exe pythagorean
```

The theorem is proved from inner-product linearity, symmetry, and orthogonality. No coordinate-distance definition assumes the Pythagorean conclusion.
