#!/bin/bash
set -e

CONFIG_FILE="./configs/config.env"

echo -e "\n=== Ethereum Validator Setup Script ===\n"

# 1. Kiểm tra file config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file $CONFIG_FILE không tồn tại."
    exit 1
fi

# Load config.env
set -a
source $CONFIG_FILE
set +a

# REQUIRED_VARS=("VC_MIN_INDEX" "VC_MAX_INDEX" "VC_YOUR_MNEMONIC")
# for VAR in "${REQUIRED_VARS[@]}"; do
#     if [ -z "${!VAR}" ]; then
#         echo "❌ Missing required environment variable: $VAR"
#         exit 1
#     fi
# done

########### 1. Check Go ##########
echo -e "\n[1/6] Checking Go..."
if command -v go >/dev/null 2>&1; then
    echo "✅ Go is already installed."
else
    echo "⚠️ Go is not installed. Installing..."
    wget https://go.dev/dl/go1.25.1.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf go1.25.1.linux-amd64.tar.gz
    export PATH=$PATH:/usr/local/go/bin
    go version
    echo "✅ Go installation completed."
fi 

########### 2. Check Geth ##########
echo -e "\n[2/6] Checking Geth..."
if command -v geth >/dev/null 2>&1; then
    echo "✅ Geth is already installed."
else
    echo "⚠️ Geth is not installed. Installing..."
    sudo add-apt-repository -y ppa:ethereum/ethereum
    sudo apt-get update
    sudo apt-get install -y ethereum
    echo "✅ Geth installation completed."
fi

########### 3. Check Python & packages ##########
echo -e "\n[3/6] Checking Python environment..."
REQUIRED_PYTHON_PACKAGES=("docker" "requests" "dotenv")

if ! command -v pip3 &>/dev/null; then
    echo "⚠️ pip3 not found. Installing..."
    sudo apt update
    sudo apt install -y python3-pip
fi

check_and_install_package() {
    local pkg="$1"

    # Kiểm tra gói có trong system site-packages chưa
    if ! sudo pip3 show "$pkg" &>/dev/null; then
        echo "⚠️  Python package '$pkg' not found (system). Installing..."
        sudo pip3 install "$pkg"
    else
        echo "✅ Python package '$pkg' is already installed (system)"
    fi
}
for pkg in "${REQUIRED_PYTHON_PACKAGES[@]}"; do
    check_and_install_package "$pkg"
done
# for pkg in "${REQUIRED_PYTHON_PACKAGES[@]}"; do
#     if ! python3 -c "import $pkg" &>/dev/null; then
#         echo "⚠️ Python package '$pkg' not found. Installing..."
#         sudo pip3 install --user "$pkg"
#     else
#         echo "✅ Python package '$pkg' is installed."
#     fi
# done


########### 4. Check eth2-validator-tools ##########
echo -e "\n[4/6] Checking eth2-validator-tools..."
ETH2_VAL_DIR="./eth2-val-tools"
DEPOSIT_DATA_DIR="./deposit-data"
ETH2_VAL_TOOLS_REPO_URL="https://github.com/protolambda/eth2-val-tools.git"

if [ ! -d "$ETH2_VAL_DIR" ]; then
    echo "⚠️ eth2-val-tools not found. Cloning repository..."
    git clone $ETH2_VAL_TOOLS_REPO_URL
    cd $ETH2_VAL_DIR && go build && cd ..
else
    echo "✅ eth2-val-tools directory exists."
    if [ ! -f "$ETH2_VAL_DIR/eth2-val-tools" ]; then
        echo "⚠️ eth2-val-tools binary missing. Building..."
        cd $ETH2_VAL_DIR && go build && cd ..
    fi
fi
