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
  val init : nrows:int -> ncols:int -> f:(int -> int -> Z3.Expr.expr) -> t

  (** Init. a vector with an expression. *)
  val init' : nrows:int -> Z3.Expr.expr -> t

  val map : t -> f:(Z3.Expr.expr -> Z3.Expr.expr) -> t
end
