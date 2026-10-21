-- ============================================================================
-- PHẦN 6: KỊCH BẢN MÔ PHỎNG CƠ SỞ DỮ LIỆU PHÂN TÁN TRÊN POSTGRESQL
-- SỬ DỤNG SCHEMA-BASED MULTI-SITE VÀ FOREIGN DATA WRAPPER (POSTGRES_FDW)
-- HỆ QUẢN TRỊ: PostgreSQL
-- ============================================================================

-- Xóa các schema cũ nếu có
DROP SCHEMA IF EXISTS site0_trungtam CASCADE;
DROP SCHEMA IF EXISTS site1_mienbac CASCADE;
DROP SCHEMA IF EXISTS site2_miennam CASCADE;

-- Tạo 3 schema đại diện cho 3 Trạm trong mô hình phân tán
CREATE SCHEMA site0_trungtam; -- Trạm Trung tâm (Liên đoàn bóng đá)
CREATE SCHEMA site1_mienbac;  -- Chi nhánh Miền Bắc (Hà Nội, Lạch Tray, Thiên Trường...)
CREATE SCHEMA site2_miennam;  -- Chi nhánh Miền Nam (Pleiku...)

-- ============================================================================
-- 1. TẠO CÁC BẢNG NHÂN BẢN (REPLICATION) TRÊN CẢ 3 TRẠM
-- ============================================================================
-- Danh mục dùng chung: DOI_BONG, MAU_AO_DOI_BONG, CAU_THU, TRONG_TAI, VONG_DAU
CREATE TABLE site1_mienbac.DOI_BONG (LIKE public.DOI_BONG INCLUDING ALL);
CREATE TABLE site1_mienbac.CAU_THU (LIKE public.CAU_THU INCLUDING ALL);
CREATE TABLE site1_mienbac.TRONG_TAI (LIKE public.TRONG_TAI INCLUDING ALL);
CREATE TABLE site1_mienbac.VONG_DAU (LIKE public.VONG_DAU INCLUDING ALL);

CREATE TABLE site2_miennam.DOI_BONG (LIKE public.DOI_BONG INCLUDING ALL);
CREATE TABLE site2_miennam.CAU_THU (LIKE public.CAU_THU INCLUDING ALL);
CREATE TABLE site2_miennam.TRONG_TAI (LIKE public.TRONG_TAI INCLUDING ALL);
CREATE TABLE site2_miennam.VONG_DAU (LIKE public.VONG_DAU INCLUDING ALL);

-- Sao chép dữ liệu danh mục sang Site 1 và Site 2 (Nhân bản toàn phần)
INSERT INTO site1_mienbac.DOI_BONG SELECT * FROM public.DOI_BONG;
INSERT INTO site1_mienbac.CAU_THU SELECT * FROM public.CAU_THU;
INSERT INTO site1_mienbac.TRONG_TAI SELECT * FROM public.TRONG_TAI;
INSERT INTO site1_mienbac.VONG_DAU SELECT * FROM public.VONG_DAU;

INSERT INTO site2_miennam.DOI_BONG SELECT * FROM public.DOI_BONG;
INSERT INTO site2_miennam.CAU_THU SELECT * FROM public.CAU_THU;
INSERT INTO site2_miennam.TRONG_TAI SELECT * FROM public.TRONG_TAI;
INSERT INTO site2_miennam.VONG_DAU SELECT * FROM public.VONG_DAU;

-- ============================================================================
-- 2. PHÂN MẢNH NGANG NGUYÊN THỦY: SAN_VAN_DONG VÀ TRAN_DAU
-- ============================================================================
-- (A) Tại Site 1 (Miền Bắc): Lưu các sân miền Bắc và các trận đấu diễn ra tại miền Bắc
CREATE TABLE site1_mienbac.SAN_VAN_DONG_1 (LIKE public.SAN_VAN_DONG INCLUDING ALL);
CREATE TABLE site1_mienbac.TRAN_DAU_1 (LIKE public.TRAN_DAU INCLUDING ALL);

