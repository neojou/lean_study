import Mathlib

/-!
# Abstract real inner-product spaces

The Pythagorean theorem is derived from the inner-product axioms rather than
being inserted into a coordinate-distance definition.
-/

structure RealInnerProductSpace (V : Type*) [AddCommGroup V] [Module ℝ V] where
  inner : V → V → ℝ
  symmetry : ∀ u v, inner u v = inner v u
  add_left : ∀ u v w, inner (u + v) w = inner u w + inner v w
  smul_left : ∀ c u v, inner (c • u) v = c * inner u v
  nonneg : ∀ u, 0 ≤ inner u u
  eq_zero_iff : ∀ u, inner u u = 0 ↔ u = 0

def normSq {V : Type*} [AddCommGroup V] [Module ℝ V]
    (G : RealInnerProductSpace V) (u : V) : ℝ :=
  G.inner u u

def Orthogonal {V : Type*} [AddCommGroup V] [Module ℝ V]
    (G : RealInnerProductSpace V) (u v : V) : Prop :=
  G.inner u v = 0

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
