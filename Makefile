# SPDX-License-Identifier: GPL-3.0-or-later

name := devhelper

m4 ?= m4
m4 := printf '%s\n%s' 'changequote([[, ]])' 'undefine(shift)' | $(m4) -

esbuild ?= esbuild
esbuild += --bundle --format=esm
esbuild += --define:NULL=null --define:NAME='"$(name)"'

terser ?= terser
terser += --module --ecma 2020 --mangle --comments false \
	  --compress 'passes=3,pure_getters=true,unsafe=true'

prefix := build
m4-prefix := $(prefix)/m4

ifneq ($(minimize),)
	minimize := -terser
endif

ifneq ($(debug),)
	debug := -debug
endif

.PHONY: install uninstall publish
install:

lib-in   := $(wildcard lib/*.js)
lib-m4-y := $(addprefix $(m4-prefix)/,$(lib-in))

devhelper-in   := entry.js $(wildcard cmd/*.js)
devhelper-m4-y := $(addprefix $(m4-prefix)/,$(devhelper-in))
devhelper-y    := $(prefix)/entry.js

$(lib-m4-y) $(devhelper-m4-y): $(m4-prefix)/%: %
	mkdir -p $(@D)
	$(m4) $< >$@

$(devhelper-y)1: $(devhelper-m4-y) $(lib-m4-y)
	$(esbuild) --banner:js="import { createRequire } from 'node:module'; \
		   		var require = createRequire(import.meta.url);" \
		   --sourcemap --platform=node --external:vscode --outfile=$@ $<

terser-y := $(addsuffix 1-terser,$(devhelper-y))
debug-y  := $(addsuffix -debug,$(devhelper-y))

$(terser-y): %1-terser: %1
	$(terser) <$< >$@

$(devhelper-y): %: %1$(minimize)
	head -n1 entry.js >$@
	printf '\n' >>$@
	cat $< >>$@

$(debug-y): %-debug: %1
	ln -f $< $@
	ln -f $< $*

package-in := $(wildcard package/*.json)
package-y  := package.json

$(package-y): %: %.in $(package-in)
	$(m4) $< >$@

archive-in += $(addsuffix $(debug),$(devhelper-y))
archive-in += README $(wildcard image/*)
archive-y  := $(prefix)/$(name).vsix

$(archive-y): $(archive-in) $(package-y)
	vsce package --skip-license -o $@

install: $(archive-y)
	code --install-extension $<

uninstall:
	code --uninstall-extension \
	     $$(code --list-extensions | grep $(name) || printf '39\n')

publish: $(archive-y)
	vsce publish --skip-license

.PHONY: clean distclean

clean:
	rm -f $(archive-y)
	rm -f $(m4-y)
	rm -f $(devhelper-y)*

distclean: clean
	rm -f $(package-y)
