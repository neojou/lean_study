# Handoff：在 Lean 4 裡自建公理系統（對象邏輯）

> 寫給下一個 session（預計切到 **Grok Build**）接著實作。
> 日期：2026-09-09。語言：繁體中文。作者脈絡：Neo Jou / Lean 4 科普筆記。

---

## 這份文件從哪裡來

上一輪對話問的是：

> 是否可以用 Lean 重頭搭建自己的公理邏輯系統，例如用現代邏輯、不用排中律，甚至機率邏輯？

結論：**可以，但要把兩種「從頭搭建」分開。** 本 handoff 記錄那個區分、限制、以及已經講過的務實路線。目標不是再解釋一遍 Lean 是什麼，而是讓下一輪可以直接寫程式。

相關既有專案（別跟這條線搞混）：

- 科普部落格：Lean 4 緣由與發展；風格通順、帶一點幽默、平易近人。
- Day 0：環境設置 https://njiot.blogspot.com/2026/09/lean-day-0-20260906.html
- Day 1：用餘弦定理在 Lean 中證明畢氏定理；數學推導另刊 https://njscientia.blogspot.com/2026/09/blog-post.html
- 主要數學 repo：https://github.com/neojou/lean_study/tree/main/mymathlib
- 本機草稿：`artifacts/mylogic/`（對象邏輯實驗，見文末「目前程式狀態」）

`mymathlib` 是「在 Lean 的邏輯裡做數學」。`mylogic` 是「用 Lean 當後設語言，編碼另一套邏輯」。兩條線分開維護。

---

## 必須先分清的兩件事

### A. 待在 Lean 自己的邏輯裡，但關掉古典公理

Lean 核心是 CIC／相依類型論，命題預設是直覺主義／建構式的。

- `P ∨ ¬P` **不是** kernel 公理。
- 排中律、由矛盾直接得 `P`、選擇公理，都走 `Classical`（關鍵常數是 `Classical.choice`）。
- Diaconescu：`propext` + `Quot.sound` + `Classical.choice` ⇒ 排中律。
- `#print axioms foo` 可以看出一個宣告踩了哪些公理。

「不用排中律」= 不要 `open Classical`，也不要用會偷偷引入 `Classical.choice` 的 tactic（Mathlib / 部分內建 tactic 常這樣做，例如不先檢查可判定性就 `by_cases`）。

這條路適合：在 Lean 裡做建構式數學。**不是**本 handoff 的主線。

### B. 把 Lean 當後設語言，編碼一套「對象邏輯」

這才是「自建公理系統」的意思：

1. 歸納型定義公式語法（對象語言）
2. 定義推導關係（自然演繹 / sequent / Hilbert）
3. 定義語意（賦值、Kripke、代數、機率測度……）
4. 證明後設性質：健全性、完備性、析取性質、某公式不可證

底層 **仍然是 Lean 的 CIC**（證明無關性、`Prop` 不可述性都在）。我們沒有把 kernel 換成線性邏輯或機率邏輯；我們是在 CIC **上面**研究那些系統。

若目標是「整個宇宙都改成 HoTT / 線性邏輯」，那是換證明助手，不是開一個 `namespace`。

本專案走 **B**。

---

## 上一輪的實質結論（濃縮）

