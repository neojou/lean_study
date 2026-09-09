# Lesson 1：把命題語言做成歸納型

> 這是一堂課，不是一份要貼進 repo 的解答。
> 對應 [`TASKS.md`](TASKS.md) 的 **Phase 1**，規格是 [`first-order-logic.md`](first-order-logic.md) 第 5 節。
> 你自己實作；五份作業都過關，Phase 1 就完成。
> **為何會有這份講義、瀏覽器裡的 Grok 該扮演什麼角色：** 見 [`handoff.md`](handoff.md) 第 0–1 節。不要把本檔當完整 `Formula.lean` 貼給作者。
> 檔名 `lession1.md` 是指定拼寫，不要改成 `lesson1.md`。
> 日期：2026-09-09。

---

同學好。Phase 0 過了：專案能編、能跑、會說 Hello。從這一週開始，我們不再玩 Lake 模板，而要讓 Lean **長出一套語言**。

請把目標講清楚。我們**不是**在 Lean 的 `Prop` 裡寫直覺主義數學——那是 `mymathlib` 的路線。我們是把 Lean 當**後設語言**，編碼另一套**對象語言**。本週只做對象語言的**字母表與公式**。沒有 `⊢`，沒有推導規則，沒有真假。有人會手癢想寫自然演繹——請把那隻手壓住。公式都還沒定義，談推導是空的。

本週結束時，你的 repo 裡應該有一個型別 `Mylogic.Formula`，使得

```lean
example : Formula ℕ := ⟪0⟫ ⋀ ∼⟪0⟫
```

能通過型別檢查，而且這裡的 `⋀`、`∼` **不是** Lean 的 `∧`、`¬`。

---

## 0. 先讀什麼、繳什麼

**課前。** 規格書第 2 節（兩層語言）與第 5 節（命題語法）。不必先把 NJ 規則背完。

**課中。** 本檔第 1–9 節。每讀完標「先做作業 N」的地方，就去寫程式，再讀下一節。不要一次讀完再通宵趕工——後面的作業依賴前面已經能編譯的定義。

**繳交。** 主要檔案只有 `Mylogic/Formula.lean`；作業五還要改 `Mylogic.lean` 的 import。不要開 `Deduction.lean`，不要 `import Mathlib`，不要動 `lakefile.toml`。`hello` 模板留著，Phase 0 的 exe 還應該印 `Hello, world!`。

**禁寫清單**（出現任何一條，作業退回）：

- 把對象合取的結果寫成 `Prop`
- 用 `∧` `∨` `→` `¬` `False` 當對象連詞的記號
- 給 `Formula` 加上 `neg` 或量詞 constructor
- `open Classical` 或 `import Mathlib`

---

## 1. 為什麼要把公式當成資料？

邏輯課本寫：

> 若 `φ`、`ψ` 是公式，則 `(φ ∧ ψ)` 是公式。

這句話有兩個讀法。

第一種：你已經活在某個邏輯裡，`φ` 是命題，`∧` 是那個邏輯的「且」。這是**使用**語言。

第二種：`φ` 是一棵樹、一串符號、一個可以拿來數葉子的物件；「是公式」是這類物件的歸納定義。這是**談論**語言。

本專案做第二種。Lean 裡，`2 + 2 = 4` 是後設世界的命題；我們的 `⟪p⟫ ⋀ ⟪q⟫` 只是一棵語法樹。它此刻既不真也不假，就像 Lisp 的 S-expression 還沒收斂到值。真假是後面 Kripke 的事，可證是後面 NJ 的事。

若你把對象公式直接定義成 Lean 的 `Prop`，兩層語言會黏在一起。以後證「排中律不可證」時，你會分不清自己到底在否定對象規則，還是在否定 Lean 自己。那是這門課最貴的混淆，本週就要預防。

---

## 2. 邏輯學裡的歸納定義

規格書第 5 節用口語寫了公式的子句。寫成 BNF 是：

```
φ, ψ  ::=  ⟪p⟫  |  ⟂  |  (φ ⋀ ψ)  |  (φ ⋁ ψ)  |  (φ ⇒ ψ)
```

其中 `p` 來自一類原子（命題變元）。這五條就是**原語**。

下面兩個**不是**原語：

```
∼φ   :=  φ ⇒ ⟂
⊤ᵢ   :=  ⟂ ⇒ ⟂
```

