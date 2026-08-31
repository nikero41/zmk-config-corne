.PHONY: all
all: build

.PHONY: build
build: corne-left.uf2 corne-right.uf2

corne-left.uf2 corne-right.uf2: config/* zephyr/* build.yaml compose.yaml
	@echo "Building zmk-config-corne"
	@docker compose run --rm build


