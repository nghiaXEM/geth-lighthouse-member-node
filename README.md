# 🧩 Private Ethereum Network (Geth + Lighthouse)

Dự án này giúp bạn **khởi tạo một mạng Ethereum riêng (Private Network)** với cơ chế đồng thuận **Proof of Stake (PoS)**, bao gồm cả **Execution Layer (EL)** và **Consensus Layer (CL)**.  
Hệ thống được thiết kế dễ triển khai, có thể mở rộng bằng cách thêm các node thành viên mới vào mạng sẵn có.

---

## 🚀 1. Khởi tạo Mạng Mới

### 1.1 Cài đặt Dependencies

Đảm bảo bạn đã cài đặt sẵn **Docker**, **Docker Compose** và **Make**.  
Sau đó chạy lệnh:

```bash
make install_dependencies
```

---

### 1.2 Cấu hình Thông tin Mạng

#### 🧾 File `configs/values.env`

Mở và chỉnh sửa file:

```bash
nano configs/values.env
```

Khai báo các trường cần thiết:

| Biến | Mô tả |
|------|-------|
| `CHAIN_ID` | Chain ID của mạng |
| `EL_PREMINE_ADDRS` | Object chứa danh sách ví và số coin mặc định (premine) |
| `EL_AND_CL_MNEMONIC` | Mnemonic dùng để tạo các ví trên |
| `GENESIS_TIMESTAMP` | Thời gian khởi chạy (epoch time, nên dùng thời gian hiện tại) |
| `WITHDRAWAL_ADDRESS` | Địa chỉ ví nhận thưởng và rút khi validator exit |

---

#### ⚙️ File `configs/config.env`

Mở và chỉnh sửa file:

```bash
nano configs/config.env
```

Các trường cần cấu hình:

| Biến | Mô tả |
|------|-------|
| `NETWORK_ID` | Chain ID của mạng |
| `SERVER_IP` | IP của server (VD: `116.118.47.142`) |
| `EL_BOOTNODES` | Danh sách bootnode cho Execution Layer (chỉ cần với member node). Nếu nhiều node, cách nhau bằng dấu `,` |
| `CL_BOOTSTRAP_NODE` | Danh sách bootstrap node cho Consensus Layer (chỉ cần với member node) |
| `CL_CHECKPOINT_SYNC_URL` | URL checkpoint sync (chỉ cần nếu node chính đã chạy > 1 tuần) |
| `VC_SUGGESTED_FEE_RECIPIENT` | Địa chỉ ví nhận thưởng |
| `VC_MIN_INDEX` | Số thứ tự địa chỉ ví bắt đầu trong mnemonic |
| `VC_MAX_INDEX` | Số thứ tự địa chỉ ví kết thúc trong mnemonic |
| `VC_YOUR_MNEMONIC` | Mnemonic 24 ký tự (dùng để tạo validator key) |
| `*_PORT` | Các trường port có thể thay đổi hoặc giữ mặc định |

---

### 1.3 Tạo Genesis Data

Tạo dữ liệu genesis cho mạng Ethereum:

```bash
make gen-genesis
```

---

### 1.4 Thiết lập Dữ liệu Cho EL, CL và VC

Cấu hình và khởi tạo toàn bộ dữ liệu cần thiết cho:
- Execution Layer (EL)
- Consensus Layer (CL)
- Validator Client (VC)

```bash
make run-setup
```

---

### 1.5 Khởi chạy Network

Khởi động mạng Ethereum gồm 3 container:

- `el_container` — Execution Layer (Geth)
- `cl_container` — Consensus Layer (Lighthouse)
- `vc_container` — Validator Client

```bash
make run
```

---

### 1.6 Kiểm thử & Xác minh

#### 🔍 1.6.1 Kiểm tra bằng **AaPanel**

- Mở **AaPanel → Docker → Container**
- Kiểm tra xem:
  - Có đủ 3 container: EL, CL, VC
  - Không container nào bị lỗi hoặc dừng bất thường

---

#### ⛓️ 1.6.2 Kiểm tra bằng **Geth CLI**

Thực hiện truy cập vào Geth để kiểm tra block:

```bash
geth attach http://localhost:8545
```

Nếu vào được, gõ lệnh sau:

```bash
eth.blockNumber
```

- Nếu số block tăng dần (12s/block), nghĩa là mạng đã hoạt động ổn định.  
- Nếu block không tăng → kiểm tra lại cấu hình hoặc log container.

---

#### 🦊 1.6.3 Kết nối với Ví MetaMask

1. Mở **MetaMask** → **Add Network Manually**  
2. Điền thông tin mạng:
   - **RPC URL:** `http://<SERVER_IP>:8545`
   - **Chain ID:** trùng với `CHAIN_ID` bạn đã cấu hình
   - **Currency Symbol:** ETH
3. Lưu và kết nối để xác nhận hoạt động.

---

## 📜 Giấy phép

Dự án phát hành theo giấy phép **MIT License**.  
Bạn được phép sao chép, chỉnh sửa và sử dụng cho mục đích học tập hoặc phát triển hệ thống riêng.

---

## 💡 Tác giả

Người phát triển: **NghiaXEM**  
Liên hệ: [nghia@xem.edu.vn](mailto:nghia@xem.edu.vn)
