(* This file is free software, part of containers. See file "license" for more details. *)

(** {1 Growable, mutable vector} *)

type ro = [`RO]
type rw = [`RW]

(** Mutability is [rw] (read-write) or [ro] (read-only). *)

type ('a, 'mut) t
(** The type of a vector of elements of type ['a], with
    a mutability flat ['mut]. *)

type 'a vector = ('a, rw) t
(** Type synonym: a ['a vector] is mutable. *)

type 'a ro_vector = ('a, ro) t
(** Alias for immutable vectors.
    @since 0.15 *)

(* TODO: remove for 3.0 *)
type 'a sequence = ('a -> unit) -> unit
(** @deprecated use ['a iter] instead *)

type 'a iter = ('a -> unit) -> unit
(** Fast internal iterator.
    @since 2.8 *)

type 'a klist = unit -> [`Nil | `Cons of 'a * 'a klist]
type 'a gen = unit -> 'a option
type 'a equal = 'a -> 'a -> bool
type 'a ord = 'a -> 'a -> int
type 'a printer = Format.formatter -> 'a -> unit

val freeze : ('a, _) t -> ('a, ro) t
(** Make an immutable vector (no copy! Don't use the old version). *)

val freeze_copy : ('a, _) t -> ('a, ro) t
(** Copy the vector into an immutable version. *)

val create : unit -> ('a, rw) t
(** Create a new, empty vector. *)

val create_with : ?capacity:int -> 'a -> ('a, rw) t
(** Create a new vector, the value is used to enforce the type the new vector.
    @param capacity the size of the underlying array. *)

val return : 'a -> ('a, 'mut) t
(** Singleton vector.
    @since 0.14 *)

val make : int -> 'a -> ('a, 'mut) t
(** [make n x] makes a vector of size [n], filled with [x]. *)

val init : int -> (int -> 'a) -> ('a, 'mut) t
(** Init the vector with the given function and size. *)

val clear : ('a, rw) t -> unit
(** Clear the content of the vector. *)

val clear_and_reset : ('a, rw) t -> unit
(** Clear the content of the vector, and deallocate the underlying array,
    removing references to all the elements.
    @since 2.8 *)

val ensure_with : init:'a -> ('a, rw) t -> int -> unit
(** Hint to the vector that it should have at least the given capacity.
    @param init if [capacity v = 0], used to enforce the type of the vector
      (see {!create_with}).
    @since 0.14 *)

val ensure : ('a, rw) t -> int -> unit
(** Hint to the vector that it should have at least the given capacity.
    Just a hint, will not be enforced if the vector is empty and [init]
      is not provided. *)

val is_empty : ('a, _) t -> bool
(** Is the vector empty? *)

val push : ('a, rw) t -> 'a -> unit
(** Add an element at the end of the vector. *)

val append : ('a, rw) t -> ('a, _) t -> unit
(** [append a b] adds all elements of b to a. *)

val append_array : ('a, rw) t -> 'a array -> unit
(** Like {!append}, with an array. *)

val append_iter : ('a, rw) t -> 'a iter -> unit
(** Append content of iterator.
    @since 2.8 *)

val append_std_seq : ('a, rw) t -> 'a Seq.t -> unit
(** Append content of iterator.
    @since 2.8 *)

val append_seq : ('a, rw) t -> 'a sequence -> unit
(** Append content of sequence. *)

val append_list : ('a, rw) t -> 'a list -> unit
(** Append content of list.
    @since 0.14 *)

val append_gen : ('a, rw) t -> 'a gen -> unit
(** Append content of generator.
    @since 0.20 *)

val equal : 'a equal -> ('a,_) t equal

val compare : 'a ord -> ('a,_) t ord
(** Total ordering on vectors. Lexicographic comparison. *)

exception Empty
(** Raised on empty stack. *)

val pop : ('a, rw) t -> 'a option
(** Remove last element, or [None]. *)

val pop_exn : ('a, rw) t -> 'a
(** Remove last element, or raise a Failure if empty.
    @raise Empty on an empty vector. *)

val top : ('a, _) t -> 'a option
(** Top element, if present.
    @since 0.6 *)

val top_exn : ('a, _) t -> 'a
(** Top element, if present.
    @raise Empty on an empty vector.
    @since 0.6 *)

val copy : ('a,_) t -> ('a,'mut) t
(** Shallow copy (may give an immutable or mutable vector). *)

val shrink : ('a, rw) t -> int -> unit
(** Shrink to the given size (remove elements above this size).
    Does nothing if the parameter is bigger than the current size. *)

val shrink_to_fit : ('a, _) t -> unit
(** Shrink internal array to fit the size of the vector
    @since 2.8 *)

val member : eq:('a -> 'a -> bool) -> 'a -> ('a, _) t -> bool
(** Is the element a member of the vector? *)

val sort : ('a -> 'a -> int) -> ('a, _) t -> ('a, 'mut) t
(** Sort the vector, returning a copy of it that is sorted
    w.r.t the given ordering. The vector itself is unchanged.
    The underlying array of the new vector can be smaller than
    the original one. *)

val sort' : ('a -> 'a -> int) -> ('a, rw) t -> unit
(** Sort the vector in place (modifying it).
    This function change the size of the underlying array. *)

val uniq_sort : ('a -> 'a -> int) -> ('a, rw) t -> unit
(** Sort the array and remove duplicates, in place (e.g. modifying
    the vector itself). *)

val iter : ('a -> unit) -> ('a,_) t -> unit
(** Iterate on the vector's content. *)

val iteri : (int -> 'a -> unit) -> ('a,_) t -> unit
(** Iterate on the vector, with indexes. *)

val map : ('a -> 'b) -> ('a,_) t -> ('b, 'mut) t
(** Map elements of the vector, yielding a new vector. *)

val mapi : (int -> 'a -> 'b) -> ('a,_) t -> ('b, 'mut) t
(** [map f v] is just like {!map}, but it also passes in the index
    of each element as the first argument to the function [f].
    @since 2.8 *)

val map_in_place : ('a -> 'a) -> ('a,_) t -> unit
(** Map elements of the vector in place
    @since 2.3 *)

val filter : ('a -> bool) -> ('a,_) t -> ('a, 'mut) t
(** Filter elements from the vector. [filter p v] leaves [v] unchanged but
    returns a new vector that only contains elements of [v] satisfying [p]. *)

val filter_in_place : ('a -> bool) -> ('a, rw) t -> unit
(** Filter elements from the vector in place.
    @since NEXT_RELEASE *)

val filter' : ('a -> bool) -> ('a, rw) t -> unit
(** Alias of {!filter_in_place}
    @deprecated since NEXT_RELEASE, use {!filter_in_place} instead. *)
[@@ocaml.deprecated "use filter_in_place instead"]

val fold : ('b -> 'a -> 'b) -> 'b -> ('a,_) t -> 'b
(** Fold on elements of the vector *)

val exists : ('a -> bool) -> ('a,_) t -> bool
(** Existential test (is there an element that satisfies the predicate?). *)

val for_all : ('a -> bool) -> ('a,_) t -> bool
(** Universal test (do all the elements satisfy the predicate?). *)

val find : ('a -> bool) -> ('a,_) t -> 'a option
(** Find an element that satisfies the predicate. *)

val find_exn  : ('a -> bool) -> ('a,_) t -> 'a
(** Find an element that satisfies the predicate, or
    @raise Not_found if no element does. *)

val find_map : ('a -> 'b option) -> ('a,_) t -> 'b option
(** [find_map f v] returns the first [Some y = f x] for [x] in [v],
    or [None] if [f x = None] for each [x] in [v].
    @since 0.14 *)

val filter_map : ('a -> 'b option) -> ('a,_) t -> ('b, 'mut) t
(** Map elements with a function, possibly filtering some of them out. *)

val filter_map_in_place : ('a -> 'a option) -> ('a,_) t -> unit
(** Filter-map elements of the vector in place
    @since 2.3 *)

val flat_map : ('a -> ('b,_) t) -> ('a,_) t -> ('b, 'mut) t
(** Map each element to a sub-vector. *)

val flat_map_iter : ('a -> 'b sequence) -> ('a,_) t -> ('b, 'mut) t
(** Like {!flat_map}, but using {!iter} for intermediate collections.
    @since 2.8 *)

val flat_map_std_seq : ('a -> 'b Seq.t) -> ('a,_) t -> ('b, 'mut) t
(** Like {!flat_map}, but using [Seq] for intermediate collections.
    @since 2.8 *)

val flat_map_seq : ('a -> 'b sequence) -> ('a,_) t -> ('b, 'mut) t
(** Like {!flat_map}, but using {!sequence} for
    intermediate collections.
    @deprecated use {!flat_map_iter} or {!flat_map_std_seq}
    @since 0.14 *)
[@@ocaml.deprecated "use flat_map_iter or flat_map_std_seq"]

val flat_map_list : ('a -> 'b list) -> ('a,_) t -> ('b, 'mut) t
(** Like {!flat_map}, but using {!list} for
    intermediate collections.
    @since 0.14 *)

val monoid_product : ('a -> 'b -> 'c) -> ('a,_) t -> ('b,_) t -> ('c,_) t
(** All combinaisons of tuples from the two vectors are passed to the function.
    @since 2.8 *)

val (>>=) : ('a,_) t -> ('a -> ('b,_) t) -> ('b, 'mut) t
(** Infix version of {!flat_map}. *)

val (>|=) : ('a,_) t -> ('a -> 'b) -> ('b, 'mut) t
(** Infix version of {!map}. *)

val get : ('a,_) t -> int -> 'a
(** Access element by its index, or
    @raise Invalid_argument if bad index. *)

val set : ('a, rw) t -> int -> 'a -> unit
(** Modify element at given index, or
    @raise Invalid_argument if bad index. *)

val remove : ('a, rw) t -> int -> unit
(** Remove the [n-th] element of the vector. Does {b NOT} preserve the order
    of the elements (might swap with the last element). *)

val rev : ('a,_) t -> ('a, 'mut) t
(** Reverse the vector. *)

val rev_in_place : ('a, rw) t -> unit
(** Reverse the vector in place.
    @since 0.14 *)

val rev_iter : ('a -> unit) -> ('a,_) t -> unit
(** [rev_iter f a] is the same as [iter f (rev a)], only more efficient.
    @since 0.14 *)

val size : ('a,_) t -> int
(** Number of elements in the vector. *)

val length : (_,_) t -> int
(** Synonym for {! size}. *)

val capacity : (_,_) t -> int
(** Number of elements the vector can contain without being resized. *)

val unsafe_get_array : ('a, rw) t -> 'a array
(** Access the underlying {b shared} array (do not modify!).
    [unsafe_get_array v] is longer than [size v], but elements at higher
    index than [size v] are undefined (do not access!). *)

val (--) : int -> int -> (int, 'mut) t
(** Range of integers, either ascending or descending (both included,
    therefore the result is never empty).
    Example: [1 -- 10] returns the vector [[1;2;3;4;5;6;7;8;9;10]]. *)

val (--^) : int -> int -> (int, 'mut) t
(** Range of integers, either ascending or descending, but excluding right.
    Example: [1 --^ 10] returns the vector [[1;2;3;4;5;6;7;8;9]].
    @since 0.17 *)

val of_array : 'a array -> ('a, 'mut) t
(** [of_array a] returns a vector corresponding to the array [a]. Operates in [O(n)] time. *)

val of_list : 'a list -> ('a, 'mut) t

val to_array : ('a,_) t -> 'a array
(** [to_array v] returns an array corresponding to the vector [v]. *)

val to_list : ('a,_) t -> 'a list
(** Return a list with the elements contained in the vector. *)

val of_iter : ?init:('a,rw) t -> 'a iter -> ('a, rw) t
(** Convert an Iterator to a vector.
    @since 2.8.1 *)

val of_seq : ?init:('a,rw) t -> 'a sequence -> ('a, rw) t
(** Convert an Iterator to a vector.
    @deprecated use of_iter *)
[@@ocaml.deprecated "use of_iter. For the standard Seq, see {!of_std_seq}"]

val of_std_seq : ?init:('a,rw) t -> 'a Seq.t -> ('a, rw) t
(** Convert an Iterator to a vector.
    @deprecated use of_iter *)
[@@ocaml.deprecated "use of_iter. For the standard Seq, see {!of_std_seq}"]

val to_iter : ('a,_) t -> 'a iter
(** Return a [iter] with the elements contained in the vector.
    @since 2.8
*)

val to_iter_rev : ('a,_) t -> 'a iter
(** [to_iter_rev v] returns the sequence of elements of [v] in reverse order,
    that is, the last elements of [v] are iterated on first.
    @since 2.8
*)

val to_std_seq : ('a,_) t -> 'a Seq.t
(** Return an iterator with the elements contained in the vector.
    @since 2.8
*)

val to_std_seq_rev : ('a,_) t -> 'a Seq.t
(** [to_seq v] returns the sequence of elements of [v] in reverse order,
    that is, the last elements of [v] are iterated on first.
    @since 2.8
*)

val to_seq : ('a,_) t -> 'a sequence
(** @deprecated use to_iter *)
[@@ocaml.deprecated "use to_iter. For the standard Seq, see {!to_std_seq}"]

val to_seq_rev : ('a, _) t -> 'a sequence
(** [to_seq_rev v] returns the sequence of elements of [v] in reverse order,
    that is, the last elements of [v] are iterated on first.
    @since 0.14
    @deprecated use {!to_iter_rev} *)
[@@ocaml.deprecated "use to_iter_rev. For the standard Seq, see {!to_std_seq_rev}"]

val slice : ('a,rw) t -> ('a array * int * int)
(** Vector as an array slice. By doing it we expose the internal array, so
    be careful!. *)

val slice_seq : ('a,_) t -> int -> int -> 'a sequence
(** [slice_seq v start len] is the sequence of elements from [v.(start)]
    to [v.(start+len-1)]. *)

val fill_empty_slots_with : ('a, _) t -> 'a -> unit
(** [fill_empty_slots_with v x] puts [x] in the slots of [v]'s underlying
    array that are not used (ie in the last [capacity v - length v] slots).
    This is useful if you removed some elements from the vector and
    @deprecated after 2.8, as the vector doesn't keep values alive anymore (see #279, #282, #283)
    @since 2.4 *)
[@@ocaml.deprecated "not needed anymore, see #279,#282,#283"]

val of_klist : ?init:('a, rw) t -> 'a klist -> ('a, rw) t
val to_klist : ('a,_) t -> 'a klist
val of_gen : ?init:('a, rw) t -> 'a gen -> ('a, rw) t
val to_gen : ('a,_) t -> 'a gen

val to_string :
  ?start:string -> ?stop:string -> ?sep:string ->
  ('a -> string) -> ('a,_) t -> string
(**  Print the vector in a string
     @since 2.7 *)

val pp : ?start:string -> ?stop:string -> ?sep:string ->
  'a printer -> ('a,_) t printer

(** Let operators on OCaml >= 4.08.0, nothing otherwise
    @since 2.8 *)
include CCShimsMkLet_.S2 with type ('a,'e) t_let2 := ('a,'e) t
