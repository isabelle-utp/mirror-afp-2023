(*******************************************************************************

  Project: Development of Security Protocols by Refinement

  Module:  Auth_simple/m3_sig.thy (Isabelle/HOL 2016-1)
  ID:      $Id: m3_sig.thy 133852 2017-03-20 15:59:33Z csprenge $
  Author:  Christoph Sprenger, ETH Zurich <sprenger@inf.ethz.ch>
  
  One-Way authentication protocols
  Refinement 3: protocol using signatures

  Copyright (c) 2009-2016 Christoph Sprenger
  Licence: LGPL

*******************************************************************************)

section {* Refinement 3a: Signature-based Dolev-Yao Protocol (Variant A) *}

theory m3_sig imports m2_auth_chan "../Refinement/Message"
begin

text {* We implement the channel protocol of the previous refinement with
signatures and add a full-fledged Dolev-Yao adversary.  In this variant, the
adversary is realized using Paulson's closure operators for message derivation
(as opposed to a collection of one-step derivation events a la Strand spaces). 
*}

text {* Proof tool configuration. Avoid annoying automatic unfolding of
@{text "dom"} (again). *}

declare domIff [simp, iff del]
declare analz_into_parts [dest]


(******************************************************************************)
subsection {* State *}
(******************************************************************************)

text {* We extend the state of @{term m1} with insecure and authentic
channels between each pair of agents. *}

record m3_state = m1_state +
  IK :: "msg set"                             -- {* intruder knowledge *}

type_synonym 
  m3_obs = m1_state

definition 
  m3_obs :: "m3_state \<Rightarrow> m3_obs" where
  "m3_obs s \<equiv> \<lparr> 
     runs = runs s
  \<rparr>"


(******************************************************************************)
subsection {* Events *}
(******************************************************************************)

definition
  m3_step1 :: "[rid_t, agent, agent, nonce] \<Rightarrow> (m3_state \<times> m3_state) set"
where
  "m3_step1 Ra A B Na \<equiv> {(s, s1).

     (* guards *)
     Ra \<notin> dom (runs s) \<and>
     Na = Ra$0 \<and>

     (* actions *)
     s1 = s\<lparr>
       runs := (runs s)(Ra \<mapsto> (Init, [A, B], [])), 
       IK := insert \<lbrace>Agent A, Agent B, Nonce Na\<rbrace> (IK s)    (* send msg 1 *)
     \<rparr>
  }"

definition
  m3_step2 :: "[rid_t, agent, agent, nonce, nonce] \<Rightarrow> (m3_state \<times> m3_state) set"
where 
  "m3_step2 Rb A B Na Nb \<equiv> {(s, s1).

     (* guards *)
     Rb \<notin> dom (runs s) \<and>
     Nb = Rb$0 \<and>

     \<lbrace>Agent A, Agent B, Nonce Na\<rbrace> \<in> IK s \<and>            (* receive msg 1 *)

     (* actions *)
     s1 = s\<lparr> 
       runs := (runs s)(Rb \<mapsto> (Resp, [A, B], [aNon Na])),
                                                        (* send msg 2 *) 
       IK := insert (Crypt (priK B) \<lbrace>Nonce Nb, Nonce Na, Agent A\<rbrace>) (IK s)  
     \<rparr>  
  }"

definition
  m3_step3 :: "[rid_t, agent, agent, nonce, nonce] \<Rightarrow> (m3_state \<times> m3_state) set"
where
  "m3_step3 Ra A B Na Nb \<equiv> {(s, s1).

     (* guards *)
     runs s Ra = Some (Init, [A, B], []) \<and>
     Na = Ra$0 \<and> 

     Crypt (priK B) \<lbrace>Nonce Nb, Nonce Na, Agent A\<rbrace> \<in> IK s \<and> (* recv msg 2 *)

     (* actions *)
     s1 = s\<lparr> 
       runs := (runs s)(Ra \<mapsto> (Init, [A, B], [aNon Nb]))
     \<rparr>  
  }"


text {* The intruder messages are now generated by a full-fledged Dolev-Yao 
intruder. *}

definition 
  m3_DY_fake :: "(m3_state \<times> m3_state) set"
where
  "m3_DY_fake \<equiv> {(s, s1).
     
     (* actions: *)
     s1 = s\<lparr> 
       IK := synth (analz (IK s))
     \<rparr>  
  }"


text {* Transition system. *}

definition 
  m3_init :: "m3_state set" 
