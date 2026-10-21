# TẬP HỢP SƠ ĐỒ MERMAID CHO HỆ THỐNG CSDL GIẢI BÓNG ĐÁ
*(Dùng để xem trực tiếp trên GitHub/VS Code Markdown Preview hoặc Import trực tiếp vào Draw.io)*

---

## HƯỚNG DẪN IMPORT VÀO DRAW.IO (3 BƯỚC NHANH CHÓNG)
1. Mở trang [Draw.io](https://app.diagrams.net/) (hoặc ứng dụng Draw.io Desktop).
2. Trên thanh menu, chọn: **Arrange** $\rightarrow$ **Insert** $\rightarrow$ **Advanced** $\rightarrow$ **Mermaid** (hoặc tiếng Việt: **Sắp xếp** $\rightarrow$ **Chèn** $\rightarrow$ **Nâng cao** $\rightarrow$ **Mermaid**).
3. Copy toàn bộ đoạn mã trong khối ` ```mermaid ... ``` ` tương ứng bên dưới và dán vào hộp thoại, sau đó nhấn **Insert**. Draw.io sẽ tự động dựng toàn bộ hình khối, liên kết có thể kéo thả, đổi màu sắc và xuất ảnh (PNG, SVG, PDF) cho báo cáo.

---

## 1. SƠ ĐỒ THỰC THỂ LIÊN KẾT (E-R DIAGRAM CHI TIẾT)

```mermaid
erDiagram
    SAN_VAN_DONG ||--o{ DOI_BONG : "là sân nhà của"
    SAN_VAN_DONG ||--o{ TRAN_DAU : "địa điểm tổ chức"
    
    DOI_BONG ||--|{ MAU_AO_DOI_BONG : "sở hữu màu áo"
    DOI_BONG ||--o{ HOP_DONG_CAU_THU : "đội chủ quản"
    DOI_BONG ||--o{ HOP_DONG_CAU_THU : "đang thi đấu tại"
    DOI_BONG ||--o{ TRAN_DAU : "đóng vai trò đội nhà"
    DOI_BONG ||--o{ TRAN_DAU : "đóng vai trò đội khách"
    DOI_BONG ||--o{ DANG_KY_THI_DAU : "đăng ký cầu thủ"
    DOI_BONG ||--o{ SU_KIEN_TRAN_DAU : "đội ghi nhận"

    CAU_THU ||--|{ HOP_DONG_CAU_THU : "ký kết hợp đồng"
    CAU_THU ||--o{ DANG_KY_THI_DAU : "được đăng ký thi đấu"
    CAU_THU ||--o{ SU_KIEN_TRAN_DAU : "ghi bàn hoặc nhận thẻ"

    VONG_DAU ||--|{ TRAN_DAU : "thuộc vòng đấu"

    TRAN_DAU ||--|{ PHAN_CONG_TRONG_TAI : "được điều khiển bởi"
    TRAN_DAU ||--|{ DANG_KY_THI_DAU : "có danh sách đăng ký"
    TRAN_DAU ||--o{ SU_KIEN_TRAN_DAU : "diễn biến các sự kiện"

    TRONG_TAI ||--o{ PHAN_CONG_TRONG_TAI : "được phân công nhiệm vụ"

    SAN_VAN_DONG {
        string MaSan PK
        string TenSan
        string DiaChi
        int SucChua
    }

    DOI_BONG {
        string MaDoi PK
        string TenDoi
        string HLV
        string MaSanNha FK
    }

    MAU_AO_DOI_BONG {
        string MaDoi PK, FK
        string LoaiMauAo PK
        string MoTaMau
    }

    CAU_THU {
        string MaCauThu PK
        string HoTen
        date NgaySinh
        string ViTri
        string QuocTich
    }

    HOP_DONG_CAU_THU {
        string MaHD PK
        string MaCauThu FK
        string MaDoiChuQuan FK
        string MaDoiHienTai FK
        int SoAo
        date NgayBatDau
        date NgayKetThuc
        string TrangThai
        decimal MucLuong
    }

    TRONG_TAI {
        string MaTrongTai PK
        string HoTen
        date NgaySinh
        string QueQuan
        string CapBac
    }

    VONG_DAU {
        int MaVong PK
        string TenVong
        int ThuTu
    }

    TRAN_DAU {
        string MaTran PK
        int MaVong FK
        string MaDoiNha FK
        string MaDoiKhach FK
        string MaSan FK
        datetime NgayGio
        decimal GiaVe
        int SoKhach
        int BanThangNha
        int BanThangKhach
        int TheVangNha
        int TheVangKhach
        int TheDoNha
        int TheDoKhach
        string TrangThai
    }

    PHAN_CONG_TRONG_TAI {
        string MaTran PK, FK
        string VaiTro PK
        string MaTrongTai FK
    }

    DANG_KY_THI_DAU {
        string MaTran PK, FK
        string MaCauThu PK, FK
        string MaDoi FK
        string LoaiDangKy
        int SoAoTran
    }

    SU_KIEN_TRAN_DAU {
        string MaSuKien PK
        string MaTran FK
        string MaCauThu FK
        string MaDoi FK
        string LoaiSuKien
        int PhutGhiNhan
    }
```

---

## 2. SƠ ĐỒ LƯỢC ĐỒ QUAN HỆ VẬT LÝ (RELATIONAL SCHEMA DIAGRAM)

```mermaid
classDiagram
    class SAN_VAN_DONG {
        +PK MaSan : VARCHAR(10)
        TenSan : NVARCHAR(100)
        DiaChi : NVARCHAR(200)
        SucChua : INT
    }

    class DOI_BONG {
        +PK MaDoi : VARCHAR(10)
        TenDoi : NVARCHAR(100)
        HLV : NVARCHAR(100)
        +FK MaSanNha : VARCHAR(10)
    }

    class MAU_AO_DOI_BONG {
        +PK, FK MaDoi : VARCHAR(10)
        +PK LoaiMauAo : VARCHAR(20)
        MoTaMau : NVARCHAR(50)
    }

    class CAU_THU {
        +PK MaCauThu : VARCHAR(10)
        HoTen : NVARCHAR(100)
        NgaySinh : DATE
        ViTri : VARCHAR(20)
        QuocTich : NVARCHAR(50)
    }

    class HOP_DONG_CAU_THU {
        +PK MaHD : VARCHAR(10)
        +FK MaCauThu : VARCHAR(10)
        +FK MaDoiChuQuan : VARCHAR(10)
        +FK MaDoiHienTai : VARCHAR(10)
        SoAo : INT [1..35]
        NgayBatDau : DATE
        NgayKetThuc : DATE
        TrangThai : VARCHAR(20)
        MucLuong : DECIMAL(15,2)
    }

    class TRONG_TAI {
        +PK MaTrongTai : VARCHAR(10)
        HoTen : NVARCHAR(100)
        NgaySinh : DATE
        QueQuan : NVARCHAR(100)
        CapBac : NVARCHAR(50)
    }

    class VONG_DAU {
        +PK MaVong : INT
        TenVong : NVARCHAR(50)
        ThuTu : INT
    }

    class TRAN_DAU {
        +PK MaTran : VARCHAR(10)
        +FK MaVong : INT
        +FK MaDoiNha : VARCHAR(10)
        +FK MaDoiKhach : VARCHAR(10)
        +FK MaSan : VARCHAR(10)
        NgayGio : DATETIME
        GiaVe : DECIMAL(12,2)
        SoKhach : INT
        BanThangNha : INT
        BanThangKhach : INT
        TheVangNha : INT
        TheVangKhach : INT
        TheDoNha : INT
        TheDoKhach : INT
        TrangThai : VARCHAR(20)
    }

    class PHAN_CONG_TRONG_TAI {
        +PK, FK MaTran : VARCHAR(10)
        +PK VaiTro : VARCHAR(20)
        +FK MaTrongTai : VARCHAR(10)
    }

    class DANG_KY_THI_DAU {
        +PK, FK MaTran : VARCHAR(10)
        +PK, FK MaCauThu : VARCHAR(10)
        +FK MaDoi : VARCHAR(10)
        LoaiDangKy : VARCHAR(20)
        SoAoTran : INT
    }

    class SU_KIEN_TRAN_DAU {
        +PK MaSuKien : VARCHAR(15)
        +FK MaTran : VARCHAR(10)
        +FK MaCauThu : VARCHAR(10)
        +FK MaDoi : VARCHAR(10)
        LoaiSuKien : VARCHAR(20)
        PhutGhiNhan : INT
    }

    SAN_VAN_DONG "1" <-- "N" DOI_BONG : MaSanNha
    SAN_VAN_DONG "1" <-- "N" TRAN_DAU : MaSan
    DOI_BONG "1" <-- "N" MAU_AO_DOI_BONG : MaDoi
    DOI_BONG "1" <-- "N" HOP_DONG_CAU_THU : MaDoiChuQuan
    DOI_BONG "1" <-- "N" HOP_DONG_CAU_THU : MaDoiHienTai
    DOI_BONG "1" <-- "N" TRAN_DAU : MaDoiNha
    DOI_BONG "1" <-- "N" TRAN_DAU : MaDoiKhach
    DOI_BONG "1" <-- "N" DANG_KY_THI_DAU : MaDoi
    DOI_BONG "1" <-- "N" SU_KIEN_TRAN_DAU : MaDoi
    CAU_THU "1" <-- "N" HOP_DONG_CAU_THU : MaCauThu
    CAU_THU "1" <-- "N" DANG_KY_THI_DAU : MaCauThu
    CAU_THU "1" <-- "N" SU_KIEN_TRAN_DAU : MaCauThu
    VONG_DAU "1" <-- "N" TRAN_DAU : MaVong
    TRAN_DAU "1" <-- "N" PHAN_CONG_TRONG_TAI : MaTran
    TRONG_TAI "1" <-- "N" PHAN_CONG_TRONG_TAI : MaTrongTai
    TRAN_DAU "1" <-- "N" DANG_KY_THI_DAU : MaTran
    TRAN_DAU "1" <-- "N" SU_KIEN_TRAN_DAU : MaTran
```

---

## 3. SƠ ĐỒ QUY TRÌNH NGHIỆP VỤ ĐIỀU HÀNH TRẬN ĐẤU (BUSINESS PROCESS)

```mermaid
flowchart TD
    Start(["Bắt đầu mùa giải"]) --> Setup["1. Thiết lập 6 đội bóng, sân nhà, $\ge 2$ màu áo & danh sách cầu thủ"]
    Setup --> CreateSchedule["2. Khởi tạo lịch thi đấu 10 vòng (30 trận vòng tròn 2 lượt)"]
    CreateSchedule --> AssignReferees["3. Phân công tổ 4 trọng tài cho từng trận (Kiểm tra: 1 TT tối đa 1 trận/vòng)"]
    AssignReferees --> PreMatch["4. Trước trận: Đăng ký danh sách thi đấu (Mỗi đội tối đa 18 cầu thủ)"]
    PreMatch --> MatchInPlay["5. Trận đấu diễn ra: Ghi nhận sự kiện (Bàn thắng, Thẻ vàng, Thẻ đỏ theo phút)"]
    MatchInPlay --> PostMatch["6. Kết thúc trận: Cập nhật tỉ số chung cuộc, số khán giả, giá vé"]
    PostMatch --> IntegrityCheck{"7. Kiểm tra toàn vẹn:\nTổng bàn thắng, thẻ khớp tỉ số?"}
    IntegrityCheck -- "Sai lệch" --> Rollback["Hủy bỏ cập nhật (Rollback Transaction)"]
    IntegrityCheck -- "Khớp đúng" --> CommitUpdate["Xác nhận lưu (Commit Transaction) & Trạng thái 'DaKetThuc'"]
    CommitUpdate --> AutoReport["8. Cập nhật Bảng xếp hạng, Top 10 phá lưới, Doanh thu sân & Lương trọng tài"]
    AutoReport --> EndMatch(["Hoàn tất trận đấu"])
```

---

## 4. SƠ ĐỒ KIẾN TRÚC CƠ SỞ DỮ LIỆU PHÂN TÁN (DISTRIBUTED ARCHITECTURE)

```mermaid
flowchart TD
    subgraph Site0["TRẠM TRUNG TÂM (SITE 0) - LIÊN ĐOÀN BÓNG ĐÁ"]
        DB0[("Cơ sở dữ liệu trung tâm\ncsdl_trungtam")]
        GlobalViews["Khung nhìn hợp nhất toàn cục:\nvw_global_tran_dau\nvw_global_su_kien"]
        SecFrag["Mảnh phân dọc bảo mật:\nHOP_DONG_TAI_CHINH (MucLuong)"]
        CentralCatalog["Dữ liệu danh mục gốc:\nDOI_BONG, CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    subgraph Site1["CHI NHÁNH MIỀN BẮC (SITE 1)"]
        DB1[("Cơ sở dữ liệu chi nhánh 1\ncsdl_chinhanh_bac")]
        Frag1_San["Phân mảnh ngang:\nSAN_VAN_DONG_1 (Hàng Đẫy, Mỹ Đình, Lạch Tray, Thiên Trường)"]
        Frag1_Tran["Phân mảnh ngang:\nTRAN_DAU_1 (25 trận đấu miền Bắc)"]
        Frag1_PK["Phân mảnh dẫn xuất:\nPHAN_CONG_TRONG_TAI_1\nDANG_KY_THI_DAU_1\nSU_KIEN_TRAN_DAU_1"]
        Replica1["Dữ liệu nhân bản tra cứu:\nDOI_BONG, CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    subgraph Site2["CHI NHÁNH MIỀN NAM (SITE 2)"]
        DB2[("Cơ sở dữ liệu chi nhánh 2\ncsdl_chinhanh_nam")]
        Frag2_San["Phân mảnh ngang:\nSAN_VAN_DONG_2 (Pleiku)"]
        Frag2_Tran["Phân mảnh ngang:\nTRAN_DAU_2 (5 trận đấu sân Pleiku)"]
        Frag2_PK["Phân mảnh dẫn xuất:\nPHAN_CONG_TRONG_TAI_2\nDANG_KY_THI_DAU_2\nSU_KIEN_TRAN_DAU_2"]
        Replica2["Dữ liệu nhân bản tra cứu:\nDOI_BONG, CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    %% Đường kết nối
    Site0 <== "Đồng bộ danh mục & Nhận báo cáo" ==> Site1
    Site0 <== "Đồng bộ danh mục & Nhận báo cáo" ==> Site2
    Site1 <-. "Truy vấn liên trạm (Foreign Data Wrapper)" .-> Site2
```
