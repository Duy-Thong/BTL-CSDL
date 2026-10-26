-- ============================================================================
-- PHẦN 6: KỊCH BẢN MÔ PHỎNG CƠ SỞ DỮ LIỆU PHÂN TÁN TRÊN POSTGRESQL
-- SỬ DỤNG MULTI-SITE SCHEMA, PHÂN MẢNH HỖN HỢP & KHUNG NHÌN TÁI THIẾT TOÀN CỤC
-- HỆ QUẢN TRỊ: PostgreSQL
-- ============================================================================
-- LƯU Ý TRIỂN KHAI THỰC TẾ TRÊN 3 MÁY VẬT LÝ QUA MẠNG ZEROTIER VPN:
-- Khi triển khai trên 3 máy độc lập thuộc mạng ảo ZeroTier (dải 10.147.17.0/24):
--   + Máy Trạm 0 (Trung tâm): 10.147.17.10
--   + Máy Trạm 1 (Miền Bắc) : 10.147.17.11
--   + Máy Trạm 2 (Miền Nam) : 10.147.17.12
-- Tại Trạm 0, sử dụng tiện ích mở rộng postgres_fdw để ánh xạ bảng từ xa:
--   CREATE EXTENSION IF NOT EXISTS postgres_fdw;
--   CREATE SERVER srv_site1_mienbac FOREIGN DATA WRAPPER postgres_fdw
--       OPTIONS (host '10.147.17.11', port '5432', dbname 'vleague_bac');
--   CREATE SERVER srv_site2_miennam FOREIGN DATA WRAPPER postgres_fdw
--       OPTIONS (host '10.147.17.12', port '5432', dbname 'vleague_nam');
--   CREATE USER MAPPING FOR postgres SERVER srv_site1_mienbac
--       OPTIONS (user 'postgres', password 'secret_pwd');
--   CREATE USER MAPPING FOR postgres SERVER srv_site2_miennam
--       OPTIONS (user 'postgres', password 'secret_pwd');
--   IMPORT FOREIGN SCHEMA public FROM SERVER srv_site1_mienbac INTO site1_mienbac;
--   IMPORT FOREIGN SCHEMA public FROM SERVER srv_site2_miennam INTO site2_miennam;
-- Kịch bản dưới đây mô phỏng trực tiếp 3 Trạm bằng 3 Schema trên cùng một
-- thực thể PostgreSQL để thuận tiện kiểm thử tức thì toàn bộ đại số phân mảnh.
-- ============================================================================

-- Xóa các schema cũ nếu có
DROP SCHEMA IF EXISTS site0_trungtam CASCADE;
DROP SCHEMA IF EXISTS site1_mienbac CASCADE;
DROP SCHEMA IF EXISTS site2_miennam CASCADE;

-- Tạo 3 schema đại diện cho 3 Trạm trong mô hình phân tán
CREATE SCHEMA site0_trungtam; -- Trạm Trung tâm (Liên đoàn bóng đá / Ban Tổ chức giải)
CREATE SCHEMA site1_mienbac;  -- Trạm Điều hành Khu vực Miền Bắc (KhuVuc = 'MienBac')
CREATE SCHEMA site2_miennam;  -- Trạm Điều hành Khu vực Miền Nam (KhuVuc = 'MienNam')

-- ============================================================================
-- 1. NHÂN BẢN BẤT ĐỒNG BỘ CHỦ - TỚ (MASTER-SLAVE) CÁC BẢNG DANH MỤC
-- Bản gốc (Master) đặt tại Site 0; Bản sao chỉ đọc (Read-Only Replica) tại Site 1, 2
-- ============================================================================
CREATE TABLE site0_trungtam.DOI_BONG (LIKE public.DOI_BONG INCLUDING ALL);
CREATE TABLE site0_trungtam.MAU_AO_DOI_BONG (LIKE public.MAU_AO_DOI_BONG INCLUDING ALL);
CREATE TABLE site0_trungtam.CAU_THU (LIKE public.CAU_THU INCLUDING ALL);
CREATE TABLE site0_trungtam.HOP_DONG_CAU_THU (LIKE public.HOP_DONG_CAU_THU INCLUDING ALL);
CREATE TABLE site0_trungtam.TRONG_TAI (LIKE public.TRONG_TAI INCLUDING ALL);
CREATE TABLE site0_trungtam.VONG_DAU (LIKE public.VONG_DAU INCLUDING ALL);

