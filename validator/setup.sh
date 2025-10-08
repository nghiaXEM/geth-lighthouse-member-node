#!/bin/bash
set -e

VALIDATOR_PATH="./validator"

SOURCE_PATH="${VALIDATOR_PATH}/validator-explorer"
DOCKER_COMPOSE_PATH="${SOURCE_PATH}/docker-compose.yml"
ENV_CONFIG="${VALIDATOR_PATH}/configs.env"
APP_CONFIG="${VALIDATOR_PATH}/config.yml"

# 1. Kiểm tra file config
if [ ! -f "$ENV_CONFIG" ]; then
    echo "❌ Config file $ENV_CONFIG không tồn tại."
    exit 1
fi

# Load config.env
set -a
source $ENV_CONFIG
set +a

REQUIRED_VARS=("REPLACE_COIN" "REPLACE_COIN_FULL" "VALIDATOR_REPO_URL")
for VAR in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!VAR}" ]; then
        echo "❌ Missing required environment variable: $VAR"
        exit 1
    fi
done

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

#Check and down source
if [ -d "$SOURCE_PATH" ]; then
  echo "🧹 Đang xóa thư mục $SOURCE_PATH..."
  rm -rf "$SOURCE_PATH"
fi
git clone  $VALIDATOR_REPO_URL $SOURCE_PATH

#Chạy script đổi coin name
# Danh sách thư mục cần duyệt
FOLDERS=("${SOURCE_PATH}/templates" "${SOURCE_PATH}/ui-package" "${SOURCE_PATH}/utils")

# Chuỗi cần thay
DEFAULT_COIN="YOUR_COIN"
DEFAULT_COIN_FULL="YOUR_COIN_FULL"

for folder in "${FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    echo "🔍 Đang xử lý thư mục: $folder"
    # Tìm toàn bộ file và thay thế trực tiếp
    find "$folder" -type f -exec sed -i "s/${DEFAULT_COIN}/${REPLACE_COIN}/g" {} +
  else
    echo "⚠️ Bỏ qua, không phải thư mục: $folder"
  fi
done
echo "✅ Hoàn tất thay thế '${DEFAULT_COIN}' → '${REPLACE_COIN}'"

for folder in "${FOLDERS[@]}"; do
  if [ -d "$folder" ]; then
    echo "🔍 Đang xử lý thư mục: $folder"
    # Tìm toàn bộ file và thay thế trực tiếp
    find "$folder" -type f -exec sed -i "s/${DEFAULT_COIN_FULL}/${REPLACE_COIN_FULL}/g" {} +
  else
    echo "⚠️ Bỏ qua, không phải thư mục: $folder"
  fi
done

echo "✅ Hoàn tất thay thế '${DEFAULT_COIN_FULL}' → '${REPLACE_COIN_FULL}'"

#Build image từ source đã config
sudo docker build -f $DOCKER_COMPOSE_PATH -t validator-explorer:latest .
