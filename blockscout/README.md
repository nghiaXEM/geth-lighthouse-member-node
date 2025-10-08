BlockScout
1. Setup các thông tin network
  1.1 Backend
    - Config thông tin network, để backend có thể lấy được data từ chain
    - Command: 'nano ./blockscout/blockscout/docker-compose/envs/common-blockscout.env'
    - Các thông tin config
      CHAIN_ID: chain id
      ETHEREUM_JSONRPC_TRACE_URL: enpoint của network (http://server_id:http_port)
      ETHEREUM_JSONRPC_HTTP_URL: enpoint của network (http://server_id:http_port)
      ETHEREUM_JSONRPC_WS_URL: socket enpoint của network (ws://server_id:http_port)
    - Tham khảo: https://docs.blockscout.com/setup/env-variables/backend-env-variables

  1.2 Frontend
    - Cấu hình để hiển thị UI
    - Tham khảo: https://docs.blockscout.com/setup/env-variables/frontend-common-envs/envs
  1.3 Stats
    - Cấu hình hiển thị thống kê
    - Cấu hình
      STATS__BLOCKSCOUT_API_URL: url của blockscout
      * Thay tất cả YOUR_COIN_NAME bằng tên coin của bạn

2. Chạy script setup
  - Command: 'make blockscout-setup'

3. Khởi chạy/dừng blockscout
  - Command:
    'make blockscout-start'
    'make blockscout-stop'
  
