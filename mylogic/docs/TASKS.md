# TASKS：在 Lean 裡建造對象邏輯（學習課綱）

> 這不是一次做完的工單。每個 Phase 結束都要能 `lake build`。
> 邏輯規格：[`first-order-logic.md`](first-order-logic.md)。硬約束：[`AGENTS.md`](AGENTS.md)。緣由：[`handoff.md`](handoff.md)。
> Phase 1 講義：[`lession1.md`](lession1.md)。**Phase 0 已完成。**
> 下一輪在瀏覽器：讀 [`handoff.md`](handoff.md)（含為何有講義、模型當助教不代寫）。
> 日期：2026-09-09。

---

## 怎麼用這份課綱

- **目標讀者**：會一點 Lean（看過 Day 0／Day 1 那種程度），想靠「自建邏輯」練習歸納型、歸納謂詞、證明項、後設歸納。
- **一次一個 Phase。** 不要在 Phase 3 還沒綠之前開 Kripke，更不要在 Phase 7 之前開 FOL。
- **對象證明**用 NJ constructor 組項；**後設證明**對 `Formula`／`Deduction` 歸納。兩邊都是在練 Lean，但練的肌群不同。
- **不要 `import Mathlib`。** 不要 `open Classical`。不要對不可判定的命題 `by_cases`。
- 重要定理旁寫一句中文：「這是對象還是後設」，並在模組末或 `PrintAxioms.lean` 留 `#print axioms`。
- 模組名是 `Mylogic`（Lake 預設），不是舊草稿的 `MyLogic`。
- 規則名稱必須與規格書第 6、14 節一致。

核對進度時，把 `[ ]` 改成 `[x]`。Phase 1 請先做完 `lession1.md` 的作業再打勾。

---

## 你會練到的 Lean（總覽）

| Phase | 邏輯 | Lean 機制 |
|---|---|---|
| 0 | 專案能編 | Lake 模組、import 圖 |
| 1 | 公式語法 | `inductive`、`namespace`、`notation`、`deriving` |
| 2 | NJ 推導 | 歸納謂詞（inductive family）、`List`、constructor 的型別 |
| 3 | 對象小定理 | 證明項、`apply`／`exact`／`have`、scoped notation |
| 4 | 後設引理 | `induction` 於歸納謂詞、generalize、動機「證明關於證明的定理」 |
| 5 | Kripke | `structure`、遞迴函數、對公式歸納 |
| 6 | 反模型 | 具體歸納型當世界、健全性的逆否 |
| 7 | 公理衛生 | `#print axioms`、避免偷偷引入 `Classical.choice` |
| 8 | 一階 | 第二套歸納型、代入／shift、側條件 |

`mymathlib` 走的是「在 Lean 邏輯裡做數學」。這裡走的是「用 Lean 編碼另一套邏輯」。兩條線的檔案不要混。

---

## Phase 0 — 專案衛生

**狀態：完成（2026-09-09）。** 作者已能 `lake build`、`lake exe mylogic`，輸出 `Hello, world!`。後續 session 於同日複核通過。

**目標。** 這個 Lake 專案能編譯，root import 不指向幽靈模組。

**完成時的實際狀態。**

- 工具鏈：`leanprover/lean4:v4.33.1`
- `lakefile.toml` 無 Mathlib；`lake-manifest.json` 的 `packages` 為空。
- `Mylogic.lean` 只 `import Mylogic.Basic`（沒有幽靈模組）。
- 保留 Lake 模板：`Mylogic/Basic.lean` 的 `hello := "world"`；`Main.lean` 印 `Hello, {hello}!`。
- `Formula.lean`／`Deduction.lean` 仍不存在——那是 Phase 1 起的事。

**要做。**

- [x] `Mylogic.lean` 只 import 實際存在的模組。Phase 0 可以暫時繼續 `import Mylogic.Basic`，或改成空檔加一句註解；**不要**提前 `import Mylogic.FirstOrder`。
- [x] 決定 `hello` 的命運：保留當 Lake 模板、或讓 `Main.lean` 改印一句「Mylogic skeleton」。不要為此引入邏輯程式。
- [x] 確認 `lake build` 成功。
- [x] 確認沒有 Mathlib 依賴（`lakefile.toml`、`lake-manifest.json`）。

