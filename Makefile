.DEFAULT_GOAL = help
.PHONY: help test clean setup teardown

TEST_DIR = ./tests
TEST_FILES = $(wildcard $(TEST_DIR)/*.test.lua)

SOURCE_DIR = ./src
SOURCE_FILES = $(subst .test,,$(subst $(TEST_DIR),$(SOURCE_DIR),$(TEST_FILES)))

TMP_DIR = /tmp/mpv_youtube_autoplay_tests
TMP_FILES = $(subst $(TEST_DIR),$(TMP_DIR),$(TEST_FILES))

GREEN = \033[32m
OK_COLOR = $(GREEN)
NO_COLOR = \033[m

help: ## Print this help
	@grep -hE '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST)\
		| awk 'BEGIN {FS = ":.*?## "}; {printf "$(GREEN)%-12s$(NO_COLOR) %s\n", $$1, $$2}'\
		| sed -e 's/\[32m##/[33m/'

setup: ## Init luarocs project and install luaunit
	luarocks init
	./luarocks install --only-deps *.rockspec
	
	# Replay luarocks init  to add lua_modules/ to ./lua environment
	luarocks init

teardown: clean ## Delete all luarocks files include dependencies
	rm -rf lua luarocks .luarocks lua_modules

clean: ## Remove files created by test target
	rm -rf $(TMP_DIR)

test: $(TMP_DIR) $(TMP_FILES) ## Run tests

# We use temporary files to launch test only for modified files
$(TMP_DIR):
	mkdir -p $(TMP_DIR)

$(TMP_FILES): $(SOURCE_FILES)

$(TMP_DIR)/%.test.lua: $(TEST_DIR)/%.test.lua lua
	./lua $<
	@touch $@

# vim: tw=0
