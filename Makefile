PKG := $(shell Rscript -e 'cat(read.dcf("DESCRIPTION")[1,"Package"])')
VERSION := $(shell Rscript -e 'cat(read.dcf("DESCRIPTION")[1,"Version"])')
TARBALL := $(PKG)_$(VERSION).tar.gz

.PHONY: help prompt response record.commit document test build check devtools.check vignettes build.vignettes check.vignettes install install.tarball install.fresh install.fresh.vignettes quick spell clean distclean

help:
	@echo "Targets:"
	@echo "  make prompt                  # record current clipboard as the latest Codex prompt"
	@echo "  make response                # record current clipboard as the latest Codex response summary"
	@echo "  make record.commit           # record full git hash and subject for the latest entry"
	@echo "  make document                # regenerate roxygen documentation"
	@echo "  make test                    # run package-aware testthat tests"
	@echo "  make build                   # build source tarball without building vignettes"
	@echo "  make check                   # run R CMD check on built tarball without building vignettes"
	@echo "  make devtools.check          # run devtools::check(), regenerating docs first"
	@echo "  make vignettes               # build vignettes in inst/doc from vignettes/"
	@echo "  make build.vignettes         # build source tarball including vignettes"
	@echo "  make check.vignettes         # run R CMD check with vignette building enabled"
	@echo "  make install                 # install current package source"
	@echo "  make install.tarball         # build tarball without building vignettes and install it"
	@echo "  make install.fresh           # document, test, build, check, install tarball"
	@echo "  make install.fresh.vignettes # document, test, build vignettes, check with vignettes, install tarball"
	@echo "  make quick                   # document, test, install from source"
	@echo "  make spell                   # spell-check package documentation"
	@echo "  make clean                   # remove build/check artefacts"
	@echo "  make distclean               # clean + remove generated docs"

prompt:
	pbpaste | python3 tools/codex_workflow.py prompt

response:
	pbpaste | python3 tools/codex_workflow.py response

record.commit:
	python3 tools/codex_workflow.py commit

document:
	Rscript -e 'if (!requireNamespace("roxygen2", quietly = TRUE)) stop("Install the roxygen2 package first: install.packages(\"roxygen2\")"); roxygen2::roxygenise(".", roclets = c("rd","namespace"))'

test:
	Rscript -e 'if (!requireNamespace("testthat", quietly = TRUE)) stop("Install the testthat package first: install.packages(\"testthat\")"); testthat::test_local(".", reporter = "summary")'

build:
	R CMD build --no-build-vignettes .

check: build
	R CMD check --no-manual --no-build-vignettes "$(TARBALL)"

devtools.check:
	Rscript -e 'if (!requireNamespace("devtools", quietly = TRUE)) stop("Install the devtools package first: install.packages(\"devtools\")"); devtools::check(".", document = TRUE, args = c("--no-manual", "--no-build-vignettes"))'

vignettes:
	Rscript -e 'if (!requireNamespace("devtools", quietly = TRUE)) stop("Install the devtools package first: install.packages(\"devtools\")"); devtools::build_vignettes(".")'

build.vignettes:
	R CMD build .

check.vignettes: build.vignettes
	R CMD check --no-manual "$(TARBALL)"

install:
	R CMD INSTALL .

install.tarball: build
	R CMD INSTALL "$(TARBALL)"

install.fresh: document test check
	R CMD INSTALL "$(TARBALL)"

install.fresh.vignettes: document test vignettes check.vignettes
	R CMD INSTALL "$(TARBALL)"

quick: document test install

spell:
	Rscript -e 'if (!requireNamespace("spelling", quietly = TRUE)) stop("Install the spelling package first: install.packages(\"spelling\")"); spelling::spell_check_package(".")'

clean:
	rm -rf "$(PKG).Rcheck"
	rm -f "$(TARBALL)"
	rm -f *~ src/*~ R/*~ man/*~ tests/testthat/*~

distclean: clean
	rm -f NAMESPACE
	rm -f man/*.Rd
