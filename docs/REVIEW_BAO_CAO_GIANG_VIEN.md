# NHẬN XÉT & PHẢN BIỆN BÁO CÁO BTL CƠ SỞ DỮ LIỆU
**Góc nhìn:** Giảng viên chấm thi môn Các hệ thống Cơ sở dữ liệu  
**Đề tài 13:** Quản lý giải bóng đá chuyên nghiệp  

---

## 1. Sai lầm nghiêm trọng nhất: Phần Chuẩn hóa BCNF (Chương 2)

Nếu nộp Chương 2 như hiện tại, phần chuẩn hóa sẽ bị đánh giá là **"chứng minh hình thức, ngụy biện bằng khóa nhân tạo và bỏ sót phụ thuộc hàm nghiệp vụ"**. Cụ thể:

### 1.1. Ngụy biện "Khóa chính nhân tạo (Surrogate Key) $\rightarrow$ Đạt BCNF"
* Ở các bảng `HOP_DONG_CAU_THU` (`MaHD`), `TRAN_DAU` (`MaTran`), `SU_KIEN_TRAN_DAU` (`MaSuKien`), báo cáo chỉ liệt kê duy nhất phụ thuộc hàm từ mã tự đặt ra toàn bộ các cột còn lại ($K \rightarrow U$), rồi kết luận đạt BCNF.
* **Phản biện của giảng viên:** *"Nếu cứ thêm một cột ID tự tăng vào bất kỳ bảng nào rồi bảo `ID -> tất cả các cột` nên đạt BCNF, vậy thì mọi bảng trên đời đều đạt BCNF ngay từ đầu mà không cần học lý thuyết chuẩn hóa ư?"*
* **Bản chất đúng:** Phải xét **tất cả các phụ thuộc hàm xuất phát từ quy tắc nghiệp vụ** giữa các thuộc tính tự nhiên bên trong bảng đó.

---

### 1.2. Ba bảng đang VI PHẠM BCNF ngay trong thiết kế hiện tại (nhưng báo cáo lại kết luận đạt BCNF)

#### (A) Bảng `TRAN_DAU(MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, ...)`
* **Quy tắc nghiệp vụ (Chương 1):** *"Mỗi đội bóng có đúng 1 sân nhà cố định"* và *"Mỗi cặp đội bóng thi đấu 2 lượt: 1 lượt sân nhà và 1 lượt sân khách"*.
* **Phụ thuộc hàm bị bỏ sót:** Đội chủ nhà quyết định sân vận động diễn ra trận đấu:
  $$\text{MaDoiNha} \rightarrow \text{MaSan}$$
* **Phân tích chuẩn hóa:**
  * Khóa ứng viên của `TRAN_DAU` là $K_1 = \{\text{MaTran}\}$, $K_2 = \{\text{MaDoiNha}, \text{MaDoiKhach}\}$, $K_3 = \{\text{MaVong}, \text{MaDoiNha}\}$.
  * Trong phụ thuộc hàm $\text{MaDoiNha} \rightarrow \text{MaSan}$, vế trái `MaDoiNha` **không phải là siêu khóa**!
  * Nếu xét theo $K_2$, `MaSan` phụ thuộc bộ phận vào một phần khóa ứng viên ($\implies$ **Vi phạm ngay từ 2NF**).
  * Nếu xét theo $K_1$, $\text{MaTran} \rightarrow \text{MaDoiNha} \rightarrow \text{MaSan}$ là phụ thuộc bắc cầu ($\implies$ **Vi phạm 3NF và BCNF**).
* **Cách xử lý đúng chuẩn BCNF:**
  * *Trường hợp 1:* Nếu trận đấu luôn tổ chức tại sân nhà của `MaDoiNha`, phải **bỏ cột `MaSan` khỏi bảng `TRAN_DAU`** (vì lấy được qua `DOI_BONG.MaSanNha`).
  * *Trường hợp 2:* Nếu giữ `MaSan` trong `TRAN_DAU` (để hỗ trợ đá sân trung lập khi sân nhà bảo trì), thì trong Chương 1 & Chương 2 **phải phát biểu rõ giả thiết**: *"Một trận đấu có thể diễn ra tại sân nhà của đội chủ nhà hoặc sân trung lập do Ban tổ chức chỉ định, do đó $\text{MaDoiNha} \nrightarrow \text{MaSan}$"*.

#### (B) Bảng `SU_KIEN_TRAN_DAU(MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan)`
* **Quy tắc nghiệp vụ:** Trong một trận đấu, một cầu thủ chỉ đăng ký và thi đấu cho đúng 1 đội bóng.
* **Phụ thuộc hàm bị bỏ sót:**
  $$\{\text{MaTran}, \text{MaCauThu}\} \rightarrow \text{MaDoi}$$
* **Phân tích chuẩn hóa:**
  * Một cầu thủ trong một trận có thể ghi 2 bàn thắng hoặc nhận 2 thẻ ở các phút khác nhau, nên $\{\text{MaTran}, \text{MaCauThu}\}$ **không phải là siêu khóa** của bảng `SU_KIEN_TRAN_DAU`.
  * Do vế trái $\{\text{MaTran}, \text{MaCauThu}\}$ không phải siêu khóa $\implies$ **Bảng `SU_KIEN_TRAN_DAU` VI PHẠM 3NF VÀ BCNF!**
