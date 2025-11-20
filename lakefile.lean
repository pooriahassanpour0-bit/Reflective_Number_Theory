import Lake
open Lake DSL

package Reflective_Number_Theory

require mathlib from git
  "https://github.com/leanprover-community/mathlib4" @ "master"

lean_lib Reflective_Number_Theory {
  srcDir := "Reflective_Number_Theory"
}