INSERT INTO site1_mienbac.SAN_VAN_DONG_1
SELECT * FROM public.SAN_VAN_DONG
WHERE MaSan IN ('SAN_HD', 'SAN_MD', 'SAN_LT', 'SAN_TT');

INSERT INTO site1_mienbac.TRAN_DAU_1
SELECT * FROM public.TRAN_DAU
WHERE MaSan IN ('SAN_HD', 'SAN_MD', 'SAN_LT', 'SAN_TT');

-- (B) Tại Site 2 (Miền Nam): Lưu các sân miền Nam và các trận đấu diễn ra tại sân Pleiku
CREATE TABLE site2_miennam.SAN_VAN_DONG_2 (LIKE public.SAN_VAN_DONG INCLUDING ALL);
CREATE TABLE site2_miennam.TRAN_DAU_2 (LIKE public.TRAN_DAU INCLUDING ALL);

INSERT INTO site2_miennam.SAN_VAN_DONG_2
SELECT * FROM public.SAN_VAN_DONG
WHERE MaSan IN ('SAN_PK');

INSERT INTO site2_miennam.TRAN_DAU_2
SELECT * FROM public.TRAN_DAU
WHERE MaSan IN ('SAN_PK');

-- ============================================================================
-- 3. PHÂN MẢNH NGANG DẪN XUẤT (SEMI-JOIN VỚI TRAN_DAU)
-- ============================================================================
-- (A) Tại Site 1: Phân công trọng tài, đăng ký cầu thủ, sự kiện của các trận miền Bắc
CREATE TABLE site1_mienbac.PHAN_CONG_TRONG_TAI_1 (LIKE public.PHAN_CONG_TRONG_TAI INCLUDING ALL);
CREATE TABLE site1_mienbac.DANG_KY_THI_DAU_1 (LIKE public.DANG_KY_THI_DAU INCLUDING ALL);
CREATE TABLE site1_mienbac.SU_KIEN_TRAN_DAU_1 (LIKE public.SU_KIEN_TRAN_DAU INCLUDING ALL);

INSERT INTO site1_mienbac.PHAN_CONG_TRONG_TAI_1
SELECT pc.* FROM public.PHAN_CONG_TRONG_TAI pc
JOIN site1_mienbac.TRAN_DAU_1 t ON pc.MaTran = t.MaTran;

INSERT INTO site1_mienbac.DANG_KY_THI_DAU_1
SELECT dk.* FROM public.DANG_KY_THI_DAU dk
JOIN site1_mienbac.TRAN_DAU_1 t ON dk.MaTran = t.MaTran;

INSERT INTO site1_mienbac.SU_KIEN_TRAN_DAU_1
SELECT sk.* FROM public.SU_KIEN_TRAN_DAU sk
JOIN site1_mienbac.TRAN_DAU_1 t ON sk.MaTran = t.MaTran;

-- (B) Tại Site 2: Các trận thuộc sân Pleiku
CREATE TABLE site2_miennam.PHAN_CONG_TRONG_TAI_2 (LIKE public.PHAN_CONG_TRONG_TAI INCLUDING ALL);
CREATE TABLE site2_miennam.DANG_KY_THI_DAU_2 (LIKE public.DANG_KY_THI_DAU INCLUDING ALL);
CREATE TABLE site2_miennam.SU_KIEN_TRAN_DAU_2 (LIKE public.SU_KIEN_TRAN_DAU INCLUDING ALL);

INSERT INTO site2_miennam.PHAN_CONG_TRONG_TAI_2
SELECT pc.* FROM public.PHAN_CONG_TRONG_TAI pc
JOIN site2_miennam.TRAN_DAU_2 t ON pc.MaTran = t.MaTran;

INSERT INTO site2_miennam.DANG_KY_THI_DAU_2
SELECT dk.* FROM public.DANG_KY_THI_DAU dk
JOIN site2_miennam.TRAN_DAU_2 t ON dk.MaTran = t.MaTran;

INSERT INTO site2_miennam.SU_KIEN_TRAN_DAU_2
SELECT sk.* FROM public.SU_KIEN_TRAN_DAU sk
JOIN site2_miennam.TRAN_DAU_2 t ON sk.MaTran = t.MaTran;

