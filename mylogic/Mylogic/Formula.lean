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
  *  左子樹 : 原子 b : Formula a
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

-- ∼p（應等於 p ⇒ ⟂）
def ex4 : Formula Nat :=
  Formula.imp (Formula.neg (Formula.atom 0)) (Formula.imp (Formula.atom 0) Formula.falsum)

-- ⊤ᵢ（應等於 ⟂ ⇒ ⟂）
def ex5 : Formula Nat :=
  Formula.imp (Formula.verum : Formula Nat) (Formula.imp Formula.falsum Formula.falsum)

example (b : Formula Nat) : Formula.neg b = Formula.imp b Formula.falsum := rfl
example : (Formula.verum : Formula Nat) = Formula.imp Formula.falsum Formula.falsum := rfl

end Mylogic
