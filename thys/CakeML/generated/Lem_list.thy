chapter \<open>Generated by Lem from \<open>list.lem\<close>.\<close>

theory "Lem_list" 

imports 
 	 Main
	 "Lem_bool" 
	 "Lem_maybe" 
	 "Lem_basic_classes" 
	 "Lem_function" 
	 "Lem_tuple" 
	 "Lem_num" 
	 "Lem" 

begin 

 

(*open import Bool Maybe Basic_classes Function Tuple Num*)

(*open import {coq} `Coq.Lists.List`*)
(*open import {isabelle} `$LIB_DIR/Lem`*)
(*open import {hol} `lemTheory` `listTheory` `rich_listTheory` `sortingTheory`*)

(* ========================================================================== *)
(* Basic list functions                                                       *)
(* ========================================================================== *)

(* The type of lists as well as list literals like [], [1;2], ... are hardcoded. 
   Thus, we can directly dive into derived definitions. *)


(* ----------------------- *)
(* cons                    *)
(* ----------------------- *)

(*val :: : forall 'a. 'a -> list 'a -> list 'a*)


(* ----------------------- *)
(* Emptyness check         *)
(* ----------------------- *)

(*val null : forall 'a. list 'a -> bool*)
(*let null l=  match l with [] -> true | _ -> false end*)

(* ----------------------- *)
(* Length                  *)
(* ----------------------- *)

(*val length : forall 'a. list 'a -> nat*)
(*let rec length l= 
  match l with
    | [] -> 0
    | x :: xs -> (Instance_Num_NumAdd_nat.+) (length xs) 1
  end*)

(* ----------------------- *)
(* Equality                *)
(* ----------------------- *)

(*val listEqual : forall 'a. Eq 'a => list 'a -> list 'a -> bool*)
(*val listEqualBy : forall 'a. ('a -> 'a -> bool) -> list 'a -> list 'a -> bool*)

fun  listEqualBy  :: "('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> bool "  where 
     " listEqualBy eq ([]) ([]) = ( True )"
|" listEqualBy eq ([]) (_ # _) = ( False )"
|" listEqualBy eq (_ # _) ([]) = ( False )"
|" listEqualBy eq (x # xs) (y # ys) = ( (eq x y \<and> listEqualBy eq xs ys))"



(* ----------------------- *)
(* compare                 *)
(* ----------------------- *)

(*val lexicographicCompare : forall 'a. Ord 'a => list 'a -> list 'a -> ordering*)
(*val lexicographicCompareBy : forall 'a. ('a -> 'a -> ordering) -> list 'a -> list 'a -> ordering*)

fun  lexicographicCompareBy  :: "('a \<Rightarrow> 'a \<Rightarrow> ordering)\<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> ordering "  where 
     " lexicographicCompareBy cmp ([]) ([]) = ( EQ )"
|" lexicographicCompareBy cmp ([]) (_ # _) = ( LT )"
|" lexicographicCompareBy cmp (_ # _) ([]) = ( GT )"
|" lexicographicCompareBy cmp (x # xs) (y # ys) = ( (
      (case  cmp x y of 
          LT => LT
        | GT => GT
        | EQ => lexicographicCompareBy cmp xs ys
      )
    ))"