**完成條件。** `lake build` 綠；`Mylogic.lean` 沒有對不存在檔案的 import。

**陷阱。** 模組名是 `Mylogic`。寫成 `import MyLogic.Formula` 會編不過（離開 TUI 時的 WIP 已踩過）。

---

## Phase 1 — 命題語法

**狀態：進行中（講義已出，作者剛起頭）。** 為何用講義而不是代寫：見 [`handoff.md`](handoff.md) 第 1 節。不要一次貼完整 `Formula.lean`。讀 [`lession1.md`](lession1.md)，依序繳交 HW1.1–HW1.5；五份作業都通過時，本 Phase 的核取清單一併打勾。

離開 TUI 時的 WIP：`Mylogic/Formula.lean` 幾乎是空註解（HW1.1 的 inductive 尚未寫）；`Mylogic.lean` 有一行錯誤的 `import MyLogic.Formula`（應為 `Mylogic.Formula`），會讓 `lake build` 失敗。這是拼法問題，不是叫模型把 Phase 1 做完。

**目標。** 對象公式是一個歸納型，記號與規格書第 5 節一致。

**檔案。** `Mylogic/Formula.lean`，由 `Mylogic.lean` import。

**講義。** [`lession1.md`](lession1.md)（大學課堂：知識 + 循序作業）。規格仍以 `first-order-logic.md` 第 5 節為準。

**要練的 Lean。**

- `inductive Formula (α : Type) where` ……
- `namespace Mylogic`（或檔案頂層 `namespace`，與後續檔一致）。
- `scoped notation`：只在 open 了這個 namespace 時啟用，避免污染後設記號。
- （可選）`deriving Repr, DecidableEq`。`DecidableEq` 對之後 List 成員有幫助；若 deriving 不順，先手寫也不算失敗。

**建議形狀（規格，不是要你抄完就算）。**

```lean
inductive Formula (α : Type) where
  | atom   : α → Formula α
  | falsum : Formula α
  | and    : Formula α → Formula α → Formula α
  | or     : Formula α → Formula α → Formula α
  | imp    : Formula α → Formula α → Formula α
```

定義連詞（**定義**，不是新 constructor）：

```lean
def Formula.neg (φ : Formula α) : Formula α := φ.imp .falsum
def Formula.verum : Formula α := Formula.falsum.imp .falsum
```

記號（scoped，對齊規格）：`⟂` `⊤ᵢ` `∼` `⋀` `⋁` `⇒` `⟪p⟫`。

**要做**（對應 [`lession1.md`](lession1.md) 作業；作者打勾，模型不要代寫）。

- [ ] `Formula` 五個 constructor，沒有 `neg` constructor。（HW1.1）
- [ ] `∼φ := φ ⇒ ⟂`、`⊤ᵢ := ⟂ ⇒ ⟂`。（HW1.2）
- [ ] scoped notation 齊全。（HW1.3）
- [ ] 短中文註解：這是對象語法，不是 Lean 的 `Prop`。（HW1.1）
- [ ] `lake build`。（HW1.5；講義另要求 `Formula.size` 見 HW1.4）

**完成條件。** 能寫出型別檢查通過的項，例如 `⟪0⟫ ⋀ ∼⟪0⟫`（若 `α := ℕ`）。

**陷阱。**

- 不要寫 ` | and : Formula α → Formula α → Prop`。對象合取的結果仍是 `Formula`，不是後設命題。
- 不要 `notation "∧" => Formula.and`，會跟 Lean 的 `∧` 打成一片。用 `⋀`。
- `α` 第一版用 `ℕ` 或 `String` 都可以。不要為了原子去引 Mathlib 的 `Finset`。

**對應規格。** `first-order-logic.md` 第 5 節。

---

## Phase 2 — NJ 推導關係

**目標。** `Γ ⊢ φ` 是歸納謂詞。規則與規格書第 6 節同名。

**檔案。** `Mylogic/Deduction.lean`。

**要練的 Lean。**