-- ============================================================================
-- 4. PHÂN MẢNH DỌC: HOP_DONG_CAU_THU
-- ============================================================================
-- Mảnh 1 (Chuyên môn thi đấu): Không chứa mức lương -> Phân phối tới các chi nhánh
CREATE TABLE site1_mienbac.HOP_DONG_THI_DAU AS
SELECT MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai
FROM public.HOP_DONG_CAU_THU;

CREATE TABLE site2_miennam.HOP_DONG_THI_DAU AS
SELECT MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai
FROM public.HOP_DONG_CAU_THU;

-- Mảnh 2 (Bảo mật tài chính): Chỉ lưu tại Site 0 (Trung tâm)
CREATE TABLE site0_trungtam.HOP_DONG_TAI_CHINH AS
SELECT MaHD, MucLuong
FROM public.HOP_DONG_CAU_THU;

-- ============================================================================
-- 5. TÁI THIẾT DỮ LIỆU TOÀN CỤC TẠI TRẠM TRUNG TÂM (SITE 0)
-- Bằng cách sử dụng các View hợp (UNION ALL) và kết nối tự nhiên (NATURAL JOIN)
-- ============================================================================
-- (A) Khung nhìn toàn cục tái thiết SÂN VẬN ĐỘNG
CREATE OR REPLACE VIEW site0_trungtam.vw_global_san_van_dong AS
SELECT * FROM site1_mienbac.SAN_VAN_DONG_1
UNION ALL
SELECT * FROM site2_miennam.SAN_VAN_DONG_2;

-- (B) Khung nhìn toàn cục tái thiết TRẬN ĐẤU (30 trận)
CREATE OR REPLACE VIEW site0_trungtam.vw_global_tran_dau AS
SELECT * FROM site1_mienbac.TRAN_DAU_1
UNION ALL
SELECT * FROM site2_miennam.TRAN_DAU_2;

-- (C) Khung nhìn toàn cục tái thiết SỰ KIỆN TRẬN ĐẤU
CREATE OR REPLACE VIEW site0_trungtam.vw_global_su_kien_tran_dau AS
SELECT * FROM site1_mienbac.SU_KIEN_TRAN_DAU_1
UNION ALL
SELECT * FROM site2_miennam.SU_KIEN_TRAN_DAU_2;

-- (D) Khung nhìn toàn cục tái thiết HỢP ĐỒNG CẦU THỦ (Tái thiết từ 2 mảnh dọc)
CREATE OR REPLACE VIEW site0_trungtam.vw_global_hop_dong_cau_thu AS
SELECT 
    td.MaHD, td.MaCauThu, td.MaDoiChuQuan, td.MaDoiHienTai, 
    td.SoAo, td.NgayBatDau, td.NgayKetThuc, td.TrangThai, 
    tc.MucLuong
FROM site1_mienbac.HOP_DONG_THI_DAU td
JOIN site0_trungtam.HOP_DONG_TAI_CHINH tc ON td.MaHD = tc.MaHD;

-- ============================================================================
-- 6. KIỂM THỬ TRUY VẤN TRONG SUỐT TRÊN HỆ THỐNG PHÂN TÁN
-- ============================================================================
-- Truy vấn số lượng trận đấu phân tán tại mỗi chi nhánh:
-- Site 1 (Miền Bắc): Kỳ vọng 25 trận
SELECT 'Site 1 (Miền Bắc)' AS Tram, COUNT(*) AS SoTran FROM site1_mienbac.TRAN_DAU_1
UNION ALL
-- Site 2 (Miền Nam): Kỳ vọng 5 trận
SELECT 'Site 2 (Miền Nam)' AS Tram, COUNT(*) AS SoTran FROM site2_miennam.TRAN_DAU_2
UNION ALL
-- Site 0 (Tổng hợp toàn quốc qua Global View): Kỳ vọng 30 trận
SELECT 'Site 0 (Toàn cục)' AS Tram, COUNT(*) AS SoTran FROM site0_trungtam.vw_global_tran_dau;
