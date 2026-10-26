# BÀI TẬP LỚN: CÁC HỆ THỐNG CƠ SỞ DỮ LIỆU

> **ĐỀ TÀI 13: XÂY DỰNG HỆ CƠ SỞ DỮ LIỆU QUẢN LÝ MỘT GIẢI BÓNG ĐÁ CHUYÊN NGHIỆP**  
> **Học viện Công nghệ Bưu chính Viễn thông (PTIT) — Khoa Sau Đại học**  
> **Lớp:** M26CQ02 (Hệ thống thông tin) — **Nhóm:** 2  
> **Giảng viên hướng dẫn:** TS. Phan Thị Hà (`hapt@ptit.edu.vn`)

---

## 👥 Danh sách thành viên Nhóm 2

| STT | Họ và tên | Mã học viên | Vai trò |
|:---:|:---|:---:|:---|
| 1 | **Hoàng Anh Tuấn** | B26CHHT102 | Thành viên |
| 2 | **Đào Duy Thông** | B26CHHT095 | Thành viên |
| 3 | **Nguyễn Hoàng Mạnh Dũng** | B26CHHT026 | Thành viên |
| 4 | **Hồ Quang Anh** | B26CHHT005 | Thành viên |
| 5 | **Nguyễn Thị Ngọc Bích** | B26CHHT010 | Thành viên |
| 6 | **Nguyễn Ngọc Quang** | B26CHHT086 | Thành viên |
| 7 | **Hoàng Minh Dũng** | B26CHHT027 | Thành viên |

---

## 📌 Tổng quan đề tài

Dự án nghiên cứu, phân tích, thiết kế và triển khai toàn diện hệ cơ sở dữ liệu phục vụ quản lý giải bóng đá chuyên nghiệp cấp quốc gia (mô phỏng theo thể thức giải V-League). 

Hệ thống bao quát toàn bộ quy trình nghiệp vụ:
* **Quản trị thực thể:** Câu lạc bộ, Sân vận động, Huấn luyện viên, Cầu thủ, Trọng tài.
* **Hợp đồng & Chuyển nhượng:** Hợp đồng lao động, cho mượn cầu thủ có thời hạn, quản lý mức lương, phí giải phóng.
* **Lịch thi đấu & Đăng ký:** Tạo lịch vòng tròn 2 lượt (10 vòng đấu, 30 trận với 6 đội bóng), kiểm soát danh sách đăng ký tối đa 18 cầu thủ/trận.
* **Diễn biến trận đấu:** Cập nhật thời gian thực sự kiện bàn thắng (bình thường, phạt đền, phản lưới nhà), thẻ phạt (vàng, đỏ), thay người.
* **Bảng xếp hạng tự động:** Cơ chế Trigger và View thống kê động điểm số, hiệu số, số trận thắng - hòa - thua theo chuẩn FIFA/VFF.
* **Kiến trúc phân tán:** Phân tích mô hình CSDL phân tán theo chi nhánh khu vực (Miền Bắc, Miền Trung, Miền Nam) với phân mảnh ngang, phân mảnh dọc và nhân bản Chủ — Tớ (Master - Slave).

---

## 🗂 Cấu trúc thư mục dự án

```text
├── app/                                    # Ứng dụng Web Dashboard tương tác
│   ├── app.py                              # Giao diện Streamlit & trực quan hóa dữ liệu
│   └── requirements.txt                    # Thư viện phụ thuộc Python
├── Báo cáo latex/                          # Toàn bộ mã nguồn báo cáo học thuật LaTeX
│   ├── Chapters/                           # 4 chương nội dung chính + Abstract
│   │   ├── 00-Abstract.tex
│   │   ├── 01-KhaoSatVaER.tex              # Khảo sát & Lược đồ E-R
│   │   ├── 02-ChuyenDoiVaBCNF.tex          # Chuyển đổi lược đồ quan hệ & Chuẩn hóa BCNF
│   │   ├── 03-CaiDatCSDL.tex               # Cài đặt CSDL, Trigger & Giao dịch
│   │   └── 04-CSDLPhanTan.tex              # Thiết kế CSDL phân tán & Mô phỏng
│   ├── Figures/                            # Sơ đồ ERD, DDB, biểu đồ kiến trúc
│   ├── Matter/                             # Trang bìa, lời cảm ơn, phụ lục
│   ├── Variables/                          # Thông tin biến đề tài, nhóm tác giả
│   └── TopicDetail.tex                     # File biên dịch chính (Main LaTeX file)
├── docs/                                   # Tài liệu kỹ thuật chi tiết theo giai đoạn
│   ├── GIAI_DOAN_1_THIET_KE_CSDL.md
│   ├── GIAI_DOAN_2_CAI_DAT_CSDL.md
│   ├── GIAI_DOAN_3_CSDL_PHAN_TAN.md
│   ├── KE_HOACH_THUC_HIEN_BTL.md
│   └── SO_DO_MERMAID_DRAWIO.md
├── sql/                                    # Kịch bản cơ sở dữ liệu PostgreSQL
│   ├── 00_full_database.sql                # File tổng hợp toàn bộ CSDL (One-click Run)
│   ├── 01_schema_ddl.sql                   # Khởi tạo bảng, khóa chính, khóa ngoại, CHECK
│   ├── 02_triggers.sql                     # Các Trigger kiểm soát nghiệp vụ & toàn vẹn
│   ├── 03_transactions_procedures.sql      # Thủ tục giao dịch ACID, phân xử tương tranh
│   ├── 04_views_statistics.sql             # View bảng xếp hạng & phân tích thống kê
│   ├── 05_mock_data.sql                    # Dữ liệu mẫu thực tế giải bóng đá
│   └── 06_distributed_simulation.sql       # Kịch bản mô phỏng phân mảnh & phân tán
├── REVIEW_TOAN_DIEN_THIET_KE_VA_CHUAN_HOA.md # Bản đánh giá toàn diện thiết kế & chuẩn hóa
├── CSDL.drawio                             # File sơ đồ hệ thống vẽ bằng Draw.io
└── README.md                               # Tài liệu hướng dẫn dự án
```

