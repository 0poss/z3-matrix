module Matrix :
sig
  type t

  (** Multiply two matrices. *)
  val mk_mul : Z3.context -> t -> t -> t

  (** Add two matrices. *)
  val mk_add : Z3.context -> t -> t -> t

  (** Get the equality expression of two matrices. *)
  val mk_eq : Z3.context -> t -> t -> Z3.Expr.expr

  (** Init. a matrix with a function taking the i and j indexes as argument. *)
  val mk_matrix : nrows:int -> ncols:int -> f:(int -> int -> Z3.Expr.expr) -> t

  (** Init. a matrix with an array. *)
  val mk_matrix_arr : Z3.Expr.expr array array -> t

  (** Init. a matrix with an expression. *)
  val mk_matrix_const : nrows:int -> ncols:int -> Z3.Expr.expr -> t

  (** A map function. *)
  val map : t -> f:(Z3.Expr.expr -> Z3.Expr.expr) -> t

  (** An iter function. *)
  val iter : t -> f:(Z3.Expr.expr -> unit) -> unit
end