(*val lexicographicLess : forall 'a. Ord 'a => list 'a -> list 'a -> bool*)
(*val lexicographicLessBy : forall 'a. ('a -> 'a -> bool) -> ('a -> 'a -> bool) -> list 'a -> list 'a -> bool*)
fun  lexicographicLessBy  :: "('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow>('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> bool "  where 
     " lexicographicLessBy less1 less_eq1 ([]) ([]) = ( False )"
|" lexicographicLessBy less1 less_eq1 ([]) (_ # _) = ( True )"
|" lexicographicLessBy less1 less_eq1 (_ # _) ([]) = ( False )"
|" lexicographicLessBy less1 less_eq1 (x # xs) (y # ys) = ( ((less1 x y) \<or> ((less_eq1 x y) \<and> (lexicographicLessBy less1 less_eq1 xs ys))))"


(*val lexicographicLessEq : forall 'a. Ord 'a => list 'a -> list 'a -> bool*)
(*val lexicographicLessEqBy : forall 'a. ('a -> 'a -> bool) -> ('a -> 'a -> bool) -> list 'a -> list 'a -> bool*)
fun  lexicographicLessEqBy  :: "('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow>('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> bool "  where 
     " lexicographicLessEqBy less1 less_eq1 ([]) ([]) = ( True )"
|" lexicographicLessEqBy less1 less_eq1 ([]) (_ # _) = ( True )"
|" lexicographicLessEqBy less1 less_eq1 (_ # _) ([]) = ( False )"
|" lexicographicLessEqBy less1 less_eq1 (x # xs) (y # ys) = ( (less1 x y \<or> (less_eq1 x y \<and> lexicographicLessEqBy less1 less_eq1 xs ys)))"



definition instance_Basic_classes_Ord_list_dict  :: " 'a Ord_class \<Rightarrow>('a list)Ord_class "  where 
     " instance_Basic_classes_Ord_list_dict dict_Basic_classes_Ord_a = ((|

  compare_method = (lexicographicCompareBy 
  (compare_method   dict_Basic_classes_Ord_a)),

  isLess_method = (lexicographicLessBy 
  (isLess_method   dict_Basic_classes_Ord_a) (isLessEqual_method   dict_Basic_classes_Ord_a)),

  isLessEqual_method = (lexicographicLessEqBy 
  (isLess_method   dict_Basic_classes_Ord_a) (isLessEqual_method   dict_Basic_classes_Ord_a)),

  isGreater_method = (\<lambda> x y. (lexicographicLessBy 
  (isLess_method   dict_Basic_classes_Ord_a) (isLessEqual_method   dict_Basic_classes_Ord_a) y x)),

  isGreaterEqual_method = (\<lambda> x y. (lexicographicLessEqBy 
  (isLess_method   dict_Basic_classes_Ord_a) (isLessEqual_method   dict_Basic_classes_Ord_a) y x))|) )"



(* ----------------------- *)
(* Append                  *)
(* ----------------------- *)

(*val ++ : forall 'a. list 'a -> list 'a -> list 'a*) (* originally append *)
(*let rec ++ xs ys=  match xs with
                     | [] -> ys
                     | x :: xs' -> x :: (xs' ++ ys)
                   end*)

(* ----------------------- *)
(* snoc                    *)
(* ----------------------- *)

(*val snoc : forall 'a. 'a -> list 'a -> list 'a*)
(*let snoc e l=  l ++ [e]*)


(* ----------------------- *)
(* Reverse                 *)
(* ----------------------- *)

(* First lets define the function [reverse_append], which is
   closely related to reverse. [reverse_append l1 l2] appends the list [l2] to the reverse of [l1].
   This can be implemented more efficienctly than appending and is
   used to implement reverse. *)

(*val reverseAppend : forall 'a. list 'a -> list 'a -> list 'a*) (* originally named rev_append *)
(*let rec reverseAppend l1 l2=  match l1 with 
                                | [] -> l2
                                | x :: xs -> reverseAppend xs (x :: l2)
                               end*)

