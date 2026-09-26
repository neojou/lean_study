# Lesson 2：把自然演繹做成歸納謂詞

> 這是一堂課，不是一份要貼進 repo 的解答。
> 對應 [`TASKS.md`](TASKS.md) 的 **Phase 2**，規格是 [`first-order-logic.md`](first-order-logic.md) 第 6–7 節。
> 你自己實作；HW2.1–HW2.5 都過關，Phase 2 就完成。
> 模型請當助教：批改、答疑，**不要**交出完整的 `Deduction.lean`。
> 日期：2026-09-09。

---

同學好。上一堂你把公式做成了樹：`Formula` 是資料，`∼` 是縮寫，`⋀` 不是 Lean 的 `∧`。樹本身既不真也不假，也不「可證」。

本週要做的是另一種歸納：**哪些樹可以從哪些假設推得出來**。判斷寫成 `Γ ⊢ φ`。這仍不是 Kripke 的「真」，也不是 Lean 的 `φ → φ`。它只是「存在一棵符合 NJ 規則的推導樹」。

本週結束時，你應該能讓下面這行通過型別檢查（`φ`、`ψ`、`Γ` 的型別稍後會講）：

```lean
#check (Deduction.impI :
  ∀ {a} {Γ : List (Formula a)} {φ ψ : Formula a},
    (φ :: Γ ⊢ ψ) → (Γ ⊢ φ ⇒ ψ))
```

注意箭頭有兩種：`→` 是後設（Lean），`⇒` 是對象。若你把它們寫成同一個符號，這堂課就失敗了。

---

## 0. 先讀什麼、繳什麼

**課前。** 規格書第 6 節（NJ 規則）與第 7 節（導出規則）。你的 `Mylogic/Formula.lean` 維持原樣；本週**不要重構**它。型別參數你寫成 `a`，講義裡的 `α` 是同一件事，作業請跟著你檔案裡的 `a`。

**課中。** 讀一節、做一份作業。後面的規則會用到前面的 constructor。

**繳交。** 新檔 `Mylogic/Deduction.lean`。作業五再改 `Mylogic.lean`，加上 `import Mylogic.Deduction`。不要開 `Examples.lean`、`Kripke.lean`，不要 `import Mathlib`，不要 `open Classical`。`hello` 模板留著，`lake exe mylogic` 仍應印 `Hello, world!`。

**禁寫清單**（出現任何一條，作業退回）：

- constructor 名叫 `lem`、`raa`、`dne`、`peirce`，或任何一條能直接得出 `φ ⋁ ∼φ`、`∼∼φ ⇒ φ`
- 把 `Γ ⊢ φ` 的型別寫成 `Type`（本週要 `Prop`）
- 用 Lean 的 `∧` `∨` `→` `¬` 當對象連詞
- 把 `negI` 做成 `Deduction` 的 constructor（它必須是 `theorem`）
- 改寫 `Formula` 去加量詞或第六個連詞

---

## 1. 判斷不是公式

上一週的 BNF 回答「什麼是公式」。本週回答「什麼是一次合法的推理」。

邏輯學把這件事寫成**判斷**（judgment）：

```
Γ ⊢ φ
```

讀作：在假設列 `Γ` 之下，公式 `φ` 可推導。`Γ` 是公式的有限列，不是集合。空列寫成 `⊢ φ`，意思是「不靠假設就是定理」。

三層不要混：

| 你寫的 | 它在說什麼 | 本週？ |
|---|---|---|
| `φ ⋀ ψ` | 一棵語法樹 | 已有 |
| `Γ ⊢ φ` | 有一棵 NJ 推導樹 | **本週** |
| `φ → ψ` | Lean 自己的蘊涵 | 只拿來連接判斷，不是對象連詞 |
| `w ⊩ φ` | 某世界強制 φ | 以後的 Kripke，本週不要做 |

所以 `theorem silly : φ → φ` 是在證 Lean 的恆等函數，**完全走錯層**。正確的最小對象定理是 `⊢ φ ⇒ φ`，而且它要等規則寫好才能組（作業五的吉祥物）。

