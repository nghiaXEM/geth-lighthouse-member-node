
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

.PHONY: healthy
healthy:
	@echo "OK!"

# Cài đặt các dependencies
.PHONY: install-dependencies
install-dependencies:
	@chmod +x ./scripts/install_dependencies.sh
	@./scripts/install_dependencies.sh

#Tạo genesis data
.PHONY: gen-genesis
gen-genesis:
	@sudo python3 ./scripts/gen_genesis_data.py

#Kiểm tra môi trường
.PHONY: run-setup
run-setup:
	@chmod +x ./scripts/setup.sh
	@./scripts/setup.sh

#Chạy container EL, CL, VC
.PHONY: run
run:
	@sudo python3 ./scripts/run.py

#Tạo deposit 
.PHONY: run-deposit
run-deposit:
	@chmod +x ./scripts/deposit.sh
	@./scripts/deposit.sh

#Blockscout setup 
.PHONY: blockscout-setup
blockscout-setup:
	@chmod +x ./blockscout/scripts/setup.sh
	@./blockscout/scripts/setup.sh

# Start Blockscout containers
.PHONY: blockscout-start
blockscout-start:
	@docker compose -f ./blockscout/blockscout/docker-compose/docker-compose.yml up -d

# Stop Blockscout containers
.PHONY: blockscout-stop
blockscout-stop:
	@docker compose -f ./blockscout/blockscout/docker-compose/docker-compose.yml down


# Validator explorer setup
.PHONY: validator-setup
validator-setup:
	@chmod +x ./validator/setup.sh
	@./validator/setup.sh

# Start Validator-explorer containers
.PHONY: validator-start
validator-start:
	@echo "🚀 Starting Validator-explorer.."
	@docker run -d \
		--name validator-explorer \
		--network host \
		--restart unless-stopped \
		-v ./validator/config.yaml:/config/dora-config.yaml:ro \
		validator-explorer \
		-config=/config/dora-config.yaml


# Start checkpointz containers
.PHONY: checkpointz-start
checkpointz-start:
	@echo "🚀 Starting Checkpointz.."
	@docker run -d \
	--name checkpointz \
	-v ./checkpointz/config.yaml:/opt/checkpointz/config.yaml \
	-p 9090:9090 \
	-p 5555:5555 \
	-it ethpandaops/checkpointz:latest \
	--config /opt/checkpointz/config.yaml;