* **Cách xử lý đúng chuẩn BCNF:**
  * Tách (loại bỏ) cột `MaDoi` ra khỏi `SU_KIEN_TRAN_DAU`! (Vì `MaDoi` đã nằm trong bảng `DANG_KY_THI_DAU(MaTran, MaCauThu, MaDoi, ...)`).
  * Đây chính là **ví dụ thực tế hoàn hảo nhất** để trình bày thuật toán tách chuẩn BCNF trong Chương 2 thay vì phải bịa ra một bảng giả định!

#### (C) Bảng `DANG_KY_THI_DAU(MaTran, MaCauThu, MaDoi, LoaiDangKy, SoAoTran)`
* **Phụ thuộc hàm bị bỏ sót:** Trong một trận đấu, không có 2 cầu thủ cùng đội mặc trùng số áo:
  $$\{\text{MaTran}, \text{MaDoi}, \text{SoAoTran}\} \rightarrow \text{MaCauThu}$$
* **Hệ quả:** Bảng này có **2 khóa ứng viên gối lên nhau (Overlapping Candidate Keys)**:
  * $K_1 = \{\text{MaTran}, \text{MaCauThu}\}$
  * $K_2 = \{\text{MaTran}, \text{MaDoi}, \text{SoAoTran}\}$
* Hơn nữa, nếu `SoAoTran` luôn cố định bằng `SoAo` trong hợp đồng và không đổi theo từng trận, thì $\{\text{MaTran}, \text{MaCauThu}\} \rightarrow \text{SoAoTran}$ sẽ dư thừa. Phải bỏ `SoAoTran` hoặc giải thích rõ cầu thủ có thể đăng ký số áo theo trận.

---

## 2. Lỗi Thiết kế Lược đồ Quan hệ & Ràng buộc Khóa ngoại (Chương 1 & 2)

### 2.1. Lỗ hổng khóa ngoại giữa `SU_KIEN_TRAN_DAU` và `DANG_KY_THI_DAU`
* **Hiện tại:** `SU_KIEN_TRAN_DAU` có `MaTran` tham chiếu `TRAN_DAU(MaTran)` và `MaCauThu` tham chiếu `CAU_THU(MaCauThu)` một cách rời rạc.
* **Lỗ hổng:** Cầu thủ Nguyễn Văn A **không hề có tên trong danh sách 18 người đăng ký thi đấu (`DANG_KY_THI_DAU`)** của trận đấu đó vẫn có thể được chèn vào bảng `SU_KIEN_TRAN_DAU` để ghi bàn thắng!
* **Thiết kế đúng:** Khóa ngoại của `SU_KIEN_TRAN_DAU` phải là **khóa ngoại tổ hợp** `(MaTran, MaCauThu)` tham chiếu trực tiếp đến khóa chính `(MaTran, MaCauThu)` của bảng `DANG_KY_THI_DAU`! Khi đó:
  1. Bắt buộc cầu thủ phải có trong danh sách 18 người đăng ký mới được ghi bàn/nhận thẻ.
  2. Không cần lưu cột `MaDoi` dư thừa trong `SU_KIEN_TRAN_DAU` nữa (đạt chuẩn BCNF tuyệt đối).

### 2.2. Thiết kế bảng `HOP_DONG_CAU_THU`
* **Hiện tại:** Chung 1 bảng có cả `MaDoiChuQuan`, `MaDoiHienTai` và `TrangThai ('ChinhThuc', 'ChoMuon')`.
* **Vấn đề:** Nếu cầu thủ A ký hợp đồng 3 năm với Hà Nội FC, năm thứ 2 cho Hải Phòng mượn $\rightarrow$ Nếu sửa dòng đó thì mất lịch sử; nếu thêm dòng mới thì lại lặp lại thông tin `MaDoiChuQuan` ($\text{MaCauThu} \rightarrow \text{MaDoiChuQuan}$ gây vi phạm BCNF).
* **Cách làm gọn và chuẩn BCNF:**
  * Hoặc chỉ lưu `MaDoi` (đội bóng thi đấu theo hợp đồng trong giai đoạn `NgayBatDau` $\rightarrow$ `NgayKetThuc`) và `LoaiHopDong ('ChinhThuc', 'ChoMuon')`.
  * Và xác định rõ khóa ứng viên theo thời gian: $\{\text{MaCauThu}, \text{NgayBatDau}\}$ và $\{\text{MaDoi}, \text{SoAo}, \text{NgayBatDau}\}$.

---

## 3. Lỗi Số liệu Thực nghiệm & Cài đặt SQL (Chương 3)

### 3.1. Bảng 3.1 (Bảng xếp hạng) bị sai toán học cơ bản
* Trong Bảng 3.1 trang cuối Chương 3:
  * Tổng số trận Thắng của 6 đội: $8 + 6 + 5 + 4 + 2 + 0 = 25$ trận.
  * Tổng số trận Thua của 6 đội: $0 + 2 + 2 + 3 + 7 + 9 = 23$ trận.
  * Số trận Hòa: $12 / 2 = 6$ trận.