CREATE TABLE site1_mienbac.DOI_BONG (LIKE public.DOI_BONG INCLUDING ALL);
CREATE TABLE site1_mienbac.MAU_AO_DOI_BONG (LIKE public.MAU_AO_DOI_BONG INCLUDING ALL);
CREATE TABLE site1_mienbac.CAU_THU (LIKE public.CAU_THU INCLUDING ALL);
CREATE TABLE site1_mienbac.HOP_DONG_CAU_THU (LIKE public.HOP_DONG_CAU_THU INCLUDING ALL);
CREATE TABLE site1_mienbac.TRONG_TAI (LIKE public.TRONG_TAI INCLUDING ALL);
CREATE TABLE site1_mienbac.VONG_DAU (LIKE public.VONG_DAU INCLUDING ALL);

CREATE TABLE site2_miennam.DOI_BONG (LIKE public.DOI_BONG INCLUDING ALL);
CREATE TABLE site2_miennam.MAU_AO_DOI_BONG (LIKE public.MAU_AO_DOI_BONG INCLUDING ALL);
CREATE TABLE site2_miennam.CAU_THU (LIKE public.CAU_THU INCLUDING ALL);
CREATE TABLE site2_miennam.HOP_DONG_CAU_THU (LIKE public.HOP_DONG_CAU_THU INCLUDING ALL);
CREATE TABLE site2_miennam.TRONG_TAI (LIKE public.TRONG_TAI INCLUDING ALL);
CREATE TABLE site2_miennam.VONG_DAU (LIKE public.VONG_DAU INCLUDING ALL);

-- Nạp bản gốc tại Site 0
INSERT INTO site0_trungtam.DOI_BONG SELECT * FROM public.DOI_BONG;
INSERT INTO site0_trungtam.MAU_AO_DOI_BONG SELECT * FROM public.MAU_AO_DOI_BONG;
INSERT INTO site0_trungtam.CAU_THU SELECT * FROM public.CAU_THU;
INSERT INTO site0_trungtam.HOP_DONG_CAU_THU SELECT * FROM public.HOP_DONG_CAU_THU;
INSERT INTO site0_trungtam.TRONG_TAI SELECT * FROM public.TRONG_TAI;
INSERT INTO site0_trungtam.VONG_DAU SELECT * FROM public.VONG_DAU;

-- Đồng bộ bản sao chỉ đọc từ Site 0 xuống Site 1 và Site 2
INSERT INTO site1_mienbac.DOI_BONG SELECT * FROM site0_trungtam.DOI_BONG;
INSERT INTO site1_mienbac.MAU_AO_DOI_BONG SELECT * FROM site0_trungtam.MAU_AO_DOI_BONG;
INSERT INTO site1_mienbac.CAU_THU SELECT * FROM site0_trungtam.CAU_THU;
INSERT INTO site1_mienbac.HOP_DONG_CAU_THU SELECT * FROM site0_trungtam.HOP_DONG_CAU_THU;
INSERT INTO site1_mienbac.TRONG_TAI SELECT * FROM site0_trungtam.TRONG_TAI;
INSERT INTO site1_mienbac.VONG_DAU SELECT * FROM site0_trungtam.VONG_DAU;

INSERT INTO site2_miennam.DOI_BONG SELECT * FROM site0_trungtam.DOI_BONG;
INSERT INTO site2_miennam.MAU_AO_DOI_BONG SELECT * FROM site0_trungtam.MAU_AO_DOI_BONG;
INSERT INTO site2_miennam.CAU_THU SELECT * FROM site0_trungtam.CAU_THU;
INSERT INTO site2_miennam.HOP_DONG_CAU_THU SELECT * FROM site0_trungtam.HOP_DONG_CAU_THU;
INSERT INTO site2_miennam.TRONG_TAI SELECT * FROM site0_trungtam.TRONG_TAI;
INSERT INTO site2_miennam.VONG_DAU SELECT * FROM site0_trungtam.VONG_DAU;

