(*
 * Copyright 2020, Data61, CSIRO (ABN 41 687 119 230)
 *
 * SPDX-License-Identifier: BSD-2-Clause
 *)

section "Additional Syntax for Word Bit Operations"

theory Word_Syntax
imports
  "HOL-Library.Word"
  Bitwise
begin

text \<open>Additional bit and type syntax that forces word types.\<close>

type_synonym word8 = "8 word"
type_synonym word16 = "16 word"
type_synonym word32 = "32 word"
type_synonym word64 = "64 word"

lemma len8: "len_of (x :: 8 itself) = 8" by simp
lemma len16: "len_of (x :: 16 itself) = 16" by simp
lemma len32: "len_of (x :: 32 itself) = 32" by simp
lemma len64: "len_of (x :: 64 itself) = 64" by simp

abbreviation
  wordNOT  :: "'a::len word \<Rightarrow> 'a word"      ("~~ _" [70] 71)
where
  "~~ x == NOT x"

abbreviation
  wordAND  :: "'a::len word \<Rightarrow> 'a word \<Rightarrow> 'a word" (infixr "&&" 64)
where
  "a && b == a AND b"

abbreviation
  wordOR   :: "'a::len word \<Rightarrow> 'a word \<Rightarrow> 'a word" (infixr "||"  59)
where
  "a || b == a OR b"

abbreviation
  wordXOR  :: "'a::len word \<Rightarrow> 'a word \<Rightarrow> 'a word" (infixr "xor" 59)
where
  "a xor b == a XOR b"

end
