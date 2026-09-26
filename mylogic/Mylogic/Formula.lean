/-!
  *  這是對象語法
  *  不是 Lean 的 Prop
  *  原語只有這五個：atom、falsum、and、or、imp；否定不是 constructor
-/


namespace Mylogic

-- *** HW 1.1 ***

/-
 *  Formula 資料樹
 *      Formula Nat : 原子是自然數的公式
 *      Formula String : 原子是字串的公式
-/
inductive Formula (a : Type) where
  -- atom 原子 - 葉子
  | atom : a → Formula a
  -- falsum 荒謬 - 葉子
  | falsum : Formula a
  -- and 合取 - 兩個子樹 - 兩邊都要成立
  | and : Formula a → Formula a → Formula a
  -- or 析取 - 兩個子樹 - 選一邊交出證明
  | or : Formula a → Formula a → Formula a
  -- imp 蘊涵 - 兩個子樹 - 把證明變成證明
  | imp : Formula a → Formula a → Formula a
  deriving Repr, DecidableEq

-- p ⋀ q（令 p = 0、q = 1）
def ex1 : Formula Nat
  := Formula.and (Formula.atom 0) (Formula.atom 1)

-- (p ⋀ q) ⇒ ⟂ (令 p = 0、q = 1）
def ex2 : Formula Nat :=
  Formula.imp (Formula.and (Formula.atom 0) (Formula.atom 1)) Formula.falsum

-- p ⇒ (q ⋁ ⟂) (令 p = 0、q = 1）
def ex3 : Formula Nat :=
  Formula.imp (Formula.atom 0) (Formula.or (Formula.atom 1) Formula.falsum)


-- *** HW 1.2 ***

variable {a : Type}

/-
  * 定義 - 對象否定：∼b := b ⇒ ⟂
  *  節點 : imp 蘊涵
  *  左子樹 : 公式 b : Formula a
  *  右子樹 : falsum 荒謬
-/
def Formula.neg (b : Formula a) : Formula a :=
    Formula.imp b Formula.falsum

/-
  * 定義 - 對象真：⊤ᵢ := ⟂ ⇒ ⟂
  *  節點 : imp 蘊涵
  *  左子樹 : falsum 荒謬
  *  右子樹 : falsum 荒謬
-/
def Formula.verum : Formula a :=
    Formula.imp Formula.falsum Formula.falsum

-- ∼p
def ex4 : Formula Nat :=
  Formula.neg (Formula.atom 0)

-- ⊤ᵢ
def ex5 : Formula Nat :=
  Formula.verum

example (b : Formula Nat) : Formula.neg b = Formula.imp b Formula.falsum := rfl
example : (Formula.verum : Formula Nat) = Formula.imp Formula.falsum Formula.falsum := rfl

-- *** HW 1.3 ***


scoped notation "⟂" => Formula.falsum
scoped notation "⊤ᵢ" => Formula.verum
scoped notation "⟪" p "⟫" => Formula.atom p

scoped prefix:max "∼" => Formula.neg
scoped infixr:35 " ⋀ " => Formula.and
scoped infixr:30 " ⋁ " => Formula.or
scoped infixr:25 " ⇒ " => Formula.imp

-- p ⋀ q（令 p = 0、q = 1）
def ex6 : Formula Nat :=
  ⟪0⟫ ⋀ ⟪1⟫

-- (p ⋀ q) ⇒ ⟂ (令 p = 0、q = 1）
def ex7 : Formula Nat :=
  ⟪0⟫ ⋀ ⟪1⟫ ⇒ ⟂

-- p ⇒ (q ⋁ ⟂) (令 p = 0、q = 1）
def ex8 : Formula Nat :=
  ⟪0⟫ ⇒ ⟪1⟫ ⋁ ⟂

example : (⟪0⟫ ⋀ ⟪1⟫ ⇒ ⟪2⟫) =
    Formula.imp (Formula.and (.atom 0) (.atom 1)) (.atom 2) := rfl

example : (∼⟪0⟫ ⋀ ⟪1⟫) =
    Formula.and (Formula.neg (.atom 0)) (.atom 1) := rfl

example : (⟪0⟫ ⇒ ⟪1⟫ ⇒ ⟪2⟫) =
    Formula.imp (.atom 0) (Formula.imp (.atom 1) (.atom 2)) := rfl

example : (∼∼⟪0⟫) =
    Formula.neg (Formula.neg (.atom 0)) := rfl

example : Formula Nat := ⟪0⟫ ⋀ ∼⟪0⟫

-- *** HW 1.4 ***

/-- 原語節點數。atom、falsum 各算 1；二元連詞算 1 + 兩邊。 -/
def Formula.size {t : Type} : Formula t -> Nat
  | .atom _ => 1
  | .falsum => 1
  | .and a b => 1 + Formula.size a + Formula.size b
  | .or a b => 1 + Formula.size a + Formula.size b
  | .imp a b => 1 + Formula.size a + Formula.size b


-- ⟪0⟫ 的 size 是 1
example : Formula.size ⟪0⟫ = 1 := rfl

-- ⟂ 的 size 是 1
example : Formula.size (⟂ : Formula Nat) = 1 := rfl

-- ⟪0⟫ ⋀ ⟪1⟫ 的 size 是 3
example : Formula.size ( ⟪0⟫ ⋀ ⟪1⟫ : Formula Nat) = 3 := rfl

-- ∼⟪0⟫ 的 size 是 3（因為它是 imp + atom + falsum）
example : Formula.size ( ∼⟪0⟫ : Formula Nat) = 3 := rfl

-- ⊤ᵢ 的 size 是 3
example : Formula.size ( ⊤ᵢ : Formula Nat) = 3 := rfl

end Mylogic