- 依值於 `List (Formula α)` 與 `Formula α` 的歸納謂詞：
  `inductive Deduction : List (Formula α) → Formula α → Prop`
- constructor 的參數裡可以再出現 `Deduction …`（遞迴前提）。
- `List.Mem`（`∈`）當 `ax` 的前提。
- `infix:50 " ⊢ " => Deduction`（同樣 scoped）。空脈絡可另定義 `⊢ φ` 當 `[] ⊢ φ` 的語法糖。

**Constructor 清單（必須齊，名稱必須對）。**

| 名字 | 結論 | 前提／側條件 |
|---|---|---|
| `ax` | `Γ ⊢ φ` | `φ ∈ Γ` |
| `weaken` | `ψ :: Γ ⊢ φ` | `Γ ⊢ φ` |
| `andI` | `Γ ⊢ φ ⋀ ψ` | `Γ ⊢ φ`、`Γ ⊢ ψ` |
| `andEL` | `Γ ⊢ φ` | `Γ ⊢ φ ⋀ ψ` |
| `andER` | `Γ ⊢ ψ` | `Γ ⊢ φ ⋀ ψ` |
| `orIL` | `Γ ⊢ φ ⋁ ψ` | `Γ ⊢ φ` |
| `orIR` | `Γ ⊢ φ ⋁ ψ` | `Γ ⊢ ψ` |
| `orE` | `Γ ⊢ χ` | `Γ ⊢ φ ⋁ ψ`、`φ :: Γ ⊢ χ`、`ψ :: Γ ⊢ χ` |
| `impI` | `Γ ⊢ φ ⇒ ψ` | `φ :: Γ ⊢ ψ` |
| `impE` | `Γ ⊢ ψ` | `Γ ⊢ φ ⇒ ψ`、`Γ ⊢ φ` |
| `falsumE` | `Γ ⊢ φ` | `Γ ⊢ ⟂` |

**導出（`def`／`theorem`，不是 constructor）。**

- [ ] `negI`、`negE`（用 `impI`／`impE`）
- [ ] `verumI`
- [ ] `ax_head`：`φ :: Γ ⊢ φ`（`ax` 的頭元素特例，對象證明會常用）
- [ ] `weaken_list`：前面加一整列
- [ ] `cut`：`Γ ⊢ φ` 與 `φ :: Γ ⊢ ψ` 得 `Γ ⊢ ψ`（`impI` + `impE`）

**要做。**

- [ ] 上述 constructor 齊。
- [ ] 導出規則齊。
- [ ] 每個 constructor 一行中文：對應哪條 NJ 規則。
- [ ] **沒有** `lem`／`raa`／`dne` constructor。
- [ ] `lake build`。

**完成條件。** 型別檢查通過；用 `#check` 能看到 `impI` 的型別是 `(φ :: Γ ⊢ ψ) → (Γ ⊢ φ ⇒ ψ)` 這種形狀。

**陷阱。**

- `impI` 的前提脈絡是 `φ :: Γ`，不是 `Γ ++ [φ]`。列的方向要從頭固定，後面所有證明都依賴它。
- `orE` 有三棵子樹，漏一棵會編不過。兩支假設各自把 `φ` 或 `ψ` **推到列頭**。
- `ax` 若只寫成 `ax_head`，後面弱化會很痛；用 `∈` 較順。
- 判斷寫成 `Prop`（我們要的是可證性），不要寫成 `Type` 除非你明確想做證明相關的推導樹資料。第一版用 `Prop` 即可：後設歸納對 IPC 夠用，也比較像「邏輯判斷」。

**對應規格。** 第 6–7 節。

---

## Phase 3 — 對象小定理（組證明項）

**目標。** 用手組出幾棵 NJ 樹。這是在練「證明項」，不是 tactic 魔術。

**檔案。** `Mylogic/Examples.lean`。

**要練的 Lean。**

- 用 constructor 組項：`Deduction.impI (Deduction.ax_head)` 這種。
- 或用 tactic 但每一步對應一條規則：`apply Deduction.impI`、`exact Deduction.ax_head`。
- `variable {α : Type} {φ ψ : Formula α}` 讓定理對任意公式成立。
- 對象定理的結論型別是 `⊢ φ` 或 `[] ⊢ φ`，**不是** Lean 的 `φ`（`φ` 根本不是 `Prop`）。

