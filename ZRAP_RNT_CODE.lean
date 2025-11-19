import RiemannZeta.lean
import Basic.lean
import Mathlib.Data.Int.Parity
import Mathlib.Data.Nat.Prime
import Mathlib.Data.Stream.Defs
import Mathlib.Analysis.Complex.Basic
import Mathlib.Algebra.BigOperators.Basic
import Mathlib.Topology.Basic
import Mathlib.Data.ZMod.Basic

open Set Nat Int Complex BigOperators Function Filter

noncomputable section

variable {s : ℂ}

/-! ### PART I: REFLECTION ALGEBRA — The Compelled Foundation -/

def OddNonZero : Set ℤ := { k | k.Odd ∧ k ≠ 0 }

def R_odd (x : ℤ) : ℤ := 2 - x

theorem R_odd_closed : ∀ x ∈ OddNonZero, R_odd x ∈ OddNonZero := by
  rintro x ⟨hodd, hnz⟩
  constructor
  · exact hodd.sub even_two
  · intro h; linarith

def ROP : Set ℕ := {1} ∪ { n | n > 2 ∧ n.Odd ∧ n.Prime }

theorem R_odd_center : R_odd 1 = 1 := rfl

theorem R_odd_period_eight (x : ℤ) (hx : x ∈ OddNonZero) :
    R_odd (R_odd (x + 8)) = x + 8 := by
  simp [R_odd]; ring

/-! ### PART II: DISCRETE DYNAMICS — The Self-Generated Sieve -/

def ZRAP_Wheel_Step : List ℕ := [6,4,2,4,2,4,6,2]

def ZRAP_Wheel : Stream ℕ :=
  1 :: Stream.corec (fun ⟨n, i⟩ => (n + ZRAP_Wheel_Step.get! (i % 8), i+1)) ⟨1, 0⟩

theorem ZRAP_Wheel_never_div_by_2_3_5 (k : ℕ) :
    ∀ n ∈ ZRAP_Wheel.take (k+1), n.Odd ∧ 3 ∤ n ∧ 5 ∤ n := by
  apply Nat.rec_on k
  · simp [ZRAP_Wheel, Stream.take]; intro n hn; cases hn <;> simp_arith
  · rintro n ih m hm
    rcases hm with rfl|hm
    · simp_arith
    · rcases ih (by simp_all) with ⟨hodd, h3, h5⟩
      have h := ZRAP_Wheel_Step.get! (n % 8)
      interval_cases (n % 8) <;> simp_all [Nat.Odd, Nat.add_mod, Nat.add_div]

theorem ZRAP_Gap_Theorem (p : ℕ) (hp : p ∈ ROP \ {1}) :
    (p % 8 = 1 ∨ p % 8 = 3 ∨ p % 8 = 5 ∨ p % 8 = 7) := by
  rcases hp with ⟨-, ⟨_, hodd, _⟩⟩
  have h_neven : ∀ k ∈ ({0, 2, 4, 6} : Set ℕ), (p : ℤ) % 8 ≠ k := by
    rintro k hk h_mod
    have h_p_even : Even p := by
      refine Nat.even_of_modEq_even (Int.coe_nat_modEq_iff.mpr ?_)
      exact Int.ModEq.trans (Int.modEq_of_mod_eq h_mod) (Int.modEq_of_mod_eq (by simp))
    exact absurd h_p_even hodd.not_even

  have h_mod_set : (p : ℤ) % 8 ∈ {0, 1, 2, 3, 4, 5, 6, 7} := by
    apply Int.emod_mem_range_of_ne_zero; norm_num

  apply (Or.imp h_neven)
  apply (Or.imp h_neven)
  apply (Or.imp h_neven)
  apply (Or.imp h_neven)
  apply (Or.imp h_neven)
  apply (Or.imp h_neven)
  apply (Or.imp h_neven)
  apply (Or.imp h_neven) h_mod_set

/-! ### PART III: ANALYTIC FOUNDATION — The Reflective Zeta (ζ_R(s)) -/

def OddPos : Set ℕ := { n | n.Odd ∧ n > 0 }

theorem classical_zeta_unstable_on_ROP (s : ℂ) :
    ¬ Summable (fun (n : ℕ) => (n : ℂ)^(-s)) (ROP : Set ℕ) := by
  intro hsumm
  have : (1 : ℕ) ∈ ROP := by simp [ROP]
  apply not_summable_of_not_tendsto_zero (tsum_tendsto_zero_of_summable hsumm)
  simp

def ζ_R (s : ℂ) : ℂ :=
  ∑' n ∈ OddPos, (n : ℂ)^(-s) + ∑' n ∈ OddPos, ((2 - n : ℤ) : ℂ)^(-s)

theorem ζ_R_reflective_symmetry (s : ℂ) :
    ζ_R s = ∑' n ∈ OddPos, ((2 - n : ℤ) : ℂ)^(-s) + ∑' n ∈ OddPos, (n : ℂ)^(-s) := by
  rw [ζ_R, add_comm]

theorem ζ_R_equals_classical_without_evens (s : ℂ) (hs : 1 < Re s) :
    ζ_R s = (2 : ℂ) * (1 - (2 : ℂ)^(-s)) * riemannZeta s := by
  have h_reflect : ∑' n ∈ OddPos, ((2 - n : ℤ) : ℂ)^(-s) = ∑' n ∈ OddPos, (n : ℂ)^(-s) := by
    apply tsum_congr
    rintro n hn
    have : (2 - n : ℤ) = - (n - 2) := by ring
    rw [this, neg_neg, cpow_neg, cpow_nat_cast]
    simp
  
  have h_odd_sum : ∑' n ∈ OddPos, (n : ℂ)^(-s) = riemannZeta s - (2 : ℂ)^(-s) * riemannZeta s := by
    rw [← tsum_even_odd (fun n => (n:ℂ)^(-s)) hs.le]
    simp [tsum_even]

  rw [ζ_R, h_reflect, ← two_mul, h_odd_sum]
  ring_nf 
  
end
