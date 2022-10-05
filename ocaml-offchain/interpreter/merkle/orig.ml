
open Ast
open Source

let do_it x f = {x with it=f x.it}

let is_func_export e = match e.edesc.it with
 | FuncExport _ -> true
 | _ -> false

let is_func_import e = match e.idesc.it with
 | FuncImport _ -> true
 | _ -> false

let process_orig tbl name =
  let str = Utf8.encode name in
  let str = if Hashtbl.mem tbl ("orig$"^str) then "ignore$" ^ str else str in 
  let str = if String.length str > 5 && 
      String.equal (String.sub str 0 5) "orig$" then
         String.sub str 5 (String.length str - 5) else str in 
  Utf8.decode str

let process_export tbl e =
  do_it e (fun e ->
     if is_func_export e then {e with name=process_orig tbl e.name}
     else e)

(* add underscores to function imports and exports *)
let process m =
  do_it m (fun m ->
    let items = Hashtbl.create 12 in
    List.iter (fun a -> Hashtbl.add items (Utf8.encode a.it.name) ()) m.exports;
    {m with exports=List.map (process_export items) m.exports})

