# Handoff：在 Lean 4 裡自建公理系統（對象邏輯）

> 寫給**下一個 session**。作者接下來會改在 **瀏覽器介面** 和 Grok 溝通（不一定還是 Grok Build TUI）。
> 日期：2026-09-09。語言：繁體中文。作者：Neo Jou／Lean 4 科普筆記。
> 進度以 [`TASKS.md`](TASKS.md) 為準；硬約束以 [`AGENTS.md`](AGENTS.md) 為準。

---

## 0. 下一輪模型立刻要做的事

你是助教，不是代工。

1. 先讀本檔第 0–4 節，再決定要不要打開別的文件。
2. 作者若在做 Phase 1：打開 [`lesson-1.md`](lesson-1.md)，**批改／答疑**。**不要**把 `Mylogic/Formula.lean` 寫完交給他。
3. 作者若貼出作業或錯誤訊息：對照 `lesson-1.md` 的 HW1.1–HW1.5 驗收清單，指出哪一條沒過、為什麼。
4. 作者若問「為什麼不直接寫程式」：用本檔第 1 節回答。
5. 在 IPC 的後設性質做完之前，不要開模態、機率邏輯、FOL 實作、Mathlib。

若瀏覽器裡的模型**看不到 repo**：請作者把本檔與 `lesson-1.md` 貼上（或至少貼第 11 節的開場白）。

---

## 1. 為何會有 `lesson-1.md`

檔名是 `lesson-1.md`（2026-09-09 由誤拼 `lession1.md` 更正）。不要改回舊名。

### 它不是規格書的複本

對象邏輯要長成什麼樣子，已經寫在 [`first-order-logic.md`](first-order-logic.md)。Lean 分幾個 Phase 做，已經寫在 [`TASKS.md`](TASKS.md)。`lesson-1.md` 是另一種文件：**大學一週的課堂講義**——先講為什麼，再出作業，由作者自己把 Phase 1 做完。

### 它怎麼來的（同一天的決策）

1. 更早的對話問：能不能在 Lean 裡自建公理系統（現代邏輯、不用排中律、甚至機率邏輯）。結論是可以，但必須走「Lean 當後設語言、編碼對象邏輯」（本檔第 5 節的路線 B），不是關掉 Lean 的 `Classical` 就算自建。
2. 接著用 `lake new mylogic` 搭了專案。文件課綱把工作切成 Phase 0–8。Phase 0（能 `lake build`／`lake exe`）作者已完成。
3. 輪到 Phase 1（`inductive Formula`、定義連詞、scoped notation）時，作者**明確要求不要直接實作**，而是：
   - 扮演大學教授；
   - 把需要的知識寫進 `mylogic/docs/lesson-1.md`；
   - 循序規劃 Homework，**由作者實作**；
   - 這些作業都做好時，Phase 1 也就完成。
4. 動機：這條線要寫進科普、也要當學習 Lean 與公理證明的練習。若模型把 `Formula.lean` 一次貼完，作者只得到一個能編的檔，學不到「公式是資料、不是 `Prop`」。

### 講義在教什麼、作業在驗什麼

本週**只做對象語法**。沒有 `⊢`、沒有 NJ、沒有 Kripke。手癢寫 `Deduction.lean` 的話，請壓住。

| 作業 | 作者要自己做出來的 | 對應 Phase 1 |
|---|---|---|
| HW1.1 | `inductive Formula`，五個 constructor，三個純 constructor 例子 | 語法落地 |
| HW1.2 | `def Formula.neg`／`verum`（**不是** constructor），定義性 `rfl` | `∼`、`⊤ᵢ` 是縮寫 |
| HW1.3 | scoped 記號 `⟂ ⊤ᵢ ∼ ⋀ ⋁ ⇒ ⟪p⟫`，解析 `rfl`，吉祥物 `⟪0⟫ ⋀ ∼⟪0⟫` | 兩層記號分開 |
| HW1.4 | `Formula.size`（`∼p` 與 `⊤ᵢ` 都是 3） | 結構遞迴；講義比 TASKS 原列多這一項 |
| HW1.5 | `Mylogic.lean` import `Mylogic.Formula`；`lake build` 綠；exe 仍 Hello | 接上函式庫 |

