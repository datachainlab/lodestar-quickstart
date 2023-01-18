TARGET_NETWORK=sepolia

.PHONY:jwt
jwt:
	openssl rand -hex 32 | tr -d "\n" > "jwtsecret"	

.PHONY:setup
setup:
	./setup.sh --dataDir sepolia-data --elClient geth --devnetVars ./$(TARGET_NETWORK).vars --dockerWithSudo

.PHONY:run
run:
	docker compose up