「不是原語」的意思是：語法樹裡沒有名叫「否定」的節點。否定是一種**縮寫**。雙重否定 `∼∼φ` 展開後是 `(φ ⇒ ⟂) ⇒ ⟂`，一共三個原語節點：兩個 `⇒`、一個 `⟂`。

為什麼要這樣小氣？因為推導規則只要對原語寫引入／消除。否定的規則會變成蘊涵規則的特例。多一個 constructor，後面每一個「對公式歸納」都要多一個 case——而且那 case 跟蘊涵重複。

原子的集合寫成參數 `α`。第一版用 `ℕ` 就很好：`⟪0⟫`、`⟪1⟫` 當 `p`、`q`。用 `String` 也可以。不要為此去引 Mathlib。

---

## 3. Lean 的 `inductive`：用自然數當模型

你在 Day 0／Day 1 已經碰過 Lean。這裡把 `inductive` 講成「BNF 的型別版」。

Peano 自然數的 BNF 是 `n ::= 0 | S n`。Lean 裡（概念上）是：

```lean
inductive MyNat where
  | zero : MyNat
  | succ : MyNat → MyNat
```

讀法：

- `MyNat` 是一個型別，裡面的東西都是用這兩種方式造出來的。
- `zero`、`succ` 叫 **constructor（建構子）**。
- 沒有別的 `MyNat`。要證明「所有自然數都有某性質」，就對這兩個 constructor 歸納。

Constructor 是**造資料**的方法，不是定理。`MyNat.succ MyNat.zero` 是資料 `1`，它不「成立」，它只是存在。

公式也一樣：`Formula.and φ ψ` 是資料，不是「φ 且 ψ 為真」這句後設命題。

課堂練習（心中做即可，不必繳）：若有人寫

```lean
inductive MyNat where
  | zero : MyNat
  | succ : MyNat → MyNat
  | double : MyNat → MyNat   -- 多餘
```

則 `double` 讓「每個數的唯一表示」壞掉，歸納也多一個 case。對象語言裡的「多餘否定 constructor」是同一類錯誤。

---

## 4. 型別參數：原子的種類

公式裡的原子來自某一個集合。Lean 用型別參數表示：

```lean
inductive Formula (α : Type) where
  ...
```

`Formula ℕ` 是「原子為自然數的公式」；`Formula String` 是另一種。第一版請固定用 `ℕ` 寫例子，但**定義本身不要寫死 `ℕ`**——後面會感謝你。

`Formula` 是 `Type → Type`：給它一種原子，它還你一種公式。它**不是** `Prop`。請把這句話寫在檔案開頭的中文註解裡（作業一會要）。

---

## 5. 黑板：五個建構子

把第 2 節的 BNF 翻譯成 Lean。constructor 名稱必須與規格、[`AGENTS.md`](AGENTS.md)、[`TASKS.md`](TASKS.md) 一致，後面 Phase 2 才對得上。

| BNF | constructor | 型別（概念上） |
|---|---|---|
| 原子 `⟪p⟫` | `atom` | `α → Formula α` |
| 荒謬 `⟂` | `falsum` | `Formula α` |
| 合取 | `and` | `Formula α → Formula α → Formula α` |
| 析取 | `or` | 同上 |
| 蘊涵 | `imp` | 同上 |

黑板草稿（這是講義內容，不是叫你放棄思考；**請你自己打進檔案**，並用自己的話寫中文註解）：

```lean
inductive Formula (α : Type) where
  | atom   : α → Formula α
  | falsum : Formula α
  | and    : Formula α → Formula α → Formula α
  | or     : Formula α → Formula α → Formula α
  | imp    : Formula α → Formula α → Formula α
```

三個必須立刻記住的細節：

1. `and` 的回傳型別是 `Formula α`，**不是** `Prop`。對象合取造一棵較大的樹，不造一個後設命題。
2. 沒有第六個 constructor。`neg` 下一節才用 `def` 做。
3. 在檔案裡用 `namespace Mylogic` 包起來，讓全名是 `Mylogic.Formula`。Lake 的模組名已經是 `Mylogic`；namespace 與模組是兩件事，兩者都用 `Mylogic` 是本專案的約定。

造一棵樹、暫時不用記號：

```lean
-- (p ⋀ q) ⇒ ⟂ ，若 p := 0、q := 1
def ex₀ : Formula ℕ :=
  Formula.imp (Formula.and (Formula.atom 0) (Formula.atom 1)) Formula.falsum
```

同一棵樹，用點記法（constructor 寫在點後面時，Lean 會看期望型別）：

