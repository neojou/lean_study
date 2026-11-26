def hello := "world"

-- 引理 1：若 n 為奇數，則 n * n 必為奇數
theorem odd_then_sq_odd (n : Nat) (h : Exists fun k => n = 2 * k + 1) : Exists fun m => n * n = 2 * m + 1 := by
    -- 1. 從假設 h 中取出 k，並直接將式子中的 n 替換成 2 * k + 1
    rcases h with ⟨k, rfl⟩
    -- 2. 指定目標的 m 為 2 * (k * k) + 2 * k
    refine ⟨2 * (k * k) + 2 * k, ?_⟩
    -- 3. 展開乘法分配律並由 grind 完成算術驗證
    grind

-- 引理 2：若 n * n 為偶數，則 n 必為偶數（純 Lean 4 核心庫版）
theorem sq_even_then_even (n : Nat) (h : Exists fun k => n * n = 2 * k) : Exists fun m => n = 2 * m := by
    -- 1. 任何自然數 n 除以 2 的餘數要嘛是 0，要嘛不是 0（即為 1）
    by_cases h_mod : n % 2 = 0
    -- 情況 1：n % 2 = 0（偶數），直接構造 m = n / 2，grind 會自動驗證 n = 2 * (n / 2)
    refine ⟨n / 2, ?_⟩
    grind
    -- 情況 2：n % 2 ≠ 0（奇數），先構造出 n = 2 * (n / 2) + 1 的條件
    have h_odd : Exists fun k => n = 2 * k + 1 := ⟨n / 2, by grind⟩
    -- 2. 呼叫引理 1 推出 n * n 是奇數
    have h_sq_odd := odd_then_sq_odd n h_odd
    -- 3. 拆解偶數與奇數的等式，讓 grind 抓出 2 * k = 2 * m + 1 的矛盾
    rcases h with ⟨k, hk⟩
    rcases h_sq_odd with ⟨m, hm⟩
    grind

-- 主定理：不存在正整數 a, b 使得 a^2 = 2 * b^2（純 Lean 4 核心庫 + grind）
theorem sqrt2_irrational : forall (a b : Nat), b != 0 -> a * a != 2 * (b * b) := by
    intro a
    induction a using Nat.strongRecOn with
    | ind a ih =>
    -- 1. 只引入 b 和 hb（因為後面的 != 是布林等式，不能用 intro 引入）
    intro b hb
    -- 2. 將 hb 與目標 (⊢) 中的布林 != 轉成邏輯上的 ≠
    simp only [bne_iff_ne, ne_eq] at hb
    simp only [bne_iff_ne, ne_eq]
    -- 3. 現在目標變成了 ¬ (a * a = 2 * (b * b))，可以安全使用 intro h_eq 了！
    intro h_eq

    -- 4. 由 a * a = 2 * (b * b)，套用引理 2 得出 a 是偶數 (a = 2 * k)
    rcases sq_even_then_even a ⟨b * b, h_eq⟩ with ⟨k, rfl⟩

    -- 5. 將 a = 2 * k 代回原式，由 grind 自動化簡出 b * b = 2 * (k * k)
    have hb_sq : b * b = 2 * (k * k) := by grind

    -- 6. 由 b * b = 2 * (k * k)，再次套用引理 2 得出 b 也是偶數 (b = 2 * m)
    rcases sq_even_then_even b ⟨k * k, hb_sq⟩ with ⟨m, rfl⟩

    -- 7. 將 b = 2 * m 代回，由 grind 自動化簡出 k * k = 2 * (m * m)
    have hk_sq : k * k = 2 * (m * m) := by grind

    -- 8. 告訴 grind：因為 2 * m ≠ 0，所以 m ≠ 0，進而 m * m ≠ 0（排除 k = 0 的情況）
    have hm_ne : m ≠ 0 := by grind
    have hm_sq_ne : m * m ≠ 0 := Nat.mul_ne_zero hm_ne hm_ne

    -- 9. 現在 grind 知道 m * m ≠ 0，就能推出 k ≠ 0 且 k < 2 * k，順利套用 ih！
    have ih_k := ih k (by grind) m (by grind)
    simp only [bne_iff_ne, ne_eq] at ih_k
    exact ih_k hk_sq