**必做對象定理。**

- [ ] `imp_id`：`⊢ φ ⇒ φ`
- [ ] `and_comm`：`⊢ (φ ⋀ ψ) ⇒ (ψ ⋀ φ)`
- [ ] `dni`：`⊢ φ ⇒ ∼∼φ`（雙重否定**引入**）

**建議加（仍是對象、仍可證）。**

- [ ] `or_comm`：`⊢ (φ ⋁ ψ) ⇒ (ψ ⋁ φ)`
- [ ] `k_axiom`：`⊢ φ ⇒ (ψ ⇒ φ)`（Hilbert K）
- [ ] `ex_falso_imp`：`⊢ ⟂ ⇒ φ`

**刻意不要證（會卡住是正確的）。**

- `⊢ φ ⋁ ∼φ`
- `⊢ ∼∼φ ⇒ φ`
- `⊢ ∼(φ ⋀ ψ) ⇒ (∼φ ⋁ ∼ψ)`

最後一條可當「試試看為什麼組不出來」的練習：在註解裡寫你卡在哪一條規則（通常是 `orIL`／`orIR` 必須選邊）。**不要**為了讓它通過而加 LEM。

**要做。**

- [ ] 三個必做定理。
- [ ] 每個定理上方一句中文：這是對象定理。
- [ ] 可選：`#print axioms imp_id` 等（正式集中檢查留給 Phase 7）。
- [ ] `lake build`。

**完成條件。** 三個必做定理 type check。沒有 DNE／LEM 的「證明」。

**陷阱。**

- 寫成 `theorem imp_id : φ → φ` 是在證 Lean 的恆等，**完全做錯層**。正確是 `⊢ φ ⇒ φ`。
- `dni` 的目標展開後是 `φ ⇒ ((φ ⇒ ⟂) ⇒ ⟂)`。先 `impI` 兩次，再 `impE`。
- tactic 模式可以，但若開始用 `tauto`／`aesop`／Mathlib 的 `finish`，停下來。本練習的點是看到規則。

**對應規格。** 第 7.5、8 節。

---

## Phase 4 — 後設引理與析取性質

**目標。** 證明關於推導的定理。這是本課綱裡「Lean 歸納」最重的一檔。

**檔案。** `Mylogic/Meta.lean`。

**要練的 Lean。**

- `induction D with` / `cases D with`，對 `Deduction` 的每個 constructor 給 case。
- 歸納假設裡脈絡會變（`impI`、`orE` 的子樹脈絡比結論長）。要先想清楚陳述是否對**任意 Γ** 夠強。
- 若定理只對 `[] ⊢ _` 成立，歸納時通常要**加強陳述**（對任意 Γ 的某個不變量），再特化到空列。

### Phase 4a — 結構引理（先做）

- [ ] 弱化的後設版：若 `Γ ⊢ φ` 則 `Δ ++ Γ ⊢ φ`（若 Phase 2 已有 `weaken_list`，這裡寫清楚它是後設還是規則即可）。
- [ ] 換脈絡（弱版即可）：若每個 `Γ` 的元素都在 `Δ` 裡（List 成員），則 `Γ ⊢ φ → Δ ⊢ φ`。這需要對推導歸納，`ax` case 用成員傳遞。
- [ ] 演繹定理的兩個方向（幾乎是 `impI`／`impE` 的包裝）。
- [ ] 每個定理標「後設」。

### Phase 4b — 析取性質（可放到 Phase 6 之後）

> 若 `⊢ φ ⋁ ψ`，則 `⊢ φ` 或 `⊢ ψ`。

這是後設、且必須建構：結論是 Lean 的 `∨`，你要交出左邊的推導或右邊的推導。

- [ ] 陳述 `disjunction_property`。
- [ ] 證明。常見做法：對空脈絡推導歸納，並維持「這棵樹沒有用到真正的開放假設」或改對「可證公式的形狀」做分析。若第一輪證不完，把 lemma 清單寫在檔案註解，不要用 `Classical.em` 混過去。
- [ ] `#print axioms disjunction_property` 不得出現 `Classical.choice`。

