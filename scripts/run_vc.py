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

vc_rpc = os.getenv("VC_BEACON_RPC_PROVIDER")
vc_rest = os.getenv("VC_BEACON_REST_API_PROVIDER")
vc_monitor_port = os.getenv("VC_MONIT_PORT")
vc_suggested_fee_recipient = os.getenv("VC_SUGGESTED_FEE_RECIPIENT")

#Path
PWD = os.path.abspath(os.path.dirname(__file__))
data_path = os.path.join(PWD, "../data/lighthouse/beacon-data")
network_path = os.path.join(PWD, "../network-configs")
validator_keys_path = os.path.join(PWD, "../validator-keys")

def run_validator():
    command = (
        "lighthouse vc --debug-level=info "
        "--testnet-dir=/network-configs "
        "--validators-dir=/validator-keys/keys "
        "--secrets-dir=/validator-keys/secrets "
        "--init-slashing-protection "
        f"--beacon-nodes={vc_rpc} "
        f"--suggested-fee-recipient={vc_suggested_fee_recipient} "
        "--metrics "
        "--metrics-address=0.0.0.0 "
        "--metrics-allow-origin=* "
        f"--metrics-port={vc_monitor_port} "
    )

    container_validator = client.containers.run(
        image="sigp/lighthouse:latest",  # hoặc digest cụ thể nếu bạn có
        name="vc-container",
        command=command,
        volumes={
            network_path: {"bind": "/network-configs", "mode": "rw"},
            validator_keys_path: {"bind": "/validator-keys", "mode": "rw"},
        },
        network_mode="host",
        detach=True,
        remove=False,
    )

#Main
if __name__ == "__main__":
    run_validator()
    
