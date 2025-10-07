
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