**完成條件。** 4a 全綠。4b 允許下一 session，但不要用古典後設假裝完成。

**陷阱。**

- 直接對 `[] ⊢ φ ⋁ ψ` 歸納時，`impI` 的子樹不在空脈絡。陳述太弱就會卡死——這是在教你 **strengthen the inductive hypothesis**。
- `orE` case 是析取性質的關鍵與痛點。
- 不要 `by_cases`「到底是左邊可證還是右邊可證」。

**對應規格。** 第 12 節。

---

## Phase 5 — Kripke 語意與健全性

**目標。** 定義強制關係，證明單調性與健全性。

**檔案。** `Mylogic/Kripke.lean`。

**要練的 Lean。**

- `structure` 打包框架：世界型、關係、賦值。
- 不必上 `Preorder` typeclass（可以，但第一版手寫自反／傳遞 lemma 更清楚）。
- 對 `Formula` 遞迴定義 `forces : W → Formula α → Prop`。
- 對公式歸納證單調性；對推導歸納證健全性。

**建議形狀。**

```lean
structure Frame (W : Type) (α : Type) where
  le        : W → W → Prop
  le_refl   : ∀ w, le w w
  le_trans  : ∀ {u v w}, le u v → le v w → le u w
  val       : W → α → Prop
  persistent : ∀ {w w' p}, le w w' → val w p → val w' p
```

強制子句必須與規格第 10.2 節一致。特別是蘊涵：

```
forces f w (φ ⇒ ψ)  :=
  ∀ w', f.le w w' → forces f w' φ → forces f w' ψ
```

`forcesCtx f w Γ` 表示 `Γ` 的每個元素都被 `w` 強制。

**要做。**

- [ ] `Frame`（或等價結構）。
- [ ] `forces` / `forcesCtx`。
- [ ] `forces_mono`：單調性。
- [ ] `soundness`：`Γ ⊢ φ → forcesCtx f w Γ → forces f w φ`。
- [ ] 中文註解標後設。
- [ ] `lake build`。
- [ ] `#print axioms soundness` 無 `Classical.choice`。

**完成條件。** 健全性可編譯、可被 Phase 6 引用。

**陷阱。**

- 蘊涵子句若寫成「當前世界：`forces w φ → forces w ψ`」（沒有量化未來），那是古典／世界內二值，LEM 會變成永真，Phase 6 會失敗。
- `falsum` 子句是 `False`（後設的假），不是對象的 `⟂` 自己。
- 賦值忘了 `persistent`，單調性的原子 case 會過不了。
- 健全性的 `impI` case 要用單調性：未來世界仍強制舊的 `Γ`。

**對應規格。** 第 10 節。

---

## Phase 6 — 反模型：排中律不可證

**目標。** 做一個兩世界框架，證明 `⊬ p ⋁ ∼p`。這是課綱的「aha」：形式系統裡「證不出來」也能被證明。

**檔案。** `Mylogic/Countermodel.lean`。

**要練的 Lean。**

- 具體的世界型，例如 `inductive W₂ | w0 | w1`。
- 定義一個 `Frame W₂ ℕ`（或 `Unit` 當單一原子標籤）。
- 證明若干 `¬ forces …`（後設否定）。
- 用健全性的逆否：若可證則處處強制；但根世界不強制，故不可證。

**兩世界（與規格 11.1 節相同）。**

- `w0 ≤ w0`、`w1 ≤ w1`、`w0 ≤ w1`，沒有 `w1 ≤ w0`。
- 原子 `p` 只在 `w1` 真。

**要做。**

- [ ] 框架實例，含前序證明與持續性。
- [ ] `w0 ⊮ p`
- [ ] `w0 ⊮ ∼p`
- [ ] `w0 ⊮ p ⋁ ∼p`
- [ ] `not_provable_lem`：`¬ (⊢ ⟪p⟫ ⋁ ∼⟪p⟫)`（`p` 是那個原子）。
- [ ] （建議）同一框架證明 `⊬ ∼∼p ⇒ p`。
- [ ] 中文：這是後設的不可證定理；對象系統裡沒有 LEM 規則。
- [ ] `#print axioms not_provable_lem`
- [ ] `lake build`