-- ============================================================================
-- 2. PHÂN MẢNH DỌC: TÁCH BẢNG TRAN_DAU THÀNH 2 MẢNH CHUYÊN MÔN VÀ DOANH THU
-- ============================================================================
-- Mảnh bảo mật tài chính (TRAN_DAU_DOANH_THU): Chỉ chứa MaTran (PK), GiaVe, SoKhach
-- Lưu trữ độc quyền tại Site 0 (Ban Tài chính - Kiểm toán giải đấu)
CREATE TABLE site0_trungtam.TRAN_DAU_DOANH_THU (
    MaTran VARCHAR(10) PRIMARY KEY,
    GiaVe DECIMAL(12, 2) NOT NULL CHECK (GiaVe >= 0),
    SoKhach INT NOT NULL DEFAULT 0 CHECK (SoKhach >= 0)
);

INSERT INTO site0_trungtam.TRAN_DAU_DOANH_THU (MaTran, GiaVe, SoKhach)
SELECT MaTran, GiaVe, SoKhach
FROM public.TRAN_DAU;

-- ============================================================================
-- 3. PHÂN MẢNH NGANG NGUYÊN THỦY: SAN_VAN_DONG THEO THUỘC TÍNH KHU VỰC
-- Vị từ phân mảnh: p1: KhuVuc = 'MienBac' ; p2: KhuVuc = 'MienNam'
-- ============================================================================
-- (A) Tại Site 1 (Miền Bắc): Các sân vận động có KhuVuc = 'MienBac'
CREATE TABLE site1_mienbac.SAN_VAN_DONG_1 (LIKE public.SAN_VAN_DONG INCLUDING ALL);
INSERT INTO site1_mienbac.SAN_VAN_DONG_1
SELECT * FROM public.SAN_VAN_DONG
WHERE KhuVuc = 'MienBac';

-- (B) Tại Site 2 (Miền Nam): Các sân vận động có KhuVuc = 'MienNam'
CREATE TABLE site2_miennam.SAN_VAN_DONG_2 (LIKE public.SAN_VAN_DONG INCLUDING ALL);
INSERT INTO site2_miennam.SAN_VAN_DONG_2
SELECT * FROM public.SAN_VAN_DONG
WHERE KhuVuc = 'MienNam';

-- ============================================================================
-- 4. PHÂN MẢNH NGANG DẪN XUẤT CẤP 1: TRAN_DAU_CHUYEN_MON (SEMI-JOIN VỚI SAN_VAN_DONG)
-- TRAN_DAU_CHUYEN_MON_i = TRAN_DAU_CHUYEN_MON SEMI-JOIN SAN_VAN_DONG_i ON MaSan
-- ============================================================================
-- (A) Tại Site 1 (Miền Bắc): 25 trận đấu diễn ra trên các sân thuộc SAN_VAN_DONG_1
CREATE TABLE site1_mienbac.TRAN_DAU_CHUYEN_MON_1 (
    MaTran VARCHAR(10) PRIMARY KEY,
    MaVong INT NOT NULL,
    MaDoiNha VARCHAR(10) NOT NULL,
    MaDoiKhach VARCHAR(10) NOT NULL,
    MaSan VARCHAR(10) NOT NULL REFERENCES site1_mienbac.SAN_VAN_DONG_1(MaSan),
    NgayGio TIMESTAMP NOT NULL,
    BanThangNha INT NOT NULL DEFAULT 0,
    BanThangKhach INT NOT NULL DEFAULT 0,
    TheVangNha INT NOT NULL DEFAULT 0,
    TheVangKhach INT NOT NULL DEFAULT 0,
    TheDoNha INT NOT NULL DEFAULT 0,
    TheDoKhach INT NOT NULL DEFAULT 0,
    TrangThai VARCHAR(20) NOT NULL
);

