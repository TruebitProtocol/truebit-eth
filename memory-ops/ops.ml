
open Wasm
open Ast
open Source
open Types
open Values

let do_it x f = {x with it=f x.it}
let it e = {it=e; at=no_region}

let rec remap_func' fill copy = function
 | MemoryFill -> Call (it fill)
 | MemoryCopy -> Call (it copy)
 | Block (ty, lst) -> Block (ty, List.map (remap_func fill copy) lst) 
 | Loop (ty, lst) -> Loop (ty, List.map (remap_func fill copy) lst)
 | If (ty, texp, fexp) -> If (ty, List.map (remap_func fill copy) texp, List.map (remap_func fill copy) fexp)
 | a -> a
and remap_func fill copy i = {i with it = remap_func' fill copy i.it}


let read_whole_file filename =
  let ch = open_in filename in
  let s = really_input_string ch (in_channel_length ch) in
  close_in ch;
  s

let func_imports m =
  let rec do_get = function
    | [] -> []
    | ({it={idesc={it=FuncImport _;_};_};_} as el)::tl -> el :: do_get tl
    | _::tl -> do_get tl in
  do_get m.it.imports

(* Change function type *)
let rec remap ftmap f = do_it f (fun f ->
  {f with ftype={(f.ftype) with it = ftmap f.ftype.it}}
)

let rec replace fill copy f = do_it f (fun f ->
  {f with body=List.map (remap_func fill copy) f.body}
)

let process_export ex =
  if Utf8.encode ex.it.name = "_start" then [ex; do_it ex (fun a -> {a with name=Utf8.decode "main"})] else [ex]

let replace m impl =
  let impl = impl.it in
  let num_funcs = List.length (func_imports m) + List.length (m.it.funcs) in
  let num_types = List.length m.it.types in
  let fill = Int32.of_int num_funcs in
  let copy = Int32.of_int (num_funcs+1) in
  (* merge from another module *)
  do_it m (fun m -> {m with
     exports=List.flatten (List.map process_export m.exports);
     funcs=List.map (replace fill copy) m.funcs@List.map (remap (fun x -> Int32.add x (Int32.of_int num_types))) impl.funcs;
     types=m.types@impl.types})

let process in_file ops_file out_file =
  let str = read_whole_file in_file in
  let str_impl = read_whole_file ops_file in
  let ast = Decode.decode in_file str in
  let ast_impl = Decode.decode ops_file str_impl in
  let ast = replace ast ast_impl in
  let res = Encode.encode ast in
  let ch = open_out out_file in
  output_string ch res;
  close_out ch;
  ()

let main () =
  if Array.length Sys.argv < 4 then
    prerr_endline "Usage: ops.native input.wasm memops.wasm output.wasm"
  else
    process Sys.argv.(1) Sys.argv.(2) Sys.argv.(3) 

let _ = main()