五份都過 → 把 [`TASKS.md`](TASKS.md) Phase 1 核取清單打勾。HW1.4 是課堂練習，仍留在 `Formula.lean`，不進入 Phase 2。

### 模型對這份講義的態度

- **當教授／助教**：解釋概念、對錯誤訊息、對照驗收、提示附錄 A 的常見叉。
- **不當代筆**：不要交出一份完整可交的 `Formula.lean`。不要「為了幫他過關」把作業三的 `rfl` 加上括號改考題。
- **不要改寫講義**，除非作者要求改作業設計。規格有變，先改 `first-order-logic.md` 再改講義。

---

## 2. 文件地圖（先讀哪個）

全部在 `mylogic/docs/`：

| 檔案 | 角色 | 瀏覽器這輪要不要打開 |
|---|---|---|
| **本檔 `handoff.md`** | 交接、現況、行為規範 | 必讀 |
| [`lesson-1.md`](lesson-1.md) | Phase 1 講義 + HW1.1–1.5 | 作者在做 Phase 1 就讀 |
| [`AGENTS.md`](AGENTS.md) | 硬約束、決策紀錄（給模型的短清單） | 建議讀 |
| [`TASKS.md`](TASKS.md) | 全課綱 Phase 0–8 | 需要看中期路線再讀 |
| [`first-order-logic.md`](first-order-logic.md) | 邏輯學規格（IPC／NJ／Kripke／IQC） | 作者問「公理是什麼」再讀 |

讀檔順序：`handoff.md` →（Phase 1）`lesson-1.md` → 卡住再看 `AGENTS.md`。不要一開場把規格書第 14 節的量詞規則講完。

兩條 repo 線不要混：

- `mymathlib/`：在 Lean 的邏輯裡做數學（畢氏定理那條）。
- `mylogic/`：用 Lean 編碼**另一套**對象邏輯。本交接只談這條。

---

## 3. 目前程式狀態（2026-09-09 離開 TUI 時）

實作目錄是 repo 內的 **`mylogic/`**（`lake new mylogic`）。模組／namespace 是 **`Mylogic`**（Lake 預設），不是早期草稿的 `MyLogic`。

**不是** `artifacts/mylogic/`。那個目錄不在本 repo；舊文若寫「Formula.lean 已有 NJ 規則」，指的是當時本機草稿，**不要**當成這個 Lake 專案已經有那些檔。

### Phase 0 — 完成

作者已能 `lake build`、`lake exe mylogic`，輸出 `Hello, world!`（在尚未誤加錯誤 import 之前；見下）。

- Lean `v4.33.1`；`lakefile.toml` **無 Mathlib**；`lake-manifest.json` 的 `packages` 為空。
- 保留模板：`Mylogic/Basic.lean` 的 `hello := "world"`；`Main.lean` 印 Hello。**不要刪**，HW1.5 仍要求 exe 印 Hello。

### Phase 1 — 講義已出，程式剛起頭，**尚未完成**

作者已開始碰檔案，但 **HW1.1 還沒做出歸納型**：

- `Mylogic/Formula.lean` 目前幾乎是空的，只剩一行註解，大意是想寫 `⟪0⟫ ⋀ ∼⟪0⟫` 這種例子（連 inductive 都還沒有）。
- `Mylogic.lean` 在 `import Mylogic.Basic` 之外多了一行 **`import MyLogic.Formula`**（大寫 L）。這是舊命名。正確是 `import Mylogic.Formula`。這個大小寫不一致會讓 **`lake build` 掛掉**（連結器找不到 `initialize_mylogic_MyLogic_Formula`）。
- 這不表示模型該把 Formula 寫完。若作者問為什麼編不過：先提示 **import 必須是 `Mylogic.Formula`**，以及 HW1.1 要求檔案裡要有 `inductive Formula`。作業五才規定入口一定要 import；作業一可以先讓 `Formula.lean` 自己過檢查。

