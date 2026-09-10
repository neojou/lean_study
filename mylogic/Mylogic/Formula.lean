-- example : Formula N := (0) ^ ~(0)
namespace Mylogic

/--
 *  Formula 資料樹
 *      Formula Nat : 原子是自然數的公理式
 *      Formula String : 原子是字串的公理式
--/
inductive Formula (a : Type) where
  -- atom 原子 - 葉子
  | atom : a → Formula a
  -- falsum 荒謬 - 葉子
  | falsum : Formula a
  -- and 合取 - 兩個子樹
  | and : Formula a → Formula a → Formula a
  -- or 析取 - 兩個子樹
  | or : Formula a → Formula a → Formula a
  -- imp 蕴含 - 兩個子樹
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

end Mylogic
