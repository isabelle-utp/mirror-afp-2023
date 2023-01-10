(*
  Title:  Example Completeness Proof for System K
  Author: Asta Halkjær From
*)

chapter \<open>Example: Modal Logic\<close>

theory Example_Modal_Logic imports Derivations begin

section \<open>Syntax\<close>

datatype ('i, 'p) fm
  = Fls (\<open>\<^bold>\<bottom>\<close>)
  | Pro 'p
  | Imp \<open>('i, 'p) fm\<close> \<open>('i, 'p) fm\<close> (infixr \<open>\<^bold>\<longrightarrow>\<close> 55)
  | Box 'i \<open>('i, 'p) fm\<close> (\<open>\<^bold>\<box>\<close>)

abbreviation Neg (\<open>\<^bold>\<not> _\<close> [70] 70) where
  \<open>Neg p \<equiv> p \<^bold>\<longrightarrow> \<^bold>\<bottom>\<close>

section \<open>Semantics\<close>

record ('i, 'p, 'w) kripke =
  \<W> :: \<open>'w set\<close>
  \<K> :: \<open>'i \<Rightarrow> 'w \<Rightarrow> 'w set\<close>
  \<pi> :: \<open>'w \<Rightarrow> 'p \<Rightarrow> bool\<close>

type_synonym ('i, 'p, 'w) ctx = \<open>('i, 'p, 'w) kripke \<times> 'w\<close>

fun semantics :: \<open>('i, 'p, 'w) ctx \<Rightarrow> ('i, 'p) fm \<Rightarrow> bool\<close> (\<open>_ \<Turnstile> _\<close> [50, 50] 50) where
  \<open>_ \<Turnstile> \<^bold>\<bottom> \<longleftrightarrow> False\<close>
| \<open>(M, w) \<Turnstile> Pro x \<longleftrightarrow> \<pi> M w x\<close>
| \<open>(M, w) \<Turnstile> p \<^bold>\<longrightarrow> q \<longleftrightarrow> (M, w) \<Turnstile> p \<longrightarrow> (M, w) \<Turnstile> q\<close>
| \<open>(M, w) \<Turnstile> \<^bold>\<box> i p \<longleftrightarrow> (\<forall>v \<in> \<W> M \<inter> \<K> M i w. (M, v) \<Turnstile> p)\<close>

section \<open>Calculus\<close>

primrec eval :: \<open>('p \<Rightarrow> bool) \<Rightarrow> (('i, 'p) fm \<Rightarrow> bool) \<Rightarrow> ('i, 'p) fm \<Rightarrow> bool\<close> where
  \<open>eval _ _ \<^bold>\<bottom> = False\<close>
| \<open>eval g _ (Pro x) = g x\<close>
| \<open>eval g h (p \<^bold>\<longrightarrow> q) = (eval g h p \<longrightarrow> eval g h q)\<close>
| \<open>eval _ h (\<^bold>\<box> i p) = h (\<^bold>\<box> i p)\<close>

abbreviation \<open>tautology p \<equiv> \<forall>g h. eval g h p\<close>

inductive SystemK :: \<open>('i, 'p) fm \<Rightarrow> bool\<close> (\<open>\<turnstile>\<^sub>\<box> _\<close> [50] 50) where
  A1: \<open>tautology p \<Longrightarrow> \<turnstile>\<^sub>\<box> p\<close>
| A2: \<open>\<turnstile>\<^sub>\<box> \<^bold>\<box> i (p \<^bold>\<longrightarrow> q) \<^bold>\<longrightarrow> \<^bold>\<box> i p \<^bold>\<longrightarrow> \<^bold>\<box> i q\<close>
| R1: \<open>\<turnstile>\<^sub>\<box> p \<Longrightarrow> \<turnstile>\<^sub>\<box> p \<^bold>\<longrightarrow> q \<Longrightarrow> \<turnstile>\<^sub>\<box> q\<close>
| R2: \<open>\<turnstile>\<^sub>\<box> p \<Longrightarrow> \<turnstile>\<^sub>\<box> \<^bold>\<box> i p\<close>

primrec imply :: \<open>('i, 'p) fm list \<Rightarrow> ('i, 'p) fm \<Rightarrow> ('i, 'p) fm\<close> (infixr \<open>\<^bold>\<leadsto>\<close> 56) where
  \<open>([] \<^bold>\<leadsto> q) = q\<close>
| \<open>(p # ps \<^bold>\<leadsto> q) = (p \<^bold>\<longrightarrow> ps \<^bold>\<leadsto> q)\<close>

abbreviation K_assms (\<open>_ \<turnstile>\<^sub>\<box> _\<close> [50, 50] 50) where
  \<open>G \<turnstile>\<^sub>\<box> p \<equiv> \<turnstile>\<^sub>\<box> G \<^bold>\<leadsto> p\<close>

section \<open>Soundness\<close>

lemma eval_semantics:
  \<open>eval (pi w) (\<lambda>q. (\<lparr>\<W> = W, \<K> = r, \<pi> = pi\<rparr>, w) \<Turnstile> q) p = ((\<lparr>\<W> = W, \<K> = r, \<pi> = pi\<rparr>, w) \<Turnstile> p)\<close>
  by (induct p) simp_all

lemma tautology:
  assumes \<open>tautology p\<close>
  shows \<open>(M, w) \<Turnstile> p\<close>
proof -
  from assms have \<open>eval (g w) (\<lambda>q. (\<lparr>\<W> = W, \<K> = r, \<pi> = g\<rparr>, w) \<Turnstile> q) p\<close> for W g r
    by simp
  then have \<open>(\<lparr>\<W> = W, \<K> = r, \<pi> = g\<rparr>, w) \<Turnstile> p\<close> for W g r
    using eval_semantics by fast
  then show \<open>(M, w) \<Turnstile> p\<close>
    by (metis kripke.cases)
qed

theorem soundness:
  assumes \<open>\<And>M w p. A p \<Longrightarrow> w \<in> \<W> M \<Longrightarrow> (M, w) \<Turnstile> p\<close>
  shows \<open>\<turnstile>\<^sub>\<box> p \<Longrightarrow> w \<in> \<W> M \<Longrightarrow> (M, w) \<Turnstile> p\<close>
  by (induct p arbitrary: w rule: SystemK.induct) (auto simp: assms tautology)

section \<open>Derived rules\<close>

lemma K_imply_head: \<open>p # ps \<turnstile>\<^sub>\<box> p\<close>
proof -
  have \<open>tautology (p # ps \<^bold>\<leadsto> p)\<close>
    by (induct ps) simp_all
  then show ?thesis
    using A1 by blast
qed

lemma K_imply_Cons:
  assumes \<open>ps \<turnstile>\<^sub>\<box> q\<close>
  shows \<open>p # ps \<turnstile>\<^sub>\<box> q\<close>
proof -
  have \<open>\<turnstile>\<^sub>\<box> (ps \<^bold>\<leadsto> q \<^bold>\<longrightarrow> p # ps \<^bold>\<leadsto> q)\<close>
    by (simp add: A1)
  with R1 assms show ?thesis .
qed

lemma K_right_mp:
  assumes \<open>ps \<turnstile>\<^sub>\<box> p\<close> \<open>ps \<turnstile>\<^sub>\<box> p \<^bold>\<longrightarrow> q\<close>
  shows \<open>ps \<turnstile>\<^sub>\<box> q\<close>
proof -
  have \<open>tautology (ps \<^bold>\<leadsto> p \<^bold>\<longrightarrow> ps \<^bold>\<leadsto> (p \<^bold>\<longrightarrow> q) \<^bold>\<longrightarrow> ps \<^bold>\<leadsto> q)\<close>
    by (induct ps) simp_all
  with A1 have \<open>\<turnstile>\<^sub>\<box> ps \<^bold>\<leadsto> p \<^bold>\<longrightarrow> ps \<^bold>\<leadsto> (p \<^bold>\<longrightarrow> q) \<^bold>\<longrightarrow> ps \<^bold>\<leadsto> q\<close> .
  then show ?thesis
    using assms R1 by blast
qed

lemma deduct1: \<open>ps \<turnstile>\<^sub>\<box> p \<^bold>\<longrightarrow> q \<Longrightarrow> p # ps \<turnstile>\<^sub>\<box> q\<close>
  by (meson K_right_mp K_imply_Cons K_imply_head)

lemma imply_append [iff]: \<open>(ps @ qs \<^bold>\<leadsto> r) = (ps \<^bold>\<leadsto> qs \<^bold>\<leadsto> r)\<close>
  by (induct ps) simp_all

lemma imply_swap_append: \<open>ps @ qs \<turnstile>\<^sub>\<box> r \<Longrightarrow> qs @ ps \<turnstile>\<^sub>\<box> r\<close>
proof (induct qs arbitrary: ps)
  case Cons
  then show ?case
    by (metis deduct1 imply.simps(2) imply_append)
qed simp

lemma K_ImpI: \<open>p # ps \<turnstile>\<^sub>\<box> q \<Longrightarrow> ps \<turnstile>\<^sub>\<box> p \<^bold>\<longrightarrow> q\<close>
  by (metis imply.simps imply_append imply_swap_append)

lemma imply_mem [simp]: \<open>p \<in> set ps \<Longrightarrow> ps \<turnstile>\<^sub>\<box> p\<close>
  using K_imply_head K_imply_Cons by (induct ps) fastforce+

lemma add_imply [simp]: \<open>\<turnstile>\<^sub>\<box> q \<Longrightarrow> ps \<turnstile>\<^sub>\<box> q\<close>
  using K_imply_head R1 by auto

lemma K_imply_weaken: \<open>ps \<turnstile>\<^sub>\<box> q \<Longrightarrow> set ps \<subseteq> set ps' \<Longrightarrow> ps' \<turnstile>\<^sub>\<box> q\<close>
  by (induct ps arbitrary: q) (simp, metis K_right_mp K_ImpI imply_mem insert_subset list.set(2))

lemma K_Boole:
  assumes \<open>(\<^bold>\<not> p) # G \<turnstile>\<^sub>\<box> \<^bold>\<bottom>\<close>
  shows \<open>G \<turnstile>\<^sub>\<box> p\<close>
proof -
  have \<open>G \<turnstile>\<^sub>\<box> \<^bold>\<not> \<^bold>\<not> p\<close>
    using assms K_ImpI by blast
  moreover have \<open>tautology (G \<^bold>\<leadsto> \<^bold>\<not> \<^bold>\<not> p \<^bold>\<longrightarrow> G \<^bold>\<leadsto> p)\<close>
    by (induct G) simp_all
  then have \<open>\<turnstile>\<^sub>\<box> (G \<^bold>\<leadsto> \<^bold>\<not> \<^bold>\<not> p \<^bold>\<longrightarrow> G \<^bold>\<leadsto> p)\<close>
    using A1 by blast
  ultimately show ?thesis
    using R1 by blast
qed

lemma K_distrib_K_imp:
  assumes \<open>\<turnstile>\<^sub>\<box> \<^bold>\<box> i (G \<^bold>\<leadsto> q)\<close>
  shows \<open>map (\<^bold>\<box> i) G \<turnstile>\<^sub>\<box> \<^bold>\<box> i q\<close>
proof -
  have \<open>\<turnstile>\<^sub>\<box> \<^bold>\<box> i (G \<^bold>\<leadsto> q) \<^bold>\<longrightarrow> map (\<^bold>\<box> i) G \<^bold>\<leadsto> \<^bold>\<box> i q\<close>
  proof (induct G)
    case Nil
    then show ?case
      by (simp add: A1)
  next
    case (Cons a G)
    have \<open>\<turnstile>\<^sub>\<box> \<^bold>\<box> i (a # G \<^bold>\<leadsto> q) \<^bold>\<longrightarrow> \<^bold>\<box> i a \<^bold>\<longrightarrow> \<^bold>\<box> i (G \<^bold>\<leadsto> q)\<close>
      by (simp add: A2)
    moreover have
      \<open>\<turnstile>\<^sub>\<box> ((\<^bold>\<box> i (a # G \<^bold>\<leadsto> q) \<^bold>\<longrightarrow> \<^bold>\<box> i a \<^bold>\<longrightarrow> \<^bold>\<box> i (G \<^bold>\<leadsto> q)) \<^bold>\<longrightarrow>
        (\<^bold>\<box> i (G \<^bold>\<leadsto> q) \<^bold>\<longrightarrow> map (\<^bold>\<box> i) G \<^bold>\<leadsto> \<^bold>\<box> i q) \<^bold>\<longrightarrow>
        (\<^bold>\<box> i (a # G \<^bold>\<leadsto> q) \<^bold>\<longrightarrow> \<^bold>\<box> i a \<^bold>\<longrightarrow> map (\<^bold>\<box> i) G \<^bold>\<leadsto> \<^bold>\<box> i q))\<close>
      by (simp add: A1)
    ultimately have \<open>\<turnstile>\<^sub>\<box> \<^bold>\<box> i (a # G \<^bold>\<leadsto> q) \<^bold>\<longrightarrow> \<^bold>\<box> i a \<^bold>\<longrightarrow> map (\<^bold>\<box> i) G \<^bold>\<leadsto> \<^bold>\<box> i q\<close>
      using Cons R1 by blast
    then show ?case
      by simp
  qed
  then show ?thesis
    using assms R1 by blast
qed

interpretation Derivations K_assms
proof
  fix A B and p :: \<open>('i, 'p) fm\<close>
  assume \<open>\<turnstile>\<^sub>\<box> A \<^bold>\<leadsto> p\<close> \<open>set A \<subseteq> set B\<close>
  then show \<open>\<turnstile>\<^sub>\<box> B \<^bold>\<leadsto> p\<close>
    using K_imply_weaken by blast
qed

section \<open>Maximal Consistent Sets\<close>

definition consistent :: \<open>('i, 'p) fm set \<Rightarrow> bool\<close> where
  \<open>consistent S \<equiv> \<nexists>S'. set S' \<subseteq> S \<and> S' \<turnstile>\<^sub>\<box> \<^bold>\<bottom>\<close>

interpretation MCS_No_Saturation consistent
proof
  fix S S' :: \<open>('i, 'p) fm set\<close>
  assume \<open>consistent S\<close> \<open>S' \<subseteq> S\<close>
  then show \<open>consistent S'\<close>
    unfolding consistent_def by fast
next
  fix S :: \<open>('i, 'p) fm set\<close>
  assume \<open>\<not> consistent S\<close>
  then show \<open>\<exists>S' \<subseteq> S. finite S' \<and> \<not> consistent S'\<close>
    unfolding consistent_def by blast
next
  show \<open>infinite (UNIV :: ('i, 'p) fm set)\<close>
    using infinite_UNIV_size[of \<open>\<lambda>p. p \<^bold>\<longrightarrow> p\<close>] by simp
qed

interpretation Derivations_MCS_Cut K_assms consistent \<open>\<^bold>\<bottom>\<close>
proof
  fix S :: \<open>('i, 'p) fm set\<close>
  show \<open>consistent S = (\<nexists>S'. set S' \<subseteq> S \<and> S' \<turnstile>\<^sub>\<box> \<^bold>\<bottom>)\<close>
    unfolding consistent_def ..
next
  fix A and p :: \<open>('i, 'p) fm\<close>
  assume \<open>p \<in> set A\<close>
  then show \<open>A \<turnstile>\<^sub>\<box> p\<close>
    by (metis K_imply_head K_imply_weaken Un_upper2 set_append split_list_first)
next
  fix A B and p q :: \<open>('i, 'p) fm\<close>
  assume \<open>A \<turnstile>\<^sub>\<box> p\<close> \<open>p # B \<turnstile>\<^sub>\<box> q\<close>
  then show \<open>A @ B \<turnstile>\<^sub>\<box> q\<close>
    by (metis K_imply_head K_right_mp R1 imply.simps(2) imply_append)
qed

lemma exists_finite_inconsistent:
  assumes \<open>\<not> consistent ({\<^bold>\<not> p} \<union> V)\<close>
  obtains W where \<open>{\<^bold>\<not> p} \<union> W \<subseteq> {\<^bold>\<not> p} \<union> V\<close> \<open>(\<^bold>\<not> p) \<notin> W\<close> \<open>finite W\<close> \<open>\<not> consistent ({\<^bold>\<not> p} \<union> W)\<close>
proof -
  obtain W' where W': \<open>set W' \<subseteq> {\<^bold>\<not> p} \<union> V\<close> \<open>W' \<turnstile>\<^sub>\<box> \<^bold>\<bottom>\<close>
    using assms unfolding consistent_def by blast
  let ?S = \<open>removeAll (\<^bold>\<not> p) W'\<close>
  have \<open>\<not> consistent ({\<^bold>\<not> p} \<union> set ?S)\<close>
    unfolding consistent_def using W'(2) by auto
  moreover have \<open>finite (set ?S)\<close>
    by blast
  moreover have \<open>{\<^bold>\<not> p} \<union> set ?S \<subseteq> {\<^bold>\<not> p} \<union> V\<close>
    using W'(1) by auto
  moreover have \<open>(\<^bold>\<not> p) \<notin> set ?S\<close>
    by simp
  ultimately show ?thesis
    by (meson that)
qed

lemma MCS_consequent:
  assumes \<open>consistent V\<close> \<open>maximal V\<close> \<open>(p \<^bold>\<longrightarrow> q) \<in> V\<close> \<open>p \<in> V\<close>
  shows \<open>q \<in> V\<close>
  using assms MCS_derive
  by (metis (mono_tags, lifting) K_imply_Cons K_imply_head K_right_mp insert_subset list.simps(15))

theorem deriv_in_maximal:
  assumes \<open>consistent V\<close> \<open>maximal V\<close> \<open>\<turnstile>\<^sub>\<box> p\<close>
  shows \<open>p \<in> V\<close>
  using assms R1 derive_split1 unfolding consistent_def maximal_def by (metis imply.simps(2))

theorem exactly_one_in_maximal:
  assumes \<open>consistent V\<close> \<open>maximal V\<close>
  shows \<open>p \<in> V \<longleftrightarrow> (\<^bold>\<not> p) \<notin> V\<close>
  using assms MCS_derive MCS_derive_fls by (metis K_Boole K_imply_Cons K_imply_head K_right_mp)

section \<open>Truth Lemma\<close>

abbreviation pi :: \<open>('i, 'p) fm set \<Rightarrow> 'p \<Rightarrow> bool\<close> where
  \<open>pi V x \<equiv> Pro x \<in> V\<close>

abbreviation known :: \<open>('i, 'p) fm set \<Rightarrow> 'i \<Rightarrow> ('i, 'p) fm set\<close> where
  \<open>known V i \<equiv> {p. \<^bold>\<box> i p \<in> V}\<close>

abbreviation reach :: \<open>'i \<Rightarrow> ('i, 'p) fm set \<Rightarrow> ('i, 'p) fm set set\<close> where
  \<open>reach i V \<equiv> {W. known V i \<subseteq> W}\<close>

abbreviation mcss :: \<open>('i, 'p) fm set set\<close> where
  \<open>mcss \<equiv> {W. consistent W \<and> maximal W}\<close>

abbreviation canonical :: \<open>('i, 'p, ('i, 'p) fm set) kripke\<close> where
  \<open>canonical \<equiv> \<lparr>\<W> = mcss, \<K> = reach, \<pi> = pi\<rparr>\<close>

fun interp ::
  \<open>('i, 'p, 'w) ctx \<Rightarrow> (('i, 'p, 'w) ctx \<Rightarrow> ('i, 'p) fm \<Rightarrow> bool) \<Rightarrow> ('i, 'p) fm \<Rightarrow> bool\<close> where
  \<open>interp _ _ \<^bold>\<bottom> = False\<close>
| \<open>interp (M, w) _ (Pro x) = \<pi> M w x\<close>
| \<open>interp (M, w) X (p \<^bold>\<longrightarrow> q) = (X (M, w) p \<longrightarrow> X (M, w) q)\<close>
| \<open>interp (M, w) X (\<^bold>\<box> i p) = (\<forall>v \<in> \<W> M \<inter> \<K> M i w. X (M, v) p)\<close>

fun rel :: \<open>('i, 'p) fm set \<Rightarrow> ('i, 'p, ('i, 'p) fm set) ctx \<Rightarrow> ('i, 'p) fm \<Rightarrow> bool\<close> where
  \<open>rel _ (_, w) p = (p \<in> w)\<close>

lemma Hintikka_model':
  fixes V :: \<open>('i, 'p) fm set\<close>
  assumes \<open>\<And>(V :: ('i, 'p) fm set) p. V \<in> mcss \<Longrightarrow> interp (canonical, V) (rel H) p \<longleftrightarrow> p \<in> V\<close>
  shows \<open>V \<in> mcss \<Longrightarrow> (canonical, V) \<Turnstile> p \<longleftrightarrow> p \<in> V\<close>
proof (induct p arbitrary: V rule: wf_induct[where r=\<open>measure size\<close>])
  case 1
  then show ?case ..
next
  case (2 x)
  then show ?case
    using assms[of V x] by (cases x) auto
qed

lemma maximal_extension:
  fixes V :: \<open>('i, 'p) fm set\<close>
  assumes \<open>consistent V\<close>
  shows \<open>\<exists>W. V \<subseteq> W \<and> consistent W \<and> maximal W\<close>
  using assms MCS_Extend' Extend_subset by meson

lemma Hintikka_canonical:
  fixes V :: \<open>('i, 'p) fm set\<close>
  assumes \<open>V \<in> mcss\<close>
  shows \<open>interp (canonical, V) (rel H) p = rel H (canonical, V) p\<close>
proof (cases p)
  case Fls
  have \<open>\<^bold>\<bottom> \<notin> V\<close>
    using assms MCS_derive unfolding consistent_def by blast
  then show ?thesis
    using Fls by simp
next
  case (Imp p q)
  have \<open>(p \<in> V \<longrightarrow> q \<in> V) \<longleftrightarrow> p \<^bold>\<longrightarrow> q \<in> V\<close>
    using assms MCS_derive MCS_derive_fls MCS_consequent
    by (metis (no_types, lifting) CollectD K_Boole K_ImpI K_imply_Cons)
  then show ?thesis
    using Imp by simp
next
  case (Box i p)
  have \<open>(\<forall>v \<in> mcss \<inter> reach i V. p \<in> v) = (\<^bold>\<box> i p \<in> V)\<close>
  proof
    assume \<open>\<^bold>\<box> i p \<in> V\<close>
    then show \<open>\<forall>v \<in> mcss \<inter> reach i V. p \<in> v\<close>
      by auto
  next
    assume *: \<open>\<forall>v \<in> mcss \<inter> reach i V. p \<in> v\<close>

    have \<open>consistent V\<close> \<open>maximal V\<close>
      using \<open>V \<in> mcss\<close> by blast+

    have \<open>\<not> consistent ({\<^bold>\<not> p} \<union> known V i)\<close>
    proof
      assume \<open>consistent ({\<^bold>\<not> p} \<union> known V i)\<close>
      then obtain W where W: \<open>{\<^bold>\<not> p} \<union> known V i \<subseteq> W\<close> \<open>consistent W\<close> \<open>maximal W\<close>
        using \<open>V \<in> mcss\<close> maximal_extension by blast
      then have \<open>(canonical, W) \<Turnstile> \<^bold>\<not> p\<close>
        using "*" exactly_one_in_maximal by auto
      moreover have \<open>W \<in> reach i V\<close> \<open>W \<in> mcss\<close>
        using W by simp_all
      ultimately have \<open>(canonical, V) \<Turnstile> \<^bold>\<not> \<^bold>\<box> i p\<close>
        by auto
      then show False
        using * W(1) \<open>W \<in> mcss\<close> exactly_one_in_maximal by auto
    qed

    then obtain W where W:
      \<open>{\<^bold>\<not> p} \<union> W \<subseteq> {\<^bold>\<not> p} \<union> known V i\<close> \<open>(\<^bold>\<not> p) \<notin> W\<close> \<open>finite W\<close> \<open>\<not> consistent ({\<^bold>\<not> p} \<union> W)\<close>
      using exists_finite_inconsistent by metis

    obtain L where L: \<open>set L = W\<close>
      using \<open>finite W\<close> finite_list by blast
    then have \<open>\<turnstile>\<^sub>\<box> L \<^bold>\<leadsto> p\<close>
      using W(4) derive_split1 unfolding consistent_def by (meson K_Boole K_imply_weaken)
    then have \<open>\<turnstile>\<^sub>\<box> \<^bold>\<box> i (L \<^bold>\<leadsto> p)\<close>
      using R2 by fast
    then have \<open>map (\<^bold>\<box> i) L \<turnstile>\<^sub>\<box> \<^bold>\<box> i p\<close>
      using K_distrib_K_imp by fast
    then have \<open>(map (\<^bold>\<box> i) L \<^bold>\<leadsto> \<^bold>\<box> i p) \<in> V\<close>
      using deriv_in_maximal \<open>V \<in> mcss\<close> by blast
    then show \<open>\<^bold>\<box> i p \<in> V\<close>
      using L W(1-2)
    proof (induct L arbitrary: W)
      case (Cons a L)
      then have \<open>\<^bold>\<box> i a \<in> V\<close>
        by auto
      then have \<open>(map (\<^bold>\<box> i) L \<^bold>\<leadsto> \<^bold>\<box> i p) \<in> V\<close>
        using Cons(2) \<open>consistent V\<close> \<open>maximal V\<close> MCS_consequent by auto
      then show ?case
        using Cons by auto
    qed simp
  qed
  then show ?thesis
    using Box by simp
qed simp

interpretation Truth_No_Saturation consistent interp semantics
  \<open>\<lambda>_. {(canonical, V) |V. V \<in> mcss}\<close> rel
proof
  fix p and M :: \<open>('i, 'p, ('i, 'p) fm set) ctx\<close>
  show \<open>(M \<Turnstile> p) = interp M semantics p\<close>
    by (cases M, induct p) simp_all
next
  fix p and H :: \<open>('i, 'p) fm set\<close> and M :: \<open>('i, 'p, ('i, 'p) fm set) ctx\<close>
  assume \<open>\<forall>M\<in>{(canonical, V) |V. V \<in> mcss}. \<forall>p. interp M (rel H) p = rel H M p\<close>
    \<open>M \<in> {(canonical, V) |V. V \<in> mcss}\<close>
  then show \<open>(M \<Turnstile> p) = rel H M p\<close>
    using Hintikka_model'[of H _ p] by auto
next
  fix H :: \<open>('i, 'p) fm set\<close>
  assume \<open>consistent H\<close> \<open>maximal H\<close>
  then show \<open>\<forall>M\<in>{(canonical, V) |V. V \<in> mcss}. \<forall>p. interp M (rel H) p = rel H M p\<close>
    using Hintikka_canonical by blast
qed

lemma Truth_lemma:
  fixes p :: \<open>('i, 'p) fm\<close>
  assumes \<open>consistent V\<close> \<open>maximal V\<close>
  shows \<open>(canonical, V) \<Turnstile> p \<longleftrightarrow> p \<in> V\<close>
  using assms truth_lemma_no_saturation by fastforce

lemma canonical_model:
  assumes \<open>consistent S\<close> \<open>p \<in> S\<close>
  defines \<open>V \<equiv> Extend S\<close> and \<open>M \<equiv> canonical\<close>
  shows \<open>(M, V) \<Turnstile> p\<close> \<open>consistent V\<close> \<open>maximal V\<close>
proof -
  have \<open>consistent V\<close>
    using \<open>consistent S\<close> unfolding V_def using consistent_Extend by auto
  have \<open>maximal V\<close>
    unfolding V_def using maximal_Extend by blast
  { fix x
    assume \<open>x \<in> S\<close>
    then have \<open>x \<in> V\<close>
      unfolding V_def using Extend_subset by blast
    then have \<open>(M, V) \<Turnstile> x\<close>
      unfolding M_def using Truth_lemma \<open>consistent V\<close> \<open>maximal V\<close> by blast }
  then show \<open>(M, V) \<Turnstile> p\<close>
    using \<open>p \<in> S\<close> by blast+
  show \<open>consistent V\<close> \<open>maximal V\<close>
    by fact+
qed

section \<open>Completeness\<close>

abbreviation valid :: \<open>('i, 'p) fm set \<Rightarrow> ('i, 'p) fm \<Rightarrow> bool\<close>
  (\<open>_ \<TTurnstile> _\<close> [50, 50] 50) where
  \<open>G \<TTurnstile> p \<equiv> \<forall>M :: ('i, 'p, ('i, 'p) fm set) kripke.
    (\<forall>w \<in> \<W> M. (\<forall>q \<in> G. (M, w) \<Turnstile> q) \<longrightarrow> (M, w) \<Turnstile> p)\<close>

theorem strong_completeness:
  assumes \<open>G \<TTurnstile> p\<close>
  shows \<open>\<exists>qs. set qs \<subseteq> G \<and> qs \<turnstile>\<^sub>\<box> p\<close>
proof (rule ccontr)
  assume \<open>\<nexists>qs. set qs \<subseteq> G \<and> qs \<turnstile>\<^sub>\<box> p\<close>
  then have *: \<open>\<forall>qs. set qs \<subseteq> G \<longrightarrow> \<not> (\<^bold>\<not> p) # qs \<turnstile>\<^sub>\<box> \<^bold>\<bottom>\<close>
    using K_Boole by blast

  let ?S = \<open>{\<^bold>\<not> p} \<union> G\<close>
  let ?V = \<open>Extend ?S\<close>

  have \<open>consistent ?S\<close>
    using * derive_split1 unfolding consistent_def by meson
  then have \<open>(canonical, ?V) \<Turnstile> (\<^bold>\<not> p)\<close> \<open>\<forall>q \<in> G. (canonical, ?V) \<Turnstile> q\<close>
    using canonical_model by fastforce+
  moreover have \<open>?V \<in> mcss\<close>
    using \<open>consistent ?S\<close> maximal_Extend canonical_model(2) by blast
  ultimately have \<open>(canonical, ?V) \<Turnstile> p\<close>
    using assms by simp
  then show False
    using \<open>(canonical, ?V) \<Turnstile> (\<^bold>\<not> p)\<close> by simp
qed

corollary completeness: \<open>{} \<TTurnstile> p \<Longrightarrow> \<turnstile>\<^sub>\<box> p\<close>
  using strong_completeness[where G=\<open>{}\<close>] by simp

theorem main: \<open>{} \<TTurnstile> p \<longleftrightarrow> \<turnstile>\<^sub>\<box> p\<close>
  using soundness completeness by fast

end