### 還沒開始

`Deduction.lean`、`Examples.lean`、`Kripke.lean`、FOL、Modal、Probability。Phase 2 起仍照 `TASKS.md`，等 Phase 1 核取清單打完再談。

---

## 4. 瀏覽器介面裡，模型該怎麼表現

作者切到瀏覽器，是為了**用對話把作業做完**，不是換一個會直接改 repo 的實作機器人。

**要做：**

- 用繁體中文。語氣可以像講義：清楚、帶一點對照，不要說教。
- 一次只盯一個作業（HW1.1 → … → HW1.5）。作者若一次丟出 Phase 2–8，請他先做完本週。
- 解釋時用「後設／對象」兩層語言。對象記號是 `⟂ ⊤ᵢ ∼ ⋀ ⋁ ⇒`，Lean 的是 `False True ¬ ∧ ∨ →`。
- 作者卡住時：要錯誤訊息原文、要他貼 `Formula.lean`，對照 `lesson-1.md` 附錄 A。可以給**片段**（例如「`and` 的回傳型別應是 `Formula α`」），不要給整份繳交檔。
- 作業通過後，提醒作者自己把 `TASKS.md` Phase 1 的 `[ ]` 改成 `[x]`；模型若改得到文件，也可以幫打勾，但前提是驗收真的過了。

**不要做：**

- 不要代寫完整 `Formula.lean`／`Deduction.lean`。
- 不要 `import Mathlib`、不要 `open Classical`。
- 不要把對象公式做成 `Prop`，不要用 `∧` 當對象合取。
- 不要開始寫 NJ、Kripke、FOL、模態、機率。
- 不要把 IPC 嵌進 Lean 的 `Prop` 再證「對象 LEM ⇔ `Classical.em`」。
- 不要依賴舊文的 `MyLogic` 與 `artifacts/mylogic/`。

若瀏覽器 Grok **有**改檔工具：仍然先問「這是批改還是你要我動手」；預設是批改。若作者說「幫我改 import 大小寫」這種一行動作，可以改，那不算代寫作業。

---

## 5. 必須先分清的兩件事（專案主線）

### A. 待在 Lean 自己的邏輯裡，但關掉古典公理

Lean 核心是 CIC。`P ∨ ¬P` 不是 kernel 公理；排中律走 `Classical.choice`。這條路是建構式數學，**不是** `mylogic` 的主線（那比較像 `mymathlib`）。

### B. 把 Lean 當後設語言，編碼一套對象邏輯

1. 歸納型定義公式語法  
2. 定義推導關係（本專案用 Gentzen NJ，不是 Hilbert 主線）  
3. 定義語意（命題階段用 Kripke）  
4. 證明後設性質：健全性、析取性質、LEM 不可證  

底層仍然是 CIC。我們沒有換 kernel。本專案走 **B**。

對象系統：先 IPC（命題 + 直覺主義 NJ），再 IQC（一階，`TASKS` Phase 8，獨立目錄 `Mylogic/FirstOrder/`）。直覺主義 = 極小邏輯 + `falsumE`；不加 LEM／RAA／DNE／Peirce。`∼φ := φ ⇒ ⟂`，`⊤ᵢ := ⟂ ⇒ ⟂`。

---

## 6. 設計約定（以現況為準，舊草稿作廢）

- 路徑：`mylogic/`。模組與 namespace：`Mylogic`。
- 對象公式：`Formula α`。第一版原子用 `ℕ` 即可。
- 對象記號（scoped）：`⟂` `⊤ᵢ` `∼` `⋀` `⋁` `⇒` `⟪p⟫`。
- 判斷（Phase 2 才出現）：`Γ ⊢ φ`，`Γ : List (Formula α)`，不用 `Finset`。
- 註解繁中。檔案職責小。
- **不要** `import Mathlib`。
- 後設也盡量建構；重要定理 `#print axioms`，預期無公理或頂多 `propext`。出現 `Classical.choice` 就停。