```lean
def ex₀' : Formula ℕ :=
  .imp (.and (.atom 0) (.atom 1)) .falsum
```

兩種都可以。作業一請至少用一種寫出三個例子。

---

## 6. 檔案放哪裡、誰 import 誰

Lean 4 的模組路徑跟檔案路徑對齊：

| 檔案 | 模組名 |
|---|---|
| `Mylogic.lean` | `Mylogic`（函式庫入口） |
| `Mylogic/Basic.lean` | `Mylogic.Basic`（Phase 0 的 `hello`） |
| `Mylogic/Formula.lean` | `Mylogic.Formula`（本週要新建） |

入口檔 `Mylogic.lean` 必須 `import` 你希望編成函式庫的子模組。現在它只 import 了 `Basic`。作業五才把 `Formula` 接上去——前面四份作業可以先在 `Formula.lean` 裡自己過型別檢查，用

```
lake build Mylogic.Formula
```

或先暫時在入口加 import（若你作業一就接上，也可以，但不要 import 不存在的 `Deduction`）。

`Main.lean` 繼續 `import Mylogic` 並印 Hello。本週**不必**讓 exe 印公式。

入口要寫 **`import Mylogic.Formula`**（Lake 模組名，小寫 l）。舊草稿的 `MyLogic` 會讓 `lake build` 在連結階段失敗。作業一不必急著改入口；作業五才強制接上。

---

### 作業一（HW1.1）——歸納型落地

讀完第 1–6 節再做。

1. 新建 `Mylogic/Formula.lean`。
2. `namespace Mylogic` … `end Mylogic`。
3. 定義 `inductive Formula (α : Type)`，五個 constructor，名稱如上。沒有 `neg`。
4. 檔案開頭用繁中註解（至少三句）說明：這是對象語法、不是 Lean 的 `Prop`、原語只有這五個。
5. 每個 constructor 一行中文註解。
6. 在 namespace 內寫三個 `def`（名字自訂），型別都是 `Formula ℕ`，**只用 constructor、不用記號**：
   - `p ⋀ q`（令 `p = 0`、`q = 1`）
   - `(p ⋀ q) ⇒ ⟂`
   - `p ⇒ (q ⋁ ⟂)`
7. 此時**還不要**定義 `∼`、**還不要** `notation`。

**驗收。** `lake build` 仍綠（若尚未改入口，至少 `Formula.lean` 本身無錯）。`#check` 那三個 `def` 看得到 `Formula ℕ`。禁寫清單沒被違反。

---

## 7. 定義連詞：為什麼 `∼` 不是建構子

數學上 `∼φ := φ ⇒ ⟂` 是**定義等式**：左邊是縮寫，右邊才是真正的樹。

Lean 對應物是 `def`，不是 inductive 的新分支。

```lean
variable {α : Type}

/-- 對象否定：∼φ := φ ⇒ ⟂。這是定義，不是新的語法節點。 -/
def Formula.neg (φ : Formula α) : Formula α :=
  Formula.imp φ Formula.falsum

/-- 對象真：⊤ᵢ := ⟂ ⇒ ⟂。 -/
def Formula.verum : Formula α :=
  Formula.imp Formula.falsum Formula.falsum
```

`variable {α : Type}` 讓後面的定義不必每次都寫 `{α : Type}`。花括號表示隱式參數：用的時候 Lean 會自己推。

請分辨三種東西：

| 東西 | 例子 | 以後歸納時有沒有獨立 case？ |
|---|---|---|
| constructor | `atom`、`falsum`、`and`、`or`、`imp` | 有 |
| 定義 | `neg`、`verum` | 沒有；會展開成 constructor |
| 記號 | `∼`、`⊤ᵢ` | 沒有；只是輸入法 |

因此：對 `Formula` 做 `match` 時，**不會**出現 `| neg φ => ...` 這一枝。若你寫得出那一枝，代表作業一不小心加了第六個 constructor，請回去刪。

`∼∼φ` 是 `Formula.neg (Formula.neg φ)`，展開為

```
Formula.imp (Formula.imp φ Formula.falsum) Formula.falsum
```

這棵樹以後會成為「雙重否定引入可證、消除不可證」的舞台。本週只要保證它**造得出來**。

---

### 作業二（HW1.2）——定義連詞