* **Lỗi chí mạng:** Trong giải đấu khép kín, 1 trận có phân thắng bại phải sinh ra 1 đội Thắng và 1 đội Thua ($\sum \text{Thắng} \equiv \sum \text{Thua}$). Ở đây $25 \neq 23$, và tổng số trận lại thành $25 + 6 = 31$ trận (vượt quá 30 trận của giải)!
* **Khắc phục:** Bắt buộc phải lấy đúng bảng kết quả truy vấn từ `05_mock_data.sql` sau khi chạy trên PostgreSQL.

### 3.2. Lệch kiểu dữ liệu giữa Chương 1 và Chương 3
* Chương 1 dùng kiểu `NVARCHAR` (SQL Server) và `DATETIME` (MySQL/SQL Server).
* Chương 3 dùng `VARCHAR` và `TIMESTAMP` (PostgreSQL).
* **Khắc phục:** Đồng bộ toàn bộ Từ điển dữ liệu ở Chương 1 sang đúng kiểu dữ liệu của PostgreSQL (`VARCHAR`, `TIMESTAMP`, `NUMERIC`/`DECIMAL`, `INT`, `DATE`).

### 3.3. Trigger và Stored Procedure (Chương 3)
1. **Race Condition khi đếm `COUNT(*)` trong Trigger:** Thêm dòng khóa bản ghi cha `PERFORM 1 FROM TRAN_DAU WHERE MaTran = NEW.MaTran FOR UPDATE;` (hoặc khóa `DOI_BONG`) trước câu lệnh `SELECT COUNT(*)` để đảm bảo an toàn đồng thời.
2. **Kiểm tra khoảng cách giờ thi đấu:** Đổi `ABS(EXTRACT(EPOCH FROM ...)) < 14400` thành phép toán khoảng hỗ trợ chỉ mục B-Tree: `NgayGio BETWEEN p_ngay_gio - INTERVAL '4 hours' AND p_ngay_gio + INTERVAL '4 hours'`.

---

## 4. Lỗi Thiết kế CSDL Phân tán (Chương 4)

1. **Vị từ phân mảnh ngang đang bị "gán cứng" (Hardcode ID):**
   * Đang viết: $p_1: \text{MaSan} \in \{\text{'SAN\_HD'}, \text{'SAN\_MD'}, \text{'SAN\_LT'}, \text{'SAN\_TT'}\}$.
   * **Nhược điểm:** Nếu thêm 1 sân mới vào CSDL, vị từ này không biết phân mảnh sân mới về đâu (vi phạm tính đầy đủ động).
   * **Cách sửa chuẩn giáo trình:** Thêm thuộc tính `KhuVuc VARCHAR(20)` (`'MienBac'`, `'MienNam'`) vào bảng `SAN_VAN_DONG`. Khi đó vị từ phân mảnh ngang cực kỳ chuẩn mực:
     $$p_1: \text{KhuVuc} = \text{'MienBac'}, \quad p_2: \text{KhuVuc} = \text{'MienNam'}$$
2. **Mô phỏng phân tán thực tế:**
   * Nên bổ sung đoạn cấu hình `postgres_fdw` kết nối qua IP mạng ảo (ZeroTier VPN) giữa các máy trạm để thể hiện đúng kiến trúc phân tán vật lý thay vì chỉ dùng `CREATE SCHEMA` nội bộ.

---

## TÓM TẮT ĐỀ XUẤT HÀNH ĐỘNG (SỬA NHANH & TRIỆT ĐỂ)

1. **Sửa nhẹ cấu trúc bảng để đạt BCNF thật sự 100% và có câu chuyện chuẩn hóa thực tế cho Chương 2:**
   * Ban đầu ở bước ánh xạ ERD sang quan hệ, bảng `SU_KIEN_TRAN_DAU` có cột `MaDoi` (và `DANG_KY_THI_DAU` có `SoAoTran`).
   * Đến bước Chuẩn hóa BCNF ở Chương 2: Chỉ ra phụ thuộc hàm $\{\text{MaTran}, \text{MaCauThu}\} \rightarrow \text{MaDoi}$ làm `SU_KIEN_TRAN_DAU` **vi phạm BCNF**. Sau đó áp dụng thuật toán tách BCNF để loại bỏ `MaDoi` khỏi `SU_KIEN_TRAN_DAU` và đặt khóa ngoại tổ hợp `(MaTran, MaCauThu)` tham chiếu đến `DANG_KY_THI_DAU`!
   * Bổ sung đầy đủ các khóa ứng viên thực tế cho `TRAN_DAU`, `DANG_KY_THI_DAU`, `HOP_DONG_CAU_THU`.
2. **Thêm cột `KhuVuc` vào `SAN_VAN_DONG`** để vị từ phân mảnh ở Chương 4 đạt chuẩn lý thuyết.
3. **Đồng bộ kiểu dữ liệu Chương 1** về chuẩn PostgreSQL và **sửa lại số liệu Bảng 3.1** khớp tuyệt đối 30 trận từ PostgreSQL.