INSERT INTO site1_mienbac.TRAN_DAU_CHUYEN_MON_1
SELECT 
    t.MaTran, t.MaVong, t.MaDoiNha, t.MaDoiKhach, t.MaSan, t.NgayGio, 
    t.BanThangNha, t.BanThangKhach, t.TheVangNha, t.TheVangKhach, t.TheDoNha, t.TheDoKhach, t.TrangThai
FROM public.TRAN_DAU t
WHERE EXISTS (
    SELECT 1 FROM site1_mienbac.SAN_VAN_DONG_1 s WHERE s.MaSan = t.MaSan
);

-- (B) Tại Site 2 (Miền Nam): 5 trận đấu diễn ra trên các sân thuộc SAN_VAN_DONG_2
CREATE TABLE site2_miennam.TRAN_DAU_CHUYEN_MON_2 (
    MaTran VARCHAR(10) PRIMARY KEY,
    MaVong INT NOT NULL,
    MaDoiNha VARCHAR(10) NOT NULL,
    MaDoiKhach VARCHAR(10) NOT NULL,
    MaSan VARCHAR(10) NOT NULL REFERENCES site2_miennam.SAN_VAN_DONG_2(MaSan),
    NgayGio TIMESTAMP NOT NULL,
    BanThangNha INT NOT NULL DEFAULT 0,
    BanThangKhach INT NOT NULL DEFAULT 0,
    TheVangNha INT NOT NULL DEFAULT 0,
    TheVangKhach INT NOT NULL DEFAULT 0,
    TheDoNha INT NOT NULL DEFAULT 0,
    TheDoKhach INT NOT NULL DEFAULT 0,
    TrangThai VARCHAR(20) NOT NULL
);

INSERT INTO site2_miennam.TRAN_DAU_CHUYEN_MON_2
SELECT 
    t.MaTran, t.MaVong, t.MaDoiNha, t.MaDoiKhach, t.MaSan, t.NgayGio, 
    t.BanThangNha, t.BanThangKhach, t.TheVangNha, t.TheVangKhach, t.TheDoNha, t.TheDoKhach, t.TrangThai
FROM public.TRAN_DAU t
WHERE EXISTS (
    SELECT 1 FROM site2_miennam.SAN_VAN_DONG_2 s WHERE s.MaSan = t.MaSan
);

-- ============================================================================
-- 5. PHÂN MẢNH NGANG DẪN XUẤT CẤP 2 (SEMI-JOIN VỚI TRAN_DAU_CHUYEN_MON)
-- ============================================================================
-- (A) Tại Site 1 (Miền Bắc): Phân công trọng tài, đăng ký cầu thủ, sự kiện của 25 trận miền Bắc
CREATE TABLE site1_mienbac.PHAN_CONG_TRONG_TAI_1 (LIKE public.PHAN_CONG_TRONG_TAI INCLUDING ALL);
CREATE TABLE site1_mienbac.DANG_KY_THI_DAU_1 (LIKE public.DANG_KY_THI_DAU INCLUDING ALL);
CREATE TABLE site1_mienbac.SU_KIEN_TRAN_DAU_1 (LIKE public.SU_KIEN_TRAN_DAU INCLUDING ALL);

INSERT INTO site1_mienbac.PHAN_CONG_TRONG_TAI_1
SELECT pc.* FROM public.PHAN_CONG_TRONG_TAI pc
WHERE EXISTS (SELECT 1 FROM site1_mienbac.TRAN_DAU_CHUYEN_MON_1 t WHERE t.MaTran = pc.MaTran);

INSERT INTO site1_mienbac.DANG_KY_THI_DAU_1
SELECT dk.* FROM public.DANG_KY_THI_DAU dk
WHERE EXISTS (SELECT 1 FROM site1_mienbac.TRAN_DAU_CHUYEN_MON_1 t WHERE t.MaTran = dk.MaTran);

INSERT INTO site1_mienbac.SU_KIEN_TRAN_DAU_1
SELECT sk.* FROM public.SU_KIEN_TRAN_DAU sk
WHERE EXISTS (SELECT 1 FROM site1_mienbac.TRAN_DAU_CHUYEN_MON_1 t WHERE t.MaTran = sk.MaTran);