1. 在 `Formula.lean` 裡加上 `Formula.neg` 與 `Formula.verum`（`def`，不是 constructor）。
2. 各寫一句中文：這是定義、展開成什麼。
3. 再加兩個 `def`（`Formula ℕ`）：
   - `∼p`（應等於 `p ⇒ ⟂`）
   - `⊤ᵢ`（應等於 `⟂ ⇒ ⟂`）
4. 用 `example` 確認定義真的是那棵樹（這是本週最重要的一題，請認真寫）：

```lean
example (φ : Formula ℕ) : Formula.neg φ = Formula.imp φ Formula.falsum := rfl
example : (Formula.verum : Formula ℕ) = Formula.imp Formula.falsum Formula.falsum := rfl
```

`rfl` 能過，表示兩邊定義上就是同一個項，不是「以後再證等價」。

**驗收。** 兩個 `rfl` 通過。`Formula` 仍只有五個 constructor（可用 `#print Formula` 看）。

---

## 8. 記號：讓公式長得像邏輯書，但不要搶 Lean 的符號

Constructor 名稱適合機器，不適合人。我們要記號，但必須**scoped**：只有 `open Mylogic`（或人已經在 `namespace Mylogic` 裡）時才啟用。否則全專案的 `∧` 會變成戰場。

本專案的對象記號是規格定好的：

| 意義 | 對象記號 | 對應 | 禁止用的 Lean 記號 |
|---|---|---|---|
| 原子 | `⟪p⟫` | `Formula.atom p` | （無） |
| 假 | `⟂` | `Formula.falsum` | `False` |
| 真 | `⊤ᵢ` | `Formula.verum` | `True` |
| 否定 | `∼` | `Formula.neg` | `¬` |
| 合取 | `⋀` | `Formula.and` | `∧` |
| 析取 | `⋁` | `Formula.or` | `∨` |
| 蘊涵 | `⇒` | `Formula.imp` | `→` |

Lean 4 常用寫法：

```lean
scoped notation "⟂" => Formula.falsum
scoped notation "⊤ᵢ" => Formula.verum
scoped notation "⟪" p "⟫" => Formula.atom p

scoped prefix:max "∼" => Formula.neg
scoped infixr:35 " ⋀ " => Formula.and
scoped infixr:30 " ⋁ " => Formula.or
scoped infixr:25 " ⇒ " => Formula.imp
```

這組數字是**建議**，與 Lean 自己的 `∧`（35）、`∨`（30）、`→`（25）同層，方便記憶。你必須用作業三的 `rfl` 測試確認解析結果；測不過就改優先順序，不要怪 Unicode。

幾個觀念：

- `scoped`：記號綁在 namespace 上。沒有 `open Mylogic` 時，外面的 Lean 程式不該突然會解析 `⋀`。
- `infixr`：右結合。`φ ⇒ ψ ⇒ χ` 讀成 `φ ⇒ (ψ ⇒ χ)`，這是邏輯學慣例。
- `prefix:max`：`∼` 綁得比 `⋀` 緊，所以 `∼φ ⋀ ψ` 是 `(∼φ) ⋀ ψ`，不是 `∼(φ ⋀ ψ)`。
- 合取比蘊涵緊，所以 `φ ⋀ ψ ⇒ χ` 應是 `(φ ⋀ ψ) ⇒ χ`。

`open Mylogic` 與 `open scoped Mylogic` 的差別：前者連名字一起打開，後者主要打開 scoped 的記號／instance。在 `namespace Mylogic` 內部，你剛定義的記號通常已經能用。

若 `#check ⟪0⟫` 說 unknown identifier，多半是人在 namespace 外面、又沒有 `open`。

---

### 作業三（HW1.3）——scoped notation

1. 加上上一節那七個 scoped 記號（優先順序可按建議，但必須通過下面的測試）。
2. 用記號重寫作業一的三個例子（可以新 `def`，舊的 constructor 版請留著當對照）。
3. **解析測試**（請原樣放進檔案；型別註解可以是 `Formula ℕ`）。這些 `rfl` 過了，才算記號綁對：

```lean
example : (⟪0⟫ ⋀ ⟪1⟫ ⇒ ⟪2⟫) =
    Formula.imp (Formula.and (.atom 0) (.atom 1)) (.atom 2) := rfl

example : (∼⟪0⟫ ⋀ ⟪1⟫) =
    Formula.and (Formula.neg (.atom 0)) (.atom 1) := rfl

example : (⟪0⟫ ⇒ ⟪1⟫ ⇒ ⟪2⟫) =
    Formula.imp (.atom 0) (Formula.imp (.atom 1) (.atom 2)) := rfl

example : (∼∼⟪0⟫) =
    Formula.neg (Formula.neg (.atom 0)) := rfl
```