| | 後設（Lean） | 對象（Mylogic） |
|---|---|---|
| 真 | `True`／有證明項 | `⊤ᵢ` |
| 假 | `False` | `⟂` |
| 否定 | `¬` | `∼` |
| 合取 | `∧` | `⋀` |
| 析取 | `∨` | `⋁` |
| 蘊涵 | `→` | `⇒` |
| 可證 | 該 `Prop` 有項 | `Γ ⊢ φ`（尚未實作） |

---

## 7. 中期路線（Phase 1 過關之後才走）

不要在瀏覽器第一輪就開工。記在這裡以免路線走丟：

1. Phase 2：NJ，constructor 名稱與規格第 6 節一致（`ax`、`weaken`、`andI`／`andEL`／`andER`、`orIL`／`orIR`／`orE`、`impI`／`impE`、`falsumE`）。
2. Phase 3：對象小定理 `⊢ φ ⇒ φ`、合取交換、雙重否定**引入**（消除不可證，不要硬證）。
3. Phase 4–7：後設弱化、Kripke 健全性、兩世界 LEM 反模型、`#print axioms`。析取性質可稍後。
4. Phase 8：一階，獨立模組，代入傾向 de Bruijn。
5. 模態 `□`／`◇` 或機率 `P≥r`：等 IPC 後設過關再決定。機率邏輯 ≠ Mathlib 測度論。

全程盯 `Classical.choice`。析取性質必須建構地給出左邊或右邊的推導。

---

## 8. 刻意先不做

- 代寫 Phase 1 繳交檔。
- 把 IPC 嵌進 `Prop` 當主線。
- 在預設 NJ 加入 `Classical.em` 的翻譯（對照請另開 `Mylogic.Classical`，現在不開）。
- Gödel、Hauptsatz、FOL 實作、Mathlib 測度、模態、機率。

---

## 9. 歷史草稿（不要當現況）

更早的本機實驗曾有 `artifacts/mylogic/`，裡面有過 `Formula.lean`／`Deduction.lean` 與一組 NJ 規則。那些檔**沒有**搬進這個 Lake 專案。舊 handoff 裡的 `MyLogic`、幽靈 `import MyLogic.Examples`、以及「尚未有 lakefile」，都已過時。

若需要邏輯細節，讀 [`first-order-logic.md`](first-order-logic.md)，不要從舊草稿反推這個 repo。

---

## 10. 對外參考（需要時再打開）

- Lean 公理與計算：https://leanprover.github.io/theorem_proving_in_lean4/Axioms-and-Computation/
- Formalized Formal Logic（只參考、不依賴）：https://formalizedformallogic.github.io/Foundation/
- Day 0 環境：https://njiot.blogspot.com/2026/09/lean-day-0-20260906.html
- Day 1 畢氏定理（`mymathlib` 那條線）：https://njiot.blogspot.com/2026/09/ 與 https://njscientia.blogspot.com/2026/09/blog-post.html

---

## 11. 作者可貼到瀏覽器的開場白

```
我在 GitHub repo lean_study 的 mylogic/ 用 Lean 4 自建對象邏輯（後設是 Lean，對象是直覺主義命題邏輯）。

請先讀 mylogic/docs/handoff.md。重點：
- Phase 0 已完成（lake exe 原本印 Hello, world!）。
- Phase 1 請當大學教授／助教：講義是 mylogic/docs/lesson-1.md。
- 我自己依 HW1.1→HW1.5 寫 Mylogic/Formula.lean，請批改、答疑，不要代寫完整檔。
- 模組名是 Mylogic（不是 MyLogic），不要 import Mathlib。
- 講義檔名是 mylogic/docs/lesson-1.md（舊名 lession1.md 已更正）。

我現在做到 HW1.__ ；這是我的 Formula.lean／錯誤訊息：
```

（作者自己填作業號與貼檔。）

---

## 12. 給下一輪模型的一句話

> 作者改在瀏覽器做 Phase 1。`lesson-1.md` 存在，是因為他要自己學會把公式做成歸納型，不是要一份代寫的 `Formula.lean`。你當教授：對作業、講兩層語言、盯 `Mylogic` 這個拼法。五份作業過了再談 NJ。
