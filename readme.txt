Source này có thể tạo mới một network và thêm một node mới.

1.Chạy mới một network
1.1 Cài dependencies
    Command: 'make install_dependencies'
1.2 Config thông tin network
    1.2.1 Mở và edit file configs/values.env
        Command: 'nano configs/values.env'
        
        - Các trường cần khai báo
            CHAIN_ID: chain id
            EL_PREMINE_ADDRS: object các ví và số coin mặc định
            EL_AND_CL_MNEMONIC: mnemonic dùng để tạo các ví trên
            GENESIS_TIMESTAMP: thời gian khởi chạy, cứ lấy thời gian hiện tại dạng epoch time
            WITHDRAWAL_ADDRESS: địa chỉ ví nhận thưởng và rút khi validator exit.

    1.2.1 Mở và edit file configs/config.env
            Command: 'nano configs/config.env'
            
            - Các trường cần khai báo
                NETWORK_ID: chain id
                SERVER_IP: ip của server ( vd: 116.118.47.142 )
                EL_BOOTNODES: nếu là member node thì mở command và thêm địa chỉ bootnodes vào, nếu nhiều bootnode thì viết liền cách nhau bằng dấu ','.
                CL_BOOTSTRAP_NODE: nếu là member node thì mở command và thêm địa chỉ CL bootnode vào, nếu nhiều bootnode thì viết liền cách nhau bằng dấu ','.
                CL_CHECKPOINT_SYNC_URL: nếu là member node, mà node chính đã chạy quá lâu (hơn 1 tuần) và có checkpoinzt thì mở command và thêm checkpoint url vào
                VC_SUGGESTED_FEE_RECIPIENT: địa chỉ ví rút thưởng
                VC_MIN_INDEX:  số thứ tự địa chỉ ví bắt đầu trong mnemonic được tạo ra
                VC_MAX_INDEX:  số thứ tự địa chỉ ví kết thúc trong mnemonic được tạo ra
                VC_YOUR_MNEMONIC:  mnemonic 24 ký tự
                *_PORT: các trường có suffix là PORT có thể chỉnh sửa hoặc để mặc định
                
1.3 Tạo genesis data
    Command: 'make gen-genesis'

1.4 Config đầy đủ dữ liệu
    - Config đầy đủ dữ liệu, gồm dữ liệu của EL, CL và VC.
    Command: 'make run-setup'

1.5  Khởi chạy network
    - Khởi động network gồm 3 container
        + el_container
        + cl_container
        + vc_container
    Command: 'make run'

1.6 Kiểm thử
    1.6.1: Kiểm tra trên AaPanel
        - Vào aapanel mở phần Docker-Container, check xem có thiếu container và có container nào bị lỗi không.
    1.6.2: Kiểm tra bằng Geth CLI
        - Thực hiện xem block của network
        Command:
            'geth attach http://localhost:8545' => nếu vào được thì EL đã hoạt động, tiếp tục gõ
            'eth.blockNumber' xem block hiện tại là bao nhiêu, chờ vài giây xem block có tăng lên hay không (12s/1 block), nếu block tăng lên thì network node gốc đã hoạt động
    1.6.3: Kết nối ví
        - Dùng các ví như MetaMask kết nối đến xem được hay chưa.