**完成條件。** `not_provable_lem` 通過。沒有靠加入 LEM 再否定它這種循環。

**陷阱。**

- `w0 ⊮ ∼p` 的證據就是「存在後繼 `w1` 強制 `p`」。要把 `≤` 和賦值寫對。
- 世界若做成 `Bool` 也可以，但要固定誰是根。
- 不可證的是**這個原子**的 LEM，不是「存在某個 φ 使得 `⊬ φ ⋁ ∼φ`」以外的誇大陳述——寫定理時量化層次要對。

**對應規格。** 第 11 節。

---

## Phase 7 — 公理衛生

**目標。** 集中檢查後設證明沒有偷偷走古典公理。

**檔案。** `Mylogic/PrintAxioms.lean`（或各檔定理正下方；集中較好當回歸）。

**要做。**

- [ ] 對至少這些名字 `#print axioms`：
  - `imp_id`、`and_comm`、`dni`
  - `soundness`
  - `not_provable_lem`
  - `disjunction_property`（若 4b 已完成）
- [ ] 預期輸出：`does not depend on any axioms`，或頂多 `propext`。
- [ ] 若出現 `Classical.choice` / `Quot.sound`：停，找是哪個 tactic 引入的。
- [ ] 在檔案頂註解寫政策：後設預設建構；將來若有古典後設，獨立檔。

**完成條件。** 上述檢查跑過一遍；結果寫進註解或本 TASKS 的核對（下一 session 更新即可）。

**陷阱。** `by_cases` 在命題不可判定時會引 `Classical.choice`。`decide` 只對 `Decidable` 實例安全。

**對應。** handoff 的 `#print axioms` 政策；規格第 12 節。

---

## Phase 8 — 直覺主義一階邏輯（IPC 過關後才開）

**前置。** Phase 1–7 能 `lake build`，健全性與 LEM 反模型在。析取性質允許仍標 TODO，但不要用 FOL 當藉口跳過 Kripke。

**原則。** 獨立目錄 `Mylogic/FirstOrder/`，**不改**命題 `Formula`。命題階段的歸納證明應繼續能編。

### 8a — 項與公式

**檔案。** `Mylogic/FirstOrder/Syntax.lean`

- [ ] `Term`：第一版可以只有變元（de Bruijn 指標 `ℕ`，或具名）。無函數符號也可以。
- [ ] `FOFormula`：原子謂詞（第一版一個一元謂詞就夠）+ `⟂` + `⋀` `⋁` `⇒` + `∀` `∃`。
- [ ] 不要複用命題 `Formula` 硬加兩個 constructor。

**Lean 練習。** 第二個歸納型；與命題記號分開（量詞記號可 `∀ᵢ` / `∃ᵢ` 或 scoped `∀'`，避免蓋 Lean 的 `∀`）。

### 8b — 代入

**檔案。** `Mylogic/FirstOrder/Substitution.lean`

這是 FOL 在證明助手裡最痛的一塊。課綱**推薦 de Bruijn**：

- [ ] `shift`／`lift`（指標遇到量詞要加一）。
- [ ] `subst`（項代入公式）。
- [ ] 一兩條之後量詞規則會用到的 lemma（例如代入與連詞交換）。

若堅持具名變元，先不要寫 `forallI`。必須先有：

- [ ] `FV : FOFormula → Finset …`（這裡會開始想用標準庫；**仍不要 Mathlib**，可用 `List` 當集合、接受沒去重）。
- [ ] 捕捉迴避的 `subst`。
- [ ] 換名 lemma。
- [ ] 新鮮變元的存在性（對有限自由變元集）。這一步很容易一不小心走古典或寫成 `sorry`——寧可改 de Bruijn。

**對應規格。** 第 13.4 節。

### 8c — 量詞 NJ

**檔案。** `Mylogic/FirstOrder/Deduction.lean`

