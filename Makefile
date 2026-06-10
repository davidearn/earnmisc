PKG := $(shell Rscript -e 'cat(read.dcf("DESCRIPTION")[1,"Package"])')
VERSION := $(shell Rscript -e 'cat(read.dcf("DESCRIPTION")[1,"Version"])')
TARBALL := $(PKG)_$(VERSION).tar.gz
TEST ?=
INSTALL_LIB ?= $(shell Rscript -e 'cat(Sys.getenv("R_LIBS_USER", unset = .libPaths()[[1L]]))')

.PHONY: help document test test.focus test.quick build check check.quick devtools.check vignettes build.vignettes check.vignettes install install.quick install.tarball install.fresh install.fresh.vignettes quick verify.quick verify.full spell clean distclean

help:
	@echo "Targets:"
	@echo "  make document                # regenerate roxygen documentation"
	@echo "  make test                    # run full package-aware testthat tests"
	@echo "  make test.focus TEST=...     # run one test file after pkgload::load_all()"
	@echo "  make test.quick              # run routine tests, skipping tikz-gated tests"
	@echo "  make build                   # build source tarball without building vignettes"
	@echo "  make check                   # run full R CMD check on built tarball without building vignettes"
	@echo "  make check.quick             # run R CMD check with quick-test environment"
	@echo "  make devtools.check          # run devtools::check(), regenerating docs first"
	@echo "  make vignettes               # build vignettes in inst/doc from vignettes/"
	@echo "  make build.vignettes         # build source tarball including vignettes"
	@echo "  make check.vignettes         # run R CMD check with vignette building enabled"
	@echo "  make install                 # install current package source; defaults to R_LIBS_USER"
	@echo "  make install.quick           # install source without check; defaults to R_LIBS_USER"
	@echo "  make install.tarball         # build tarball without building vignettes and install it"
	@echo "  make install.fresh           # document, test, build, check, install tarball"
	@echo "  make install.fresh.vignettes # document, test, build vignettes, check with vignettes, install tarball"
	@echo "  make verify.quick            # document, quick test, diff check, install.quick"
	@echo "  make verify.full             # alias for install.fresh"
	@echo "  make quick                   # alias for verify.quick"
	@echo "  make spell                   # spell-check package documentation"
	@echo "  make clean                   # remove build/check artefacts"
	@echo "  make distclean               # clean + remove generated docs"
	@echo ""
	@echo "During iteration, use test.focus or verify.quick."
	@echo "Before committing, use verify.full or install.fresh."

document:
	Rscript -e 'if (!requireNamespace("roxygen2", quietly = TRUE)) stop("Install the roxygen2 package first: install.packages(\"roxygen2\")"); roxygen2::roxygenise(".", roclets = c("rd","namespace"))'

test:
	RUN_SLOW_TESTS=true RUN_TIKZ_TESTS=true Rscript -e 'if (!requireNamespace("testthat", quietly = TRUE)) stop("Install the testthat package first: install.packages(\"testthat\")"); testthat::test_local(".", reporter = "summary")'

test.focus:
	@test -n "$(TEST)" || { echo "Usage: make test.focus TEST=tests/testthat/test-file.R"; exit 2; }
	RUN_SLOW_TESTS=true RUN_TIKZ_TESTS=true Rscript -e 'if (!requireNamespace("pkgload", quietly = TRUE)) stop("Install the pkgload package first: install.packages(\"pkgload\")"); if (!requireNamespace("testthat", quietly = TRUE)) stop("Install the testthat package first: install.packages(\"testthat\")"); pkgload::load_all("."); testthat::test_file("$(TEST)")'

test.quick:
	RUN_SLOW_TESTS=false RUN_TIKZ_TESTS=false Rscript -e 'if (!requireNamespace("testthat", quietly = TRUE)) stop("Install the testthat package first: install.packages(\"testthat\")"); testthat::test_local(".", reporter = "summary")'

build:
	R CMD build --no-build-vignettes .

check: build
	RUN_SLOW_TESTS=true RUN_TIKZ_TESTS=true R CMD check --no-manual --no-build-vignettes "$(TARBALL)"

check.quick: build
	RUN_SLOW_TESTS=false RUN_TIKZ_TESTS=false R CMD check --no-manual --no-build-vignettes "$(TARBALL)"

devtools.check:
	Rscript -e 'if (!requireNamespace("devtools", quietly = TRUE)) stop("Install the devtools package first: install.packages(\"devtools\")"); devtools::check(".", document = TRUE, args = c("--no-manual", "--no-build-vignettes"))'

vignettes:
	Rscript -e 'if (!requireNamespace("devtools", quietly = TRUE)) stop("Install the devtools package first: install.packages(\"devtools\")"); devtools::build_vignettes(".")'

build.vignettes:
	R CMD build .

check.vignettes: build.vignettes
	RUN_SLOW_TESTS=true RUN_TIKZ_TESTS=true R CMD check --no-manual "$(TARBALL)"

install:
	mkdir -p "$(INSTALL_LIB)"
	R CMD INSTALL --library="$(INSTALL_LIB)" .

install.quick:
	mkdir -p "$(INSTALL_LIB)"
	R CMD INSTALL --library="$(INSTALL_LIB)" .

install.tarball: build
	mkdir -p "$(INSTALL_LIB)"
	R CMD INSTALL --library="$(INSTALL_LIB)" "$(TARBALL)"

install.fresh: document test check
	mkdir -p "$(INSTALL_LIB)"
	R CMD INSTALL --library="$(INSTALL_LIB)" "$(TARBALL)"

install.fresh.vignettes: document test vignettes check.vignettes
	mkdir -p "$(INSTALL_LIB)"
	R CMD INSTALL --library="$(INSTALL_LIB)" "$(TARBALL)"

verify.quick: document test.quick
	git diff --check
	$(MAKE) install.quick

verify.full: install.fresh

quick: verify.quick

spell:
	Rscript -e 'if (!requireNamespace("spelling", quietly = TRUE)) stop("Install the spelling package first: install.packages(\"spelling\")"); spelling::spell_check_package(".")'

clean:
	rm -rf "$(PKG).Rcheck"
	rm -f "$(TARBALL)"
	rm -f *~ src/*~ R/*~ man/*~ tests/testthat/*~

distclean: clean
	rm -f NAMESPACE
	rm -f man/*.Rd