---

## 2. 從歸納型到歸納謂詞

`Formula` 的 constructor 造**資料**。本週的 constructor 造**「可推導」這個事實**。

Lean 允許歸納型的結果是 `Prop`，而且索引可以依值於別的型別。概念上：

```lean
inductive Deduction : List (Formula a) → Formula a → Prop where
  | 某規則 : …前提… → Deduction Γ φ
```

讀法：

- `Deduction Γ φ` 這個命題為真，當且僅當你用這些規則把它造出來。
- 每個 constructor 是一條 NJ 規則。前提是更小的推導（遞迴），或是一個側條件（例如 `φ ∈ Γ`）。
- 沒有別的推導。以後「對所有推導歸納」就是對這些 constructor 做 `induction`。那是 Phase 4 的事；本週先把 constructor 的型別寫對。

為什麼結果是 `Prop` 不是 `Type`？因為我們現在要的是「可證性」這個判斷，不是把推導樹當成可以拿去 `match` 出程式的資料。證明項你仍然要**用手組**（Curry–Howard 沒消失，只是 Lean 會把 `Prop` 的證明擦掉）。若寫成 `Type`，後面每個引理都會突然在意兩個證明項是否相等，本週不值得。

檔案開頭：

```lean
import Mylogic.Formula

namespace Mylogic
```

`Deduction.lean` 是另一個模組，不會自動看見 `Formula`。必須 `import`。

---

## 3. 脈絡是 `List`，頭在左邊

規格規定：脈絡是 `List (Formula a)`，不用 `Finset`。重複假設可以出現。

列的方向本週就釘死，以後不准改：

```
φ :: Γ     =  [φ, …Γ 的其餘元素]
```

**最近假設放在頭。** `impI` 把前件推到頭上；`orE` 的兩支也是把頭上暫時多一個公式。

不要寫成 `Γ ++ [φ]`。那是把新假設放在尾巴，和本專案所有規則的圖相反。

成員關係 `φ ∈ Γ` 是 Lean 標準庫的 `List.Mem`（`∈` 的意思）。證明「頭元素在列裡」：

```lean
List.Mem.head Γ    -- 型別：φ ∈ φ :: Γ
List.mem_cons_self -- 同樣這件事，隱式參數版
```

「第二個元素在列裡」要先 `tail` 再 `head`。這是作業二會用到的唯一一個 List 引理，先認得它。

---

## 4. 結構規則：`ax` 與 `weaken`

這兩條不處理連詞，只處理假設列。

**假設。** 列裡有的公式可以直接用。

```
  φ ∈ Γ
 ────── ax
  Γ ⊢ φ
```

Lean 的形狀（隱式參數可以讓呼叫時少寫 `Γ`、`φ`；Lean 會從期望型別推）：

```lean
| ax : {Γ : List (Formula a)} → {φ : Formula a} →
    φ ∈ Γ → Deduction Γ φ
```

這不是古典公理，也不是排中律。它只是「假設可用」。

**弱化。** 多一個用不到的假設，舊推導仍然算數。新假設放在**頭**：

```
   Γ ⊢ φ
 ────────── weaken
  ψ :: Γ ⊢ φ
```

```lean
| weaken : {Γ : List (Formula a)} → {ψ φ : Formula a} →
    Deduction Γ φ → Deduction (ψ :: Γ) φ
```

每個 constructor 請寫一行中文：它對應哪條 NJ 規則。

記號（放在 `namespace Mylogic` 裡，跟上一週一樣用 `scoped`）：

```lean
scoped infix:50 " ⊢ " => Deduction
scoped notation "⊢" φ:50 => Deduction [] φ
```

第一行是 `Γ ⊢ φ`。第二行是空脈絡的 `⊢ φ`，也就是 `[] ⊢ φ`。兩行都要。優先順序 50 讓它比 `⋀`、`⇒` 鬆，公式會先組好再送進判斷。