4. 再寫一個本週的「吉祥物」：

```lean
example : Formula ℕ := ⟪0⟫ ⋀ ∼⟪0⟫
```

若第 3 點的第一個 `example` 編不過，通常是 `⋀` 沒有比 `⇒` 緊。若第二個編不過，通常是 `∼` 綁太鬆。不要用括號把測試改到永遠成立——括號是來救命的，不是來把作業改掉的。

**驗收。** 四個 `rfl` 加一個吉祥物 `example` 全過。檔案裡找不到 `∧` `∨` `→` `¬` 當對象記號。

---

## 9. 結構遞迴與 `deriving`

公式是樹，就可以對樹寫函數。這不是 Phase 1 的規格必備項，但是學 `inductive` 不做 `match`，等於學了字母不拼字。本週用一個最笨的函數：數節點。

自然數上你見過這種形狀：

```lean
def MyNat.double : MyNat → Nat
  | .zero => 0
  | .succ n => n.double + 2
```

對 `Formula` 也一樣：每個 constructor 一枝。**沒有** `| .neg φ => ...`。否定節點不存在；`∼φ` 已經是一棵 `imp`。

請你定義：

```lean
/-- 原語節點數。atom、falsum 各算 1；二元連詞算 1 + 兩邊。 -/
def Formula.size {α : Type} : Formula α → Nat
```

預期：

- `⟪0⟫` 的 size 是 1
- `⟂` 的 size 是 1
- `⟪0⟫ ⋀ ⟪1⟫` 的 size 是 3
- `∼⟪0⟫` 的 size 是 3（因為它是 `imp` + `atom` + `falsum`）
- `⊤ᵢ` 的 size 是 3

最後一點是 conceit check：若有人把 `verum` 做成 constructor，`⊤ᵢ` 的 size 會變成 1，測驗會抓到。

（可選，但建議。）在 `inductive Formula` 的結尾加：

```lean
deriving Repr, DecidableEq
```

`Repr` 讓 `#eval` 印得出樹；`DecidableEq` 以後 Phase 2 的 `φ ∈ Γ` 會比較好過。兩者都需要原子型別本身也有對應 instance（`ℕ` 有）。若 `deriving` 報錯，先拿掉、作業四仍可只交 `size`；在檔案註解寫你卡在哪。

`#eval` 範例（有 `Repr` 才比較好看）：

```lean
#eval (⟪0⟫ ⋀ ∼⟪0⟫ : Formula ℕ)
```

---

### 作業四（HW1.4）——對語法樹遞迴

1. 寫 `Formula.size`，五個 constructor 各一枝。
2. 用 `rfl` 或 `example : Formula.size ... = ... := rfl` 驗證上一節列出的五個數字（至少驗證 `∼⟪0⟫` 與 `⊤ᵢ` 都是 3）。
3. （建議）`deriving Repr, DecidableEq`。
4. 仍不要寫推導關係。

**驗收。** `∼p` 與 `⊤ᵢ` 的 size 是 3。`match` 沒有 `neg` 枝。

---

## 10. 接上函式庫入口

到這裡，`Formula.lean` 應該已經是一個完整的小模組。最後一步是讓它屬於 `Mylogic` 這座函式庫，而不是一個孤兒檔。

`Mylogic.lean` 現在大概是：

```lean
import Mylogic.Basic
```

請改成**兩個都 import**（順序無所謂，但不要刪 `Basic`，否則 `Main.lean` 的 `hello` 會掛）。注意拼法是 `Mylogic`：

```lean
import Mylogic.Basic
import Mylogic.Formula
```

不要加 `import Mylogic.Deduction` 或 `FirstOrder`。

然後從 `mylogic/` 目錄：

```sh
lake build
lake exe mylogic
```

預期：編譯成功；exe 仍印 `Hello, world!`。

---

### 作業五（HW1.5）——總驗收（= Phase 1 完成條件）

把下面這份清單當成期末小考。全部成立，才能在 [`TASKS.md`](TASKS.md) 把 Phase 1 的核取清單打勾。

