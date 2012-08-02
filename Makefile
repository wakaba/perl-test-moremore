PERL = perl
PERL_VERSION = latest
PERL_PATH = $(abspath local/perlbrew/perls/perl-$(PERL_VERSION)/bin)
PROVE = prove

all:

## ------ Deps ------

Makefile-setupenv: Makefile.setupenv
	make --makefile Makefile.setupenv setupenv-update \
	    SETUPENV_MIN_REVISION=20120329

Makefile.setupenv:
	wget -O $@ https://raw.github.com/wakaba/perl-setupenv/master/Makefile.setupenv

local-perl generatepm \
perl-exec perl-version pmb-update pmb-install lperl lprove \
: %: Makefile-setupenv
	make --makefile Makefile.setupenv $@

## ------ Tests ------

PERL_ENV = PATH="local/perl-$(PERL_VERSION)/pm/bin:$(PERL_PATH):$(PATH)" \
	   PERL5LIB="$(shell cat config/perl/libs.txt)"

test: safetest

test-deps: pmb-install

safetest: test-deps safetest-main

safetest-main: 
	$(PERL_ENV) $(PROVE) t/test/*.t

## ------ Distribution ------

GENERATEPM = local/generatepm/bin/generate-pm-package
GENERATEPM_ = $(GENERATEPM) --generate-json

dist: generatepm
	mkdir -p dist
	$(GENERATEPM_) config/dist/test-moremore.pi dist

dist-wakaba-packages: local/wakaba-packages dist
	cp dist/*.json local/wakaba-packages/data/perl/
	cp dist/*.tar.gz local/wakaba-packages/perl/
	cd local/wakaba-packages && $(MAKE) all

local/wakaba-packages: always
	git clone "git@github.com:wakaba/packages.git" $@ || (cd $@ && git pull)
	cd $@ && git submodule update --init

always:

## License: Public Domain.
