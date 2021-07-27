module Matrix :
sig
  type t

  val mk_mul : Z3.context -> t -> t -> t

  val mk_add : Z3.context -> t -> t -> t

  val mk_eq : Z3.context -> t -> t -> Z3.Expr.expr

  val init : nrows:int -> ncols:int -> f:(int -> int -> Z3.Expr.expr) -> t

  val map : t -> f:(Z3.Expr.expr -> Z3.Expr.expr) -> t
end
