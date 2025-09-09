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

REQUIRED_VARS=("VC_MIN_INDEX" "VC_MAX_INDEX" "VC_YOUR_MNEMONIC")
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "❌ Missing required environment variable: $VAR"
        exit 1
    fi
done

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

# if [ ! -d "$DEPOSIT_DATA_DIR" ]; then
#     cd $ETH2_VAL_DIR
#     ./eth2-val-tools deposit-data
#     deposit-data \
#         --source-min="$VC_MIN_INDEX" \
#         --source-max="$VC_MAX_INDEX" \
#         --validators-mnemonic="$VC_YOUR_MNEMONIC" \
#         --withdrawals-mnemonic="$VC_YOUR_MNEMONIC" \
#         --fork-version=0x10000038 \
#         --as-json-list > ./deposit-data.json
#     cd ..    
# fi

########### 5. Check validator keys ##########
echo -e "\n[5/6] Checking validator keys..."
VALIDATOR_KEYS_DIR="./validator-keys"
if [ ! -d "$VALIDATOR_KEYS_DIR" ]; then
    echo "⚠️ Validator keys not found. Generating..."
    sudo docker run --rm \
        --name eth2-vt-container \
        -v "$(pwd):/data" \
        protolambda/eth2-val-tools:latest \
        keystores \
        --insecure \
        --source-min="$VC_MIN_INDEX" \
        --source-max="$VC_MAX_INDEX" \
        --source-mnemonic="$VC_YOUR_MNEMONIC" \
        --out-loc="/data/validator-keys"
else
    echo "✅ Validator keys already exist."
fi

########### 6. Check network configs ##########
echo -e "\n[6/6] Checking network configs..."
NETWORK_CONFIGS_DIR="./network-configs"
if [ ! -d "$NETWORK_CONFIGS_DIR" ]; then
    echo "❌ Missing folder: $NETWORK_CONFIGS_DIR"
    exit 1
fi

REQUIRED_FILES=(
    "genesis.json"
    "genesis.ssz"
    "config.yaml"
    "deposit_contract_block_hash.txt"
    "deposit_contract_block.txt"
    "deposit_contract.txt"
    "genesis_validators_root.txt"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$NETWORK_CONFIGS_DIR/$file" ]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done
echo "✅ All required network config files exist."

########### JWT Secret ##########
echo -e "\n🔐 Checking JWT secret..."
if [ ! -d "./jwt" ]; then
    echo "⚠️ jwt directory not found. Creating..."
    mkdir -p ./jwt
fi

if [ ! -f "./jwt/jwtsecret" ]; then
    echo "⚠️ jwtsecret not found. Generating..."
    openssl rand -hex 32 | tr -d '\n' > ./jwt/jwtsecret
    echo "✅ jwtsecret generated."
else
    echo "✅ jwtsecret already exists."
fi

########### Ports ##########
echo -e "\n🌐 Checking ports..."
PORT_VARS=$(env | grep '_PORT=' | awk -F= '{print $1}')
for PORT_VAR in $PORT_VARS; do
    PORT_VALUE=${!PORT_VAR}
    if [ -z "$PORT_VALUE" ]; then
        echo "⚠️ $PORT_VAR is not configured."
        continue
    fi

    if lsof -i TCP:"$PORT_VALUE" >/dev/null 2>&1; then
        echo "❌ Port in use: $PORT_VAR ($PORT_VALUE)"
    else
        echo "✅ Port available: $PORT_VAR ($PORT_VALUE)"
    fi
done

PORTS=(30303 9000)
for PORT in "${PORTS[@]}"; do
    if sudo ufw status numbered | grep -qw "$PORT"; then
        echo "✅ Port $PORT already allowed in UFW."
    else
        echo "⚠️ Port $PORT not allowed in UFW. Adding..."
        sudo ufw allow "$PORT"
    fi
done

########### Init Execution Data ##########
echo -e "\n📦 Initializing Geth execution data..."
DATA_DIR="./data/geth/execution-data"

docker run --rm \
  --name geth-init-container \
  -v "$NETWORK_CONFIGS_DIR:/network-configs:ro" \
  -v "$DATA_DIR:/data/gethdata:rw" \
  ethereum/client-go:latest \
  --history.state=0 \
  --datadir=/data/gethdata init /network-configs/genesis.json

echo -e "\n🎉 Setup completed successfully!"