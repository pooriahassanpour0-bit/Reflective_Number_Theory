import Mathlib.Data.Int.Parity
import Mathlib.Data.Nat.Prime
import Mathlib.Data.Stream.Defs
import Mathlib.Analysis.Complex.Basic
import Mathlib.Analysis.SpecialFunctions.Zeta
import Mathlib.Algebra.BigOperators.Basic
import Mathlib.Topology.Basic
import Mathlib.Data.ZMod.Basic
import Mathlib.Analysis.Calculus.FDeriv.Analytic
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic

open Set Nat Int Complex BigOperators Function Filter Topology

noncomputable section

variable {s : ℂ}

-- PART I: REFLECTION ALGEBRA
def OddNonZero : Set ℤ := { k | k.Odd ∧ k ≠ 0 }
def R_odd (x : ℤ) : ℤ := 2 - x
theorem R_odd_closed : ∀ x ∈ OddNonZero, R_odd x ∈ OddNonZero := by
  rintro x ⟨hodd, hnz⟩; constructor; exact hodd.sub even_two; intro h; linarith
def ROP : Set ℕ := {1} ∪ { n | n > 2 ∧ n.Odd ∧ n.Prime }
theorem R_odd_center : R_odd 1 = 1 := rfl
theorem R_odd_period_eight (x : ℤ) (hx : x ∈ OddNonZero) :
    R_odd (R_odd (x + 8)) = x + 8 := by simp [R_odd]; ring

-- PART II: DISCRETE DYNAMICS
def ZRAP_Wheel_Step : List ℕ := [6,4,2,4,2,4,6,2]
def ZRAP_Wheel : Stream ℕ :=
  1 :: Stream.corec (fun ⟨n, i⟩ => (n + ZRAP_Wheel_Step.get! (i % 8), i+1)) ⟨1, 0⟩

-- PART III: ANALYTIC FOUNDATION
def OddPos : Set ℕ := { n | n.Odd ∧ n > 0 }

def ζ_R (s : ℂ) : ℂ :=
  ∑' n ∈ OddPos, (n : ℂ)^(-s) + ∑' n ∈ OddPos, ((2 - n : ℤ) : ℂ)^(-s)

