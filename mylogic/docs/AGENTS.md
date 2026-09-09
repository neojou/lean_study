# AGENTS：在 `mylogic` 裡思考與實作時先看這裡

> 給下一個 session 的模型與作者。短、可執行。
> 邏輯規格在 [`first-order-logic.md`](first-order-logic.md)；Lean 課綱在 [`TASKS.md`](TASKS.md)；緣由在 [`handoff.md`](handoff.md)。
> 日期：2026-09-09。

---

## 一句話

`mylogic` 用 Lean 4 當**後設語言**，編碼一套**對象邏輯**：先做直覺主義命題邏輯（IPC + Gentzen NJ），再做直覺主義一階邏輯（IQC）。這不是在 Lean 的 `Prop` 裡做建構式數學（那是 `mymathlib` 的路線）。

讀檔順序：`handoff.md` → `first-order-logic.md` → `TASKS.md` → 本檔。

---

## 硬約束（違反就停下來改）

1. **不要 `import Mathlib`。** 標準庫的 `List`、歸納、結構就夠。Mathlib 會把古典 tactic 習慣一起帶進來。
2. **兩套記號必須分開。** 對象連詞是 `⟂` `⊤ᵢ` `∼` `⋀` `⋁` `⇒`；後設用 Lean 的 `False` `True` `¬` `∧` `∨` `→`。不要把對象公式定義成 Lean 的 `Prop` 連詞。
3. **對象系統是直覺主義 NJ。** 不加 LEM、RAA（從 `∼φ ⊢ ⟂` 得 `φ`）、雙重否定消除、Peirce。`falsumE`（ex falso）要加，那是直覺主義與極小邏輯的分界。
4. **模組與 namespace 用 `Mylogic`**（Lake `lake new mylogic` 的預設），不是 handoff 寫的 `MyLogic`。
5. **脈絡用 `List (Formula α)`**，不用 `Finset`。重複假設可接受。
6. **註解用繁體中文。** 每個重要定理旁寫一句：這是對象定理還是後設定理。
7. **後設也盡量建構。** 重要定理底下 `#print axioms`。預期不依賴任何公理，或頂多 `propext`。出現 `Classical.choice` 就停：是誤用 tactic，還是故意走古典後設？後者要獨立檔並在模組註解寫明。
8. **檔案職責小。** 新功能先對 `TASKS.md` 的階段，不要一個檔寫完語法+語意+FOL。
9. **本輪文件寫完後、IPC 後設性質過關前，不要開模態、機率邏輯、古典對照模組、Gödel、Hauptsatz。**

---

## 後設還是對象？（每次寫宣告先問）

| 你在寫的東西 | 應該看起來像 |
|---|---|
| 對象語法 | `inductive Formula`，constructor 是 `atom` / `falsum` / `and` / `or` / `imp` |
| 對象可證 | `Γ ⊢ φ`，證明項是 NJ 規則的 constructor 樹 |
| 對象真值（語意） | Kripke 的 `forces w φ`（`w ⊩ φ`） |
| 後設定理 | 關於上述歸納型的 Lean `theorem`：健全性、析取性質、`⊬ LEM` |
| Lean 自己的邏輯 | 不要拿來當對象規則。`intro`/`apply` 是在組後設證明，不是 NJ 規則本身 |

快速檢查：如果讀者可能把 `→` 看成 `⇒`，記號就還沒分開。

---

## 與 `handoff.md` 的偏差（刻意的）

handoff 是上一輪的交接，以下幾點以本檔與課綱為準：

| 項目 | handoff | 現在 |
|---|---|---|
| 路徑 | `artifacts/mylogic/` | repo 內 `mylogic/`（已 `lake new`） |
| 模組名 | `MyLogic` | `Mylogic` |
| FOL | 「root 有 import 但先不要做」 | 規格寫在 `first-order-logic.md`；實作是 `TASKS.md` Phase 8，**插在 Phase 1–7 之前就做錯** |
| 程式狀態 | 宣稱已有 `Formula.lean` / `Deduction.lean` | **尚未搬進這個 Lake 專案**；現在只有模板 `hello` |

不要把 handoff 裡的「目前程式狀態」當成這個目錄已經有那些檔。

