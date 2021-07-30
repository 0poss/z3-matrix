# Z3Matrix
Just a dirty implementation of matrices for Z3 in OCaml.

## Example
```ocaml
open Z3
open Z3Matrix (* I'll probably just extend the Z3 module in the near future. *)

let ctx = mk_context [] in
let bvsort = BitVector.mk_sort ctx 32 in

let coeffs =
  [|[| 1; 3; -2 |];
    [| 3; 5;  6 |]|] in
let matA = Matrix.mk_matrix ~nrows:2 ~ncols:3 ~f:(
  fun i j -> Expr.mk_numeral_int ctx coeffs.(i).(j) bvsort
) in

let vecY = Matrix.mk_matrix ~nrows:3 ~ncols:1 ~f:(
  fun i _ ->
    let name = "Y" ^ string_of_int i in
    Expr.mk_const_s ctx name bvsort
) in

let mul = Matrix.mk_mul ctx matA vecY in
let eq =
  Expr.mk_numeral_int ctx 0 bvsort |>
  Matrix.mk_matrix_const ~nrows:3 ~ncols:1 |>
  Matrix.mk_eq ctx mul in
let _ = print_endline @@ Expr.to_string eq
```
Output :
```smt
(and true
     (= (bvadd #x00000000
               (bvmul #x00000003 Y0)
               (bvmul #x00000005 Y1)
               (bvmul #x00000006 Y2))
        #x00000000)
     (= (bvadd #x00000000
               (bvmul #x00000001 Y0)
               (bvmul #x00000003 Y1)
               (bvmul #xfffffffe Y2))
        #x00000000))
```