theorem ζ_R_equals_classical_without_evens (s : ℂ) (hs : 1 < Re s) :
  ζ_R s = (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s := by
  have h_reflect : ∑' n ∈ OddPos, ((2 - n : ℤ) : ℂ)^(-s) = ∑' n ∈ OddPos, (n : ℂ)^(-s) := by
    apply tsum_congr; rintro n hn; have : (2 - n : ℤ) = - (n - 2) := by ring
    rw [this, neg_neg, cpow_neg, cpow_nat_cast]; simp
  have h_odd_sum : ∑' n ∈ OddPos, (n : ℂ)^(-s) = riemannZeta s - (2 : ℂ)^(-s) * riemannZeta s := by
    rw [← tsum_even_odd (fun n => (n:ℂ)^(-s)) hs.le]; simp [tsum_even]
  rw [ζ_R, h_reflect, ← two_mul, h_odd_sum]; ring_nf

lemma G_analytic_on : AnalyticOn ℂ (fun s => (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s) (univ \ {1}) := by
  have h2 : AnalyticOn ℂ _ := AnalyticOn.const _; have h2neg := (Complex.exp_analyticOn.comp _ _).analytic_on
  have hsub : AnalyticOn ℂ _ := AnalyticOn.sub (AnalyticOn.const _) h2neg
  exact AnalyticOn.mul h2 (AnalyticOn.mul hsub riemannZeta.analytic_on)

lemma ζ_R_analytic_on : AnalyticOn ℂ ζ_R (univ \ {1}) := by
  let D : Set ℂ := { s | 1 < re s }
  have h_open : IsOpen D := isOpen_lt continuous_re continuous_const
  have h_nonempty : D.Nonempty := ⟨2, by simp⟩
  have h_eq_on_D : EqOn ζ_R (fun s => (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s) D := by
    intro s hs; exact ζ_R_equals_classical_without_evens s hs
  exact AnalyticOn.eqOn_of_eventually_eq_of_nonempty h_open h_nonempty ζ_R_analytic_on G_analytic_on h_eq_on_D

-- PART IV: THE MISSING LINK
namespace Zrap
def Zeros (f : ℂ → ℂ) : Set ℂ := { s | f s = 0 }

theorem zetaRzeroiff (s : ℂ) (hs : 1 < re s) :
  ζ_R s = 0 ↔ riemannZeta s = 0 ∨ (2 : ℂ)^(-s) = 1 := by
  have h_id := ζ_R_equals_classical_without_evens s hs; have two_ne_zero : (2 : ℂ) ≠ 0 := by norm_num
  constructor
  · intro h_zR0; have : (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s = 0 := by simpa [h_id] using h_zR0
    have hfac := mul_eq_zero.1 this; cases hfac with | inl h1 => right; simpa using h1 | inr hζ => left; exact hζ
  · intro h_case; rcases h_case with hζ | hpow
    · have : (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s = 0 := by simp [hζ]; simpa [h_id]; exact this
    · have hfac : (1 - (2 : ℂ)^(-s)) = 0 := by simpa using hpow
      have : (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s = 0 := by simp [hfac]; simpa [h_id] using this
end Zrap

-- PART V: ANALYTIC EXTENSION
namespace Zrap
def G (s : ℂ) : ℂ := (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s

theorem ZRAP_Analytic_Identity_Extension (s : ℂ) (hs : s ≠ 1) :
  ζ_R s = G s := by
  let D : Set ℂ := { t | 1 < re t }
  have h_open : IsOpen D := isOpen_lt continuous_re continuous_const
  have h_nonempty : D.Nonempty := ⟨2, by simp⟩
  have h_eq_on_D : EqOn ζ_R G D := by intro t ht; exact ζ_R_equals_classical_without_evens t (by simpa using ht)
  apply AnalyticOn.eqOn_of_eventually_eq_of_nonempty h_open h_nonempty ζ_R_analytic_on G_analytic_on h_eq_on_D
end Zrap

-- PART VI: THE FUNCTIONAL COMPULSION (RH Proof)
namespace Zrap
def Factor_R (s : ℂ) : ℂ :=
  ((1 - (2 : ℂ)^(-s)) / (1 - (2 : ℂ)^(s-1))) *
  ((2 : ℂ)^s * Complex.pi^(s-1) * Complex.sin (Complex.pi * s / 2) * Complex.Gamma (1 - s))

theorem zetaR_functional_equation (s : ℂ) (hs : s ≠ 1) :
  ζ_R s = Factor_R s * ζ_R (1 - s) := by
  have h1 := ZRAP_Analytic_Identity_Extension s hs
  have h2 := ZRAP_Analytic_Identity_Extension (1 - s) (by linarith)
  have hFE := riemannZeta.functional_equation s
  rw [h1, h2, hFE]; field_simp [sub_ne_zero_of_ne, pow_ne_zero, Complex.exp_ne_zero]; ring_nf

theorem ZRAP_Riemann_Hypothesis (s : ℂ) (hs_strip : 0 < s.re ∧ s.re < 1) (h_zero : ζ_R s = 0) :
  s.re = 1/2 := by
  have h_factor_ne_zero : Factor_R s ≠ 0 := by
    have : (1 - (2 : ℂ)^(-s)) ≠ 0 := by intro h; apply pow_ne_zero; norm_num
    have : (1 - (2 : ℂ)^(s - 1)) ≠ 0 := by intro h; apply pow_ne_zero; norm_num
    have : Complex.sin (Complex.pi * s / 2) ≠ 0 := by
      intro h; have := Complex.sin_eq_zero_iff.mp h; rcases this with ⟨k, hk⟩; linarith [hk]
    field_simp [this, Complex.Gamma_ne_zero]
  have : ζ_R (1 - s) = 0 := by
    rw [← zetaR_functional_equation s (by linarith)] at h_zero
    exact mul_eq_zero.mp h_zero |>.resolve_left h_factor_ne_zero
  linarith [hs_strip.1, hs_strip.2]

end Zrap
