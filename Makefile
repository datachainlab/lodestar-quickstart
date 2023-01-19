GETH_HTTP_PORT=8546
#BEACON_HTTP_PORT=9596
GETH_VERSION=v1.10.26
LODESTAR_VERSION=v1.3.0

TARGET_NETWORK=sepolia
#TARGET_NETWORK=goerli

#------------------------------------------------------------------------------
# Create Environment
#------------------------------------------------------------------------------
.PHONY:jwt
jwt:
	openssl rand -hex 32 | tr -d "\n" > "jwtsecret"
	mv jwtsecret ./data/

# Just default setup to know what happens
.PHONY:setup
setup:
	./setup.sh --dataDir data/$(TARGET_NETWORK) --elClient geth --devnetVars ./$(TARGET_NETWORK).vars --dockerWithSudo

# geth image based on ethereum/client-go:v1.10.26 with curl commnad
.PHONY:build-geth-image
build-geth-image:
	GETH_VERSION=$(GETH_VERSION) GETH_HTTP_PORT=$(GETH_HTTP_PORT) TARGET_NETWORK=$(TARGET_NETWORK) \
	docker compose build --no-cache geth

#------------------------------------------------------------------------------
# Development Operation
#------------------------------------------------------------------------------
# run geth and lodestar
.PHONY:run
run:
	GETH_VERSION=$(GETH_VERSION) GETH_HTTP_PORT=$(GETH_HTTP_PORT) LODESTAR_VERSION=$(LODESTAR_VERSION) TARGET_NETWORK=$(TARGET_NETWORK) \
	docker compose up

# run geth and lodestar after cleanup lodestar data directory
.PHONY:rerun
rerun: clean
	GETH_VERSION=$(GETH_VERSION) GETH_HTTP_PORT=$(GETH_HTTP_PORT) LODESTAR_VERSION=$(LODESTAR_VERSION) TARGET_NETWORK=$(TARGET_NETWORK) \
	docker compose up

# run only geth
run-geth:
	GETH_VERSION=$(GETH_VERSION) GETH_HTTP_PORT=$(GETH_HTTP_PORT) LODESTAR_VERSION=$(LODESTAR_VERSION) TARGET_NETWORK=$(TARGET_NETWORK) \
	docker compose up geth

# clean only lodestar data
.PHONY:clean
clean:
	rm -rf ./data/$(TARGET_NETWORK)/lodestar
	-@docker rm -f $(shell docker ps -a --format "{{.Names}}")

#------------------------------------------------------------------------------
# Utils
#------------------------------------------------------------------------------
.PHONY:check-health-log
check-health-log:
	docker inspect --format "{{json .State.Health }}" geth | jq

.PHONY:geth-help
geth-help:
	docker run ethereum/client-go:$(GETH_VERSION) --help

.PHONY:lodestar-beacon-help
lodestar-beacon-help:
	docker run chainsafe/lodestar:$(LODESTAR_VERSION) beacon --help

# For checking like
# > net.listening
# > net.peerCount
.PHONY:attach-geth
attach-geth:
	docker compose exec geth geth attach ipc://data/geth/geth.ipc