- Lean 很適合當金屬語言：歸納型 + 依值型別 + typeclass 很對口。
- 已有大型先行者：[Formalized Formal Logic / Foundation](https://github.com/FormalizedFormalLogic/Foundation)（古典／直覺主義命題與一階、超直覺主義、模態、Kripke、不完備性等）。需要時參考，不要一開始就依賴它；本專案要自己長，才寫得進科普。
- 「現代邏輯、不用排中律」：對象邏輯用 IPC（直覺主義命題邏輯）即可；後設證明預設也盡量不踩 `Classical.choice`。
- 「機率邏輯」要再拆三層，別跟 Mathlib 測度混為一談：
  1. **機率理論**：測度、幾乎必然——Mathlib 已有，那是標準數學，不是另套推理規則。
  2. **機率程式**：如 [Probly](https://github.com/lecopivo/Probly)，隨機程式 + 密度。
  3. **機率邏輯**：對象語言加算子 `P≥r φ`（「φ 的機率至少是 r」），再給公理與模型。技術上跟模態邏輯同類；Lean 沒本質障礙，工程量大，強完備常碰到無窮規則／非緊緻。Coq 有人做過 LPP 這類系統。模糊邏輯、信念邏輯同理：`Prop` 不會自動變成 `[0,1]` 值。

---

## 務實路線（下一輪就照這個做）

這是上一輪明確給出、本 handoff **必須保留**的建議：

1. **先做一個很小的對象邏輯：命題語言 + 直覺主義自然演繹。**
   - 原語連詞只要 `⟂`、`⋀`、`⋁`、`⇒`。
   - `∼φ := φ ⇒ ⟂`，`⊤ᵢ := ⟂ ⇒ ⟂`。
   - 對象連詞**不要**複用 Lean 的 `∧ ∨ → ¬ False`，以免後設／對象看起來像同一件事。
   - 推導系統用 Gentzen NJ，判斷形如 `Γ ⊢ φ`，`Γ : List (Formula α)`。
   - 這是極小邏輯 + `⟂E`（ex falso）= 直覺主義；**不要**加 RAA / LEM / double-negation elimination。

2. **證明幾個後設性質：**
   - **析取性質（disjunction property）**：若 `⊢ φ ⋁ ψ`，則 `⊢ φ` 或 `⊢ ψ`。
   - **排中律不可證**：`⊬ p ⋁ ∼p`（對一般原子 `p`）。用 **Kripke 反模型**最乾淨：做兩世界的框架，根世界看不到 `p` 也看不到 `∼p`，原子在後繼世界才為真。
   - 順便值得做、但可排第二優先：弱化引理（已有規則版）、cut 可容許（`Deduction.lean` 裡已有一版 `cut`）、否定引入／消除、演繹定理（跟 `→I` 幾乎是同一件事）。

3. **再決定要不要加模態算子，或加 `P≥r`。**
   - 模態：加 `□` / `◇`，Kripke 框架已經在 LEM 反模型裡用過，擴充成本低。
   - 機率邏輯：加 `P≥r`，語意用有限樣本空間上的機率分配就夠當第一版；先健全性，完備性以後再說。
   - 兩條都不要在 IPC 的後設性質還沒證完之前開工。

4. **全程用 `#print axioms` 盯著**，確保對象邏輯的後設證明沒有意外引入 `Classical.choice`——除非你故意用古典後設理論去研究直覺主義對象邏輯（這在邏輯學裡很常見，也完全合法）。
   - 預設政策：**後設也走建構**。析取性質的證明本身就該是建構的（給出左邊或右邊的推導）。
   - Kripke 反模型通常也不需要選擇公理。
   - 若某個完備性證明最後非用古典不可，把它標成 `noncomputable` / 獨立檔，並在模組註解寫明「後設古典、對象直覺主義」。
   - 每個重要定理底下留一行：
     ```lean
     #print axioms disjunction_property
     #print axioms not_provable_lem
     ```
     預期輸出是「does not depend on any axioms」或頂多 `propext`；出現 `Classical.choice` 就要停下來問是不是誤用 tactic。

---

## 設計約定（請下一輪遵守）

- Namespace：`MyLogic`。
- 對象公式：`Formula α`，`α` 是命題變元的類型（第一版用 `String` 或 `ℕ` 即可）。
- 記號（已在 `Formula.lean` 用 scoped notation）：
  - `⟂` `⊤ᵢ` `∼` `⋀` `⋁` `⇒` `⟪p⟫`
- 判斷記號：`Γ ⊢ φ`、`⊢ φ`（空脈絡）。
- 脈絡用 `List`，不先上 `Finset`。重複假設可以接受；之後若要「集合脈絡」再證等價。
- 檔案職責小、註解用中文（對齊部落格讀者）。
- **不要**為了省事 `import Mathlib` 進來寫 IPC。標準庫 `List` / 歸納足夠。Mathlib 會把古典習慣一起帶進來。
- Lake 專案可隨 Grok Build 補；本機目前只有 Lean 原始檔，還沒有 `lakefile` / `lean-toolchain`。

後設邏輯 vs 對象邏輯，寫程式時用這張對照：

| | 後設（Lean） | 對象（MyLogic） |
|---|---|---|
| 真 | `True` / 有證明項 | `⊤ᵢ` |
| 假 | `False` | `⟂` |
| 否定 | `¬` | `∼` |
| 合取 | `∧` | `⋀` |
| 析取 | `∨` | `⋁` |
| 蘊涵 | `→` | `⇒` |
| 可證 | 該 `Prop` 有項 | `⊢ φ` |

---

## 建議的檔案切分（Grok Build 按這個長）

已有：

```
artifacts/mylogic/
  MyLogic.lean              -- 總入口（目前 import 了還不存在的模組，見下）
  MyLogic/Formula.lean      -- 公式 + 記號
  MyLogic/Deduction.lean    -- NJ 規則 + 幾個導出規則
```

下一輪依序補：

```
MyLogic/Examples.lean       -- 小定理：φ ⇒ φ、φ ⋀ ψ ⇒ ψ ⋀ φ、雙重否定引入（注意：消除不可證）
MyLogic/Meta.lean           -- 後設定理：弱化／換脈絡、析取性質
MyLogic/Kripke.lean         -- 世界、強制關係 ⊩、單調性、健全性
MyLogic/Countermodel.lean   -- LEM 的兩世界反模型；可再加雙重否定消除的反模型
MyLogic/PrintAxioms.lean    -- 集中 #print axioms，當回歸檢查
```

再後面（明確決定後才開）：

```
MyLogic/Modal.lean          -- □、K 公理、框架條件
MyLogic/Probability.lean    -- P≥r 語法；有限分配語意
MyLogic/FirstOrder.lean     -- 現在 root 有 import，但檔案不存在；先不要做
MyLogic/Exercises.lean      -- 同樣，root 有 import、檔案不存在
```

---

## 目前程式狀態（2026-09-09 實查）

`Formula.lean` 已完成第一版語法與記號。

`Deduction.lean` 已有 NJ 規則：

- `ax`、`weaken`
- `andI` / `andEL` / `andER`
- `orIL` / `orIR` / `orE`
- `impI` / `impE`
- `falsumE`
- 導出：`negI`、`negE`、`verumI`、`ax_head`、`ax_tail_head`、`weaken_list`、`cut`

**缺口 / 地雷：**

- `MyLogic.lean` 寫了 `import MyLogic.Examples`、`Exercises`、`FirstOrder`，這三個檔**不存在**。下一輪第一件事：要嘛建空模組，要嘛先把這三行 import 拿掉，否則 lake build 會掛。
- 還沒有語意、還沒有析取性質、還沒有 Kripke、還沒有 `#print axioms` 檢查。
- 還沒有 Lake 專案檔。Grok Build 若要編譯，需補 `lean-toolchain`、`lakefile.toml`（或 `.lean`），**不要依賴 Mathlib**。
- `cut` 目前用 `impI` + `impE` 證，這對 NJ 沒問題；若之後改 sequent 再另證容許性。

---

## Grok Build 建議的第一個工作單元

不要一次做完。建議一個 session 只做這一包，而且要能 `lake build`：

1. 修好 root import（刪掉不存在的模組，或放空 `namespace` 檔）。
2. 補最小 Lake 專案（無 Mathlib）。
3. `Examples.lean`：至少三個對象定理
   - `⊢ φ ⇒ φ`
   - `⊢ (φ ⋀ ψ) ⇒ (ψ ⋀ φ)`
   - `⊢ φ ⇒ ∼∼φ`（雙重否定引入；消除刻意不要證）
4. `Kripke.lean` 最小定義：
   - 結構：世界型、前序 `≤`、原子賦值（對 `≤` 單調）
   - 強制 `forces W φ`（對公式歸納）
   - 單調性引理
   - 健全性：`Γ ⊢ φ` ⇒ 所有世界、所有把 Γ 強制住的賦值都強制 φ
5. `Countermodel.lean`：兩個世界 `w₀ ≤ w₁`，原子 `p` 只在 `w₁` 真。證明
   - `w₀ ⊮ p`、`w₀ ⊮ ∼p`、因此 `w₀ ⊮ p ⋁ ∼p`
   - 由健全性得 `⊬ p ⋁ ∼p`
6. 每個新定理後 `#print axioms`。
7. 析取性質可放同一 session 或下一個；它比較像對推導做歸納，不依賴 Kripke。

完成後在本檔「目前程式狀態」更新，並在定理旁用一句中文寫「這在講後設還是對象」。

---

## 刻意先不做的事

- 不要把 IPC 嵌進 `Prop` 再「證明對象排中律等價 Lean 排中律」當主線——那會讓讀者以為兩層邏輯是同一個。
- 不要一開始就形式化 Gödel 不完備、切割消除的完整 Hauptsatz、或 FOL。
- 不要為了機率邏輯先引 Mathlib 測度論。
- 不要在對象系統裡加入 `Classical.em` 的翻譯當公理，除非另開 `MyLogic.Classical` 做對照。

---

## 對外參考（需要時再打開）

- Lean 古典推理：https://leanprover.github.io/theorem_proving_in_lean4/Propositions-and-Proofs/
- Axioms and Computation：https://leanprover.github.io/theorem_proving_in_lean4/Axioms-and-Computation/
- Formalized Formal Logic：https://formalizedformallogic.github.io/Foundation/
- Lean 做建構式數學的限制討論：https://proofassistants.stackexchange.com/questions/1115/how-usable-is-lean-for-constructive-mathematics

---

## 給下一輪模型的一句話

> 在 `artifacts/mylogic` 把直覺主義命題邏輯當對象語言做完：NJ + Kripke 健全性 + LEM 反模型 + `#print axioms` 乾淨。模態與 `P≥r` 等這包過關再談。
