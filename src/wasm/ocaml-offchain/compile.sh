


opam init  -y
eval $(opam config env )
opam update
opam upgrade
opam install cryptokit ctypes ctypes-foreign yojson ocamlbuild -y
cd interpreter && eval $(opam config env ) && make
rm -rf ~/.opam