-- (B) Tại Site 2 (Miền Nam): Phân công trọng tài, đăng ký cầu thủ, sự kiện của 5 trận miền Nam
CREATE TABLE site2_miennam.PHAN_CONG_TRONG_TAI_2 (LIKE public.PHAN_CONG_TRONG_TAI INCLUDING ALL);
CREATE TABLE site2_miennam.DANG_KY_THI_DAU_2 (LIKE public.DANG_KY_THI_DAU INCLUDING ALL);
CREATE TABLE site2_miennam.SU_KIEN_TRAN_DAU_2 (LIKE public.SU_KIEN_TRAN_DAU INCLUDING ALL);

INSERT INTO site2_miennam.PHAN_CONG_TRONG_TAI_2
SELECT pc.* FROM public.PHAN_CONG_TRONG_TAI pc
WHERE EXISTS (SELECT 1 FROM site2_miennam.TRAN_DAU_CHUYEN_MON_2 t WHERE t.MaTran = pc.MaTran);

INSERT INTO site2_miennam.DANG_KY_THI_DAU_2
SELECT dk.* FROM public.DANG_KY_THI_DAU dk
WHERE EXISTS (SELECT 1 FROM site2_miennam.TRAN_DAU_CHUYEN_MON_2 t WHERE t.MaTran = dk.MaTran);

INSERT INTO site2_miennam.SU_KIEN_TRAN_DAU_2
SELECT sk.* FROM public.SU_KIEN_TRAN_DAU sk
WHERE EXISTS (SELECT 1 FROM site2_miennam.TRAN_DAU_CHUYEN_MON_2 t WHERE t.MaTran = sk.MaTran);

-- ============================================================================
-- 6. TÁI THIẾT DỮ LIỆU TOÀN CỤC TẠI TRẠM TRUNG TÂM (SITE 0)
-- Đảm bảo tính trong suốt phân mảnh bằng phép hợp (UNION ALL) và phép nối khóa chính
-- ============================================================================
-- (A) Khung nhìn toàn cục tái thiết SÂN VẬN ĐỘNG
CREATE OR REPLACE VIEW site0_trungtam.vw_global_san_van_dong AS
SELECT * FROM site1_mienbac.SAN_VAN_DONG_1
UNION ALL
SELECT * FROM site2_miennam.SAN_VAN_DONG_2;

-- (B) Khung nhìn toàn cục tái thiết TRẬN ĐẤU (Phép hợp ngang + Phép nối dọc trên MaTran)
CREATE OR REPLACE VIEW site0_trungtam.vw_global_tran_dau AS
SELECT 
    cm.MaTran, cm.MaVong, cm.MaDoiNha, cm.MaDoiKhach, cm.MaSan, cm.NgayGio,
    dt.GiaVe, dt.SoKhach,
    cm.BanThangNha, cm.BanThangKhach, cm.TheVangNha, cm.TheVangKhach, 
    cm.TheDoNha, cm.TheDoKhach, cm.TrangThai
FROM (
    SELECT * FROM site1_mienbac.TRAN_DAU_CHUYEN_MON_1
    UNION ALL
    SELECT * FROM site2_miennam.TRAN_DAU_CHUYEN_MON_2
) cm
JOIN site0_trungtam.TRAN_DAU_DOANH_THU dt ON cm.MaTran = dt.MaTran;

-- (C) Khung nhìn toàn cục tái thiết PHÂN CÔNG TRỌNG TÀI, ĐĂNG KÝ THI ĐẤU & SỰ KIỆN TRẬN ĐẤU
CREATE OR REPLACE VIEW site0_trungtam.vw_global_phan_cong_trong_tai AS
SELECT * FROM site1_mienbac.PHAN_CONG_TRONG_TAI_1
UNION ALL
SELECT * FROM site2_miennam.PHAN_CONG_TRONG_TAI_2;

CREATE OR REPLACE VIEW site0_trungtam.vw_global_dang_ky_thi_dau AS
SELECT * FROM site1_mienbac.DANG_KY_THI_DAU_1
UNION ALL
SELECT * FROM site2_miennam.DANG_KY_THI_DAU_2;

