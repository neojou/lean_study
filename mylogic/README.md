# mylogic

用 Lean 4 當後設語言，編碼一套直覺主義對象邏輯（命題 NJ，之後才一階）。

這不是 `mymathlib` 那條線（在 Lean 的 `Prop` 裡做數學）。

## 從哪裡讀

1. [`docs/handoff.md`](docs/handoff.md) — 現況、為何有講義、給下一個（含瀏覽器）Grok 的角色
2. [`docs/lession1.md`](docs/lession1.md) — Phase 1 課堂講義與作業（作者自己寫 `Formula.lean`）
3. [`docs/AGENTS.md`](docs/AGENTS.md) — 硬約束
4. [`docs/TASKS.md`](docs/TASKS.md) — 全課綱
5. [`docs/first-order-logic.md`](docs/first-order-logic.md) — 邏輯學規格

## 進度（2026-09-09）

- Phase 0 完成：`lake exe mylogic` 原本印 `Hello, world!`（保留 `hello` 模板）。
- Phase 1 進行中：依 `lession1.md` 的 HW1.1–HW1.5，**不要代寫**。
- 模組名是 `Mylogic`。不要 `import Mathlib`。

```sh
lake build
lake exe mylogic
```
