#
 ERLANG_HOME ?= /opt/erlang/release/latest

 CC ?= /opt/gnu/gcc/4.7.3/bin/gcc

#
 REBAR_BIN  = ./rebar

 REBAR_ENV  =
 REBAR_ENV += PATH=$(ERLANG_HOME)/bin:$(PATH)
 REBAR_ENV += CC="$(CC)"
 REBAR_ENV += ERL_LIBS=..

 REBAR_OPT  =
#REBAR_OPT += --verbose 3

#
 ERL_ENV  =
 ERL_ENV += ERL_LIBS=..

 ERL_OPT  =
 ERL_OPT += -config priv/conf/$(1)

#PLT = .dialyzer_plt.local

 DIALYZER_OPT  =
 DIALYZER_OPT += --no_native
 DIALYZER_OPT += --plts $(ERLANG_HOME)/.dialyzer_plt $(PLT)
 DIALYZER_OPT += --src src
#DIALYZER_OPT += -I deps

#
default: compile

#
delete-deps:
	@$(REBAR_ENV) $(REBAR_BIN) $(REBAR_OPT) $@

compile eunit:
	@$(REBAR_ENV) $(REBAR_BIN) $(REBAR_OPT) $@ skip_deps=true


all: build

build: get-deps build-deps compile

build-deps:
	@(cd deps/libmbfl; ./buildconf;	\
	  $(REBAR_ENV) ./configure --prefix=$(shell pwd)/priv; make install)
build_plt:
	@$(ERLANG_HOME)/bin/dialyzer --$@ --output_plt $(PLT) --apps deps/*/ebin

clean: delete-autosave
	@$(REBAR_ENV) $(REBAR_BIN) $(REBAR_OPT) $@ skip_deps=true

delete-autosave:
	@-find . -name "*~" | xargs rm -f

dialyzer:
	@$(ERLANG_HOME)/bin/dialyzer $(DIALYZER_OPT)

distclean: clean delete-deps
	@-rm -rf deps $(PLT)

get-deps:
	@git clone https://github.com/moriyoshi/libmbfl deps/libmbfl
	@cp -p deps/libmbfl/buildconf deps/libmbfl/buildconf.orig
	@sed 's/libtoolize/glibtoolize/g' deps/libmbfl/buildconf.orig > deps/libmbfl/buildconf

test: compile eunit

#
shell:
	@$(ERL_ENV) $(ERLANG_HOME)/bin/erl $(call ERL_OPT,$@)
