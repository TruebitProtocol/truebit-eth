

type w256 = string

let w256_to_string bs =
  let res = ref "" in
  for i = 0 to String.length bs - 1 do
    let code = Char.code (String.get bs i) in
    res := !res ^ (if code < 16 then "0" else "") ^ Printf.sprintf "%x" code
  done;
  !res


type res = {
   get_hash : w256 array -> w256;
   get_hash16 : w256 array -> w256;
   map_hash : 'a. ('a -> w256) -> 'a array -> w256;
   location_proof : w256 array -> int -> w256 list;
   map_location_proof : 'a. ('a -> w256) -> 'a array -> int -> w256 list;
}


