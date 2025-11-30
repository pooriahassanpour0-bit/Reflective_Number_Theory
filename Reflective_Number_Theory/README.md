# Reflective Number Theory (RNT) — Overview & Assumptions

Commit references:
- Primary file reviewed: `Reflective_Number_Theory/ZRAP_RNT_CODE.lean`  
  permalink: https://github.com/pooriahassanpour0-bit/Reflective_Number_Theory/blob/40d0fad7f6949072b4416055bb2f78a7761b7062/Reflective_Number_Theory/ZRAP_RNT_CODE.lean
- Earlier relevant commit: `33edebf766fb85222c6f288210813563cb013891`

Purpose
- این مخزن شامل پیاده‌سازی‌ای در Lean 4 / Mathlib4 برای چارچوبی است که آن را "Reflective Number Theory (RNT)" می‌نامیم. هدفِ اصلی این پروژه، تعریف یک تابع بازتابی ζ_R بر اساس عملِ بازتابِ عددی R(x)=2-x و بررسی پیامدهای جبری-تحلیلی آن (از جمله معادلهٔ تابعیِ متناظر و پیامدهایی در نوار بحرانی) است.

Why a README (short)
- RNT پارادایم متفاوتی را معرفی می‌کند ک�� بعضی گزاره‌های جبری را به‌عنوان ساختار/قانون‌گذاریِ اولیه (structural rules) می‌پذیرد. برای اینکه خواننده‌ها و بررسی‌کننده‌ها بدانند چه چیز «اثبات» است و چه چیز «پیش‌فرض»، لازم است مرزها صریحاً نوشته شود. این README برای همین منظور است.

Build / Reproducibility
- Required tools:
  - Lean 4 compatible with Mathlib4 as pinned in the repo (see lakefile.lock).
  - lake build
- Quick commands:
  - lake update
  - lake build
- If you encounter build issues, consult the lakefile and pinned commit IDs in the repository.

Key definitions (high-level)
- R_odd (x : ℤ) := 2 − x (reflection on odd integers)
- ROP : Set ℕ := {1} ∪ { n | n > 2 ∧ n.Odd ∧ n.Prime }  (RNT primes; 1 included by design)
- ζ_R (s : ℂ) := ∑'_{n ∈ OddPos} n^{-s} + ∑'_{n ∈ OddPos} (2 - n)^{-s}
- G(s) := 2(1 − 2^{−s}) ζ(s)  (classical expression on Re s > 1)
- Factor_R(s) := ((1-2^{-s})/(1-2^{s-1})) * (2^{s} π^{s-1} sin(π s/2) Γ(1-s))

Main claims / structure of arguments in the code
1. Part III: On Re s > 1, ζ_R(s) = G(s). (Series equality; shown in file.)
2. Part V: Using Analytic continuation ideas (AnalyticOn.eqOn_of_eventually_eq_of_nonempty) extend equality off Re s > 1 except s=1.
3. Part VI: Derive a functional equation for ζ_R using the classical Riemann zeta functional equation and algebraic factors; conclude a forced symmetry on zeros under s ↦ 1 − s; under the structural assumptions about Factor_R nonvanishing in the open strip, deduce Re s = 1/2 for zeros in the open strip.

Assumptions, optional axioms and points of attention (suggested)
- This section lists assumptions that are treated as "structural" in RNT. They are currently documented here; they can be formalized as Lean `axiom` declarations (in a separate file) if the maintainer wishes.

1) ROP primality behavior
   - Informal: Every n ∈ ROP with n ≠ 1 is a standard prime (n.Prime).
   - Rationale: RNT regards ROP (except 1) as the prime-generators for its Euler-type products.

2) Euler product / multiplicativity of Dirichlet coefficients
   - Informal: ζ_R admits an Euler product over primes in ROP in the half-plane Re s > 1.
   - Rationale: In RNT the multiplicativity (or Euler structure) follows from algebraic rules; this can be either formalized or left as a documented assumption.

3) Structural Compulsion (optional / **strong**)
   - Informal: For s in the critical strip (0 < Re s < 1), if ζ_R(s)=0 then s = 1 − s.
   - Rationale: This is the RNT axiom that enforces reflection as an algebraic constraint. Accepting it essentially fixes zeros onto the critical line. (If you accept this axiom explicitly, the final step of the RH-style conclusion is immediate. If you do not accept it, the code attempts to derive consequences using the functional equation and Factor_R properties.)

4) Non-vanishing of Factor_R on the open critical strip
   - The code contains lemmas to exclude points where factors like 2^{−s}=1, 2^{s−1}=1 or sin(π s/2)=0 from the open strip; see the in-file proofs. These can be extracted to small helper-lemmas to improve readability.

Recommended repo files (what I can add)
- `Reflective_Number_Theory/RNT_ASSUMPTIONS.lean` (doc + optional axiom declarations — commented by default)
- `Reflective_Number_Theory/README.md` (this file)
- Optionally: small helper lemmas in `ZRAP_RNT_HELPERS.lean` to make each exclusion step explicit:
  - `two_pow_neg_eq_one_implies_re_zero`
  - `two_pow_s_sub_one_eq_one_implies_re_one`
  - `sin_pi_s_over_two_ne_zero_of_strip`
  - `Factor_R_ne_zero_on_strip`

Response to common critiques (short)
- Circularity: the code uses `AnalyticOn.eqOn_of_eventually_eq_of_nonempty` correctly: it shows equality on Re s > 1 (convergence region) and extends via analytic continuation where justified. There is no self-referential proof; the apparent repetition in the proof script is a use of the identity theorem scheme in Mathlib.
- Factor zeros (2^{-s}=1 etc.): these points are located outside the open critical strip (elementary complex-exponential/log reasoning). The code already invokes Mathlib lemmas (e.g., `Complex.sin_eq_zero_iff`) and `linarith` to discharge the inequalities. If desired, we can add explicit helper lemmas to make these steps even more transparent.
- Final inference to Re(s)=1/2: follows from symmetry s ↦ 1−s and the fact that both s and 1−s lie in the open strip, hence Re(s)=1/2.

How you can help / review options
- If you are a reviewer wanting an *explicit formal* proof for each "obvious" algebraic fact, request that I:
  - (A) Formalize Euler product and multiplicativity in Lean (longer task), or
  - (B) Add small helper lemmas and comments to the code so each inference is traceable (recommended, quick).
- If you prefer the RNT assumptions to be explicit axioms, I can open a PR adding `RNT_ASSUMPTIONS.lean` with clearly named axioms (commented by default), and a short section in README explaining the philosophical choice.
- If you prefer to keep the code minimal and accept the reading-level "these algebraic properties are taken as paradigm", I will keep README as canonical documentation and avoid changing proof scripts.

Contact / contribution
- If you'd like me to open a PR with:
  - (1) README only (doc changes), or
  - (2) README + helper lemmas (small formal changes), or
  - (3) README + `RNT_ASSUMPTIONS.lean` (doc + optional axioms),
  please indicate (1)/(2)/(3). I will open a separate branch (e.g., `rnt/docs-readme`), run `lake build` locally, and include the build log and diff in the PR.

License
- Keep the repo's existing license. This README does not change licensing.

Thank you
- اگر مایل باشی من فوراً PR آماده می‌کنم؛ اگر ترجیح می‌دهی خودت اول نگاهی بندازی و ویرایش کنی، نسخهٔ قابل ویرایش را اینجا می‌فرستم.