build: ./boards/ ./config/ ./zephyr ./build.yaml ./compose.yaml
	@echo "Building zmk-config-corne"
	@docker compose run --rm build


