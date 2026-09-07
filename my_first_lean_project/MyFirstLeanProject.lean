import MyFirstLeanProject.Basic
import Mathlib.Data.Rat.Defs

def a : ℚ := 1 / 2
def b : ℚ := 3 / 4
def c : ℚ := a + b

def main : IO Unit := do
  IO.println s!"Hello, {hello}!"
  IO.println s!"1 + 1 = {1 + 1}"
  IO.println a
  IO.println b
  IO.println c
