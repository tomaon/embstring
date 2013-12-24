#
 ERLANG_HOME ?= /opt/erlang/release/latest

#
 CC = /opt/gnu/gcc/4.7.3/bin/gcc

 CFLAGS =
 CFLAGS += -std=c99
 CFLAGS += -g
 CFLAGS += -Wall
 CFLAGS += -Wextra
 CFLAGS += -fPIC
 CFLAGS += -fno-common

 LDFLAGS  =

#
 REBAR_BIN  = ./rebar

 REBAR_ENV  =
 REBAR_ENV += CC="$(CC)"
 REBAR_ENV += CFLAGS="$(CFLAGS)"
 REBAR_ENV += LDFLAGS="$(LDFLAGS)"

 REBAR_OPT  =
#REBAR_OPT += --verbose 3

#
 ERL_OPT  =

 DIALYZER_OPT  =
 DIALYZER_OPT += --no_native
 DIALYZER_OPT += --plts $(ERLANG_HOME)/.dialyzer_plt
 DIALYZER_OPT += --src src

#
default: compile

#
all: build

clean compile eunit:
	@$(REBAR_ENV) $(REBAR_BIN) $(REBAR_OPT) $@ skip_deps=true

build: get-deps build-deps compile

get-deps:
	@git clone https://github.com/moriyoshi/libmbfl deps/libmbfl
	@cp -p deps/libmbfl/buildconf deps/libmbfl/buildconf.orig
	@sed 's/libtoolize/glibtoolize/g' deps/libmbfl/buildconf.orig >  deps/libmbfl/buildconf

delete-deps:
	@-rm -rf deps/libmbfl

build-deps:
	@(cd deps/libmbfl; ./buildconf;	\
	  $(REBAR_ENV) ./configure --prefix=$(shell pwd)/priv; make install)

dialyzer:
	@$(ERLANG_HOME)/bin/dialyzer $(DIALYZER_OPT)

shell:
	@$(ERLANG_HOME)/bin/erl $(ERL_OPT) -config files/$@

test: compile eunit

distclean: clean delete-deps
	@-rm -rf deps
