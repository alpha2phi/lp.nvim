tests_init=tests/minimal_init.lua
tests_dir=tests/

.phony: test

test:
	@nvim \
		--headless \
		--noplugin \
		-u ${tests_init} \
		-c "plenarybusteddirectory ${tests_dir} { minimal_init = '${tests_init}' }"