- [ ] 命題規則的複製品（或抽象出共用核心——第一版複製比較不容易牽動舊檔）。
- [ ] `forallI`、`forallE`、`existsI`、`existsE`，側條件與規格第 14 節一致。
- [ ] de Bruijn 下，eigenvariable 條件通常變成「公式在某個 depth 以上不依賴該指標」；在註解寫你選的編碼與規格具名規則的對應。

### 8d — 對象小定理

**檔案。** `Mylogic/FirstOrder/Examples.lean`

- [ ] `⊢ (∀x φ) ⇒ φ[t/x]`
- [ ] `⊢ φ[t/x] ⇒ ∃x φ`
- [ ] （建議）`⊢ (∀x φ) ⇒ ∼∃x ∼φ`
- [ ] **不要**證 `⊢ (∼∀x ∼φ) ⇒ ∃x φ`

### 8e — 語意與存在性質（進階，可再拆 session）

- [ ] 世界帶論域、論域隨 `≤` 擴張。
- [ ] `∀`／`∃` 的強制子句（規格第 15 節）。
- [ ] 健全性。
- [ ] 存在性質可標 optional。

**Phase 8 完成條件。** 8a–8d 能 `lake build`，至少兩個量詞對象定理。8e 不擋「一階語法+NJ 已落地」。

**陷阱。**

- 在命題 `Formula` 上加量詞，Phase 4–6 的歸納全破。
- 側條件寫錯：從 `R(x)` 推出 `∀x R(x)`。
- `existsE` 讓特徵變元漏進結論。
- 為了新鮮變元 `import Mathlib.Data.Finset.Basic`——不要。

---

## 明確延後（不要開 issue 假裝正在做）

- `Mylogic/Modal.lean`、`Mylogic/Probability.lean`
- `Mylogic/Classical.lean`（LEM 對照）除非 IPC 課綱已完整、且另開 session
- 等號（規格第 16 節）
- 完備性、Hauptsatz、Gödel、算術
- Mathlib 測度論
- 把對象 `Formula` 解釋成 Lean `Prop` 的嵌入當主線

---

## 建議的 session 切法

| Session | 做什麼 | 結束時你學會 |
|---|---|---|
| 0 | Phase 0 | Lake 專案能編、能跑（**已完成**） |
| 1 | Phase 1（[`lession1.md`](lession1.md) 作業） | 歸納型、定義連詞、scoped notation |
| 2 | Phase 2 | 歸納謂詞 `Γ ⊢ φ` |
| 3 | Phase 3 | 用 constructor 組對象證明 |
| 4 | Phase 4a + 5 | 後設歸納 + 結構／遞迴 |
| 5 | Phase 6–7 | 反模型、`#print axioms` |
| 6 | Phase 4b | 析取性質（較難的歸納） |
| 7+ | Phase 8 | 一階語法、代入、量詞 |

Phase 1 結束，應能解釋：為什麼 `∼` 不是 constructor，以及 `⟪0⟫ ⋀ ∼⟪0⟫` 為什麼不是 Lean 的 `0 ∧ ¬0`。Phase 3 結束，才輪到解釋 `⊢ φ ⇒ φ` 為什麼不是 `fun a => a`。

---

## 檔案地圖（做完 Phase 7 應長這樣）

```
mylogic/
  lakefile.toml              -- 仍無 Mathlib
  Mylogic.lean
  Main.lean
  Mylogic/
    Formula.lean
    Deduction.lean
    Examples.lean
    Meta.lean
    Kripke.lean
    Countermodel.lean
    PrintAxioms.lean
  docs/
    handoff.md
    first-order-logic.md
    TASKS.md
    AGENTS.md
    lession1.md              -- Phase 1 講義與作業（檔名依作者指定）
```

`Mylogic/Basic.lean`（hello）可刪可留；不要讓它成為邏輯入口。

Phase 8 之後再多 `Mylogic/FirstOrder/`。

---

## 下一 session 的第一句話

作者改在瀏覽器繼續 Phase 1。讀 [`handoff.md`](handoff.md) 與 [`lession1.md`](lession1.md)，由作者依 HW1.1 → HW1.5 實作 `Formula.lean`。**不要代寫 Phase 1。** 不要先寫 Kripke，也不要先寫 FOL。
