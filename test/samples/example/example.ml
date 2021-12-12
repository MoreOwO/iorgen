(** A struct for the example *)
type a_struct = {
  integer : int; (** an integer *)
  character : char; (** a char *)
}

(**
   @param n a number, used as a size
   @param list a list of structs
*)
let example n list =
  (** TODO In a real life scenario, you will describe here what you want the
  end user to do with this generated code *)
  ()

let () =
  let n = read_int () in
  let list = List.init n (fun _ -> Scanf.sscanf (read_line ()) "%d %c" (fun integer character -> {integer; character})) in
  example n list
