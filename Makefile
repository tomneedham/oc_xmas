SHELL := /bin/bash

#
# Define NPM and check if it is available on the system.
#
NPM := $(shell command -v npm 2> /dev/null)
ifndef NPM
    $(error npm is not available on your system, please install npm)
endif
app_name=xmas
project_directory=$(CURDIR)/../$(app_name)
build_tools_directory=$(CURDIR)/build/tools
appstore_package_name=$(CURDIR)/build/dist/$(app_name)
npm=$(shell which npm 2> /dev/null)

occ=$(CURDIR)/../../occ
private_key=$(HOME)/.owncloud/certificates/$(app_name).key
certificate=$(HOME)/.owncloud/certificates/$(app_name).crt
sign=php -f $(occ) integrity:sign-app --privateKey="$(private_key)" --certificate="$(certificate)"
sign_skip_msg="Skipping signing, either no key and certificate found in $(private_key) and $(certificate) or occ can not be found at $(occ)"
ifneq (,$(wildcard $(private_key)))
ifneq (,$(wildcard $(certificate)))
ifneq (,$(wildcard $(occ)))
	CAN_SIGN=true
endif
endif
endif

app_doc_files=README.md CHANGELOG.md
app_src_dirs=js appinfo lib css
app_all_src=$(app_src_dirs) $(app_doc_files)
build_dir=build
dist_dir=$(build_dir)/dist

# internal aliases
js_deps=node_modules/

#
# Catch-all rules
#
.PHONY: all
all: $(dist_dir)/$(app_name)

.PHONY: clean
clean: clean-js-deps clean-dist clean-build


#
# ownCloud support_portal JavaScript dependencies
#
$(js_deps): $(NPM) package.json
	$(NPM) install
	touch $(js_deps)

.PHONY: install-js-deps
install-js-deps: $(js_deps)

.PHONY: update-js-deps
update-js-deps: $(js_deps)


.PHONY: clean-js-deps
clean-js-deps:
	rm -Rf $(js_deps)

#
# build
#
.PHONY: js/$(app_name).bundle.js
js/$(app_name).bundle.js: $(js_deps)
	$(NPM) run build

#
# dist
#

$(dist_dir)/$(app_name):  $(js_deps)  js/$(app_name).bundle.js
	rm -Rf $@; mkdir -p $@
	cp -R $(app_all_src) $@

.PHONY: dist
dist: clean $(dist_dir)/$(app_name)
ifdef CAN_SIGN
	$(sign) --path="$(appstore_package_name)"
else
	@echo $(sign_skip_msg)
endif
	tar -czf $(appstore_package_name).tar.gz -C $(appstore_package_name)/../ $(app_name)

.PHONY: clean-dist
clean-dist:
	rm -Rf $(dist_dir)

.PHONY: clean-build
clean-build:
	rm -Rf $(build_dir)

.PHONY: dist-cached
dist-cached: $(dist_dir)/$(app_name)
	tar -czf $(CURDIR)/build/dist/$(app_name).tar.gz -C $(CURDIR)/build/dist/ $(app_name)