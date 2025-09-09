#!/bin/bash
set -e

echo "=== ETH2 Deposit Data Generator ==="

# Nhập range validator
read -p "Source min index: " SRC_MIN
read -p "Source max index: " SRC_MAX

# Nhập mnemonic (nên cẩn thận copy/paste)
read -p "Validators mnemonic: " VAL_MNEMONIC
read -p "Withdrawals mnemonic: " WITHDRAW_MNEMONIC

# Nhập fork version (mặc định 0x10000038)
read -p "Fork version (default 0x10000038): " FORK_VERSION
FORK_VERSION=${FORK_VERSION:-0x10000038}

# Thư mục output
OUTPUT_DIR="$(pwd)/data"
mkdir -p "$OUTPUT_DIR"

echo "⚙️  Generating deposit-data.json ..."
eth2-val-tools deposit-data
  deposit-data \
    --source-min="$SRC_MIN" \
    --source-max="$SRC_MAX" \
    --validators-mnemonic="$VAL_MNEMONIC" \
    --withdrawals-mnemonic="$WITHDRAW_MNEMONIC" \
    --fork-version="$FORK_VERSION" \
    --as-json-list > "$OUTPUT_DIR/deposit-data.json"

echo "✅ Done! File saved at: $OUTPUT_DIR/deposit-data.json"
