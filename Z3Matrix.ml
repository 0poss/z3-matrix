open Core_kernel
open Z3enums
open Z3


module Matrix =
struct
  module A = Z3.Arithmetic
  module B = Z3.Boolean
  module BV = Z3.BitVector

  exception Err of string

  type t =
    {
      nrows : int;
      ncols : int;

      esort : Sort.sort;
      elems : Expr.expr array array;
    }

  let mk_matrix ~nrows:n ~ncols:m ~f:f : t =
    {
      nrows = n;
      ncols = m;
      esort = Expr.get_sort @@ f 0 0;
      elems = Array.init n ~f:(fun i -> Array.init m ~f:(f i));
    }

  let mk_matrix' ~nrows ~ncols e : t =
    mk_matrix ~nrows ~ncols ~f:(fun _ _ -> e)

  let map a ~f:f =
    {
      nrows = a.nrows;
      ncols = a.nrows;

      esort = a.esort;
      elems = Array.map a.elems ~f:(fun row -> Array.map row ~f);
    }

  let mk_mul_s mulfn addfn ctx a b : t =
    let calc_e i j =
      let rec aux k e =
        if k = a.ncols-1 then e
        else aux (k+1) (addfn e @@ mulfn a.elems.(i).(k) b.elems.(k).(j)) in
      aux 0 @@ Expr.mk_numeral_int ctx 0 a.esort in
    mk_matrix ~nrows:a.nrows ~ncols:b.ncols ~f:calc_e

  let mk_mul ctx a b : t =
    if a.ncols <> b.nrows then
      raise (Err "Sizes aren't compatible.");
    let mat_mul = match Sort.get_sort_kind a.esort with
      | BOOL_SORT -> mk_mul_s (fun x y -> B.mk_and ctx [x;y]) (B.mk_xor ctx)
      | INT_SORT
      | REAL_SORT -> mk_mul_s (fun x y -> A.mk_mul ctx [x;y]) (fun x y -> A.mk_add ctx [x;y])
      | BV_SORT -> mk_mul_s (BV.mk_mul ctx) (BV.mk_add ctx)
      | _ -> raise (Err "Unsupported type.") in
    mat_mul ctx a b

  let mk_add_s addfn _ a b : t =
    {
      nrows = a.nrows;
      ncols = a.ncols;

      esort = a.esort;
      elems = Array.map2_exn a.elems b.elems ~f:(Array.map2_exn ~f:addfn)
    }

  let mk_add ctx a b : t =
    if a.nrows <> b.nrows || a.ncols <> b.ncols then
      raise (Err "Sizes aren't compatible.");
    let mat_add = match Sort.get_sort_kind a.esort with
      | BOOL_SORT -> mk_add_s @@ B.mk_xor ctx
      | INT_SORT
      | REAL_SORT -> mk_add_s @@ fun x y -> A.mk_add ctx [x;y]
      | BV_SORT -> mk_add_s @@ BV.mk_add ctx
      | _ -> raise (Err "Unsupported type.") in
    mat_add ctx a b

  let mk_eq ctx a b : Expr.expr =
    let rec aux eq i j =
      let calc_eq i j = B.mk_eq ctx eq @@ (B.mk_eq ctx a.elems.(i).(j) b.elems.(i).(j)) in
      match i, j with
      | (0, 0) -> calc_eq 0 0
      | (0, j) -> aux (calc_eq 0 j) 0 (j-1)
      | (i, 0) -> aux (calc_eq i 0) (i-1) 0
      | (i, j) -> aux (calc_eq i j) (i-1) (j-1) in
    aux (B.mk_true ctx) (a.nrows-1) (a.ncols-1)

end
