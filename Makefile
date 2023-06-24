BUILD_DIR := builddir
BUILD_DIR_INIT := $(BUILD_DIR)/.init
VERSION_FILE := $(BUILD_DIR)/version
BUILD_NETRC_FILE := $(BUILD_DIR)/.netrc
DOCKER_COMPOSE ?= docker-compose

$(BUILD_DIR_INIT):
	mkdir -p $(dir $@)
	touch $@

$(VERSION_FILE): $(BUILD_DIR_INIT)
	echo "$$(date -u +%Y%m%d%H%M%S)-$$(git rev-parse --abbrev-ref HEAD | tr /- __)-$$(git rev-parse --short HEAD)-local" >$@

$(BUILD_NETRC_FILE): ~/.netrc $(BUILD_DIR_INIT)
	cp $< $@

.PHONY: build
build: $(VERSION_FILE) $(BUILD_NETRC_FILE)   ## Builds the developers image
	$(DOCKER_COMPOSE) -f docker-compose.yml build

.PHONY: run
run: build ## Run the service
	$(DOCKER_COMPOSE) -f docker-compose.yml up

destroy:
	$(DOCKER_COMPOSE) -f docker-compose.yml down && docker system prune --all

.PHONY: shell
shell: build   ## Run in shell
	$(DOCKER_COMPOSE) -f docker-compose.yml run -v $$PWD/src:/code --service-ports django-cbv /bin/sh

test: $(VERSION_FILE) $(BUILD_NETRC_FILE)  ## Run unit tests in docker
	$(DOCKER_COMPOSE) -f docker-compose.yml down
	$(DOCKER_COMPOSE) -f docker-compose.yml build
	trap '$(DOCKER_COMPOSE) -f docker-compose.yml down' EXIT && \
	$(DOCKER_COMPOSE) -f docker-compose.yml run --entrypoint '/bin/sh -ec' django-cbv "$(TESTS)"