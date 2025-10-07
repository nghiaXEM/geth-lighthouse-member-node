# Đây là file tạo genesis (dữ liệu để chạy EL và CL) 
# Nó sẽ tạo ra folder network-configs, trong đó có chứa nhiều file cấu hình network

import os
import subprocess
import shutil
import docker
import getpass

client = docker.from_env()

#Path
PWD = os.path.abspath(os.path.dirname(__file__))
DATA_PATH = os.path.join(PWD, "../data")
CONFIGS_PATH = os.path.join(PWD, '../configs')

#Images
IMG_GENESIS_GENERATOR = "ethpandaops/ethereum-genesis-generator:master"

def run_genesis_generator():
    #Create data directory
    os.makedirs(DATA_PATH, exist_ok=True)

    docker_cmd = [
        "docker", "run", "--rm", "-it",
        "-u", str(os.getuid()),
        "-v", f"{DATA_PATH}:/data",
        "-v", f"{CONFIGS_PATH}:/config",
        IMG_GENESIS_GENERATOR,
        "all"
    ]

    print("🚀 Đang chạy Docker để tạo genesis...")
    result = subprocess.run(docker_cmd)
    if result.returncode != 0:
        print("❌ Lỗi khi chạy Docker.")
        exit(1)

    print("✅ Genesis tạo thành công!")

    # === Xử lý folder sau khi sinh genesis ===
    parsed_dir = os.path.join(DATA_PATH, "parsed")
    metadata_dir = os.path.join(DATA_PATH, "metadata")
    network_configs_dir = os.path.join(DATA_PATH, "network-configs")
    jwt_dir = os.path.join(DATA_PATH, "jwt")
    out_dir =  os.path.join(PWD, "../")  # move ra ngoài 1 cấp, tức là cùng cấp với data

    # Move parsed vào metadata
    if os.path.exists(parsed_dir) and os.path.exists(metadata_dir):
        dest_parsed = os.path.join(metadata_dir, "parsed")
        if os.path.exists(dest_parsed):
            shutil.rmtree(dest_parsed)
        shutil.move(parsed_dir, dest_parsed)
        print("✅ Đã move 'parsed' vào 'metadata'.")
    else:
        print("⚠️ Không tìm thấy 'parsed' hoặc 'metadata' trong data.")

    # Đổi tên metadata thành network-configs
    if os.path.exists(network_configs_dir):
        shutil.rmtree(network_configs_dir)
    if os.path.exists(metadata_dir):
        shutil.move(metadata_dir, network_configs_dir)
        print("✅ Đã đổi tên 'metadata' thành 'network-configs'.")
    else:
        print("⚠️ Không tìm thấy 'metadata' để đổi tên.")

    # Move network-configs ra ngoài 1 cấp
    out_network_configs = os.path.join(out_dir, "network-configs")
    if os.path.exists(out_network_configs):
        shutil.rmtree(out_network_configs)
    if os.path.exists(network_configs_dir):
        shutil.move(network_configs_dir, out_network_configs)
        print("✅ Đã move 'network-configs' ra ngoài.")
    else:
        print("⚠️ Không tìm thấy 'network-configs' để move ra ngoài.")

    # Move jwt ra ngoài 1 cấp
    out_jwt = os.path.join(out_dir, "jwt")
    if os.path.exists(out_jwt):
        shutil.rmtree(out_jwt)
    if os.path.exists(jwt_dir):
        shutil.move(jwt_dir, out_jwt)
        print("✅ Đã move 'jwt' ra ngoài.")
    else:
        print("⚠️ Không tìm thấy 'jwt' để move ra ngoài.")

#Main
if __name__ == "__main__":
    run_genesis_generator()