where 
  "m3_init \<equiv> { \<lparr> 
     runs = empty, 
     IK = (Key`priK`bad) \<union> (Key`range pubK) \<union> (Key`shrK`bad)
  \<rparr> }"

definition 
  m3_trans :: "(m3_state \<times> m3_state) set" where
  "m3_trans \<equiv> (\<Union> A B Ra Rb Na Nb.
     m3_step1 Ra A B Na    \<union>
     m3_step2 Rb A B Na Nb \<union>
     m3_step3 Ra A B Na Nb \<union>
     m3_DY_fake         \<union>
     Id
  )"

definition
  m3 :: "(m3_state, m3_obs) spec" where
  "m3 \<equiv> \<lparr>
    init = m3_init,
    trans = m3_trans,
    obs = m3_obs
  \<rparr>"

lemmas m3_defs = 
  m3_def m3_init_def m3_trans_def m3_obs_def
  m3_step1_def m3_step2_def m3_step3_def 
  m3_DY_fake_def


(******************************************************************************)
subsection {* Invariants *}
(******************************************************************************)

text {* Specialize injectiveness of parts to enable aggressive application. *}

lemmas parts_Inj_IK = parts.Inj [where H="IK s" for s]
lemmas analz_Inj_IK = analz.Inj [where H="IK s" for s]


text {* The following invariants do not depend on the protocol messages.  
We want to keep this compilation refinement from channel protocols to
full-fledged Dolev-Yao protocols as generic as possible. *} 


subsubsection {* inv1: Long-term key secrecy *}
(******************************************************************************)

text {* Private signing keys are secret, that is, the intruder only knows 
private keys of corrupted agents. 

The invariant uses the weaker @{term parts} operator instead of the perhaps
more intuitive @{term analz} in its premise.  This strengthens the invariant 
and potentially simplifies its proof. 
*}

definition
  m3_inv1_lkeysec :: "m3_state set" where
  "m3_inv1_lkeysec \<equiv> {s. \<forall> A. 
     Key (priK A) \<in> analz (IK s) \<longrightarrow> A \<in> bad
  }"

lemmas m3_inv1_lkeysecI = 
  m3_inv1_lkeysec_def [THEN setc_def_to_intro, rule_format]
lemmas m3_inv1_lkeysecE [elim] = 
  m3_inv1_lkeysec_def [THEN setc_def_to_elim, rule_format]
lemmas m3_inv1_lkeysecD = 
  m3_inv1_lkeysec_def [THEN setc_def_to_dest, rule_format, rotated 1]


lemma PO_m3_inv1_lkeysec_init [iff]: 
  "init m3 \<subseteq> m3_inv1_lkeysec"
by (auto simp add: PO_hoare_def m3_defs intro!: m3_inv1_lkeysecI)

lemma PO_m3_inv1_lkeysec_trans [iff]:
  "{m3_inv1_lkeysec} trans m3 {> m3_inv1_lkeysec}"
by (auto simp add: PO_hoare_def m3_defs intro!: m3_inv1_lkeysecI)

lemma PO_m3_inv1_lkeysec [iff]: "reach m3 \<subseteq> m3_inv1_lkeysec"
by (rule inv_rule_basic) (auto)


subsubsection {* inv2: Intruder knows long-term keys of bad guys *}
(******************************************************************************)

definition 
  m3_inv2_badkeys :: "m3_state set" 
where
  "m3_inv2_badkeys \<equiv> {s. \<forall>C.
     C \<in> bad \<longrightarrow> Key (priK C) \<in> analz (IK s)
  }"

lemmas m3_inv2_badkeysI = 
  m3_inv2_badkeys_def [THEN setc_def_to_intro, rule_format]
lemmas m3_inv2_badkeysE [elim] = 
  m3_inv2_badkeys_def [THEN setc_def_to_elim, rule_format]
lemmas m3_inv2_badkeysD [dest] = 
  m3_inv2_badkeys_def [THEN setc_def_to_dest, rule_format, rotated 1]


text {* Invariance proof. *}

lemma PO_m3_inv2_badkeys_init [iff]:
  "init m3 \<subseteq> m3_inv2_badkeys"
by (auto simp add: m3_defs m3_inv2_badkeys_def)

lemma PO_m3_inv2_badkeys_trans [iff]:
  "{m3_inv2_badkeys} trans m3 {> m3_inv2_badkeys}"
by (auto simp add: PO_hoare_defs m3_defs intro!: m3_inv2_badkeysI)

lemma PO_m3_inv2_badkeys [iff]: "reach m3 \<subseteq> m3_inv2_badkeys"
by (rule inv_rule_basic) (auto)


subsubsection {* inv3: Intruder knows all public keys (NOT USED) *}
(******************************************************************************)

text {* This invariant is only needed with equality in @{text "R23_msgs"}. *}

definition 
  m3_inv3_pubkeys :: "m3_state set" 
where
  "m3_inv3_pubkeys \<equiv> {s. \<forall>C.
     Key (pubK C) \<in> analz (IK s)
  }"

lemmas m3_inv3_pubkeysI = 
  m3_inv3_pubkeys_def [THEN setc_def_to_intro, rule_format]
lemmas m3_inv3_pubkeysE [elim] = 
  m3_inv3_pubkeys_def [THEN setc_def_to_elim, rule_format]
lemmas m3_inv3_pubkeysD [dest] = 
  m3_inv3_pubkeys_def [THEN setc_def_to_dest, rule_format, rotated 1]


text {* Invariance proof. *}

lemma PO_m3_inv3_pubkeys_init [iff]:
  "init m3 \<subseteq> m3_inv3_pubkeys"
by (auto simp add: m3_defs m3_inv3_pubkeys_def)

lemma PO_m3_inv3_pubkeys_trans [iff]:
  "{m3_inv3_pubkeys} trans m3 {> m3_inv3_pubkeys}"
by (auto simp add: PO_hoare_defs m3_defs intro!: m3_inv3_pubkeysI)

lemma PO_m3_inv3_pubkeys [iff]: "reach m3 \<subseteq> m3_inv3_pubkeys"
by (rule inv_rule_basic) (auto)


(******************************************************************************)
subsection {* Refinement *}
(******************************************************************************)

text {* Automatic tool tuning. Tame too-agressive pair decomposition, which is
declared as a safe elim rule ([elim!]). *}

lemmas MPair_parts [rule del, elim]
lemmas MPair_analz [rule del, elim] 


subsubsection {* Simulation relation *}
(******************************************************************************)

abbreviation
  nonces :: "msg set \<Rightarrow> nonce set"
where
  "nonces H \<equiv> {N. Nonce N \<in> analz H}"

abbreviation
  ink :: "chmsg set \<Rightarrow> nonce set"
where
  "ink H \<equiv> {N. aNon N \<in> extr ik0 H}"


text {* Abstraction function on sets of messages. *}

inductive_set 
  abs_msg :: "msg set \<Rightarrow> chmsg set"
  for H :: "msg set"
where 
  am_M1: 
    "{| Agent A, Agent B, Nonce Na |} \<in> H
  \<Longrightarrow> Insec A B (Msg [aNon Na]) \<in> abs_msg H"

| am_M2:
    "Crypt (priK B) {| Nonce Nb, Nonce Na, Agent A |} \<in> H 
  \<Longrightarrow> Auth B A (Msg [aNon Nb, aNon Na]) \<in> abs_msg H"


text {* The simulation relation is canonical. It states that the protocol 
messages in the intruder knowledge refine the abstract messages appearing in 
the channels @{term Insec} and @{term Auth}. *}

definition
  R23_msgs :: "(m2_state \<times> m3_state) set" where
  "R23_msgs \<equiv> {(s, t). abs_msg (parts (IK t)) \<subseteq> chan s}"   (* with parts! *)

definition 
  R23_ink :: "(m2_state \<times> m3_state) set" where
  "R23_ink \<equiv> {(s, t). nonces (IK t) \<subseteq> ink (chan s)}"

definition 
  R23_preserved :: "(m2_state \<times> m3_state) set" where
  "R23_preserved \<equiv> {(s, t). runs s = runs t}"

definition 
  R23 :: "(m2_state \<times> m3_state) set" where
  "R23 \<equiv> R23_msgs \<inter> R23_ink \<inter> R23_preserved"

lemmas R23_defs = R23_def R23_msgs_def R23_ink_def R23_preserved_def


text {* Mediator function: nothing new. *}

definition
  med32 :: "m3_obs \<Rightarrow> m2_obs" where
  "med32 \<equiv> id"


lemmas R23_msgsI = 
  R23_msgs_def [THEN rel_def_to_intro, simplified, rule_format]
lemmas R23_msgsE [elim] = 
  R23_msgs_def [THEN rel_def_to_elim, simplified, rule_format]
lemmas R23_msgsE' [elim] = 
  R23_msgs_def [THEN rel_def_to_dest, simplified, rule_format, THEN subsetD]

lemmas R23_inkI = 
  R23_ink_def [THEN rel_def_to_intro, simplified, rule_format]
lemmas R23_inkE [elim] = 
  R23_ink_def [THEN rel_def_to_elim, simplified, rule_format]

lemmas R23_preservedI = 
  R23_preserved_def [THEN rel_def_to_intro, simplified, rule_format]
lemmas R23_preservedE [elim] = 
  R23_preserved_def [THEN rel_def_to_elim, simplified, rule_format]

lemmas R23_intros = R23_msgsI R23_inkI R23_preservedI


subsubsection {* Facts about the abstraction function *}
(******************************************************************************)

declare abs_msg.intros [intro!]
declare abs_msg.cases [elim!]

lemma abs_msg_empty: "abs_msg {} = {}"
by (auto)

lemma abs_msg_Un [simp]: 
  "abs_msg (G \<union> H) = abs_msg G \<union> abs_msg H"
by (auto)

lemma abs_msg_mono [elim]: 
  "\<lbrakk> m \<in> abs_msg G; G \<subseteq> H \<rbrakk> \<Longrightarrow> m \<in> abs_msg H"
by (auto)

lemma abs_msg_insert_mono [intro]: 
  "\<lbrakk> m \<in> abs_msg H \<rbrakk> \<Longrightarrow> m \<in> abs_msg (insert m' H)"
by (auto)


text {* Abstraction of concretely fakeable message yields abstractly fakeable 
messages. This is the key lemma for the refinement of the intruder. *}

lemma abs_msg_DY_subset_fakeable:
  "\<lbrakk> (s, t) \<in> R23_msgs; (s, t) \<in> R23_ink; t \<in> m3_inv1_lkeysec \<rbrakk>
  \<Longrightarrow> abs_msg (synth (analz (IK t))) \<subseteq> fake ik0 (dom (runs s)) (chan s)"
apply (auto)
  apply (rule fake_intros, auto)
  apply (rule fake_Inj, auto) 
  apply (rule fake_intros, auto)
done

lemma absmsg_parts_subset_fakeable:
  "\<lbrakk> (s, t) \<in> R23_msgs \<rbrakk>
  \<Longrightarrow> abs_msg (parts (IK t)) \<subseteq> fake ik0 (-dom (runs s)) (chan s)"
by (rule_tac B="chan s" in subset_trans) (auto)

declare abs_msg_DY_subset_fakeable [simp, intro!]
declare absmsg_parts_subset_fakeable [simp, intro!]



subsubsection {* Refinement proof *}
(******************************************************************************)

lemma PO_m3_step1_refines_m2_step1:
  "{R23} 
     (m2_step1 Ra A B Na), (m3_step1 Ra A B Na) 
   {> R23}"
by (auto simp add: PO_rhoare_defs R23_def m2_defs m3_defs intro!: R23_intros)
   (auto)

lemma PO_m3_step2_refines_m2_step2:
  "{R23 (* \<inter> UNIV \<times> m3_inv3_pubkeys *)} 
     (m2_step2 Rb A B Na Nb), (m3_step2 Rb A B Na Nb) 
   {> R23}"
by (auto simp add: PO_rhoare_defs R23_def m2_defs m3_defs intro!: R23_intros)
   (auto)

lemma PO_m3_step3_refines_m2_step3:
  "{R23} 
     (m2_step3 Ra A B Na Nb), (m3_step3 Ra A B Na Nb) 
   {> R23}"
by (auto simp add: PO_rhoare_defs R23_def m2_defs m3_defs intro!: R23_intros)
   (auto)


text {* The Dolev-Yao fake event refines the abstract fake event. *}

lemma PO_m3_DY_fake_refines_m2_fake:
  "{R23 \<inter> UNIV \<times> (m3_inv1_lkeysec \<inter> m3_inv2_badkeys)} 
     m2_fake, m3_DY_fake
   {> R23}"
by (auto simp add: PO_rhoare_defs R23_def m2_defs m3_defs)
   (rule R23_intros, auto)+


text {* All together now... *}

lemmas PO_m3_trans_refines_m2_trans = 
  PO_m3_step1_refines_m2_step1 PO_m3_step2_refines_m2_step2
  PO_m3_step3_refines_m2_step3 PO_m3_DY_fake_refines_m2_fake 

lemma PO_m3_refines_init_m2 [iff]:
  "init m3 \<subseteq> R23``(init m2)"
by (auto simp add: R23_defs m2_defs m3_defs)

lemma PO_m3_refines_trans_m2 [iff]:
  "{R23 \<inter> UNIV \<times> (m3_inv2_badkeys \<inter> m3_inv1_lkeysec)} 
     (trans m2), (trans m3) 
   {> R23}"
apply (auto simp add: m3_def m3_trans_def m2_def m2_trans_def)
apply (blast intro!: PO_m3_trans_refines_m2_trans)+
done

lemma PO_obs_consistent [iff]:
  "obs_consistent R23 med32 m2 m3"
by (auto simp add: obs_consistent_def R23_def med32_def m2_defs m3_defs)

lemma PO_m3_refines_m2:
  "refines 
     (R23 \<inter> UNIV \<times> (m3_inv2_badkeys \<inter> m3_inv1_lkeysec))
     med32 m2 m3"
by (rule Refinement_using_invariants) (auto)


end