CREATE OR REPLACE VIEW site0_trungtam.vw_global_su_kien_tran_dau AS
SELECT * FROM site1_mienbac.SU_KIEN_TRAN_DAU_1
UNION ALL
SELECT * FROM site2_miennam.SU_KIEN_TRAN_DAU_2;

-- ============================================================================
-- 7. KIỂM THỬ TRUY VẤN TRONG SUỐT PHÂN TÁN TẠI TRẠM TRUNG TÂM (SITE 0)
-- ============================================================================
-- 7.1. Kiểm tra tính đầy đủ và tính tách biệt của phân mảnh trận đấu
SELECT 'Site 1 (Miền Bắc)' AS Tram, COUNT(*) AS SoTran FROM site1_mienbac.TRAN_DAU_CHUYEN_MON_1
UNION ALL
SELECT 'Site 2 (Miền Nam)' AS Tram, COUNT(*) AS SoTran FROM site2_miennam.TRAN_DAU_CHUYEN_MON_2
UNION ALL
SELECT 'Site 0 (Tái thiết toàn cục)' AS Tram, COUNT(*) AS SoTran FROM site0_trungtam.vw_global_tran_dau;

-- 7.2. Truy vấn Top 10 Vua phá lưới toàn giải trên kiến trúc phân tán (Tối ưu đẩy phép gom nhóm xuống từng Trạm)
WITH BanThangPhanTan AS (
    SELECT local_agg.MaCauThu, SUM(local_agg.SoBan) AS TongBanThang
    FROM (
        SELECT sk1.MaCauThu, COUNT(*) AS SoBan
        FROM site1_mienbac.SU_KIEN_TRAN_DAU_1 sk1
        WHERE sk1.LoaiSuKien = 'BanThang'
        GROUP BY sk1.MaCauThu
        UNION ALL
        SELECT sk2.MaCauThu, COUNT(*) AS SoBan
        FROM site2_miennam.SU_KIEN_TRAN_DAU_2 sk2
        WHERE sk2.LoaiSuKien = 'BanThang'
        GROUP BY sk2.MaCauThu
    ) local_agg
    GROUP BY local_agg.MaCauThu
),
DoiBongHienTai AS (
    SELECT DISTINCT ON (hd.MaCauThu)
        hd.MaCauThu,
        db.TenDoi
    FROM site0_trungtam.HOP_DONG_CAU_THU hd
    JOIN site0_trungtam.DOI_BONG db ON hd.MaDoiHienTai = db.MaDoi
    WHERE hd.TrangThai IN ('ChinhThuc', 'ChoMuon')
    ORDER BY hd.MaCauThu, hd.NgayBatDau DESC
)
SELECT
    ROW_NUMBER() OVER (ORDER BY b.TongBanThang DESC, ct.HoTen ASC) AS XepHang,
    ct.MaCauThu,
    ct.HoTen,
    COALESCE(d.TenDoi, 'Tự do') AS TenDoiHienTai,
    b.TongBanThang
FROM BanThangPhanTan b
JOIN site0_trungtam.CAU_THU ct ON b.MaCauThu = ct.MaCauThu
LEFT JOIN DoiBongHienTai d ON b.MaCauThu = d.MaCauThu
ORDER BY b.TongBanThang DESC, ct.HoTen ASC
LIMIT 10;

-- 7.3. Kiểm toán doanh thu bán vé toàn giải tại Site 0 (Kết hợp mảnh dọc tại Site 0 và mảnh ngang từ Site 1, 2)
SELECT 
    s.TenSan,
    s.KhuVuc,
    COUNT(t.MaTran) AS SoTranDaDau,
    SUM(t.SoKhach) AS TongKhanGia,
    SUM(t.SoKhach * t.GiaVe) AS TongDoanhThuVe
FROM site0_trungtam.vw_global_tran_dau t
JOIN site0_trungtam.vw_global_san_van_dong s ON t.MaSan = s.MaSan
WHERE t.TrangThai = 'DaKetThuc'
GROUP BY s.TenSan, s.KhuVuc
ORDER BY TongDoanhThuVe DESC;
