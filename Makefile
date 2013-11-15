#
 ERLANG_HOME ?= /opt/erlang/release/latest

#
 REBAR_BIN  = ./rebar

 REBAR_ENV  =

 REBAR_OPT  =
#REBAR_OPT += --verbose 3

#
 ERL_OPT  =

 DIALYZER_OPT  =
 DIALYZER_OPT += --no_native
 DIALYZER_OPT += --plts $(ERLANG_HOME)/.dialyzer_plt
 DIALYZER_OPT += --src src

 BASE = $(shell pwd)

#
all: compile

#delete-deps get-deps:
#	@$(REBAR_ENV) $(REBAR_BIN) $(REBAR_OPT) $@

clean compile eunit:
	@$(REBAR_ENV) $(REBAR_BIN) $(REBAR_OPT) $@ skip_deps=true

build: get-deps build_priv compile

get-deps:
	@git clone https://github.com/moriyoshi/libmbfl deps/libmbfl
	@cp -p deps/libmbfl/buildconf deps/libmbfl/buildconf.orig
	@sed 's/libtoolize/glibtoolize/g' deps/libmbfl/buildconf.orig >  deps/libmbfl/buildconf
delete-deps:
	@-rm -rf deps/libmbfl

build_priv:
	@(cd deps/libmbfl; ./buildconf; ./configure --prefix=$(BASE)/priv; make install)

dialyzer:
	@$(ERLANG_HOME)/bin/dialyzer $(DIALYZER_OPT)

shell:
	@$(ERLANG_HOME)/bin/erl $(ERL_OPT) -config files/$@

test: compile eunit

distclean: clean delete-deps
	@-rm -rf deps
