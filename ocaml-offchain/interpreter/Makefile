# This Makefile uses ocamlbuild but does not rely on ocamlfind or the Opam
# package manager to build. However, Opam package management is available
# optionally through the check/install/uninstall targets.
#
# The $(JSLIB) target requires node.js and BuckleScript.
#
# See README.me for instructions.


# Configuration

NAME =		wasm
UNOPT = 	$(NAME).debug
OPT =   	$(NAME)
LIB =		$(NAME)
ZIP =		$(NAME).zip
JSLIB =		wast.js
WINMAKE =	winmake.bat

DIRS =		util syntax binary text valid merkle exec script host main
LIBS =		
FLAGS = 	-cflags '-w +a-4-27-42-44-45'
OCB =		ocamlbuild -package cryptokit -package yojson -package bigarray $(FLAGS) $(DIRS:%=-I %) $(LIBS:%=-libs %)
JS =		# set to JS shell command to run JS tests

# Main targets

.PHONY:		default opt unopt libopt libunopt jslib all land zip

default:	opt
opt:		$(OPT)
unopt:		$(UNOPT)
libopt:		_build/$(LIB).cmx
libunopt:	_build/$(LIB).cmo
jslib:		$(JSLIB)
all:		unopt opt libunopt libopt test
land:		all $(WINMAKE)
zip: 		$(ZIP)


# Building executable

empty =
space =		$(empty) $(empty)
comma =		,

.INTERMEDIATE:	_tags
_tags:
		echo >$@ "true: bin_annot"
		echo >>$@ "<{$(subst $(space),$(comma),$(DIRS))}/*.cmx>: for-pack($(PACK))"

$(UNOPT):	main.d.byte
		mv $< $@

$(OPT):		main.native
		mv $< $@

.PHONY:		main.d.byte main.native
main.d.byte:	_tags
		$(OCB) -quiet $@

main.native:	_tags
		$(OCB) $@


# Building library

PACK =		$(shell echo `echo $(LIB) | sed 's/^\(.\).*$$/\\1/g' | tr [:lower:] [:upper:]``echo $(LIB) | sed 's/^.\(.*\)$$/\\1/g'`)

.INTERMEDIATE:	$(LIB).mlpack
$(LIB).mlpack:	$(DIRS)
		ls $(DIRS:%=%/*.ml*) \
		| sed 's:\(.*/\)\{0,1\}\(.*\)\.[^\.]*:\2:' \
		| grep -v main \
		| sort | uniq \
		>$@

_build/$(LIB).cmo: $(LIB).mlpack
		$(OCB) -quiet $(LIB).cmo

_build/$(LIB).cmx: $(LIB).mlpack
		$(OCB) -quiet $(LIB).cmx


# Building JavaScript library

.PHONY:		$(JSLIB)
$(JSLIB):	$(UNOPT)
		mkdir -p _build/jslib/src
		cp meta/jslib/* _build/jslib
		cp $(DIRS:%=_build/%/*.ml*) meta/jslib/*.ml _build/jslib/src
		rm _build/jslib/src/*.ml[^i]
		(cd _build/jslib; ./build.sh ../../$@)


# Building Windows build file

$(WINMAKE):	clean
		echo rem Auto-generated from Makefile! >$@
		echo set NAME=$(NAME) >>$@
		echo if \'%1\' neq \'\' set NAME=%1 >>$@
		$(OCB) main.d.byte \
		| grep -v ocamldep \
		| grep -v mkdir \
		| sed s:`which ocaml`:ocaml:g \
		| sed s:host/main.d.byte:%NAME%.exe: \
		>>$@


# Executing test suite

.PHONY:		test debugtest

test:		$(OPT)
		../test/core/run.py --wasm `pwd`/$(OPT) $(if $(JS),--js '$(JS)',)
debugtest:	$(UNOPT)
		../test/core/run.py --wasm `pwd`/$(UNOPT) $(if $(JS),--js '$(JS)',)

test/%:		$(OPT)
		../test/core/run.py --wasm `pwd`/$(OPT) $(if $(JS),--js '$(JS)',) $(@:test/%=../test/core/%.wast)
debugtest/%:	$(UNOPT)
		../test/core/run.py --wasm `pwd`/$(UNOPT) $(if $(JS),--js '$(JS)',) $(@:test/%=../test/core/%.wast)

run/%:		$(OPT)
		./$(OPT) $(@:run/%=../test/core/%.wast)
debugrun/%:		$(UNOPT)
		./$(UNOPT) $(@:run/%=../test/core/%.wast)


# Miscellaneous targets

.PHONY:		clean

$(ZIP):		$(WINMAKE)
		git archive --format=zip --prefix=$(NAME)/ -o $@ HEAD

clean:
		rm -rf _build/jslib wasm.mlpack _tags
		$(OCB) -clean


# Opam support

.PHONY:		check install uninstall

check:
		# Check that we can find all relevant libraries
		# when using ocamlfind
		ocamlfind query $(LIBS)

install:	_build/$(LIB).cmx _build/$(LIB).cmo
		ocamlfind install wasm meta/findlib/META _build/wasm.o \
		  $(wildcard _build/$(LIB).cm*) \
		  $(wildcard $(DIRS:%=%/*.mli))

uninstall:
		ocamlfind remove wasm