---

### 作業一（HW2.1）——判斷落地

1. 新建 `Mylogic/Deduction.lean`，`import Mylogic.Formula`，`namespace Mylogic`。
2. 檔案開頭三句繁中：這是對象可證性、不是 Lean 的 `→`、結果是 `Prop`。
3. 只寫 `ax` 與 `weaken` 兩個 constructor。型別如上。還沒有合取。
4. 加上兩行 `⊢` 記號。
5. 讓下面這行過（可放在 namespace 內）：

```lean
example {Γ : List (Formula Nat)} {φ : Formula Nat} (h : φ ∈ Γ) :
    Γ ⊢ φ :=
  Deduction.ax h
```

**驗收。** `lake build` 綠（入口還沒 import `Deduction` 也可以，用 `lake build Mylogic.Deduction`）。`#print Deduction` 只看得到 `ax`、`weaken`。

---

## 5. 合取：造對與拆對

```
  Γ ⊢ φ    Γ ⊢ ψ
 ──────────────── andI
    Γ ⊢ φ ⋀ ψ

    Γ ⊢ φ ⋀ ψ              Γ ⊢ φ ⋀ ψ
   ───────── andEL        ───────── andER
      Γ ⊢ φ                   Γ ⊢ ψ
```

三個 constructor。合取是**對象**的 `Formula.and`（記號 `⋀`），不是 Lean 的 `And`。

```lean
| andI  : Deduction Γ φ → Deduction Γ ψ → Deduction Γ (φ.and ψ)
| andEL : Deduction Γ (φ.and ψ) → Deduction Γ φ
| andER : Deduction Γ (φ.and ψ) → Deduction Γ ψ
```

（`Γ`、`φ`、`ψ` 照上一節做成隱式參數。這裡只寫結論的形狀，避免黑板被花括號淹沒。）

`andEL` 的前提是「已經有一棵推出合取的樹」，不是兩個公式擺在那裡。消除拆的是**推導**，不是拆語法樹——語法樹上一週的 `size` 已經會拆了。

小例子（你作業二要自己組，這裡只講步驟）：假設列是 `⟪0⟫ :: ⟪1⟫ :: []`。

1. `ax` + `Mem.head` 得到這列推出 `⟪0⟫`。
2. `ax` + `Mem.tail` 再 `Mem.head` 得到這列推出 `⟪1⟫`。
3. `andI` 把兩棵樹接成 `⟪0⟫ ⋀ ⟪1⟫`。

這是**對象證明項**：一個 `Deduction` 的值。它不是 tactic 變出來的魔法。

---

### 作業二（HW2.2）——合取三規則

1. 加上 `andI`、`andEL`、`andER`。各一行中文。
2. 自己組出：

```lean
def and_from_hyps :
    (⟪0⟫ :: ⟪1⟫ :: []) ⊢ (⟪0⟫ ⋀ ⟪1⟫) :=
  sorry  -- 改成 ax / andI，不准留 sorry
```

提示：第二個假設不在列頭，`List.Mem.head` 不夠，要經過 `List.Mem.tail`。

**驗收。** 沒有 `sorry`。`#print Deduction` 多了這三個名字，仍然沒有 `lem`。

---

## 6. 析取：必須選邊，消除才分案

```
     Γ ⊢ φ                    Γ ⊢ ψ
 ──────────── orIL       ──────────── orIR
   Γ ⊢ φ ⋁ ψ                Γ ⊢ φ ⋁ ψ

  Γ ⊢ φ ⋁ ψ    φ :: Γ ⊢ χ    ψ :: Γ ⊢ χ
 ───────────────────────────────────── orE
                 Γ ⊢ χ
```

```lean
| orIL : Deduction Γ φ → Deduction Γ (φ.or ψ)
| orIR : Deduction Γ ψ → Deduction Γ (φ.or ψ)
| orE  : Deduction Γ (φ.or ψ) →
         Deduction (φ :: Γ) χ →
         Deduction (ψ :: Γ) χ →
         Deduction Γ χ
```

