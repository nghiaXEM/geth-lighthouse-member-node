import os
import subprocess
import shutil
import docker

from dotenv import load_dotenv

#Path
PWD = os.path.abspath(os.path.dirname(__file__))

# Load .env từ file hiện tại hoặc đường dẫn tùy chỉnh
dotenv_path = os.path.join(PWD,'../configs', "config.env")
data_path = os.path.join(PWD, "../data/geth/execution-data")
jwt_path = os.path.join(PWD, "../jwt")
load_dotenv(dotenv_path=dotenv_path)

client = docker.from_env()

# Lấy giá trị từ biến môi trường
network_id = os.getenv("NETWORK_ID")
server_ip = os.getenv("SERVER_IP")
el_http_port = os.getenv("EL_HTTP_PORT")
el_ws_port = os.getenv("EL_WS_PORT")
el_authrpc = os.getenv("EL_AUTHRPC")
el_p2p_port = os.getenv("EL_P2P_PORT")
el_metrics_port = os.getenv("EL_METRICS_PORT")
el_bootnodes = os.getenv("EL_BOOTNODES")

def run_execution():
    geth_command = (
        f"--networkid={network_id} "
        f"--verbosity=3 "
        f"--datadir=/data/geth/execution-data "
        f"--http --http.addr=127.0.0.1 --http.port={el_http_port} --http.vhosts=* --http.corsdomain=* "
        f"--http.api=admin,engine,net,eth,web3,debug,txpool "
        f"--ws --ws.addr=127.0.0.1 --ws.port={el_ws_port} --ws.api=admin,engine,net,eth,web3,debug,txpool "
        f"--ws.origins=* "
        f"--nat=extip:{server_ip} "
        f"--authrpc.port={el_authrpc} --authrpc.addr=127.0.0.1 --authrpc.vhosts=* --authrpc.jwtsecret=/jwt/jwtsecret "
        f"--history.state=0 "
        f"--syncmode=full "
        f"--gcmode=archive "
        f"--metrics --metrics.addr=0.0.0.0 --metrics.port={el_metrics_port} "
        f"--discovery.port={el_p2p_port} --port={el_p2p_port} "
    )

    # Thêm dòng bootnodes nếu tồn tại
    if el_bootnodes:
        geth_command += f" --bootnodes={el_bootnodes}"

    print(f"command: {geth_command}")
    geth_container = client.containers.run(
        image="ethereum/client-go:latest",
        name="geth-container",
        command=geth_command,
        user=f"{os.getuid()}:{os.getgid()}",
        volumes={
            data_path: {"bind": "/data/geth/execution-data", "mode": "rw"},
            jwt_path: {"bind": "/jwt", "mode": "rw"},
        },
        network_mode="host",
        detach=True,
        remove=False,
    )

    # Log theo thời gian thực
    print("📺 Streaming logs từ container...")

    # try:
    #     for line in geth_container.logs(stream=True):
    #         decoded_line = line.decode().strip()
    #         print(decoded_line)

    #         if "Started P2P networking" in decoded_line:
    #             with open( os.path.join(PWD, "data", "el_ern.txt"), "w") as f:
    #                 f.write(decoded_line)

    #         # 👉 Ví dụ: Bắt sự kiện cụ thể trong logs
    #         if "Started log indexer" in decoded_line:
    #             break

    # except Exception as e:
    #     print(f"❌ Lỗi khi đọc log Geth: {e}")

    # geth_container.wait()
    print("✅ Khởi chạy GETH thành công.")


#Main
if __name__ == "__main__":
    run_execution()
