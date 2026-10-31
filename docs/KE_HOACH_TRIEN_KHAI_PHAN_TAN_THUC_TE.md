# KẾ HOẠCH TRIỂN KHAI CSDL PHÂN TÁN THỰC TẾ TRÊN 7 MÁY TÍNH
> **Học viện Công nghệ Bưu chính Viễn thông (PTIT) — Khoa Sau Đại học**  
> **Môn học:** Các hệ thống Cơ sở dữ liệu | **Lớp:** M26CQ02 — **Nhóm 2**  
> **Đề tài 13:** Hệ CSDL Quản lý Giải bóng đá chuyên nghiệp V-League  
> **Tài liệu:** Hướng dẫn hành động chi tiết từng thao tác (Step-by-step Runbook)

---

## 📌 BÁO CÁO ĐÁNH GIÁ THIẾT KẾ VÀ DỮ LIỆU HIỆN TẠI

Nhóm đã rà soát toàn bộ cấu trúc bảng và bộ dữ liệu mẫu trong [`sql/05_mock_data.sql`](file:///d:/Learning/CSDL/sql/05_mock_data.sql). Kết luận:
1. **Thiết kế phân tán 6 Trạm cho 6 thành viên là HOÀN TOÀN TỐI ƯU VÀ CÂN XỨNG**:
   - Mùa giải có **6 Câu lạc bộ chuyên nghiệp**, thi đấu vòng tròn 2 lượt đúng **30 trận đấu**.
   - Mỗi câu lạc bộ có đúng **5 trận đá trên sân nhà** và **5 trận đá sân khách**.
   - **6 thành viên còn lại** (trừ Quang làm máy chủ) chia nhau quản lý đúng **5 trận sân nhà** của 1 đội bóng. Dữ liệu chia đều tăm tắp, không ai nhiều hơn ai.
2. **Không cần thiết kế lại dữ liệu hay sửa đổi cấu trúc bảng**:
   - Toàn bộ danh mục 108 cầu thủ, 12 trọng tài, 5 sân vận động, 6 đội bóng và 30 trận đấu đã đạt chuẩn BCNF và có đầy đủ khóa ngoại.
   - Các kịch bản SQL cài đặt cho từng người đã được bóc tách riêng thành các file `.sql` độc lập trong thư mục [`sql/distributed_nodes/`](file:///d:/Learning/CSDL/sql/distributed_nodes/).

---

## 👥 BẢNG PHÂN CÔNG THÔNG SỐ & FILE SQL CHO 7 THÀNH VIÊN

| STT | Họ và tên | Vai trò | Trạm phụ trách | IP ZeroTier | Tên Database | File SQL thực thi |
|:---:|:---|:---:|:---|:---:|:---|:---|
| **1** | **Nguyễn Ngọc Quang** | **MÁY CHỦ** | **Site 0: Ban Tổ chức VFF** | `10.147.17.10` | `vleague_master` | [`00_master_quang.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/00_master_quang.sql) |
| 2 | Hoàng Anh Tuấn | Máy khách | Site 1: CLB Hà Nội FC | `10.147.17.11` | `vleague_hnfc` | [`01_worker_hnfc_tuan.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/01_worker_hnfc_tuan.sql) |
| 3 | Đào Duy Thông | Máy khách | Site 2: CLB Công An Hà Nội | `10.147.17.12` | `vleague_cahn` | [`02_worker_cahn_thong.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/02_worker_cahn_thong.sql) |
| 4 | Nguyễn Hoàng Mạnh Dũng | Máy khách | Site 3: CLB Thể Công Viettel | `10.147.17.13` | `vleague_viettel` | [`03_worker_viettel_manhdung.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/03_worker_viettel_manhdung.sql) |
| 5 | Hồ Quang Anh | Máy khách | Site 4: CLB Hải Phòng FC | `10.147.17.14` | `vleague_haiphong` | [`04_worker_haiphong_quanganh.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/04_worker_haiphong_quanganh.sql) |
| 6 | Nguyễn Thị Ngọc Bích | Máy khách | Site 5: CLB Thép Xanh Nam Định | `10.147.17.15` | `vleague_namdinh` | [`05_worker_namdinh_ngocbich.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/05_worker_namdinh_ngocbich.sql) |
| 7 | Hoàng Minh Dũng | Máy khách | Site 6: CLB Hoàng Anh Gia Lai | `10.147.17.16` | `vleague_hagl` | [`06_worker_hagl_minhdung.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/06_worker_hagl_minhdung.sql) |

> ⚠️ **Mật khẩu tài khoản PostgreSQL**: Khuyến nghị tất cả 7 thành viên đặt mật khẩu tài khoản `postgres` là `123456` để các lệnh `USER MAPPING` từ máy chủ kết nối thông suốt mà không bị lỗi xác thực.

---

## 🚀 QUY TRÌNH THỰC HIỆN CHI TIẾT QUA 4 BƯỚC

---

### BƯỚC 1: CÀI ĐẶT MẠNG ẢO ZEROTIER VPN

#### 1.1. Dành cho Nguyễn Ngọc Quang (Tạo Network)
1. Đăng nhập [my.zerotier.com](https://my.zerotier.com) $\rightarrow$ Bấm **Create A Network**.
2. Đặt tên mạng: `VLeague-Group2`.
3. Trong mục **IPv4 Auto-Assign** $\rightarrow$ Chọn **Advanced** $\rightarrow$ Dải IP: `10.147.17.1` đến `10.147.17.254`.
4. Copy mã **Network ID (16 ký tự hex)** gửi vào nhóm Zalo cho 6 bạn.

#### 1.2. Dành cho cả 7 thành viên (Cài đặt & Join Network)
1. Tải ứng dụng [ZeroTier One for Windows](https://download.zerotier.com/dist/ZeroTier%20One.msi) và cài đặt.
2. Chuột phải icon ZeroTier ở khay hệ thống (góc dưới bên phải màn hình) $\rightarrow$ Chọn **Join New Network...**
3. Dán mã Network ID của Quang $\rightarrow$ Bấm **Join**.
4. Khi Windows hiện thông báo xanh *"Do you want to allow your PC to be discoverable..."* $\rightarrow$ **Bấm YES** (Private network).

#### 1.3. Dành cho Nguyễn Ngọc Quang (Phê duyệt và Cấp IP)
Quang vào lại web ZeroTier, cuộn xuống mục **Members**:
* Tích chọn ô vuông **Auth** cho cả 7 máy.
* Tại ô **IP Assignments**, gán cố định IP tĩnh cho từng người theo đúng bảng ở trên (`10.147.17.10` đến `10.147.17.16`).

#### 1.4. Cả 7 thành viên mở Firewall (Bắt buộc)
Mở **PowerShell (Run as Administrator)** trên máy mình, copy và chạy 2 lệnh sau:
```powershell
New-NetFirewallRule -DisplayName "ZeroTier Ping ICMP" -Direction Inbound -Protocol ICMPv4 -IcmpType 8 -Action Allow
New-NetFirewallRule -DisplayName "PostgreSQL Port 5432" -Direction Inbound -Protocol TCP -LocalPort 5432 -Action Allow
```

#### 1.5. Xác nhận Ping thông suốt
* 6 máy khách mở cmd gõ: `ping 10.147.17.10` (Ping về máy Quang).
* Máy Quang mở cmd ping kiểm tra tới 6 máy khách: `ping 10.147.17.11`, `ping 10.147.17.12`, ...
* **Yêu cầu**: Phải có `Reply from ... time=...ms`, không được bị `Request timed out`.

---

### BƯỚC 2: CẤU HÌNH POSTGRESQL LẮNG NGHE MẠNG NGOÀI (CẢ 7 THÀNH VIÊN)

Mặc định PostgreSQL chặn kết nối từ máy khác. Cần chỉnh 2 file cấu hình trong thư mục cài đặt:

1. **Sửa file `postgresql.conf`**:
   - Mở Notepad bằng quyền **Administrator** (Tìm Notepad $\rightarrow$ Chuột phải $\rightarrow$ *Run as Administrator*).
   - Mở file: `C:\Program Files\PostgreSQL\<version>\data\postgresql.conf`.
   - Tìm dòng: `#listen_addresses = 'localhost'`
   - Bỏ dấu `#` và sửa thành:
     ```ini
     listen_addresses = '*'
     ```
   - Bấm `Ctrl + S` lưu lại.

2. **Sửa file `pg_hba.conf`**:
   - Cũng từ Notepad Administrator, mở file: `C:\Program Files\PostgreSQL\<version>\data\pg_hba.conf`.
   - Cuộn xuống tận cùng file, thêm dòng sau vào cuối:
     ```ini
     host    all             all             10.147.17.0/24          trust
     ```
     *(Dùng chế độ `trust` để các máy trong mạng ZeroTier kết nối thông suốt mà không lo lỗi mật khẩu).*
   - Bấm `Ctrl + S` lưu lại.

3. **Khởi động lại dịch vụ PostgreSQL**:
   Mở PowerShell (Admin) chạy lệnh:
   ```powershell
   Restart-Service postgresql*
   ```

---

### BƯỚC 3: HƯỚNG DẪN KHỞI TẠO VÀ CÀI ĐẶT CSDL CHI TIẾT TỪNG BƯỚC

> ⚠️ **QUY TẮC BẮT BUỘC VỀ THỨ TỰ THỰC HIỆN**:
> * **Giai đoạn 3A (LÀM TRƯỚC)**: **6 máy khách** (Tuấn, Thông, Mạnh Dũng, Quang Anh, Ngọc Bích, Minh Dũng) phải khởi tạo Database và nạp xong file SQL của mình trước.
> * **Giai đoạn 3B (LÀM SAU CÙNG)**: **Máy chủ của Nguyễn Ngọc Quang** mới chạy file `00_master_quang.sql` (vì nếu 6 máy khách chưa có database, máy chủ Quang sẽ bị lỗi kết nối không tìm thấy bảng từ xa).

---

#### 3A. HƯỚNG DẪN DÀNH CHO 6 MÁY KHÁCH (THỰC HIỆN TRƯỚC)

Mỗi bạn chọn **1 trong 2 cách** dưới đây để khởi tạo và nạp database:

##### CÁCH 1: SỬ DỤNG GIAO DIỆN PGADMIN 4 (KHUYÊN DÙNG CHO MỌI NGƯỜI)

1. **Khởi động pgAdmin 4**:
   - Mở menu Start $\rightarrow$ Tìm và mở **pgAdmin 4**.
   - Nhập mật khẩu Master Password của pgAdmin (khi được hỏi).
2. **Kết nối tới Server**:
   - Ở cây thư mục bên trái (Browser Tree), click đúp vào **Servers** $\rightarrow$ Click vào **PostgreSQL 15** (hoặc 16/17).
   - Nhập mật khẩu của user `postgres` (thường là `123456`).
3. **Tạo Database mới**:
   - Chuột phải vào mục **Databases** $\rightarrow$ Chọn **Create** $\rightarrow$ **Database...**
   - Tại ô **Database**, gõ chính xác tên Database theo phân công của bạn:
     - Bạn **Tuấn**: gõ `vleague_hnfc`
     - Bạn **Thông**: gõ `vleague_cahn`
     - Bạn **Mạnh Dũng**: gõ `vleague_viettel`
     - Bạn **Quang Anh**: gõ `vleague_haiphong`
     - Bạn **Ngọc Bích**: gõ `vleague_namdinh`
     - Bạn **Minh Dũng**: gõ `vleague_hagl`
   - Bấm nút **Save** ở góc dưới.
4. **Mở công cụ thực thi lệnh (Query Tool)**:
   - Click chọn vào Database vừa tạo ở cây bên trái (ví dụ click vào `vleague_hnfc`).
   - Trên thanh menu trên cùng, bấm vào **Tools** $\rightarrow$ Chọn **Query Tool** (hoặc bấm vào icon hình cái cờ lê/tia chớp).
5. **Nạp và thực thi Script SQL**:
   - **Cách nạp file**: 
     - Trên thanh công cụ của Query Tool, bấm vào biểu tượng **Open File** (hình thư mục mở 📁).
     - Duyệt tới thư mục dự án: `sql/distributed_nodes/` và chọn đúng file của bạn:
       - Tuấn: `01_worker_hnfc_tuan.sql`
       - Thông: `02_worker_cahn_thong.sql`
       - Mạnh Dũng: `03_worker_viettel_manhdung.sql`
       - Quang Anh: `04_worker_haiphong_quanganh.sql`
       - Ngọc Bích: `05_worker_namdinh_ngocbich.sql`
       - Minh Dũng: `06_worker_hagl_minhdung.sql`
     - *(Hoặc bạn có thể mở file `.sql` bằng Notepad, bấm `Ctrl + A` $\rightarrow$ `Ctrl + C`, rồi dán vào màn hình Query Tool).*
   - **Chạy lệnh**: Bấm phím **F5** (hoặc bấm nút **Execute** hình tam giác màu xanh ▶).
6. **Kiểm tra kết quả thành công**:
   - Ở tab **Messages** phía dưới màn hình, thấy thông báo:
     `Query returned successfully in ... ms.`
   - Gõ lệnh kiểm tra và bấm F5:
     ```sql
     SELECT * FROM tran_dau_chuyen_mon;
     ```
     👉 Kết quả hiện ra đúng **5 dòng trận đấu** sân nhà của đội mình là **HOÀN THÀNH 100%**. Báo lên nhóm Zalo cho bạn Quang biết!

---

##### CÁCH 2: DÙNG DÒNG LỆNH CMD / POWERSHELL (DÀNH CHO AI THÍCH GÕ LỆNH NHANH)
Mở PowerShell, di chuyển vào thư mục dự án và gõ đúng 2 lệnh (ví dụ cho bạn Tuấn):
```powershell
# 1. Tạo database
createdb -U postgres vleague_hnfc

# 2. Nạp file SQL trực tiếp
psql -U postgres -d vleague_hnfc -f sql/distributed_nodes/01_worker_hnfc_tuan.sql
```
*(Thay `vleague_hnfc` và tên file bằng đúng database và file SQL của bạn).*

---

#### 3B. HƯỚNG DẪN DÀNH CHO MÁY CHỦ: NGUYỄN NGỌC QUANG (LÀM SAU CÙNG)

Sau khi cả 6 bạn máy khách đã xác nhận nạp xong database trên máy của họ:

1. **Tạo Database Master trên máy Quang**:
   - Mở pgAdmin 4 trên máy Quang.
   - Chuột phải **Databases** $\rightarrow$ **Create** $\rightarrow$ **Database...** đặt tên là: `vleague_master` $\rightarrow$ Bấm **Save**.
2. **Mở Query Tool trên `vleague_master`**:
   - Click vào `vleague_master` $\rightarrow$ Bấm **Tools** $\rightarrow$ **Query Tool**.
3. **Thực thi script phân tán**:
   - Bấm nút **Open File** (📁) $\rightarrow$ Chọn file: [`sql/distributed_nodes/00_master_quang.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/00_master_quang.sql).
   - Bấm **F5** (hoặc nút ▶) để chạy.
4. **Kiểm tra kết quả liên kết 6 trạm**:
   - Nhìn tab **Messages**, nếu không báo lỗi đỏ tức là máy Quang đã kết nối thông suốt qua ZeroTier tới cả 6 máy khách và import thành công 6 Foreign Schema!
   - Gõ lệnh kiểm tra thử nghiệm thu:
     ```sql
     SELECT COUNT(*) FROM vw_global_tran_dau;
     ```
     👉 Trả về kết quả: **30** (đủ 30 trận toàn giải gom từ 6 máy tính của 6 bạn) là **THÀNH CÔNG RỰC RỠ**.

---

### BƯỚC 4: KỊCH BẢN DEMO THỰC CHIẾN KHI BÁO CÁO BẢO VỆ

Khi hội đồng chấm thi hoặc giảng viên hướng dẫn yêu cầu demo hệ thống chạy trên cả 7 máy tính:

Bạn **Nguyễn Ngọc Quang** mở pgAdmin 4 trên máy mình, kết nối vào database `vleague_master`, mở file [`sql/distributed_nodes/07_demo_test_queries.sql`](file:///d:/Learning/CSDL/sql/distributed_nodes/07_demo_test_queries.sql) và chạy lần lượt 3 bài test:

#### Test 1 — Kiểm tra tính trong suốt vị trí và gom dữ liệu 6 máy
Chạy câu lệnh:
```sql
SELECT 
    COUNT(*) AS TongSoTran, 
    SUM(SoKhach) AS TongKhanGia,
    SUM(GiaVe * SoKhach) AS TongDoanhThuVeToanGiai
FROM vw_global_tran_dau;
```
* **Kết quả**: `TongSoTran = 30`, `TongKhanGia = 496000`, `TongDoanhThu = 37.160.000.000 VNĐ`.
* **Ý nghĩa**: Dữ liệu chuyên môn 30 trận nằm rải rác ở 6 máy khách, dữ liệu giá vé nằm ở máy chủ Quang, nhưng khi truy vấn qua View phân tán, toàn bộ hệ thống trả về kết quả hợp nhất tức thì mà không cần ứng dụng phải biết dữ liệu đang nằm ở đâu.

#### Test 2 — Thống kê Vua phá lưới toàn giải phân tán
Chạy câu lệnh:
```sql
SELECT 
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, ct.HoTen ASC) AS XepHang,
    ct.HoTen, ct.ViTri, COUNT(*) AS SoBanThang
FROM vw_global_su_kien_tran_dau sk
JOIN CAU_THU ct ON sk.MaCauThu = ct.MaCauThu
WHERE sk.LoaiSuKien = 'BanThang'
GROUP BY ct.MaCauThu, ct.HoTen, ct.ViTri
ORDER BY SoBanThang DESC, ct.HoTen ASC
LIMIT 5;
```
* **Kết quả**: Hiển thị bảng xếp hạng Vua phá lưới: Rafaelson Bezerra (5 bàn), Nguyễn Văn Quyết (4 bàn), Phạm Tuấn Hải (4 bàn),...

#### Test 3 — Demo cập nhật thời gian thực xuyên mạng (Real-time Cross-node Demo)
1. Giảng viên yêu cầu ghi nhận 1 sự kiện mới tại Hải Phòng.
2. Bạn **Hồ Quang Anh** (ngồi ở máy Hải Phòng) mở pgAdmin chạy 1 câu lệnh thêm bàn thắng cho tiền đạo Lucao:
   ```sql
   INSERT INTO su_kien_tran_dau VALUES ('SK999', 'TR15', 'CT082', 'BanThang', 89);
   ```
3. Bạn **Nguyễn Ngọc Quang** tại máy chủ bấm F5 chạy lại câu lệnh ở **Test 2**.
4. 👉 Màn hình máy chủ lập tức hiển thị số bàn thắng của cầu thủ Lucao tăng thêm 1 bàn ngay trước mắt giảng viên!
