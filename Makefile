
SHELL = /bin/bash
.SHELLFLAGS = -o pipefail -c

.PHONY: healthy
healthy:
	@echo "OK!"

#Kiểm tra môi trường
.PHONY: run-setup
run-setup:
	@chmod +x ./scripts/setup.sh
	@./scripts/setup.sh

#Chạy container EL, CL, VC
.PHONY: run
run:
	@sudo python3 ./scripts/run.pyVC

#Tạo deposit 
.PHONY: run-deposit
run-deposit:
	@chmod +x ./scripts/deposit.sh
	@./scripts/deposit.sh
