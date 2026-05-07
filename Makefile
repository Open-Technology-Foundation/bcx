# Makefile for bcx - BCS1212-compliant
# Targets: all (=help), install, uninstall, check, test, help
# Override paths via PREFIX, BINDIR, MANDIR, COMPDIR, DESTDIR.

PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
MANDIR  ?= $(PREFIX)/share/man
COMPDIR ?= /etc/bash_completion.d
DESTDIR ?=

PROG := bcx
MAN1 := $(PROG).1
COMP := .bash_completion

INSTALL         := install
INSTALL_PROGRAM := $(INSTALL) -m 0755
INSTALL_DATA    := $(INSTALL) -m 0644
INSTALL_DIR     := $(INSTALL) -d -m 0755

HAS_MAN  := $(wildcard $(MAN1))
HAS_COMP := $(wildcard $(COMP))

.PHONY: all help install uninstall check test lint

all: help

help:
	@echo 'bcx Makefile targets:'
	@echo '  install     Install $(PROG) to $(BINDIR) (+ manpage, completion if present)'
	@echo '  uninstall   Remove installed files'
	@echo '  check       Verify installed command (skipped if DESTDIR set)'
	@echo '  test        Run shellcheck + smoke tests + manpage lint'
	@echo '  lint        Alias for test'
	@echo '  help        Show this message (default)'
	@echo ''
	@echo 'Variables (override with VAR=value):'
	@echo '  PREFIX  = $(PREFIX)'
	@echo '  BINDIR  = $(BINDIR)'
	@echo '  MANDIR  = $(MANDIR)'
	@echo '  COMPDIR = $(COMPDIR)'
	@echo '  DESTDIR = $(DESTDIR)'

install:
	$(INSTALL_DIR) $(DESTDIR)$(BINDIR)
	$(INSTALL_PROGRAM) $(PROG) $(DESTDIR)$(BINDIR)/$(PROG)
ifneq ($(HAS_MAN),)
	$(INSTALL_DIR) $(DESTDIR)$(MANDIR)/man1
	$(INSTALL_DATA) $(MAN1) $(DESTDIR)$(MANDIR)/man1/$(MAN1)
endif
ifneq ($(HAS_COMP),)
	$(INSTALL_DIR) $(DESTDIR)$(COMPDIR)
	$(INSTALL_DATA) $(COMP) $(DESTDIR)$(COMPDIR)/$(PROG)
endif

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/$(PROG)
	rm -f $(DESTDIR)$(MANDIR)/man1/$(MAN1)
	rm -f $(DESTDIR)$(COMPDIR)/$(PROG)

check:
ifneq ($(DESTDIR),)
	@echo 'DESTDIR set; skipping post-install check'
else
	$(BINDIR)/$(PROG) -V >/dev/null
	@out=$$($(BINDIR)/$(PROG) '23*42'); \
	  [ "$$out" = '966' ] || { echo "check FAILED: 23*42 -> $$out"; exit 1; }
	@out=$$($(BINDIR)/$(PROG) 'sqrt(144)'); \
	  [ "$$out" = '12.00000000000000000000' ] || { echo "check FAILED: sqrt(144) -> $$out"; exit 1; }
endif

test: lint

lint:
	shellcheck -x --severity=warning $(PROG)
	@out=$$(./$(PROG) '23*42'); \
	  [ "$$out" = '966' ] || { echo "smoke FAILED: 23*42 -> $$out"; exit 1; }
	@out=$$(./$(PROG) 'sqrt(144)'); \
	  [ "$$out" = '12.00000000000000000000' ] || { echo "smoke FAILED: sqrt(144) -> $$out"; exit 1; }
ifneq ($(HAS_MAN),)
	@command -v groff >/dev/null && groff -t -man -Tutf8 -ww $(MAN1) >/dev/null || true
endif