`orE` 有**三棵**子樹。漏一棵，型別對不上。兩支假設各自把 `φ` 或 `ψ` 推到列頭，推出**同一個** `χ`，然後把頭上的假設丟掉。

這不是 `by_cases`。`by_cases` 是對 `P ∨ ¬P` 分案，會把古典排中律帶進後設。我們的 `orE` 只在**已經有一棵對象析取的推導**時才能用。

引入必須選邊：你要呼叫 `orIL` 或 `orIR`，不能「先丟一個析取再看心情」。這就是以後析取性質的源頭，也是 `∼(φ ⋀ ψ) ⇒ (∼φ ⋁ ∼ψ)` 在直覺主義裡組不出來的原因——那一步必須選邊，可是你不知道選哪邊。本週不要去證那條。

---

### 作業三（HW2.3）——析取三規則

1. 加上 `orIL`、`orIR`、`orE`。
2. 讓下面的型別註解通過（這是在檢查 `orE` 的三個前提與列頭方向，不是叫你證明排中律）：

```lean
#check (Deduction.orE :
  ∀ {a} {Γ : List (Formula a)} {φ ψ χ : Formula a},
    (Γ ⊢ φ ⋁ ψ) →
    (φ :: Γ ⊢ χ) →
    (ψ :: Γ ⊢ χ) →
    (Γ ⊢ χ))
```

**驗收。** 這個 `#check` 沒有型別錯誤。若 Lean 抱怨 `or` 與 `⋁` 對不上，是 constructor 用了錯誤的連詞。若抱怨 `Γ ++ [φ]`，是列的方向寫反了。

---

## 7. 蘊涵與荒謬

蘊涵引入就是演繹定理本身：在假設 `φ` 之下證出 `ψ`，就得到 `φ ⇒ ψ`，並把 `φ` 從頭上拿掉。

```
   φ :: Γ ⊢ ψ
  ────────── impI
   Γ ⊢ φ ⇒ ψ

  Γ ⊢ φ ⇒ ψ    Γ ⊢ φ
 ────────────────── impE
        Γ ⊢ ψ
```

```lean
| impI : Deduction (φ :: Γ) ψ → Deduction Γ (φ.imp ψ)
| impE : Deduction Γ (φ.imp ψ) → Deduction Γ φ → Deduction Γ ψ
```

`impI` 的**前提**脈絡比結論多一個頭。寫反是本週最常見的錯：你會得到「先有蘊涵再製造假設」，那不是 NJ。

`impE` 是 modus ponens。兩棵樹的脈絡必須是**同一個** `Γ`。不要讓其中一棵偷偷多假設。

荒謬消除是直覺主義與極小邏輯的分界：

```
  Γ ⊢ ⟂
 ────── falsumE
  Γ ⊢ φ
```

```lean
| falsumE : Deduction Γ .falsum → Deduction Γ φ
```

`φ` 是任意公式，必須是這個 constructor 的參數（通常隱式）。沒有 `falsumI`。你不能無中生有造出 `⟂`；唯一的辦法是已經有 `φ` 又有 `∼φ`（下一節的 `negE`），或假設列裡本來就有 `⟂`。

本系統到這裡就**封口**。不要再加 constructor。

---

### 作業四（HW2.4）——蘊涵、荒謬、空脈絡記號

1. 加上 `impI`、`impE`、`falsumE`。各一行中文。
2. 確認本檔開頭那段 `impI` 的 `#check` 通過（講義第 0 節那一則）。
3. `#print Deduction`，核對恰好這 11 個 constructor：

`ax` `weaken` `andI` `andEL` `andER` `orIL` `orIR` `orE` `impI` `impE` `falsumE`

**驗收。** 多一個、少一個、或名字不同，都退回。特別檢查沒有 `lem`。

---

## 8. 導出規則是定理，不是新 constructor

規格第 7 節的規則必須用上面 11 條**組出來**。它們是 `theorem`（或 `def`），出現在 `inductive` **結束之後**。`#print Deduction` 不該把它們算進 constructor。