---

## 卡住時怎麼想

- 對象證明組不出來：先在紙上畫 NJ 樹，再把每一條規則對成 constructor。不要 `open Classical`，也不要 `by_cases`。
- 後設定理組不出來：對 `Deduction` 或 `Formula` 做歸納，不要對公式的「真假」做個案。
- 要證明「證不出來」：做 Kripke 反模型 + 健全性。**不要**在對象系統裡加一條公理然後宣稱不可證——那是換系統。
- 析取性質必須是建構的：給出左邊或右邊的推導，不要用 Lean 的排中律「總有一邊可證」。
- FOL 代入爆炸：停下來看 Phase 8 的 de Bruijn 建議，不要在命題 `Formula` 上硬加量詞。
- `#print axioms` 出現 `Classical.choice`：先搜這個檔有沒有 `by_cases`、`Classical.*`、或 Mathlib tactic。

---

## 決策紀錄（2026-09-09，寫規格時定的）

1. **推導系統用 Gentzen NJ，不實作 Hilbert 主線。** Hilbert／Heyting 公設只寫在規格書當對照。兩套 `⊢` 並存會讓學習噪音大於收穫。
2. **直覺主義 = 極小邏輯 + `falsumE`。** `∼` 與 `⊤ᵢ` 是定義，不是原語。
3. **IPC 先於 IQC。** 規格一次寫完；Lean 實作 Phase 0–7 只做命題，Phase 8 才開一階。
4. **FOL 語法獨立模組** `Mylogic/FirstOrder/`，不改命題 `Formula`，以免 Phase 1–7 崩壞。
5. **FOL 代入傾向 de Bruijn。** 具名變元較好讀，但捕捉迴避引理在證明助手裡很煩；若改具名，必須先把自由變元／換名／代入引理清單證完再寫量詞規則。
6. **等號、模態、機率邏輯、古典對照**都不進第一條學習路徑。
7. **完備性不當 Phase 1–7 目標。** 第一階段用有限反模型證明不可證；完備性以後再說，若非古典後設不可則獨立標註。
8. **文件名 `AGENTS.md`**（不是 `AGENtS.md`）。

---

## 建議的檔案地圖（實作時）

命題階段（Phase 1–7）：

```
Mylogic.lean                 -- 只 import 已存在的模組
Mylogic/Formula.lean
Mylogic/Deduction.lean
Mylogic/Examples.lean
Mylogic/Meta.lean
Mylogic/Kripke.lean
Mylogic/Countermodel.lean
Mylogic/PrintAxioms.lean
```

一階階段（Phase 8，IPC 過關後）：

```
Mylogic/FirstOrder/Syntax.lean
Mylogic/FirstOrder/Substitution.lean
Mylogic/FirstOrder/Deduction.lean
Mylogic/FirstOrder/Examples.lean
```

明確先不要存在（除非 TASKS 該階段已核准）：

```
Mylogic/Modal.lean
Mylogic/Probability.lean
Mylogic/Classical.lean
Mylogic/FirstOrder.lean   -- 不要在 root 空 import
```

Lake 模板的 `Mylogic/Basic.lean`（`hello`）與 `Main.lean` 在 Phase 0 處理：主入口不要依賴不存在的模組。

---

## 寫程式時的對照表

| | 後設（Lean） | 對象（Mylogic） |
|---|---|---|
| 真 | `True` / 有證明項 | `⊤ᵢ` |
| 假 | `False` | `⟂` |
| 否定 | `¬` | `∼` |
| 合取 | `∧` | `⋀` |
| 析取 | `∨` | `⋁` |
| 蘊涵 | `→` | `⇒` |
| 可證 | 該 `Prop` 有項 | `Γ ⊢ φ` |
| 全稱／存在 | `∀` / `∃`（Lean） | 對象量詞（Phase 8 才有） |

---

## 下一 session 開工指令

若目標是開始寫 Lean：從 [`TASKS.md`](TASKS.md) 的 **Phase 0** 做起，做完一個 phase 就 `lake build`，不要一次做完 IPC。若目標是改邏輯規格：先改 `first-order-logic.md`，再改 TASKS，最後才動程式。
