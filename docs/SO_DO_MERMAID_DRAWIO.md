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
    SAN_VAN_DONG ||--o{ DOI_BONG : "là sân nhà của (0,N)-(1,1)"
    SAN_VAN_DONG ||--o{ TRAN_DAU : "địa điểm tổ chức (0,N)-(1,1)"
    
    DOI_BONG ||--|{ MAU_AO_DOI_BONG : "sở hữu màu áo (1,1)-(2,3)"
    DOI_BONG ||--o{ HOP_DONG_CAU_THU : "đội chủ quản (1,1)-(18,30)"
    DOI_BONG ||--o{ HOP_DONG_CAU_THU : "đang thi đấu tại (1,1)-(18,30)"
    DOI_BONG ||--o{ TRAN_DAU : "đóng vai trò đội nhà (1,1)-(5,5)"
    DOI_BONG ||--o{ TRAN_DAU : "đóng vai trò đội khách (1,1)-(5,5)"
    DOI_BONG ||--o{ DANG_KY_THI_DAU : "đăng ký cầu thủ"

    CAU_THU ||--|{ HOP_DONG_CAU_THU : "ký kết hợp đồng (1,1)-(1,N)"
    CAU_THU ||--o{ DANG_KY_THI_DAU : "được đăng ký thi đấu (0,10)"

    VONG_DAU ||--|{ TRAN_DAU : "thuộc vòng đấu (1,1)-(3,3)"

    TRAN_DAU ||--|{ PHAN_CONG_TRONG_TAI : "được điều khiển bởi (1,1)-(4,4)"
    TRAN_DAU ||--|{ DANG_KY_THI_DAU : "có danh sách đăng ký (1,1)-(22,36)"

    TRONG_TAI ||--o{ PHAN_CONG_TRONG_TAI : "được phân công nhiệm vụ (0,N)"

    DANG_KY_THI_DAU ||--o{ SU_KIEN_TRAN_DAU : "phát sinh sự kiện (1,1)-(0,N)"

    SAN_VAN_DONG {
        string MaSan PK
        string TenSan UK
        string DiaChi
        int SucChua
        string KhuVuc
    }

    DOI_BONG {
        string MaDoi PK
        string TenDoi UK
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
        string MaCauThu FK, UK
        string MaDoiChuQuan FK
        string MaDoiHienTai FK, UK
        int SoAo UK
        date NgayBatDau
        date NgayKetThuc
        string TrangThai
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
        string TenVong UK
        int ThuTu UK
    }

    TRAN_DAU {
        string MaTran PK
        int MaVong FK
        string MaDoiNha FK
        string MaDoiKhach FK
        string MaSan FK
        timestamp NgayGio
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
        string MaTrongTai FK, UK
    }

    DANG_KY_THI_DAU {
        string MaTran PK, FK
        string MaCauThu PK, FK
        string MaDoi FK
        string VaiTroThiDau
        int SoAoDangKy
    }

    SU_KIEN_TRAN_DAU {
        string MaSuKien PK
        string MaTran FK
        string MaCauThu FK
        string LoaiSuKien
        int PhutGhiNhan
    }
```

---

## 2. SƠ ĐỒ LƯỢC ĐỒ QUAN HỆ VẬT LÝ SAU CHUẨN HÓA BCNF (RELATIONAL SCHEMA DIAGRAM)

```mermaid
classDiagram
    class SAN_VAN_DONG {
        +PK MaSan : VARCHAR(10)
        +UK TenSan : VARCHAR(100)
        DiaChi : VARCHAR(200)
        SucChua : INT
        KhuVuc : VARCHAR(20)
    }

    class DOI_BONG {
        +PK MaDoi : VARCHAR(10)
        +UK TenDoi : VARCHAR(100)
        HLV : VARCHAR(100)
        +FK MaSanNha : VARCHAR(10)
    }

    class MAU_AO_DOI_BONG {
        +PK, FK MaDoi : VARCHAR(10)
        +PK LoaiMauAo : VARCHAR(20)
        MoTaMau : VARCHAR(50)
    }

    class CAU_THU {
        +PK MaCauThu : VARCHAR(10)
        HoTen : VARCHAR(100)
        NgaySinh : DATE
        ViTri : VARCHAR(20)
        QuocTich : VARCHAR(50)
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
    }

    class TRONG_TAI {
        +PK MaTrongTai : VARCHAR(10)
        HoTen : VARCHAR(100)
        NgaySinh : DATE
        QueQuan : VARCHAR(100)
        CapBac : VARCHAR(50)
    }

    class VONG_DAU {
        +PK MaVong : INT
        +UK TenVong : VARCHAR(50)
        +UK ThuTu : INT
    }

    class TRAN_DAU {
        +PK MaTran : VARCHAR(10)
        +FK MaVong : INT
        +FK MaDoiNha : VARCHAR(10)
        +FK MaDoiKhach : VARCHAR(10)
        +FK MaSan : VARCHAR(10)
        NgayGio : TIMESTAMP
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
        VaiTroThiDau : VARCHAR(20)
        SoAoDangKy : INT
    }

    class SU_KIEN_TRAN_DAU {
        +PK MaSuKien : VARCHAR(15)
        +FK MaTran : VARCHAR(10)
        +FK MaCauThu : VARCHAR(10)
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
    CAU_THU "1" <-- "N" HOP_DONG_CAU_THU : MaCauThu
    CAU_THU "1" <-- "N" DANG_KY_THI_DAU : MaCauThu
    VONG_DAU "1" <-- "N" TRAN_DAU : MaVong
    TRAN_DAU "1" <-- "N" PHAN_CONG_TRONG_TAI : MaTran
    TRONG_TAI "1" <-- "N" PHAN_CONG_TRONG_TAI : MaTrongTai
    TRAN_DAU "1" <-- "N" DANG_KY_THI_DAU : MaTran
    DANG_KY_THI_DAU "1" <-- "N" SU_KIEN_TRAN_DAU : (MaTran, MaCauThu)
```

---

## 3. SƠ ĐỒ QUY TRÌNH NGHIỆP VỤ ĐIỀU HÀNH TRẬN ĐẤU

```mermaid
flowchart TD
    Start(["Bắt đầu mùa giải"]) --> Setup["1. Thiết lập 6 đội bóng, sân nhà, >= 2 màu áo & danh sách cầu thủ"]
    Setup --> CreateSchedule["2. Khởi tạo lịch thi đấu 10 vòng (30 trận vòng tròn 2 lượt)"]
    CreateSchedule --> AssignReferees["3. Phân công tổ 4 trọng tài cho từng trận (Kiểm tra: 1 TT tối đa 1 trận/vòng)"]
    AssignReferees --> PreMatch["4. Trước trận: Đăng ký 11 đá chính + tối đa 7 dự bị (Kiểm tra treo giò thẻ phạt)"]
    PreMatch --> MatchInPlay["5. Trận đấu diễn ra: Ghi nhận sự kiện (Bàn thắng, Thẻ vàng, Thẻ đỏ theo phút)"]
    MatchInPlay --> PostMatch["6. Kết thúc trận: Cập nhật tỉ số chung cuộc, số khán giả, giá vé"]
    PostMatch --> IntegrityCheck{"7. Trigger đối soát:\nTổng bàn thắng, thẻ khớp tỉ số?"}
    IntegrityCheck -- "Sai lệch" --> Rollback["Hủy bỏ cập nhật (Rollback)"]
    IntegrityCheck -- "Khớp đúng" --> CommitUpdate["Xác nhận lưu (Commit) & Trạng thái 'DaKetThuc'"]
    CommitUpdate --> AutoReport["8. Cập nhật Bảng xếp hạng, Top 10 phá lưới, Doanh thu sân & Lương trọng tài"]
    AutoReport --> EndMatch(["Hoàn tất trận đấu"])
```

---

## 4. SƠ ĐỒ KIẾN TRÚC CƠ SỞ DỮ LIỆU PHÂN TÁN (ZEROTIER VPN + POSTGRES_FDW)

```mermaid
flowchart TD
    subgraph Site0["TRẠM TRUNG TÂM (SITE 0: 10.147.17.10) - LIÊN ĐOÀN BÓNG ĐÁ"]
        DB0[("Cơ sở dữ liệu trung tâm\nsite0_trungtam")]
        GlobalViews["Khung nhìn tái thiết toàn cục:\nvw_global_san_van_dong\nvw_global_tran_dau\nvw_global_su_kien_tran_dau"]
        SecFrag["Mảnh phân dọc tài chính (Độc quyền):\nTRAN_DAU_DOANH_THU (MaTran, GiaVe, SoKhach)"]
        CentralCatalog["Bản gốc danh mục (Master):\nDOI_BONG, MAU_AO_DOI_BONG, CAU_THU,\nHOP_DONG_CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    subgraph Site1["CHI NHÁNH MIỀN BẮC (SITE 1: 10.147.17.11)"]
        DB1[("Cơ sở dữ liệu chi nhánh Bắc\nsite1_mienbac")]
        Frag1_San["Phân mảnh ngang nguyên thủy:\nSAN_VAN_DONG_1 (KhuVuc = 'MienBac': 4 sân)"]
        Frag1_Tran["Phân mảnh ngang dẫn xuất cấp 1:\nTRAN_DAU_CHUYEN_MON_1 (25 trận miền Bắc)"]
        Frag1_PK["Phân mảnh ngang dẫn xuất cấp 2:\nPHAN_CONG_TRONG_TAI_1\nDANG_KY_THI_DAU_1\nSU_KIEN_TRAN_DAU_1"]
        Replica1["Bản sao chỉ đọc (Read-Only Replica):\nDOI_BONG, MAU_AO_DOI_BONG, CAU_THU,\nHOP_DONG_CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    subgraph Site2["CHI NHÁNH MIỀN NAM (SITE 2: 10.147.17.12)"]
        DB2[("Cơ sở dữ liệu chi nhánh Nam\nsite2_miennam")]
        Frag2_San["Phân mảnh ngang nguyên thủy:\nSAN_VAN_DONG_2 (KhuVuc = 'MienNam': Sân Pleiku)"]
        Frag2_Tran["Phân mảnh ngang dẫn xuất cấp 1:\nTRAN_DAU_CHUYEN_MON_2 (5 trận sân Pleiku)"]
        Frag2_PK["Phân mảnh ngang dẫn xuất cấp 2:\nPHAN_CONG_TRONG_TAI_2\nDANG_KY_THI_DAU_2\nSU_KIEN_TRAN_DAU_2"]
        Replica2["Bản sao chỉ đọc (Read-Only Replica):\nDOI_BONG, MAU_AO_DOI_BONG, CAU_THU,\nHOP_DONG_CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    Site0 == "Nhân bản bất đồng bộ Chủ - Tớ & postgres_fdw (ZeroTier VPN)" ==> Site1
    Site0 == "Nhân bản bất đồng bộ Chủ - Tớ & postgres_fdw (ZeroTier VPN)" ==> Site2
```