因為 `∼φ` 定義上就是 `φ ⇒ ⟂`：

- `negI`：前提 `φ :: Γ ⊢ ⟂`，結論 `Γ ⊢ ∼φ`。這就是 `impI`。
- `negE`：前提 `Γ ⊢ ∼φ` 與 `Γ ⊢ φ`，結論 `Γ ⊢ ⟂`。這就是 `impE`。

真：

- `verumI`：結論 `Γ ⊢ ⊤ᵢ`，沒有前提。`⊤ᵢ` 是 `⟂ ⇒ ⟂`。先在 `⟂ :: Γ` 用 `ax` 得到 `⟂`（頭元素），再 `impI`。

切割：

```
  Γ ⊢ φ    φ :: Γ ⊢ ψ
 ──────────────────── cut
        Γ ⊢ ψ
```

做法一句話：對第二棵樹做 `impI`，得到 `Γ ⊢ φ ⇒ ψ`，再與第一棵做 `impE`。這在 NJ 裡很短。將來若改成 sequent，cut 會變成大定理；本專案不走那條路。

列上的弱化：一次在頭上加**一整列** `Δ`，得到 `Δ ++ Γ ⊢ φ`。對 `Δ` 做歸納：

- `Δ = []` 時，`[] ++ Γ` 就是 `Γ`，交回原推導。
- `Δ = ψ :: Δ'` 時，歸納假設已經給你 `Δ' ++ Γ ⊢ φ`，再用一次 `weaken` 把頭上補 `ψ`。

`++` 是把左邊那列接在前面，所以和 `weaken`「加在頭上」的方向一致。歸納變元是 `Δ`，不是 `φ`。

頭假設：

```lean
-- 目標型別（名字用 ax_head）
φ :: Γ ⊢ φ
```

這是 `ax` 的特例，對象證明會天天用。證明就是 `Deduction.ax (List.Mem.head Γ)`。

---

### 作業五（HW2.5）——導出規則與總驗收

在 `Deduction.lean` 裡、`inductive` 之外，完成下列定理。每個上方一行中文，註明「導出規則，不是 constructor」或「對象定理」。**不准 `sorry`，不准 `open Classical`。**

```lean
theorem ax_head {Γ : List (Formula a)} {φ : Formula a} :
    φ :: Γ ⊢ φ := sorry

theorem negI {Γ : List (Formula a)} {φ : Formula a}
    (d : φ :: Γ ⊢ ⟂) : Γ ⊢ ∼φ := sorry

theorem negE {Γ : List (Formula a)} {φ : Formula a}
    (dn : Γ ⊢ ∼φ) (d : Γ ⊢ φ) : Γ ⊢ ⟂ := sorry

theorem verumI {Γ : List (Formula a)} : Γ ⊢ ⊤ᵢ := sorry

theorem cut {Γ : List (Formula a)} {φ ψ : Formula a}
    (dφ : Γ ⊢ φ) (dψ : φ :: Γ ⊢ ψ) : Γ ⊢ ψ := sorry

theorem weaken_list {Γ Δ : List (Formula a)} {φ : Formula a}
    (d : Γ ⊢ φ) : Δ ++ Γ ⊢ φ := sorry
```

`a` 若還沒有 `variable {a : Type}`，請加上，或把 `{a}` 寫進每個定理。

吉祥物（對象定理，仍放在本檔，不要另開 `Examples.lean`）：

```lean
theorem imp_id {φ : Formula a} : ⊢ φ ⇒ φ := sorry
```

提示：空脈絡。先在 `φ :: []` 用 `ax_head`，再 `impI`。結論必須是 `⊢ φ ⇒ φ`，不是 `φ → φ`。

然後：

1. `Mylogic.lean` 加上 `import Mylogic.Deduction`，保留 `Basic` 與 `Formula`。
2. `lake build`。
3. `lake exe mylogic` 仍印 `Hello, world!`。

