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

cl_rpc_port = os.getenv("CL_RPC_PORT")
cl_http_port = os.getenv("CL_HTTP_PORT")
cl_p2p_tcp_port = os.getenv("CL_P2P_TCP_PORT")
cl_p2p_udp_port = os.getenv("CL_P2P_UDP_PORT")
cl_p2p_quic_port = os.getenv("CL_P2P_QUIC_PORT")
cl_monit_port = os.getenv("CL_MONIT_PORT")
cl_pprof_port = os.getenv("CL_PPROFPORT")
cl_bootstrap_node = os.getenv("CL_BOOTSTRAP_NODE")
cl_checkpoint_sync_url = os.getenv("CL_CHECKPOINT_SYNC_URL")

vc_suggested_fee_recipient = os.getenv("VC_SUGGESTED_FEE_RECIPIENT")

#Path
PWD = os.path.abspath(os.path.dirname(__file__))
data_path = os.path.join(PWD, "../data/lighthouse/beacon-data")
jwt_path = os.path.join(PWD, "../jwt")
network_path = os.path.join(PWD, "../network-configs")

def run_consensus():
    command = (
        "lighthouse beacon_node --debug-level=info "
        "--datadir=/data/lighthouse/beacon-data "
        f"--listen-address=0.0.0.0 "
        f"--port={cl_rpc_port} "
        "--http "
        "--http-address=0.0.0.0 "
        "--http-port=5052 "
        "--disable-packet-filter "
        f"--execution-endpoints=http://localhost:{el_authrpc} "
        "--jwt-secrets=/jwt/jwtsecret "
        f"--suggested-fee-recipient={vc_suggested_fee_recipient} "
        f"--enr-address={server_ip} "
        f"--enr-tcp-port={cl_p2p_tcp_port} "
        f"--enr-udp-port={cl_p2p_udp_port} "
        f"--enr-quic-port={cl_p2p_quic_port} "
        f"--quic-port={cl_p2p_quic_port} "
        "--metrics "
        "--metrics-address=0.0.0.0 "
        "--metrics-allow-origin=* "
        f"--metrics-port={cl_monit_port} "
        "--enable-private-discovery "
        "--testnet-dir=/network-configs "
    )

    if cl_bootstrap_node:
        command += f"--boot-nodes={cl_bootstrap_node} "
    
    if cl_checkpoint_sync_url:
        command += f"--checkpoint-sync-url={cl_checkpoint_sync_url} "

    print(command)

    cl_container = client.containers.run(
        image="sigp/lighthouse:latest",
        name="cl-container",
        command=command,
        volumes={
            data_path: {"bind": "/data/lighthouse/beacon-data", "mode": "rw"},
            jwt_path: {"bind": "/jwt", "mode": "rw"},
            network_path: {"bind": "/network-configs", "mode": "rw"},
        },
        network_mode="host",
        detach=True,
        remove=False,
    )
    # try:
    #     for line in cl_container.logs(stream=True):
    #         decoded_line = line.decode().strip()
    #         print(decoded_line)

    #         # if "Started P2P networking" in decoded_line:
    #         #     with open( os.path.join(PWD, "data", "el_ern.txt"), "w") as f:
    #         #         f.write(decoded_line)

    #         # 👉 Ví dụ: Bắt sự kiện cụ thể trong logs
    #         if "Connected to new endpoint" in decoded_line:
    #             break

    # except Exception as e:
    #     print(f"❌ Lỗi khi đọc log Geth: {e}")

    #geth_container.wait()
    print("✅ Khởi chạy Consensus thành công.")


#Main
if __name__ == "__main__":
    run_consensus()
