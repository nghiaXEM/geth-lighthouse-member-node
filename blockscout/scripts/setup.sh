#!/bin/bash
set -e

BLOCKSCOUT_PATH="./blockscout"

CONFIG_PATH="${BLOCKSCOUT_PATH}/configs"
CONFIG_FILE="${BLOCKSCOUT_PATH}/configs/config.env"
SOURCE_PATH="${BLOCKSCOUT_PATH}/blockscout"
DOCKER_COMPOSE_PATH="${SOURCE_PATH}/docker-compose"

# 1. Kiểm tra file config
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file $CONFIG_FILE không tồn tại."
    exit 1
fi

# Load config.env
set -a
source $CONFIG_FILE
set +a

REQUIRED_VARS=("BLOCKSCOUT_REPO_URL" "BLOCKSCOUT_FE_IMAGE" "BLOCKSCOUT_PUBLIC_PORT")
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

#Down source
git clone $BLOCKSCOUT_REPO_URL $SOURCE_PATH

#Replace setup
REPLACE_CONFIG_PATH=$CONFIG_PATH
REPLACE_TARGET_PATH=$DOCKER_COMPOSE_PATH

# 1. Replace file config
FILES=(
  "proxy/default.conf.template"
  "services/nginx.yml"
  "docker-compose.yml"
)
for FILE in "${FILES[@]}"; do
  SRC="${REPLACE_CONFIG_PATH}/${FILE}"
  DST="${REPLACE_TARGET_PATH}/${FILE}"

  if [ -f "$SRC" ]; then
    mkdir -p "$(dirname "$DST")"
    cp -f "$SRC" "$DST"
    echo "🔁 Replaced: $FILE"
  else
    echo "⚠️  Không tìm thấy file ở source: $SRC"
  fi
done

# 2. Repalce variable
FILES=(
  "envs/common-blockscout.env"
  "envs/common-frontend.env"
  "envs/common-stats.env"
)
sync_env_file() {
  local SRC_FILE="$1"
  local DST_FILE="$2"

  echo "🔧 Processing: $SRC_FILE → $DST_FILE"

  while IFS='=' read -r KEY VALUE; do
    # Bỏ qua dòng trống hoặc comment
    [[ -z "$KEY" || "$KEY" == \#* ]] && continue

    # Escape ký tự đặc biệt trong VALUE (/, &)
    ESCAPED_VALUE=$(printf '%s\n' "$VALUE" | sed 's/[\/&]/\\&/g')

    # Nếu biến có sẵn trong file đích → thay thế
    if grep -q "^${KEY}=" "$DST_FILE"; then
      sed -i "s|^${KEY}=.*|${KEY}=${ESCAPED_VALUE}|" "$DST_FILE"
      echo "  🔁 Updated: $KEY=$VALUE"
    else
      # Nếu chưa có → thêm mới cuối file
      echo "${KEY}=${VALUE}" >> "$DST_FILE"
      echo "  ➕ Added: $KEY=$VALUE"
    fi
  done < "$SRC_FILE"
}

# Vòng lặp qua tất cả file trong danh sách
for FILE in "${FILES[@]}"; do
  SRC_FILE="${REPLACE_CONFIG_PATH}/${FILE}"
  DST_FILE="${REPLACE_TARGET_PATH}/${FILE}"

  # Kiểm tra tồn tại
  if [ ! -f "$SRC_FILE" ]; then
    echo "⚠️  Source file không tồn tại: $SRC_FILE"
    continue
  fi
  if [ ! -f "$DST_FILE" ]; then
    echo "⚠️  Target file không tồn tại, tạo mới: $DST_FILE"
    mkdir -p "$(dirname "$DST_FILE")"
    touch "$DST_FILE"
  fi

  sync_env_file "$SRC_FILE" "$DST_FILE"
done

echo "✅ Hoàn tất thay thế giá trị biến trong tất cả file."


