# GIAI ĐOẠN 2: CÀI ĐẶT CƠ SỞ DỮ LIỆU, TRIGGERS VÀ TRANSACTIONS
**Đề tài 13:** Xây dựng Hệ CSDL quản lý một giải bóng đá chuyên nghiệp  
**Môn học:** Các hệ thống CSDL - M26CQ02 (Nhóm 2)  
**Hệ quản trị CSDL:** PostgreSQL (PL/pgSQL)

---

## MỤC LỤC
1. [Tổng quan cài đặt cơ sở dữ liệu](#1-tổng-quan-cài-đặt-cơ-sở-dữ-liệu)
2. [Cài đặt cấu trúc các bảng và ràng buộc DDL](#2-cài-đặt-cấu-trúc-các-bảng-và-ràng-buộc-ddl)
3. [Cài đặt 5 Triggers kiểm tra toàn vẹn nghiệp vụ](#3-cài-đặt-5-triggers-kiểm-tra-toàn-vẹn-nghiệp-vụ)
4. [Cài đặt 5 Giao dịch (Transactions / Stored Procedures)](#4-cài-đặt-5-giao-dịch-transactions--stored-procedures)
5. [Cài đặt các Views và Hàm nghiệp vụ thống kê](#5-cài-đặt-các-views-và-hàm-nghiệp-vụ-thống-kê)
6. [Bộ dữ liệu mẫu hoàn chỉnh mùa giải](#6-bộ-dữ-liệu-mẫu-hoàn-chỉnh-mùa-giải)
7. [Hướng dẫn cài đặt và chạy thử nghiệm](#7-hướng-dẫn-cài-đặt-và-chạy-thử-nghiệm)

---

## 1. TỔNG QUAN CÀI ĐẶT CƠ SỞ DỮ LIỆU

Hệ thống cơ sở dữ liệu được xây dựng trên hệ quản trị **PostgreSQL**, đáp ứng các tiêu chuẩn:
* Tuân thủ chuẩn SQL quốc tế, bảo đảm tính toàn vẹn dữ liệu thông qua các ràng buộc khóa chính, khóa ngoại, kiểm tra miền giá trị.
* Sử dụng ngôn ngữ thủ tục **PL/pgSQL** để lập trình các bộ kích hoạt (Trigger) và thủ tục giao dịch (Stored Procedure/Transaction).
* Hỗ trợ đầy đủ các tính chất ACID (Nguyên tử, Nhất quán, Cô lập, Bền vững) trong việc thực thi các nghiệp vụ phức tạp của giải đấu.

Tất cả các tệp mã nguồn SQL đã được đóng gói tại thư mục `d:\Learning\CSDL\sql\`:
* `01_schema_ddl.sql`: Kịch bản tạo 11 bảng dữ liệu, khóa chính, khóa ngoại và chỉ mục (Index).
* `02_triggers.sql`: Cài đặt 5 bộ kích hoạt kiểm tra toàn vẹn nghiệp vụ bắt buộc.
* `03_transactions_procedures.sql`: Cài đặt 5 thủ tục giao dịch thực thi nghiệp vụ trọng yếu.
* `04_views_statistics.sql`: Cài đặt View bảng xếp hạng tự động và các hàm thống kê theo yêu cầu đề bài.
* `05_mock_data.sql`: Dữ liệu mẫu hoàn chỉnh cho 6 đội bóng và 30 trận đấu trọn vẹn của mùa giải.
* `00_full_database.sql`: Kịch bản tổng hợp để khởi tạo toàn bộ hệ thống bằng một thao tác duy nhất.

---

## 2. CÀI ĐẶT CẤU TRÚC CÁC BẢNG VÀ RÀNG BUỘC DDL

Cơ sở dữ liệu gồm 11 bảng được liên kết chặt chẽ:
1. `SAN_VAN_DONG`: Quản lý sân thi đấu (`MaSan`, `TenSan`, `DiaChi`, `SucChua`). Sân Hàng Đẫy (`SAN_HD`) là sân nhà của cả Hà Nội FC và Công An Hà Nội.
2. `DOI_BONG`: Quản lý câu lạc bộ (`MaDoi`, `TenDoi`, `HLV`, `MaSanNha`).
3. `MAU_AO_DOI_BONG`: Quản lý các màu áo của đội bóng (`MaDoi`, `LoaiMauAo`, `MoTaMau`).
4. `CAU_THU`: Quản lý nhân thân cầu thủ (`MaCauThu`, `HoTen`, `NgaySinh`, `ViTri`, `QuocTich`).
5. `HOP_DONG_CAU_THU`: Quản lý hợp đồng thi đấu và cho mượn (`MaHD`, `MaCauThu`, `MaDoiChuQuan`, `MaDoiHienTai`, `SoAo`, `NgayBatDau`, `NgayKetThuc`, `TrangThai`, `MucLuong`). Ràng buộc số áo từ 1 đến 35.
6. `TRONG_TAI`: Quản lý thông tin trọng tài (`MaTrongTai`, `HoTen`, `NgaySinh`, `QueQuan`, `CapBac`).
7. `VONG_DAU`: Danh mục 10 vòng đấu (`MaVong`, `TenVong`, `ThuTu`).
8. `TRAN_DAU`: Quản lý các trận đấu (`MaTran`, `MaVong`, `MaDoiNha`, `MaDoiKhach`, `MaSan`, `NgayGio`, `GiaVe`, `SoKhach`, `BanThangNha`, `BanThangKhach`, `TheVangNha`, `TheVangKhach`, `TheDoNha`, `TheDoKhach`, `TrangThai`).
9. `PHAN_CONG_TRONG_TAI`: Phân công tổ 4 trọng tài cho mỗi trận (`MaTran`, `VaiTro`, `MaTrongTai`).
10. `DANG_KY_THI_DAU`: Danh sách cầu thủ đăng ký cho từng trận (`MaTran`, `MaCauThu`, `MaDoi`, `LoaiDangKy`, `SoAoTran`).
11. `SU_KIEN_TRAN_DAU`: Diễn biến bàn thắng, thẻ vàng, thẻ đỏ theo phút (`MaSuKien`, `MaTran`, `MaCauThu`, `MaDoi`, `LoaiSuKien`, `PhutGhiNhan`).

---

## 3. CÀI ĐẶT 5 TRIGGERS KIỂM TRA TOÀN VẸN NGHIỆP VỤ

### Trigger 1: Kiểm tra số áo duy nhất trong cùng một đội bóng
* **Mục đích**: Đảm bảo trong cùng một đội bóng, không có hai cầu thủ nào mang cùng số áo trong khoảng thời gian hợp đồng có hiệu lực.
* **Thời điểm kích hoạt**: `BEFORE INSERT OR UPDATE OF SoAo, MaDoiHienTai, NgayBatDau, NgayKetThuc ON HOP_DONG_CAU_THU`.
* **Cơ chế**: Truy vấn trong bảng `HOP_DONG_CAU_THU` xem có cầu thủ nào khác tại đội `MaDoiHienTai` đang sử dụng `SoAo` này và có khoảng thời gian hợp đồng giao thoa với hợp đồng mới. Nếu phát hiện vi phạm, hệ thống báo lỗi và hủy bỏ thao tác.

### Trigger 2: Kiểm tra giới hạn tối đa 30 cầu thủ mỗi đội
* **Mục đích**: Đảm bảo một đội bóng không có quá 30 cầu thủ đang có hợp đồng thi đấu còn hiệu lực.
* **Thời điểm kích hoạt**: `BEFORE INSERT OR UPDATE OF MaDoiHienTai ON HOP_DONG_CAU_THU`.
* **Cơ chế**: Đếm số lượng cầu thủ hiện tại của đội bóng (`COUNT(*)`). Nếu đã đạt 30 cầu thủ, giao dịch bị chặn lại.

### Trigger 3: Một trọng tài chỉ điều khiển tối đa 1 trận trong một vòng đấu
* **Mục đích**: Đảm bảo công bằng và thể lực của trọng tài, không phân công một trọng tài điều khiển 2 trận đấu trong cùng một vòng đấu.
* **Thời điểm kích hoạt**: `BEFORE INSERT OR UPDATE OF MaTrongTai, MaTran ON PHAN_CONG_TRONG_TAI`.
* **Cơ chế**: Lấy mã vòng đấu của trận hiện tại, kiểm tra trong bảng phân công xem trọng tài đó đã có nhiệm vụ trong bất kỳ trận nào khác của vòng đấu này chưa. Nếu có, phát sinh ngoại lệ.

### Trigger 4: Giới hạn tối đa 18 cầu thủ đăng ký cho mỗi trận đấu
* **Mục đích**: Đúng theo luật thi đấu bóng đá chuyên nghiệp, mỗi đội bóng chỉ được đăng ký tối đa 18 cầu thủ cho mỗi trận (gồm đá chính và dự bị).
* **Thời điểm kích hoạt**: `BEFORE INSERT ON DANG_KY_THI_DAU`.
* **Cơ chế**: Đếm số lượng cầu thủ đã đăng ký của đội đó trong trận đấu. Nếu đã đủ 18 người, từ chối việc đăng ký thêm.

### Trigger 5: Kiểm tra tính khớp giữa tổng số bàn thắng, thẻ phạt và kết quả trận đấu
* **Mục đích**: Bảo đảm tính toàn vẹn dữ liệu tuyệt đối giữa kết quả trận đấu và diễn biến chi tiết.
* **Thời điểm kích hoạt**: `AFTER INSERT OR UPDATE OF TrangThai, BanThangNha, BanThangKhach... ON TRAN_DAU`.
* **Cơ chế**: Khi trạng thái trận đấu chuyển sang `'DaKetThuc'`, trigger tự động đếm tổng số sự kiện `'BanThang'`, `'TheVang'`, `'TheDo'` của từng đội trong bảng `SU_KIEN_TRAN_DAU`. Nếu các con số này không bằng chính xác với các cột kết quả trong bảng `TRAN_DAU`, hệ thống phát tín hiệu lỗi và dừng giao dịch.

---

## 4. CÀI ĐẶT 5 GIAO DỊCH (TRANSACTIONS / STORED PROCEDURES)

### Giao dịch 1: Khởi tạo lịch thi đấu trận đấu (`sp_tao_lich_thi_dau`)
* **Nghiệp vụ**: Thêm trận đấu mới thuộc một vòng đấu cụ thể.
* **Kiểm tra**:
  * Đội nhà và đội khách phải khác nhau.
  * Cặp đấu sân nhà -- sân khách này chưa từng diễn ra trong mùa giải.
  * Sân vận động không bị trùng giờ với trận đấu khác (cách nhau tối thiểu 4 tiếng).

### Giao dịch 2: Phân công tổ 4 trọng tài (`sp_phan_cong_to_trong_tai`)
* **Nghiệp vụ**: Phân công đồng thời 4 trọng tài cho 1 trận đấu trong một giao dịch nguyên tử.
* **Kiểm tra**:
  * 4 trọng tài phải là các cá nhân phân biệt.
  * Khi lưu vào CSDL, Trigger 3 sẽ tự động kiểm tra việc không ai bị trùng lịch trong vòng đấu.

### Giao dịch 3: Đăng ký danh sách thi đấu (`sp_dang_ky_cau_thu_tran`)
* **Nghiệp vụ**: Đăng ký từng cầu thủ vào danh sách trận đấu.
* **Kiểm tra**:
  * Cầu thủ phải có hợp đồng hợp lệ còn hiệu lực với đội bóng.
  * Tự động lấy số áo đăng ký của cầu thủ tại đội bóng đó gán vào trận.

### Giao dịch 4: Ghi nhận kết quả trận đấu (`sp_ghi_nhan_ket_qua_tran_dau`)
* **Nghiệp vụ**: Hoàn tất trận đấu, ghi nhận tỉ số, thẻ phạt, số lượng khán giả và chuyển trạng thái trận đấu sang `'DaKetThuc'`.
* **Kiểm tra**:
  * Thời gian diễn ra trận đấu không được nằm ở tương lai so với thời điểm ghi nhận.
  * Trigger 5 sẽ kiểm tra tính toàn vẹn đối chiếu với các sự kiện đã ghi nhận.

### Giao dịch 5: Chuyển nhượng hoặc cho mượn cầu thủ (`sp_chuyen_nhuong_cho_muon_cau_thu`)
* **Nghiệp vụ**: Đưa cầu thủ sang đội bóng mới.
* **Kiểm tra**:
  * Tự động đóng thời hạn hợp đồng cũ.
  * Mở hợp đồng mới tại đội bóng mới kèm số áo mới. Trigger 1 và Trigger 2 sẽ tự động kiểm tra xem đội mới đã đủ 30 cầu thủ chưa và số áo mới đã có ai mặc chưa.

---

## 5. CÀI ĐẶT CÁC VIEWS VÀ HÀM NGHIỆP VỤ THỐNG KÊ

### 1. View Bảng xếp hạng mùa giải (`vw_bang_xep_hang`)
* Tính điểm: Thắng = 3 điểm, Hòa = 1 điểm, Thua = 0 điểm.
* Xếp hạng theo đúng thứ tự ưu tiên đề bài quy định:
  $$\text{Điểm số} \rightarrow \text{Hiệu số} \rightarrow \text{Tổng bàn thắng} \rightarrow \text{Số trận thắng sân khách} \rightarrow \text{Ít thẻ đỏ hơn} \rightarrow \text{Ít thẻ vàng hơn}.$$

### 2. Hàm Thống kê Vua phá lưới (`fn_top10_vua_pha_luoi()`)
* Trích xuất danh sách 10 cầu thủ ghi được nhiều bàn thắng nhất toàn mùa giải từ bảng sự kiện.

### 3. Hàm Tính lương trọng tài theo tháng (`fn_tinh_luong_trong_tai_thang(thang, nam)`)
* Tính thù lao điều hành các trận đấu trong tháng theo định mức:
  * Trọng tài chính: $3.000.000$ VNĐ / trận.
  * Trọng tài biên: $2.000.000$ VNĐ / trận.
  * Trọng tài bàn: $1.000.000$ VNĐ / trận.

### 4. Hàm Thống kê Doanh thu sân vận động (`fn_thong_ke_doanh_thu_san()`)
* Tổng hợp doanh thu bán vé cho từng sân: $\text{Doanh thu} = \sum (\text{Số khán giả} \times \text{Giá vé mỗi trận})$.

### 5. Hàm Thống kê chi tiết vòng đấu (`fn_thong_ke_vong_dau(ma_vong)`)
* Hiển thị tỉ số, số thẻ, số lượng khán giả của tất cả các trận đấu trong vòng đấu được chọn.

---

## 6. BỘ DỮ LIỆU MẪU HOÀN CHỈNH MÙA GIẢI

Dữ liệu mẫu được xây dựng sát với thực tế giải V-League:
* **6 đội bóng**: Hà Nội FC, Công An Hà Nội, Thể Công Viettel, Hải Phòng FC, Thép Xanh Nam Định, Hoàng Anh Gia Lai.
* **108 cầu thủ** chia đều cho 6 đội, số áo phân biệt từ 1 đến 35.
* **12 trọng tài** quốc gia và FIFA.
* **10 vòng đấu = 30 trận đấu** trọn vẹn theo thể thức vòng tròn 2 lượt.
* Đầy đủ dữ liệu khán giả, giá vé, sự kiện bàn thắng và thẻ phạt cho từng trận, đảm bảo khớp 100% kết quả.

---

## 7. HƯỚNG DẪN CÀI ĐẶT VÀ CHẠY THỬ NGHIỆM

### Cách 1: Khởi tạo nhanh bằng file tổng hợp
1. Mở **pgAdmin**, **DBeaver** hoặc công cụ dòng lệnh **psql** kết nối đến PostgreSQL.
2. Tạo một cơ sở dữ liệu mới (ví dụ: `ql_giai_bong_da`).
3. Mở và thực thi tệp `sql/00_full_database.sql`.

### Cách 2: Khởi tạo lần lượt theo thứ tự
Chạy các tệp script theo thứ tự sau:
```bash
01_schema_ddl.sql              # Tạo bảng, khóa, chỉ mục
02_triggers.sql                # Tạo 5 Triggers
03_transactions_procedures.sql # Tạo 5 Thủ tục giao dịch
04_views_statistics.sql        # Tạo View và các hàm thống kê
05_mock_data.sql               # Nạp dữ liệu mẫu 1 mùa giải
```

### Kiểm tra kết quả truy vấn:
```sql
-- Xem Bảng xếp hạng mùa giải
SELECT * FROM vw_bang_xep_hang;

-- Xem Top 10 Vua phá lưới
SELECT * FROM fn_top10_vua_pha_luoi();

-- Xem Thù lao trọng tài tháng 3/2026
SELECT * FROM fn_tinh_luong_trong_tai_thang(3, 2026);

-- Xem Doanh thu các sân vận động
SELECT * FROM fn_thong_ke_doanh_thu_san();

-- Xem Chi tiết vòng đấu số 1
SELECT * FROM fn_thong_ke_vong_dau(1);
```