---

## 🛠 Công nghệ sử dụng

* **Hệ quản trị CSDL:** PostgreSQL 15+ (Hỗ trợ JSONB, Procedural PL/pgSQL, Foreign Data Wrappers).
* **Chuẩn hóa dữ liệu:** 100% các quan hệ đạt **Dạng chuẩn Boyce–Codd (BCNF)**.
* **Ngôn ngữ & Framework ứng dụng:** Python 3.10+, Streamlit, Plotly, Pandas.
* **Soạn thảo báo cáo:** LaTeX (Mẫu chuẩn học thuật cao học PTIT / IPLeiriaThesis).
* **Công cụ thiết kế sơ đồ:** Draw.io, Mermaid.js.

---

## 🚀 Hướng dẫn cài đặt & Khởi chạy

### 1. Khởi tạo Cơ sở dữ liệu (PostgreSQL)

**Cách 1: Khởi tạo nhanh toàn bộ (Khuyên dùng)**
Chạy duy nhất file `00_full_database.sql` trong pgAdmin hoặc command line:
```bash
psql -U postgres -d postgres -f sql/00_full_database.sql
```

**Cách 2: Chạy tuần tự từng giai đoạn**
1. `sql/01_schema_ddl.sql` (Tạo bảng & ràng buộc)
2. `sql/02_triggers.sql` (Tạo function & trigger nghiệp vụ)
3. `sql/03_transactions_procedures.sql` (Tạo procedure & transaction)
4. `sql/04_views_statistics.sql` (Tạo view bảng xếp hạng)
5. `sql/05_mock_data.sql` (Nạp dữ liệu mẫu)
6. `sql/06_distributed_simulation.sql` (Mô phỏng phân tán)

---

### 2. Khởi chạy Ứng dụng Web Dashboard (Streamlit)

Ứng dụng cung cấp bảng điều khiển trực quan theo dõi bảng xếp hạng, danh sách cầu thủ ghi bàn (Top Scorers), thẻ phạt và lịch thi đấu.

```bash
# 1. Di chuyển vào thư mục app
cd app

# 2. Cài đặt các thư viện phụ thuộc
pip install -r requirements.txt

# 3. Khởi chạy ứng dụng Web
streamlit run app.py
```
Sau khi chạy, mở trình duyệt tại địa chỉ: `http://localhost:8501`.

---

### 3. Biên dịch Báo cáo LaTeX

* **Biên dịch Offline:** Mở thư mục `Báo cáo latex/` trong TeXstudio / VS Code (với LaTeX Workshop) và biên dịch file `TopicDetail.tex` bằng engine `XeLaTeX` hoặc `pdfLaTeX`.
* **Biên dịch Online:** Nén toàn bộ thư mục `Báo cáo latex/` thành file `.zip` và tải lên [Overleaf](https://www.overleaf.com), chọn Main document là `TopicDetail.tex`.

---

## 💡 Điểm nổi bật trong thiết kế kỹ thuật

1. **Chuẩn hóa BCNF toàn diện:**
   - Phân tích bao đóng thuộc tính và hệ tiên đề Armstrong.
   - Tách triệt để các phụ thuộc hàm vi phạm BCNF (chuyển nhượng, danh sách đăng ký thi đấu, diễn biến sự kiện).
2. **Bộ kiểm soát toàn vẹn nghiệp vụ tự động (Triggers):**
   - Ràng buộc độ tuổi cầu thủ thi đấu chuyên nghiệp (từ 16 đến 40 tuổi).
   - Ngăn chặn ký hợp đồng trùng lặp thời gian hoặc vi phạm hợp đồng cho mượn.
   - Giới hạn nghiêm ngặt tối đa 18 cầu thủ trong danh sách đăng ký mỗi trận đấu.
   - Tự động kiểm tra thẻ phạt (2 thẻ vàng thành 1 thẻ đỏ gián tiếp).
3. **An toàn giao dịch & Kiểm soát tương tranh:**
   - Thủ tục ghi nhận kết quả và sự kiện trận đấu áp dụng mức cô lập giao dịch cao, khóa dòng bi quan (`SELECT ... FOR UPDATE`) chống xung đột dữ liệu đồng thời.
4. **Kiến trúc CSDL phân tán:**
   - Phân mảnh ngang dẫn xuất lịch thi đấu và đăng ký cầu thủ theo khu vực địa lý của CLB.
   - Phân mảnh dọc bảo mật thông tin tài chính và điều khoản cá nhân của cầu thủ.
   - Cơ chế nhân bản bảng tham chiếu dùng chung (Bảng xếp hạng, Luật thi đấu).

---

## 📜 Bản quyền & Học thuật

Đề tài được thực hiện phục vụ mục đích học tập và nghiên cứu trong khuôn khổ học phần **Các hệ thống Cơ sở dữ liệu** — Chương trình Đào tạo Sau Đại học, Học viện Công nghệ Bưu chính Viễn thông.