**Phase 2 完成條件（全部成立才把 [`TASKS.md`](TASKS.md) 的 Phase 2 核取清單打勾）：**

- [ ] 11 個 constructor 齊，名字與規格一致。
- [ ] `negI`、`negE`、`verumI`、`ax_head`、`weaken_list`、`cut` 都是定理且無 `sorry`。
- [ ] `imp_id` 的型別是 `⊢ φ ⇒ φ`。
- [ ] 講義第 0 節的 `impI` `#check` 通過。
- [ ] 作業三的 `orE` `#check` 通過。
- [ ] 沒有 `lem`／`raa`／`dne`。
- [ ] `lake build` 綠，exe 仍 Hello。
- [ ] 沒有 Mathlib、沒有 `Classical`。

---

## 附錄 A — 改作業時常見的叉

1. **`impI` 的脈絡寫成 `Γ ⊢ φ ⇒ ψ` 當前提。** 前提必須是 `φ :: Γ ⊢ ψ`。
2. **新假設接到尾巴 `Γ ++ [φ]`。** 本專案一律 `φ :: Γ`。
3. **`orE` 只有兩棵子樹。** 要三棵：析取本身，加左邊，加右邊。
4. **`negI` 做成 constructor。** `#print Deduction` 會多一名。改成 `theorem`，本體是 `impI`。
5. **`theorem imp_id : φ → φ`。** 走錯層。要 `⊢ φ ⇒ φ`。
6. **`falsumE` 沒有把目標公式當參數。** 從 `⟂` 推出的 `φ` 必須能隨呼叫改變，否則你只能推出某一個寫死的公式。
7. **`weaken_list` 對公式歸納。** 請對 `Δ` 歸納。`[] ++ Γ = Γ` 是定義等式，`nil` 那支通常直接 `exact d`。
8. **`by_cases`、`tauto`、`aesop`。** 本週的重點是看見規則。這些 tactic 不是 NJ。
9. **順便證明 `⊢ ∼∼φ ⇒ φ`。** 不可證。卡住是正確的。留到反模型那週。
10. **`import MyLogic.Deduction`。** 模組名是 `Mylogic`。

---

## 附錄 B — 本週的兩層箭頭

| 符號 | 層 | 例子 |
|---|---|---|
| `→` | 後設 Lean | `impI` 的型別：(前提判斷) `→` (結論判斷) |
| `⇒` | 對象公式 | `φ ⇒ φ` 這棵樹 |
| `⊢` | 對象可證性 | `Γ ⊢ φ`，本身是一個 `Prop` |
| `∧` | 後設 Lean | 兩個 `Prop` 同時成立；**不要**拿來寫公式 |
| `⋀` | 對象公式 | `Formula.and` |

`cut` 的型別同時用到三個：`(Γ ⊢ φ) → (φ :: Γ ⊢ ψ) → (Γ ⊢ ψ)`。兩個 `→` 是後設，三個 `⊢` 是對象判斷。

---

## 附錄 C — 節奏

| 時段 | 讀 | 做 | 停手條件 |
|---|---|---|---|
| 一 | §1–4 | HW2.1 | `ax` 的 example 過 |
| 二 | §5 | HW2.2 | `and_from_hyps` 無 `sorry` |
| 三 | §6 | HW2.3 | `orE` 的 `#check` 過 |
| 四 | §7 | HW2.4 | 11 個 constructor，`impI` 的 `#check` 過 |
| 五 | §8 | HW2.5 | `imp_id` 過，`lake exe` 仍 Hello |

卡住超過二十分鐘：先 `#print Deduction`，再對照附錄 A。把錯誤訊息和 `Deduction.lean` 帶來問，不要先要完整解答檔。

下一堂（Phase 3）才把 `⊢ (φ ⋀ ψ) ⇒ (ψ ⋀ φ)` 和 `⊢ φ ⇒ ∼∼φ` 組成練習。雙重否定**消除**仍然不要證。本週把規則的型別釘對，下週才組得動樹。
