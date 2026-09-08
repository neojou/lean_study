import Mathlib

/-!
# Real inner-product spaces

This file develops only the linear-algebraic part of the argument. An inner
product assigns a real number to two vectors and behaves linearly in each
argument. Its value `inner u u` is the squared length of `u`; orthogonality is
the statement that the inner product of two vectors is zero.

The Pythagorean identity below is therefore a theorem about vector addition,
not a coordinate-specific definition of distance.
-/

structure RealInnerProductSpace (V : Type*) [AddCommGroup V] [Module ℝ V] where
  /-- The inner product measures the signed interaction of two vectors. -/
  inner : V → V → ℝ
  /-- Swapping the two vectors does not change their inner product. -/
  symmetry : ∀ u v, inner u v = inner v u
  /-- The inner product is additive in its first vector. -/
  add_left : ∀ u v w, inner (u + v) w = inner u w + inner v w
  /-- Scaling the first vector scales the inner product by the same scalar. -/
  smul_left : ∀ c u v, inner (c • u) v = c * inner u v
  /-- A vector has nonnegative squared length. -/
  nonneg : ∀ u, 0 ≤ inner u u
  /-- Only the zero vector has squared length zero. -/
  eq_zero_iff : ∀ u, inner u u = 0 ↔ u = 0

/-! The squared norm is the inner product of a vector with itself. -/
def normSq {V : Type*} [AddCommGroup V] [Module ℝ V]
    (G : RealInnerProductSpace V) (u : V) : ℝ :=
  G.inner u u

/-! Two vectors are orthogonal when their inner product vanishes. -/
def Orthogonal {V : Type*} [AddCommGroup V] [Module ℝ V]
    (G : RealInnerProductSpace V) (u v : V) : Prop :=
  G.inner u v = 0

/-!
The inner product expands the squared length of a sum. When the summands are
orthogonal, the mixed terms vanish, which is exactly the Pythagorean identity.
-/
theorem real_inner_pythagorean
    {V : Type*} [AddCommGroup V] [Module ℝ V]
    (G : RealInnerProductSpace V) (u v : V)
    (horth : Orthogonal G u v) :
    normSq G (u + v) = normSq G u + normSq G v := by
  have add_right : ∀ a b c,
      G.inner a (b + c) = G.inner a b + G.inner a c := by
    intro a b c
    rw [G.symmetry, G.add_left, G.symmetry b a, G.symmetry c a]
  dsimp [normSq, Orthogonal] at horth ⊢
  rw [G.add_left, add_right, add_right, G.symmetry v u, horth]
  ring