- [ ] `Mylogic/Formula.lean` 存在，`namespace Mylogic`。
- [ ] `Formula` 五個 constructor：`atom`、`falsum`、`and`、`or`、`imp`。沒有 `neg`。
- [ ] `Formula.neg`、`Formula.verum` 是 `def`；兩個定義性 `rfl` 通過。
- [ ] scoped 記號齊：`⟂` `⊤ᵢ` `∼` `⋀` `⋁` `⇒` `⟪p⟫`。
- [ ] 作業三的四個解析 `rfl` 通過。
- [ ] `example : Formula ℕ := ⟪0⟫ ⋀ ∼⟪0⟫` 通過。
- [ ] `Formula.size` 對 `∼⟪0⟫` 與 `⊤ᵢ` 給出 3。
- [ ] 繁中註解說明「這是對象語法，不是 Lean 的 `Prop`」。
- [ ] `Mylogic.lean` 有 `import Mylogic.Formula`，且沒有幽靈 import。
- [ ] `lake build` 綠；`lake exe mylogic` 仍是 `Hello, world!`。
- [ ] 無 Mathlib、無 Classical、無對象記號盜用 `∧∨→¬`。

對應回 TASKS Phase 1 原列的完成條件：那一條「能寫出 `⟪0⟫ ⋀ ∼⟪0⟫`」已被作業三／五覆蓋；`size` 是本講義多要求的課堂練習，但仍在 `Formula.lean` 裡，不進入 Phase 2。

---

## 附錄 A — 教授改作業時常見的十個叉

1. **`and` 回傳 `Prop`。** 那你造的是後設命題，不是對象公式。退回。
2. **第六個 constructor 叫 `neg`。** `#print Formula` 會出賣你。用 `def`。
3. **記號用了 `∧`。** 兩層語言黏住了。改 `⋀`。
4. **`∼φ ⋀ ψ` 解析成 `∼(φ ⋀ ψ)`。** 調整 `prefix` 優先順序。
5. **`φ ⋀ ψ ⇒ χ` 解析成 `φ ⋀ (ψ ⇒ χ)`。** 讓 `⋀` 比 `⇒` 緊。
6. **在 namespace 外使用 `⟪0⟫` 失敗。** `open Mylogic`，或把例子放進 namespace。
7. **`verum` 被做成 constructor。** 則 `⊤ᵢ` 的 `size` 不是 3。
8. **作業三把測試加上括號讓 `rfl` 碰巧成立。** 那是在改考題。
9. **`import Mathlib`「只是為了 Repr」。** 標準庫自己會 deriving，不需要 Mathlib。
10. **順便寫了 `Deduction`。** 熱情可嘉，本週零分（開玩笑的；請另開 Phase 2 再寫）。
11. **`import MyLogic.Formula`（大寫 L）。** 模組是 `Mylogic`。拼錯時錯誤常出現在連結器（`undefined symbol: initialize_mylogic_MyLogic_Formula`），不一定像「找不到檔案」。

---

## 附錄 B — 兩層語言（本週用得到的那幾格）

| | 後設（Lean） | 對象（本週） |
|---|---|---|
| 假 | `False` | `⟂` |
| 真 | `True` | `⊤ᵢ` |
| 否定 | `¬` | `∼` |
| 合取 | `∧` | `⋀` |
| 析取 | `∨` | `⋁` |
| 蘊涵 | `→` | `⇒` |
| 「這是一棵公式樹」 | 型別 `Formula α` | （就是那棵樹） |
| 「這句話可證」 | 有一個 `Prop` 的證明項 | **下週才有** `⊢` |

本週沒有最後一列。若你發現自己在證 `φ → φ`，你走錯層了。

---

## 附錄 C — 建議的實作節奏

| 時段 | 讀 | 做 | 停手條件 |
|---|---|---|---|
| 一 | §1–6 | HW1.1 | 三個 constructor 例子能 `#check` |
| 二 | §7 | HW1.2 | 兩個定義性 `rfl` |
| 三 | §8 | HW1.3 | 四個解析 `rfl` + 吉祥物 |
| 四 | §9 | HW1.4 | `∼p`、`⊤ᵢ` 的 size = 3 |
| 五 | §10 | HW1.5 | `lake build` 且 exe 仍 Hello |

卡住超過二十分鐘：先 `#print Formula`，再看附錄 A。仍卡著，把**錯誤訊息原文**和你的 `Formula.lean` 帶來問，不要先要解答檔。

下一堂課（Phase 2）會把 `Γ ⊢ φ` 做成歸納謂詞。那棵語法樹將第一次被「使用」。本週把它造得乾淨，下週才有好日子過。