(* Reversing a list *)
(*val reverse : forall 'a. list 'a -> list 'a*) (* originally named rev *)
(*let reverse l=  reverseAppend l []*)

(* ----------------------- *)
(* Map                     *)
(* ----------------------- *)

(*val map_tr : forall 'a 'b. list 'b -> ('a -> 'b) -> list 'a -> list 'b*)
function (sequential,domintros)  map_tr  :: " 'b list \<Rightarrow>('a \<Rightarrow> 'b)\<Rightarrow> 'a list \<Rightarrow> 'b list "  where 
     " map_tr rev_acc f ([]) = ( List.rev rev_acc )"
|" map_tr rev_acc f (x # xs) = ( map_tr ((f x) # rev_acc) f xs )" 
by pat_completeness auto


(* taken from: https://blogs.janestreet.com/optimizing-list-map/ *)
(*val count_map : forall 'a 'b. ('a -> 'b) -> list 'a -> nat -> list 'b*)
function (sequential,domintros)  count_map  :: "('a \<Rightarrow> 'b)\<Rightarrow> 'a list \<Rightarrow> nat \<Rightarrow> 'b list "  where 
     " count_map f ([]) ctr = ( [])"
|" count_map f (hd1 # tl1) ctr = ( f hd1 # 
    (if ctr <( 5000 :: nat) then count_map f tl1 (ctr +( 1 :: nat)) 
    else map_tr [] f tl1))" 
by pat_completeness auto

 
(*val map : forall 'a 'b. ('a -> 'b) -> list 'a -> list 'b*)
(*let map f l=  count_map f l 0*)

(* ----------------------- *)
(* Reverse Map             *)
(* ----------------------- *)

(*val reverseMap : forall 'a 'b. ('a -> 'b) -> list 'a -> list 'b*)


(* ========================================================================== *)
(* Folding                                                                    *)
(* ========================================================================== *)

(* ----------------------- *)
(* fold left               *)
(* ----------------------- *)

(*val foldl : forall 'a 'b. ('a -> 'b -> 'a) -> 'a -> list 'b -> 'a*) (* originally foldl *)

(*let rec foldl f b l=  match l with
  | []      -> b
  | x :: xs -> foldl f (f b x) xs
end*)


(* ----------------------- *)
(* fold right              *)
(* ----------------------- *)

(*val foldr : forall 'a 'b. ('a -> 'b -> 'b) -> 'b -> list 'a -> 'b*) (* originally foldr with different argument order *)
(*let rec foldr f b l=  match l with
  | []      -> b
  | x :: xs -> f x (foldr f b xs)
end*)


(* ----------------------- *)
(* concatenating lists     *)
(* ----------------------- *)

(*val concat : forall 'a. list (list 'a) -> list 'a*) (* before also called flatten *)
(*let concat=  foldr (++) []*)


(* -------------------------- *)
(* concatenating with mapping *)
(* -------------------------- *)

(*val concatMap : forall 'a 'b. ('a -> list 'b) -> list 'a -> list 'b*)


(* ------------------------- *)
(* universal qualification   *)
(* ------------------------- *)

(*val all : forall 'a. ('a -> bool) -> list 'a -> bool*) (* originally for_all *)
(*let all P l=  foldl (fun r e -> P e && r) true l*)



(* ------------------------- *)
(* existential qualification *)
(* ------------------------- *)

(*val any : forall 'a. ('a -> bool) -> list 'a -> bool*) (* originally exist *)
(*let any P l=  foldl (fun r e -> P e || r) false l*)


(* ------------------------- *)
(* dest_init                 *)
(* ------------------------- *)

(* get the initial part and the last element of the list in a safe way *)

(*val dest_init : forall 'a. list 'a -> maybe (list 'a * 'a)*) 

fun  dest_init_aux  :: " 'a list \<Rightarrow> 'a \<Rightarrow> 'a list \<Rightarrow> 'a list*'a "  where 
     " dest_init_aux rev_init last_elem_seen ([]) = ( (List.rev rev_init, last_elem_seen))"
|" dest_init_aux rev_init last_elem_seen (x # xs) = ( dest_init_aux (last_elem_seen # rev_init) x xs )"


fun dest_init  :: " 'a list \<Rightarrow>('a list*'a)option "  where 
     " dest_init ([]) = ( None )"
|" dest_init (x # xs) = ( Some (dest_init_aux [] x xs))"



(* ========================================================================== *)
(* Indexing lists                                                             *)
(* ========================================================================== *)

(* ------------------------- *)
(* index / nth with maybe   *)
(* ------------------------- *)

(*val index : forall 'a. list 'a -> nat -> maybe 'a*)

(*let rec index l n=  match l with 
  | []      -> Nothing
  | x :: xs -> if (Instance_Basic_classes_Eq_nat.=) n 0 then Just x else index xs ((Instance_Num_NumMinus_nat.-)n 1)
end*)

(* ------------------------- *)
(* findIndices               *)
(* ------------------------- *)

(* [findIndices P l] returns the indices of all elements of list [l] that satisfy predicate [P]. 
   Counting starts with 0, the result list is sorted ascendingly *)
(*val findIndices : forall 'a. ('a -> bool) -> list 'a -> list nat*)

fun  findIndices_aux  :: " nat \<Rightarrow>('a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow>(nat)list "  where 
     " findIndices_aux (i::nat) P ([]) = ( [])"
|" findIndices_aux (i::nat) P (x # xs) = ( if P x then i # findIndices_aux (i +( 1 :: nat)) P xs else findIndices_aux (i +( 1 :: nat)) P xs )"

(*let findIndices P l=  findIndices_aux 0 P l*)



(* ------------------------- *)
(* findIndex                 *)
(* ------------------------- *)

(* findIndex returns the first index of a list that satisfies a given predicate. *)
(*val findIndex : forall 'a. ('a -> bool) -> list 'a -> maybe nat*)
(*let findIndex P l=  match findIndices P l with
  | [] -> Nothing
  | x :: _ -> Just x
end*)

(* ------------------------- *)
(* elemIndices               *)
(* ------------------------- *)

(*val elemIndices : forall 'a. Eq 'a => 'a -> list 'a -> list nat*)

(* ------------------------- *)
(* elemIndex                 *)
(* ------------------------- *)

(*val elemIndex : forall 'a. Eq 'a => 'a -> list 'a -> maybe nat*)


(* ========================================================================== *)
(* Creating lists                                                             *)
(* ========================================================================== *)

(* ------------------------- *)
(* genlist                   *)
(* ------------------------- *)

(* [genlist f n] generates the list [f 0; f 1; ... (f (n-1))] *)
(*val genlist : forall 'a. (nat -> 'a) -> nat -> list 'a*)


(*let rec genlist f n= 
  match n with
    | 0 -> []
    | n' + 1 -> snoc (f n') (genlist f n')
  end*)


(* ------------------------- *)
(* replicate                 *)
(* ------------------------- *)

(*val replicate : forall 'a. nat -> 'a -> list 'a*)
(*let rec replicate n x= 
  match n with
    | 0 -> []
    | n' + 1 -> x :: replicate n' x
  end*)


(* ========================================================================== *)
(* Sublists                                                                   *)
(* ========================================================================== *)

(* ------------------------- *)
(* splitAt                   *)
(* ------------------------- *)

(* [splitAt n xs] returns a tuple (xs1, xs2), with append xs1 xs2 = xs and 
   length xs1 = n. If there are not enough elements 
   in [xs], the original list and the empty one are returned. *)
(*val splitAtAcc : forall 'a. list 'a -> nat -> list 'a -> (list 'a * list 'a)*)
function (sequential,domintros)  splitAtAcc  :: " 'a list \<Rightarrow> nat \<Rightarrow> 'a list \<Rightarrow> 'a list*'a list "  where 
     " splitAtAcc revAcc n l = ( 
  (case  l of
      []    => (List.rev revAcc, [])
    | x # xs => if n \<le>( 0 :: nat) then (List.rev revAcc, l) else splitAtAcc (x # revAcc) (n-( 1 :: nat)) xs
  ))" 
by pat_completeness auto


(*val splitAt : forall 'a. nat -> list 'a -> (list 'a * list 'a)*)
(*let rec splitAt n l=  
   splitAtAcc [] n l*)


(* ------------------------- *)
(* take                      *)
(* ------------------------- *)

(* take n xs returns the prefix of xs of length n, or xs itself if n > length xs *)
(*val take : forall 'a. nat -> list 'a -> list 'a*)
(*let take n l=  fst (splitAt n l)*)

(* ------------------------- *)
(* drop                      *)
(* ------------------------- *)

(* [drop n xs] drops the first [n] elements of [xs]. It returns the empty list, if [n] > [length xs]. *)
(*val drop : forall 'a. nat -> list 'a -> list 'a*)
(*let drop n l=  snd (splitAt n l)*)

(* ------------------------------------ *)
(* splitWhile, takeWhile, and dropWhile *)
(* ------------------------------------ *)

(*val splitWhile_tr : forall 'a. ('a -> bool) -> list 'a -> list 'a -> (list 'a * list 'a)*)
fun  splitWhile_tr  :: "('a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list \<Rightarrow> 'a list*'a list "  where 
     " splitWhile_tr p ([]) acc1 = (
    (List.rev acc1, []))"
|" splitWhile_tr p (x # xs) acc1 = (
    if p x then
      splitWhile_tr p xs (x # acc1)
    else
      (List.rev acc1, (x # xs)))"


(*val splitWhile : forall 'a. ('a -> bool) -> list 'a -> (list 'a * list 'a)*)
definition splitWhile  :: "('a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list*'a list "  where 
     " splitWhile p xs = ( splitWhile_tr p xs [])"


(* [takeWhile p xs] takes the first elements of [xs] that satisfy [p]. *)
(*val takeWhile : forall 'a. ('a -> bool) -> list 'a -> list 'a*)
definition takeWhile  :: "('a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list "  where 
     " takeWhile p l = ( fst (splitWhile p l))"


(* [dropWhile p xs] drops the first elements of [xs] that satisfy [p]. *)
(*val dropWhile : forall 'a. ('a -> bool) -> list 'a -> list 'a*)
definition dropWhile  :: "('a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list "  where 
     " dropWhile p l = ( snd (splitWhile p l))"


(* ------------------------- *)
(* isPrefixOf                *)
(* ------------------------- *)

(*val isPrefixOf : forall 'a. Eq 'a => list 'a -> list 'a -> bool*)
fun  isPrefixOf  :: " 'a list \<Rightarrow> 'a list \<Rightarrow> bool "  where 
     " isPrefixOf ([]) _ = ( True )"
|" isPrefixOf (_ # _) ([]) = ( False )"
|" isPrefixOf (x # xs) (y # ys) = ( (x = y) \<and> isPrefixOf xs ys )"


(* ------------------------- *)
(* update                    *)
(* ------------------------- *)
(*val update : forall 'a. list 'a -> nat -> 'a -> list 'a*)
(*let rec update l n e=  
  match l with
    | []      -> []
    | x :: xs -> if (Instance_Basic_classes_Eq_nat.=) n 0 then e :: xs else x :: (update xs ((Instance_Num_NumMinus_nat.-) n 1) e)
end*)



(* ========================================================================== *)
(* Searching lists                                                            *)
(* ========================================================================== *)

(* ------------------------- *)
(* Membership test           *)
(* ------------------------- *)

(* The membership test, one of the basic list functions, is actually tricky for
   Lem, because it is tricky, which equality to use. From Lem`s point of 
   perspective, we want to use the equality provided by the equality type - class.
   This allows for example to check whether a set is in a list of sets.

   However, in order to use the equality type class, elem essentially becomes
   existential quantification over lists. For types, which implement semantic
   equality (=) with syntactic equality, this is overly complicated. In
   our theorem prover backend, we would end up with overly complicated, harder
   to read definitions and some of the automation would be harder to apply.
   Moreover, nearly all the old Lem generated code would change and require 
   (hopefully minor) adaptions of proofs.

   For now, we ignore this problem and just demand, that all instances of
   the equality type class do the right thing for the theorem prover backends.   
*)

(*val elem : forall 'a. Eq 'a => 'a -> list 'a -> bool*)
(*val elemBy : forall 'a. ('a -> 'a -> bool) -> 'a -> list 'a -> bool*)

definition elemBy  :: "('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow> 'a \<Rightarrow> 'a list \<Rightarrow> bool "  where 
     " elemBy eq e l = ( ((\<exists> x \<in> (set l).  (eq e) x)))"

(*let elem=  elemBy (=)*)

(* ------------------------- *)
(* Find                      *)
(* ------------------------- *)
(*val find : forall 'a. ('a -> bool) -> list 'a -> maybe 'a*) (* previously not of maybe type *)
(*let rec find P l=  match l with 
  | []      -> Nothing
  | x :: xs -> if P x then Just x else find P xs
end*)


(* ----------------------------- *)
(* Lookup in an associative list *)
(* ----------------------------- *)
(*val lookup   : forall 'a 'b. Eq 'a              => 'a -> list ('a * 'b) -> maybe 'b*)
(*val lookupBy : forall 'a 'b. ('a -> 'a -> bool) -> 'a -> list ('a * 'b) -> maybe 'b*)

(* DPM: eta-expansion for Coq backend type-inference. *)
definition lookupBy  :: "('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow> 'a \<Rightarrow>('a*'b)list \<Rightarrow> 'b option "  where 
     " lookupBy eq k m = ( map_option (\<lambda> x .  snd x) (List.find ( \<lambda>x .  
  (case  x of (k', _) => eq k k' )) m))"


(* ------------------------- *)
(* filter                    *)
(* ------------------------- *)
(*val filter : forall 'a. ('a -> bool) -> list 'a -> list 'a*)
(*let rec filter P l=  match l with
                       | [] -> []
                       | x :: xs -> if (P x) then x :: (filter P xs) else filter P xs
                     end*)


(* ------------------------- *)
(* partition                 *)
(* ------------------------- *)
(*val partition : forall 'a. ('a -> bool) -> list 'a -> list 'a * list 'a*)
(*let partition P l=  (filter P l, filter (fun x -> not (P x)) l)*)

(*val reversePartition : forall 'a. ('a -> bool) -> list 'a -> list 'a * list 'a*)
definition reversePartition  :: "('a \<Rightarrow> bool)\<Rightarrow> 'a list \<Rightarrow> 'a list*'a list "  where 
     " reversePartition P l = ( List.partition P (List.rev l))"



(* ------------------------- *)
(* delete first element      *)
(* with certain property     *)
(* ------------------------- *)

(*val deleteFirst : forall 'a. ('a -> bool) -> list 'a -> maybe (list 'a)*) 
(*let rec deleteFirst P l=  match l with
                            | [] -> Nothing
                            | x :: xs -> if (P x) then Just xs else Maybe.map (fun xs' -> x :: xs') (deleteFirst P xs)
                          end*)


(*val delete : forall 'a. Eq 'a => 'a -> list 'a -> list 'a*)
(*val deleteBy : forall 'a. ('a -> 'a -> bool) -> 'a -> list 'a -> list 'a*)

definition deleteBy  :: "('a \<Rightarrow> 'a \<Rightarrow> bool)\<Rightarrow> 'a \<Rightarrow> 'a list \<Rightarrow> 'a list "  where 
     " deleteBy eq x l = ( case_option l id (delete_first (eq x) l))"



(* ========================================================================== *)
(* Zipping and unzipping lists                                                *)
(* ========================================================================== *)

(* ------------------------- *)
(* zip                       *)
(* ------------------------- *)

(* zip takes two lists and returns a list of corresponding pairs. If one input list is short, excess elements of the longer list are discarded. *)
(*val zip : forall 'a 'b. list 'a -> list 'b -> list ('a * 'b)*) (* before combine *)
(*let rec zip l1 l2=  match (l1, l2) with
  | (x :: xs, y :: ys) -> (x, y) :: zip xs ys
  | _ -> []
end*)

(* ------------------------- *)
(* unzip                     *)
(* ------------------------- *)

(*val unzip: forall 'a 'b. list ('a * 'b) -> (list 'a * list 'b)*)
(*let rec unzip l=  match l with
  | [] -> ([], [])
  | (x, y) :: xys -> let (xs, ys) = unzip xys in (x :: xs, y :: ys)
end*)

(* ------------------------- *)
(* distinct elements         *)
(* ------------------------- *)

(*val allDistinct : forall 'a. Eq 'a => list 'a -> bool*)
fun  allDistinct  :: " 'a list \<Rightarrow> bool "  where 
     " allDistinct ([]) = ( True )"
|" allDistinct (x # l') = ( \<not> (Set.member x (set l')) \<and> allDistinct l' )"


(* some more useful functions *)
(*val mapMaybe : forall 'a 'b. ('a -> maybe 'b) -> list 'a -> list 'b*)
function (sequential,domintros)  mapMaybe  :: "('a \<Rightarrow> 'b option)\<Rightarrow> 'a list \<Rightarrow> 'b list "  where 
     " mapMaybe f ([]) = ( [])"
|" mapMaybe f (x # xs) = (
      (case  f x of
        None => mapMaybe f xs
      | Some y => y # (mapMaybe f xs)
      ))" 
by pat_completeness auto


(*val mapi : forall 'a 'b. (nat -> 'a -> 'b) -> list 'a -> list 'b*)
function (sequential,domintros)  mapiAux  :: "(nat \<Rightarrow> 'b \<Rightarrow> 'a)\<Rightarrow> nat \<Rightarrow> 'b list \<Rightarrow> 'a list "  where 
     " mapiAux f (n :: nat) ([]) = ( [])"
|" mapiAux f (n :: nat) (x # xs) = ( (f n x) # mapiAux f (n +( 1 :: nat)) xs )" 
by pat_completeness auto

definition mapi  :: "(nat \<Rightarrow> 'a \<Rightarrow> 'b)\<Rightarrow> 'a list \<Rightarrow> 'b list "  where 
     " mapi f l = ( mapiAux f(( 0 :: nat)) l )"


(*val deletes: forall 'a. Eq 'a => list 'a -> list 'a -> list 'a*)
definition deletes  :: " 'a list \<Rightarrow> 'a list \<Rightarrow> 'a list "  where 
     " deletes xs ys = (
  List.foldl ((\<lambda> x y. remove1 y x)) xs ys )"


(* ========================================================================== *)
(* Comments (not clean yet, please ignore the rest of the file)               *)
(* ========================================================================== *)

(* ----------------------- *)
(* skipped from Haskell Lib*)
(* ----------------------- 

intersperse :: a -> [a] -> [a]
intercalate :: [a] -> [[a]] -> [a]
transpose :: [[a]] -> [[a]]
subsequences :: [a] -> [[a]]
permutations :: [a] -> [[a]]
foldl` :: (a -> b -> a) -> a -> [b] -> aSource
foldl1` :: (a -> a -> a) -> [a] -> aSource

and
or
sum
product
maximum
minimum
scanl
scanr
scanl1
scanr1
Accumulating maps

mapAccumL :: (acc -> x -> (acc, y)) -> acc -> [x] -> (acc, [y])Source
mapAccumR :: (acc -> x -> (acc, y)) -> acc -> [x] -> (acc, [y])Source

iterate :: (a -> a) -> a -> [a]
repeat :: a -> [a]
cycle :: [a] -> [a]
unfoldr


takeWhile :: (a -> Bool) -> [a] -> [a]Source
dropWhile :: (a -> Bool) -> [a] -> [a]Source
dropWhileEnd :: (a -> Bool) -> [a] -> [a]Source
span :: (a -> Bool) -> [a] -> ([a], [a])Source
break :: (a -> Bool) -> [a] -> ([a], [a])Source
break p is equivalent to span (not . p).
stripPrefix :: Eq a => [a] -> [a] -> Maybe [a]Source
group :: Eq a => [a] -> [[a]]Source
inits :: [a] -> [[a]]Source
tails :: [a] -> [[a]]Source


isPrefixOf :: Eq a => [a] -> [a] -> BoolSource
isSuffixOf :: Eq a => [a] -> [a] -> BoolSource
isInfixOf :: Eq a => [a] -> [a] -> BoolSource



notElem :: Eq a => a -> [a] -> BoolSource

zip3 :: [a] -> [b] -> [c] -> [(a, b, c)]Source
zip4 :: [a] -> [b] -> [c] -> [d] -> [(a, b, c, d)]Source
zip5 :: [a] -> [b] -> [c] -> [d] -> [e] -> [(a, b, c, d, e)]Source
zip6 :: [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [(a, b, c, d, e, f)]Source
zip7 :: [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [g] -> [(a, b, c, d, e, f, g)]Source

zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]Source
zipWith3 :: (a -> b -> c -> d) -> [a] -> [b] -> [c] -> [d]Source
zipWith4 :: (a -> b -> c -> d -> e) -> [a] -> [b] -> [c] -> [d] -> [e]Source
zipWith5 :: (a -> b -> c -> d -> e -> f) -> [a] -> [b] -> [c] -> [d] -> [e] -> [f]Source
zipWith6 :: (a -> b -> c -> d -> e -> f -> g) -> [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [g]Source
zipWith7 :: (a -> b -> c -> d -> e -> f -> g -> h) -> [a] -> [b] -> [c] -> [d] -> [e] -> [f] -> [g] -> [h]Source


unzip3 :: [(a, b, c)] -> ([a], [b], [c])Source
unzip4 :: [(a, b, c, d)] -> ([a], [b], [c], [d])Source
unzip5 :: [(a, b, c, d, e)] -> ([a], [b], [c], [d], [e])Source
unzip6 :: [(a, b, c, d, e, f)] -> ([a], [b], [c], [d], [e], [f])Source
unzip7 :: [(a, b, c, d, e, f, g)] -> ([a], [b], [c], [d], [e], [f], [g])Source


lines :: String -> [String]Source
words :: String -> [String]Source
unlines :: [String] -> StringSource
unwords :: [String] -> StringSource
nub :: Eq a => [a] -> [a]Source
delete :: Eq a => a -> [a] -> [a]Source

() :: Eq a => [a] -> [a] -> [a]Source
union :: Eq a => [a] -> [a] -> [a]Source
intersect :: Eq a => [a] -> [a] -> [a]Source
sort :: Ord a => [a] -> [a]Source
insert :: Ord a => a -> [a] -> [a]Source


nubBy :: (a -> a -> Bool) -> [a] -> [a]Source
deleteBy :: (a -> a -> Bool) -> a -> [a] -> [a]Source
deleteFirstsBy :: (a -> a -> Bool) -> [a] -> [a] -> [a]Source
unionBy :: (a -> a -> Bool) -> [a] -> [a] -> [a]Source
intersectBy :: (a -> a -> Bool) -> [a] -> [a] -> [a]Source
groupBy :: (a -> a -> Bool) -> [a] -> [[a]]Source
sortBy :: (a -> a -> Ordering) -> [a] -> [a]Source
insertBy :: (a -> a -> Ordering) -> a -> [a] -> [a]Source
maximumBy :: (a -> a -> Ordering) -> [a] -> aSource
minimumBy :: (a -> a -> Ordering) -> [a] -> aSource
genericLength :: Num i => [b] -> iSource
genericTake :: Integral i => i -> [a] -> [a]Source
genericDrop :: Integral i => i -> [a] -> [a]Source
genericSplitAt :: Integral i => i -> [b] -> ([b], [b])Source
genericIndex :: Integral a => [b] -> a -> bSource
genericReplicate :: Integral i => i -> a -> [a]Source


*)


(* ----------------------- *)
(* skipped from Lem Lib    *)
(* ----------------------- 


val for_all2 : forall 'a 'b. ('a -> 'b -> bool) -> list 'a -> list 'b -> bool
val exists2 : forall 'a 'b. ('a -> 'b -> bool) -> list 'a -> list 'b -> bool
val map2 : forall 'a 'b 'c. ('a -> 'b -> 'c) -> list 'a -> list 'b -> list 'c 
val rev_map2 : forall 'a 'b 'c. ('a -> 'b -> 'c) -> list 'a -> list 'b -> list 'c
val fold_left2 : forall 'a 'b 'c. ('a -> 'b -> 'c -> 'a) -> 'a -> list 'b -> list 'c -> 'a
val fold_right2 : forall 'a 'b 'c. ('a -> 'b -> 'c -> 'c) -> list 'a -> list 'b -> 'c -> 'c


(* now maybe result and called lookup *)
val assoc : forall 'a 'b. 'a -> list ('a * 'b) -> 'b
let inline {ocaml} assoc = Ocaml.List.assoc


val mem_assoc : forall 'a 'b. 'a -> list ('a * 'b) -> bool
val remove_assoc : forall 'a 'b. 'a -> list ('a * 'b) -> list ('a * 'b)



val stable_sort : forall 'a. ('a -> 'a -> num) -> list 'a -> list 'a
val fast_sort : forall 'a. ('a -> 'a -> num) -> list 'a -> list 'a

val merge : forall 'a. ('a -> 'a -> num) -> list 'a -> list 'a -> list 'a
val intersect : forall 'a. list 'a -> list 'a -> list 'a


*)

(*val     catMaybes : forall 'a. list (maybe 'a) -> list 'a*)
function (sequential,domintros)  catMaybes  :: "('a option)list \<Rightarrow> 'a list "  where 
     " catMaybes ([]) = (
        [])"
|" catMaybes (None # xs') = (
        catMaybes xs' )"
|" catMaybes (Some x # xs') = (
        x # catMaybes xs' )" 
by pat_completeness auto

end
