-- ============================================================================
-- HỌC VIỆN CÔNG NGHỆ BƯU CHÍNH VIỄN THÔNG
-- BÀI TẬP LỚN: CÁC HỆ THỐNG CƠ SỞ DỮ LIỆU (MÃ HP: B26CHHT...)
-- ĐỀ TÀI: XÂY DỰNG HỆ CƠ SỞ DỮ LIỆU QUẢN LÝ MỘT GIẢI BÓNG ĐÁ CHUYÊN NGHIỆP
-- GIẢNG VIÊN HƯỚNG DẪN: TS. PHAN THỊ HÀ
-- TOÀN BỘ KỊCH BẢN CƠ SỞ DỮ LIỆU TẬP TRUNG VÀ PHÂN TÁN (POSTGRESQL)
-- ============================================================================



-- >>> FILE: 01_schema_ddl.sql <<<

-- ============================================================================
-- HỆ CƠ SỞ DỮ LIỆU QUẢN LÝ GIẢI BÓNG ĐÁ CHUYÊN NGHIỆP
-- MÔN HỌC: CÁC HỆ THỐNG CƠ SỞ DỮ LIỆU - MÃ LỚP: M26CQ02 (NHÓM 2)
-- PHẦN 1: DDL TẠO BẢNG, KHÓA CHÍNH, KHÓA NGOẠI VÀ RÀNG BUỘC TOÀN VẸN
-- HỆ QUẢN TRỊ: PostgreSQL
-- ============================================================================

-- Xóa các bảng cũ nếu đã tồn tại (theo thứ tự phụ thuộc khóa ngoại)
DROP TABLE IF EXISTS SU_KIEN_TRAN_DAU CASCADE;
DROP TABLE IF EXISTS DANG_KY_THI_DAU CASCADE;
DROP TABLE IF EXISTS PHAN_CONG_TRONG_TAI CASCADE;
DROP TABLE IF EXISTS TRAN_DAU CASCADE;
DROP TABLE IF EXISTS VONG_DAU CASCADE;
DROP TABLE IF EXISTS TRONG_TAI CASCADE;
DROP TABLE IF EXISTS HOP_DONG_CAU_THU CASCADE;
DROP TABLE IF EXISTS CAU_THU CASCADE;
DROP TABLE IF EXISTS MAU_AO_DOI_BONG CASCADE;
DROP TABLE IF EXISTS DOI_BONG CASCADE;
DROP TABLE IF EXISTS SAN_VAN_DONG CASCADE;

-- 1. BẢNG SÂN VẬN ĐỘNG
CREATE TABLE SAN_VAN_DONG (
    MaSan VARCHAR(10) PRIMARY KEY,
    TenSan VARCHAR(100) NOT NULL UNIQUE,
    DiaChi VARCHAR(200) NOT NULL,
    SucChua INT NOT NULL CHECK (SucChua > 0),
    KhuVuc VARCHAR(20) NOT NULL DEFAULT 'MienBac' CHECK (KhuVuc IN ('MienBac', 'MienNam'))
);

-- 2. BẢNG ĐỘI BÓNG
CREATE TABLE DOI_BONG (
    MaDoi VARCHAR(10) PRIMARY KEY,
    TenDoi VARCHAR(100) NOT NULL UNIQUE,
    HLV VARCHAR(100) NOT NULL,
    MaSanNha VARCHAR(10) NOT NULL REFERENCES SAN_VAN_DONG(MaSan) ON UPDATE CASCADE
);

-- 3. BẢNG MÀU ÁO ĐỘI BÓNG (Tối thiểu 2 màu áo mỗi đội)
CREATE TABLE MAU_AO_DOI_BONG (
    MaDoi VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON DELETE CASCADE ON UPDATE CASCADE,
    LoaiMauAo VARCHAR(20) NOT NULL CHECK (LoaiMauAo IN ('SanNha', 'SanKhach', 'Phu')),
    MoTaMau VARCHAR(50) NOT NULL,
    PRIMARY KEY (MaDoi, LoaiMauAo)
);

-- 4. BẢNG CẦU THỦ
CREATE TABLE CAU_THU (
    MaCauThu VARCHAR(10) PRIMARY KEY,
    HoTen VARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    ViTri VARCHAR(20) NOT NULL CHECK (ViTri IN ('ThuMon', 'HauVe', 'TienVe', 'TienDao')),
    QuocTich VARCHAR(50) NOT NULL DEFAULT 'Việt Nam'
);

-- 5. BẢNG HỢP ĐỒNG CẦU THỦ & ĐỘI BÓNG THI ĐẤU
-- Lưu trữ toàn bộ lịch sử hợp đồng (Chính thức, Cho mượn, Đã thanh lý)
CREATE TABLE HOP_DONG_CAU_THU (
    MaHD VARCHAR(10) PRIMARY KEY,
    MaCauThu VARCHAR(10) NOT NULL REFERENCES CAU_THU(MaCauThu) ON UPDATE CASCADE,
    MaDoiChuQuan VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    MaDoiHienTai VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    SoAo INT NOT NULL CHECK (SoAo BETWEEN 1 AND 35),
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    TrangThai VARCHAR(20) NOT NULL CHECK (TrangThai IN ('ChinhThuc', 'ChoMuon', 'TamDung', 'ThanhLy')),
    CHECK (NgayKetThuc >= NgayBatDau)
);

-- Chỉ mục duy nhất có điều kiện (Partial Unique Index) cho các hợp đồng đang hiệu lực:
-- 1. Tại một thời điểm, mỗi cầu thủ chỉ có tối đa 1 hợp đồng đang thi đấu ('ChinhThuc' hoặc 'ChoMuon')
CREATE UNIQUE INDEX idx_uq_cauthu_active_contract 
ON HOP_DONG_CAU_THU (MaCauThu) 
WHERE TrangThai IN ('ChinhThuc', 'ChoMuon');

-- 2. Trong cùng một đội bóng, không có 2 cầu thủ nào trùng số áo trong các hợp đồng đang hiệu lực
CREATE UNIQUE INDEX idx_uq_doihientai_soao_active 
ON HOP_DONG_CAU_THU (MaDoiHienTai, SoAo) 
WHERE TrangThai IN ('ChinhThuc', 'ChoMuon');

-- 6. BẢNG TRỌNG TÀI
CREATE TABLE TRONG_TAI (
    MaTrongTai VARCHAR(10) PRIMARY KEY,
    HoTen VARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    QueQuan VARCHAR(100) NOT NULL,
    CapBac VARCHAR(50) NOT NULL DEFAULT 'Quốc gia'
);

-- 7. BẢNG VÒNG ĐẤU (10 vòng đấu mùa giải)
CREATE TABLE VONG_DAU (
    MaVong INT PRIMARY KEY CHECK (MaVong BETWEEN 1 AND 10),
    TenVong VARCHAR(50) NOT NULL UNIQUE,
    ThuTu INT NOT NULL UNIQUE CHECK (ThuTu BETWEEN 1 AND 10)
);

-- 8. BẢNG TRẬN ĐẤU
CREATE TABLE TRAN_DAU (
    MaTran VARCHAR(10) PRIMARY KEY,
    MaVong INT NOT NULL REFERENCES VONG_DAU(MaVong) ON UPDATE CASCADE,
    MaDoiNha VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    MaDoiKhach VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    MaSan VARCHAR(10) NOT NULL REFERENCES SAN_VAN_DONG(MaSan) ON UPDATE CASCADE,
    NgayGio TIMESTAMP NOT NULL,
    GiaVe DECIMAL(12, 2) NOT NULL DEFAULT 50000 CHECK (GiaVe >= 0),
    SoKhach INT DEFAULT 0 CHECK (SoKhach >= 0),
    BanThangNha INT DEFAULT 0 CHECK (BanThangNha >= 0),
    BanThangKhach INT DEFAULT 0 CHECK (BanThangKhach >= 0),
    TheVangNha INT DEFAULT 0 CHECK (TheVangNha >= 0),
    TheVangKhach INT DEFAULT 0 CHECK (TheVangKhach >= 0),
    TheDoNha INT DEFAULT 0 CHECK (TheDoNha >= 0),
    TheDoKhach INT DEFAULT 0 CHECK (TheDoKhach >= 0),
    TrangThai VARCHAR(20) NOT NULL DEFAULT 'ChuaDienRa' CHECK (TrangThai IN ('ChuaDienRa', 'DaKetThuc')),
    CHECK (MaDoiNha <> MaDoiKhach),
    UNIQUE (MaDoiNha, MaDoiKhach),
    UNIQUE (MaVong, MaDoiNha),
    UNIQUE (MaVong, MaDoiKhach)
);

-- 9. BẢNG PHÂN CÔNG TRỌNG TÀI (Đủ 4 trọng tài cho mỗi trận)
CREATE TABLE PHAN_CONG_TRONG_TAI (
    MaTran VARCHAR(10) NOT NULL REFERENCES TRAN_DAU(MaTran) ON DELETE CASCADE ON UPDATE CASCADE,
    VaiTro VARCHAR(20) NOT NULL CHECK (VaiTro IN ('Chinh', 'Bien1', 'Bien2', 'Ban')),
    MaTrongTai VARCHAR(10) NOT NULL REFERENCES TRONG_TAI(MaTrongTai) ON UPDATE CASCADE,
    PRIMARY KEY (MaTran, VaiTro),
    UNIQUE (MaTran, MaTrongTai)
);

-- 10. BẢNG ĐĂNG KÝ THI ĐẤU (Tối đa 18 cầu thủ mỗi đội trong trận)
CREATE TABLE DANG_KY_THI_DAU (
    MaTran VARCHAR(10) NOT NULL REFERENCES TRAN_DAU(MaTran) ON DELETE CASCADE ON UPDATE CASCADE,
    MaCauThu VARCHAR(10) NOT NULL REFERENCES CAU_THU(MaCauThu) ON UPDATE CASCADE,
    MaDoi VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    VaiTroThiDau VARCHAR(20) NOT NULL CHECK (VaiTroThiDau IN ('ChinhThuc', 'DuBi')),
    SoAoDangKy INT NOT NULL CHECK (SoAoDangKy BETWEEN 1 AND 35),
    PRIMARY KEY (MaTran, MaCauThu),
    UNIQUE (MaTran, MaDoi, SoAoDangKy)
);

-- 11. BẢNG SỰ KIỆN TRẬN ĐẤU (Đã chuẩn hóa BCNF: Loại bỏ MaDoi dư thừa, tham chiếu tổ hợp tới DANG_KY_THI_DAU)
CREATE TABLE SU_KIEN_TRAN_DAU (
    MaSuKien VARCHAR(15) PRIMARY KEY,
    MaTran VARCHAR(10) NOT NULL,
    MaCauThu VARCHAR(10) NOT NULL,
    LoaiSuKien VARCHAR(20) NOT NULL CHECK (LoaiSuKien IN ('BanThang', 'PhanLuoi', 'TheVang', 'TheDo')),
    PhutGhiNhan INT NOT NULL CHECK (PhutGhiNhan BETWEEN 1 AND 120),
    FOREIGN KEY (MaTran, MaCauThu) REFERENCES DANG_KY_THI_DAU(MaTran, MaCauThu) ON DELETE CASCADE ON UPDATE CASCADE
);

-- TẠO CHỈ MỤC (INDEX) ĐỂ TỐI ƯU TRUY VẤN
CREATE INDEX idx_tran_dau_vong ON TRAN_DAU(MaVong);
CREATE INDEX idx_tran_dau_san_ngaygio ON TRAN_DAU(MaSan, NgayGio);
CREATE INDEX idx_tran_dau_doinha ON TRAN_DAU(MaDoiNha);
CREATE INDEX idx_tran_dau_doikhach ON TRAN_DAU(MaDoiKhach);
CREATE INDEX idx_hopdong_doihientai ON HOP_DONG_CAU_THU(MaDoiHienTai);
CREATE INDEX idx_sukien_tran_cauthu ON SU_KIEN_TRAN_DAU(MaTran, MaCauThu);
CREATE INDEX idx_dangky_tran_doi ON DANG_KY_THI_DAU(MaTran, MaDoi);


-- >>> FILE: 02_triggers.sql <<<

-- ============================================================================
-- PHẦN 2: CÀI ĐẶT 5 TRIGGER BẮT BUỘC KIỂM TRA TOÀN VẸN NGHIỆP VỤ & ĐIỀU KHIỂN TƯƠNG TRANH
-- HỆ QUẢN TRỊ: PostgreSQL (PL/pgSQL) - Kiểm soát tương tranh đa phiên bản (MVCC)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRIGGER 1: KIỂM TRA QUY ĐỊNH SÂN ĐẤU, SỨC CHỨA VÀ THỜI GIAN THI ĐẤU
-- Bảng áp dụng: TRAN_DAU
-- Nghiệp vụ: Số khán giả không vượt sức chứa; trận đấu kết thúc không ở tương lai;
--            hai trận đấu trên cùng một sân phải cách nhau tối thiểu 4 giờ.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_quy_dinh_san_dau()
RETURNS TRIGGER AS $$
DECLARE
    v_suc_chua INT;
    v_so_tran_trung_gio INT;
BEGIN
    -- Khóa dòng sân vận động (Row-level lock) để tuần tự hóa các giao dịch xếp lịch đồng thời
    SELECT SucChua INTO v_suc_chua
    FROM SAN_VAN_DONG
    WHERE MaSan = NEW.MaSan
    FOR NO KEY UPDATE;

    -- 1. Kiểm tra sức chứa khán đài
    IF NEW.SoKhach > v_suc_chua THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Số lượng khán giả (%) vượt quá sức chứa sân vận động (%)!',
            NEW.SoKhach, v_suc_chua;
    END IF;

    -- 2. Kiểm tra tính hợp lệ về thời gian khi kết thúc trận
    IF NEW.TrangThai = 'DaKetThuc' AND NEW.NgayGio > CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Trận đấu có thời điểm diễn ra ở tương lai không thể có trạng thái DaKetThuc!';
    END IF;

    -- 3. Kiểm tra khoảng cách 4 giờ trên cùng sân vận động (sử dụng chỉ mục B-Tree idx_tran_dau_san_ngaygio)
    SELECT COUNT(*) INTO v_so_tran_trung_gio
    FROM TRAN_DAU
    WHERE MaSan = NEW.MaSan
      AND MaTran <> NEW.MaTran
      AND NgayGio > NEW.NgayGio - INTERVAL '4 hours'
      AND NgayGio < NEW.NgayGio + INTERVAL '4 hours';

    IF v_so_tran_trung_gio > 0 THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Sân vận động % đã có trận đấu khác diễn ra trong khoảng 4 giờ lân cận!', 
            NEW.MaSan;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_quy_dinh_san_dau ON TRAN_DAU;
CREATE TRIGGER trg_check_quy_dinh_san_dau
BEFORE INSERT OR UPDATE OF MaSan, NgayGio, SoKhach, TrangThai
ON TRAN_DAU
FOR EACH ROW
EXECUTE FUNCTION fn_check_quy_dinh_san_dau();


-- ----------------------------------------------------------------------------
-- TRIGGER 2: KIỂM TRA HỢP ĐỒNG CẦU THỦ, SỐ ÁO VÀ GIỚI HẠN TỐI ĐA 30 CẦU THỦ
-- Bảng áp dụng: HOP_DONG_CAU_THU
-- Nghiệp vụ: Tại một thời điểm, mỗi cầu thủ chỉ thi đấu cho 1 đội; số áo trong đội
--            không được trùng giữa các cầu thủ đang thi đấu; mỗi đội tối đa 30 cầu thủ.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_hop_dong_va_so_ao()
RETURNS TRIGGER AS $$
DECLARE
    v_so_hop_dong_hieu_luc INT;
    v_trung_so_ao INT;
    v_so_luong_cau_thu INT;
BEGIN
    -- Khóa bản ghi đội bóng cha để tuần tự hóa các giao dịch đăng ký cầu thủ vào cùng một đội
    PERFORM 1 FROM DOI_BONG WHERE MaDoi = NEW.MaDoiHienTai FOR NO KEY UPDATE;

    -- Chỉ kiểm tra các hợp đồng đang có hiệu lực thi đấu
    IF NEW.TrangThai IN ('ChinhThuc', 'ChoMuon') THEN
        -- 1. Kiểm tra cầu thủ có đang vướng hợp đồng hiệu lực nào khác không
        SELECT COUNT(*) INTO v_so_hop_dong_hieu_luc
        FROM HOP_DONG_CAU_THU
        WHERE MaCauThu = NEW.MaCauThu 
          AND MaHD <> NEW.MaHD
          AND TrangThai IN ('ChinhThuc', 'ChoMuon')
          AND NOT (NgayKetThuc < NEW.NgayBatDau OR NgayBatDau > NEW.NgayKetThuc);

        IF v_so_hop_dong_hieu_luc > 0 THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ: Cầu thủ % đang có hợp đồng thi đấu còn hiệu lực khác trong thời gian này!', 
                NEW.MaCauThu;
        END IF;

        -- 2. Kiểm tra số áo không trùng trong cùng đội bóng đang thi đấu
        SELECT COUNT(*) INTO v_trung_so_ao
        FROM HOP_DONG_CAU_THU
        WHERE MaDoiHienTai = NEW.MaDoiHienTai 
          AND SoAo = NEW.SoAo 
          AND MaHD <> NEW.MaHD
          AND TrangThai IN ('ChinhThuc', 'ChoMuon')
          AND NOT (NgayKetThuc < NEW.NgayBatDau OR NgayBatDau > NEW.NgayKetThuc);

        IF v_trung_so_ao > 0 THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ: Số áo % đã được sử dụng bởi cầu thủ khác trong đội bóng %!', 
                NEW.SoAo, NEW.MaDoiHienTai;
        END IF;

        -- 3. Kiểm tra giới hạn tối đa 30 cầu thủ đang thi đấu của đội bóng
        SELECT COUNT(*) INTO v_so_luong_cau_thu
        FROM HOP_DONG_CAU_THU
        WHERE MaDoiHienTai = NEW.MaDoiHienTai 
          AND MaHD <> NEW.MaHD
          AND TrangThai IN ('ChinhThuc', 'ChoMuon');

        IF v_so_luong_cau_thu >= 30 THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ: Đội bóng % đã có đủ tối đa 30 cầu thủ đang thi đấu!', 
                NEW.MaDoiHienTai;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_hop_dong_va_so_ao ON HOP_DONG_CAU_THU;
CREATE TRIGGER trg_check_hop_dong_va_so_ao
BEFORE INSERT OR UPDATE OF MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai
ON HOP_DONG_CAU_THU
FOR EACH ROW
EXECUTE FUNCTION fn_check_hop_dong_va_so_ao();


-- ----------------------------------------------------------------------------
-- TRIGGER 3: KIỂM TRA ĐĂNG KÝ THI ĐẤU (11 ĐÁ CHÍNH, TỐI ĐA 7 DỰ BỊ) VÀ ÁN TREO GIÒ
-- Bảng áp dụng: DANG_KY_THI_DAU
-- Nghiệp vụ: Đội hình 18 người (11 đá chính, tối đa 7 dự bị); kiểm tra hạn hợp đồng
--            theo ngày trận đấu; cấm cầu thủ cho mượn đá chống đội chủ quản;
--            kiểm tra án treo giò do thẻ phạt ở trận trước đó của đội.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_dang_ky_thi_dau_va_treo_gio()
RETURNS TRIGGER AS $$
DECLARE
    v_ma_vong INT;
    v_doi_nha VARCHAR(10);
    v_doi_khach VARCHAR(10);
    v_ngay_gio TIMESTAMP;
    v_doi_chu_quan VARCHAR(10);
    v_doi_hien_tai VARCHAR(10);
    v_so_chinh_thuc INT;
    v_so_du_bi INT;
    v_tong_dang_ky INT;
    v_the_do_gan_nhat INT;
    v_the_vang_gan_nhat INT;
    v_tong_the_vang_tich_luy INT;
    v_ma_tran_truoc VARCHAR(10);
BEGIN
    -- Khóa bản ghi trận đấu cha để ngăn chặn điều kiện tranh chấp (Race Condition)
    SELECT MaVong, MaDoiNha, MaDoiKhach, NgayGio 
    INTO v_ma_vong, v_doi_nha, v_doi_khach, v_ngay_gio
    FROM TRAN_DAU 
    WHERE MaTran = NEW.MaTran 
    FOR NO KEY UPDATE;

    -- 1. Kiểm tra đội bóng có tham gia trận đấu này không
    IF NEW.MaDoi NOT IN (v_doi_nha, v_doi_khach) THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Đội bóng % không tham gia trận đấu %!', 
            NEW.MaDoi, NEW.MaTran;
    END IF;

    -- 2. Kiểm tra cầu thủ có hợp đồng còn hiệu lực tại ngày diễn ra trận đấu
    SELECT MaDoiChuQuan, MaDoiHienTai INTO v_doi_chu_quan, v_doi_hien_tai
    FROM HOP_DONG_CAU_THU
    WHERE MaCauThu = NEW.MaCauThu 
      AND MaDoiHienTai = NEW.MaDoi
      AND TrangThai IN ('ChinhThuc', 'ChoMuon')
      AND v_ngay_gio::DATE BETWEEN NgayBatDau AND NgayKetThuc
    LIMIT 1;

    IF v_doi_hien_tai IS NULL THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Cầu thủ % không có hợp đồng hiệu lực tại đội % vào ngày diễn ra trận đấu (%)!', 
            NEW.MaCauThu, NEW.MaDoi, v_ngay_gio::DATE;
    END IF;

    -- 3. Điều khoản mượn cầu thủ: Cầu thủ cho mượn không được đối đầu đội bóng chủ quản
    IF v_doi_chu_quan <> v_doi_hien_tai AND v_doi_chu_quan IN (v_doi_nha, v_doi_khach) THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Cầu thủ % đang được cho mượn từ %, không được phép thi đấu đối đầu đội chủ quản!', 
            NEW.MaCauThu, v_doi_chu_quan;
    END IF;

    -- 4. Kiểm tra giới hạn đăng ký: Tối đa 18 cầu thủ, 11 đá chính, tối đa 7 dự bị (11 + 7 = 18)
    SELECT 
        COUNT(*) FILTER (WHERE VaiTroThiDau = 'ChinhThuc'),
        COUNT(*) FILTER (WHERE VaiTroThiDau = 'DuBi'),
        COUNT(*)
    INTO v_so_chinh_thuc, v_so_du_bi, v_tong_dang_ky
    FROM DANG_KY_THI_DAU
    WHERE MaTran = NEW.MaTran 
      AND MaDoi = NEW.MaDoi 
      AND MaCauThu <> NEW.MaCauThu;

    IF v_tong_dang_ky >= 18 THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Đội % đã đăng ký đủ tối đa 18 cầu thủ cho trận đấu %!', 
            NEW.MaDoi, NEW.MaTran;
    END IF;

    IF NEW.VaiTroThiDau = 'ChinhThuc' AND v_so_chinh_thuc >= 11 THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Đội % đã đủ 11 cầu thủ đá chính cho trận đấu %!', 
            NEW.MaDoi, NEW.MaTran;
    END IF;

    IF NEW.VaiTroThiDau = 'DuBi' AND v_so_du_bi >= 7 THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Đội % đã có đủ tối đa 7 cầu thủ dự bị (tổng tối đa 18)!', 
            NEW.MaDoi;
    END IF;

    -- 5. Kiểm tra án treo giò: Xét trận đấu liền trước của đội bóng này
    SELECT MaTran INTO v_ma_tran_truoc
    FROM TRAN_DAU
    WHERE (MaDoiNha = NEW.MaDoi OR MaDoiKhach = NEW.MaDoi)
      AND NgayGio < v_ngay_gio
      AND TrangThai = 'DaKetThuc'
    ORDER BY NgayGio DESC
    LIMIT 1;

    IF v_ma_tran_truoc IS NOT NULL THEN
        -- Kiểm tra thẻ đỏ trực tiếp ở trận trước
        SELECT COUNT(*) INTO v_the_do_gan_nhat
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = v_ma_tran_truoc 
          AND MaCauThu = NEW.MaCauThu 
          AND LoaiSuKien = 'TheDo';

        -- Kiểm tra số thẻ vàng nhận trong trận trước
        SELECT COUNT(*) INTO v_the_vang_gan_nhat
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = v_ma_tran_truoc 
          AND MaCauThu = NEW.MaCauThu 
          AND LoaiSuKien = 'TheVang';

        -- Trường hợp 1: Nhận thẻ đỏ trực tiếp hoặc 2 thẻ vàng trong cùng trận trước (= thẻ đỏ gián tiếp)
        IF v_the_do_gan_nhat > 0 OR v_the_vang_gan_nhat >= 2 THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ: Cầu thủ % đang thụ án treo giò do nhận thẻ đỏ ở trận đấu liền trước (%)!', 
                NEW.MaCauThu, v_ma_tran_truoc;
        END IF;

        -- Trường hợp 2: Nhận thẻ vàng ở trận trước và hoàn tất tích lũy đủ bội số 2 thẻ vàng (thẻ thứ 2, 4...)
        IF v_the_vang_gan_nhat = 1 THEN
            SELECT COUNT(*) INTO v_tong_the_vang_tich_luy
            FROM SU_KIEN_TRAN_DAU sk
            JOIN TRAN_DAU td ON sk.MaTran = td.MaTran
            WHERE sk.MaCauThu = NEW.MaCauThu 
              AND sk.LoaiSuKien = 'TheVang'
              AND td.NgayGio <= (SELECT NgayGio FROM TRAN_DAU WHERE MaTran = v_ma_tran_truoc);

            IF (v_tong_the_vang_tich_luy % 2) = 0 THEN
                RAISE EXCEPTION 'Lỗi nghiệp vụ: Cầu thủ % đang thụ án treo giò do đã tích lũy đủ % thẻ vàng!',
                    NEW.MaCauThu, v_tong_the_vang_tich_luy;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_dang_ky_thi_dau_va_treo_gio ON DANG_KY_THI_DAU;
CREATE TRIGGER trg_check_dang_ky_thi_dau_va_treo_gio
BEFORE INSERT OR UPDATE OF MaTran, MaCauThu, MaDoi, VaiTroThiDau
ON DANG_KY_THI_DAU
FOR EACH ROW
EXECUTE FUNCTION fn_check_dang_ky_thi_dau_va_treo_gio();


-- ----------------------------------------------------------------------------
-- TRIGGER 4: MỘT TRỌNG TÀI CHỈ ĐIỀU KHIỂN TỐI ĐA 1 TRẬN TRONG MỖI VÒNG ĐẤU
-- Bảng áp dụng: PHAN_CONG_TRONG_TAI
-- Nghiệp vụ: 1 trọng tài không được phân công điều khiển 2 trận đấu trong cùng 1 vòng.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_phan_cong_trong_tai()
RETURNS TRIGGER AS $$
DECLARE
    v_ma_vong INT;
    v_trung_vong INT;
BEGIN
    -- Lấy mã vòng đấu của trận hiện tại
    SELECT MaVong INTO v_ma_vong 
    FROM TRAN_DAU 
    WHERE MaTran = NEW.MaTran;

    -- Khóa bản ghi trọng tài để tuần tự hóa các giao dịch phân công
    PERFORM 1 FROM TRONG_TAI WHERE MaTrongTai = NEW.MaTrongTai FOR NO KEY UPDATE;

    -- Kiểm tra xem trọng tài đã có nhiệm vụ trong bất kỳ trận nào thuộc vòng này chưa
    SELECT COUNT(*) INTO v_trung_vong
    FROM PHAN_CONG_TRONG_TAI pc
    JOIN TRAN_DAU td ON pc.MaTran = td.MaTran
    WHERE pc.MaTrongTai = NEW.MaTrongTai
      AND td.MaVong = v_ma_vong
      AND td.MaTran <> NEW.MaTran;

    IF v_trung_vong > 0 THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Trọng tài % đã được phân công làm nhiệm vụ tại trận khác trong vòng %!', 
            NEW.MaTrongTai, v_ma_vong;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_phan_cong_trong_tai ON PHAN_CONG_TRONG_TAI;
CREATE TRIGGER trg_check_phan_cong_trong_tai
BEFORE INSERT OR UPDATE OF MaTrongTai, MaTran
ON PHAN_CONG_TRONG_TAI
FOR EACH ROW
EXECUTE FUNCTION fn_check_phan_cong_trong_tai();


-- ----------------------------------------------------------------------------
-- TRIGGER 5: ĐỐI SOÁT TỔ TRỌNG TÀI, TỔNG BÀN THẮNG (KỂ CẢ PHẢN LƯỚI) VÀ THẺ PHẠT
-- Bảng áp dụng: TRAN_DAU
-- Nghiệp vụ: Khi trận chuyển sang DaKetThuc, phải có đủ 4 trọng tài;
--            tổng bàn thắng (bàn thắng thường + phản lưới nhà của đối phương)
--            và số lượng thẻ phạt phải khớp chính xác với bảng SU_KIEN_TRAN_DAU.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_khop_ban_thang_va_the()
RETURNS TRIGGER AS $$
DECLARE
    v_so_trong_tai INT;
    v_ban_nha INT;
    v_ban_khach INT;
    v_the_vang_nha INT;
    v_the_vang_khach INT;
    v_the_do_nha INT;
    v_the_do_khach INT;
BEGIN
    IF NEW.TrangThai = 'DaKetThuc' THEN
        -- 1. Kiểm tra đủ tổ 4 trọng tài
        SELECT COUNT(*) INTO v_so_trong_tai 
        FROM PHAN_CONG_TRONG_TAI 
        WHERE MaTran = NEW.MaTran;

        IF v_so_trong_tai <> 4 THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ: Trận đấu % phải có đủ 4 trọng tài làm nhiệm vụ trước khi kết thúc (hiện có %)!', 
                NEW.MaTran, v_so_trong_tai;
        END IF;

        -- 2. Đếm tổng hợp sự kiện:
        -- Bàn thắng Đội Nhà = (Cầu thủ nhà ghi BanThang) + (Cầu thủ khách ghi PhanLuoi)
        -- Bàn thắng Đội Khách = (Cầu thủ khách ghi BanThang) + (Cầu thủ nhà ghi PhanLuoi)
        SELECT
            COUNT(*) FILTER (WHERE (dk.MaDoi = NEW.MaDoiNha AND sk.LoaiSuKien = 'BanThang')
                                OR (dk.MaDoi = NEW.MaDoiKhach AND sk.LoaiSuKien = 'PhanLuoi')),
            COUNT(*) FILTER (WHERE (dk.MaDoi = NEW.MaDoiKhach AND sk.LoaiSuKien = 'BanThang')
                                OR (dk.MaDoi = NEW.MaDoiNha AND sk.LoaiSuKien = 'PhanLuoi')),
            COUNT(*) FILTER (WHERE dk.MaDoi = NEW.MaDoiNha AND sk.LoaiSuKien = 'TheVang'),
            COUNT(*) FILTER (WHERE dk.MaDoi = NEW.MaDoiKhach AND sk.LoaiSuKien = 'TheVang'),
            COUNT(*) FILTER (WHERE dk.MaDoi = NEW.MaDoiNha AND sk.LoaiSuKien = 'TheDo'),
            COUNT(*) FILTER (WHERE dk.MaDoi = NEW.MaDoiKhach AND sk.LoaiSuKien = 'TheDo')
        INTO 
            v_ban_nha, v_ban_khach,
            v_the_vang_nha, v_the_vang_khach,
            v_the_do_nha, v_the_do_khach
        FROM SU_KIEN_TRAN_DAU sk
        JOIN DANG_KY_THI_DAU dk ON sk.MaTran = dk.MaTran AND sk.MaCauThu = dk.MaCauThu
        WHERE sk.MaTran = NEW.MaTran;

        -- Đối soát bàn thắng
        IF v_ban_nha <> NEW.BanThangNha OR v_ban_khach <> NEW.BanThangKhach THEN
            RAISE EXCEPTION 'Lỗi toàn vẹn dữ liệu: Số bàn thắng trong sự kiện (Nhà: %, Khách: %) không khớp tỉ số trận % (Nhà: %, Khách: %)!', 
                v_ban_nha, v_ban_khach, NEW.MaTran, NEW.BanThangNha, NEW.BanThangKhach;
        END IF;

        -- Đối soát thẻ vàng
        IF v_the_vang_nha <> NEW.TheVangNha OR v_the_vang_khach <> NEW.TheVangKhach THEN
            RAISE EXCEPTION 'Lỗi toàn vẹn dữ liệu: Số thẻ vàng trong sự kiện (Nhà: %, Khách: %) không khớp thống kê trận % (Nhà: %, Khách: %)!', 
                v_the_vang_nha, v_the_vang_khach, NEW.MaTran, NEW.TheVangNha, NEW.TheVangKhach;
        END IF;

        -- Đối soát thẻ đỏ
        IF v_the_do_nha <> NEW.TheDoNha OR v_the_do_khach <> NEW.TheDoKhach THEN
            RAISE EXCEPTION 'Lỗi toàn vẹn dữ liệu: Số thẻ đỏ trong sự kiện (Nhà: %, Khách: %) không khớp thống kê trận % (Nhà: %, Khách: %)!', 
                v_the_do_nha, v_the_do_khach, NEW.MaTran, NEW.TheDoNha, NEW.TheDoKhach;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_khop_ban_thang_va_the ON TRAN_DAU;
CREATE TRIGGER trg_check_khop_ban_thang_va_the
AFTER INSERT OR UPDATE OF TrangThai, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach
ON TRAN_DAU
FOR EACH ROW
EXECUTE FUNCTION fn_check_khop_ban_thang_va_the();


-- ----------------------------------------------------------------------------
-- TRIGGER BỔ TRỢ: BẢO VỆ DỮ LIỆU SỰ KIỆN KHI TRẬN ĐẤU ĐÃ KẾT THÚC
-- Bảng áp dụng: SU_KIEN_TRAN_DAU
-- Nghiệp vụ: Chặn INSERT/UPDATE/DELETE sự kiện khi trận đấu đã 'DaKetThuc'
--            nhằm bảo toàn tuyệt đối tính nhất quán của tỉ số và thẻ phạt.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_prevent_modify_finished_events()
RETURNS TRIGGER AS $$
DECLARE
    v_target_tran VARCHAR(10);
    v_trang_thai VARCHAR(20);
BEGIN
    IF TG_OP = 'DELETE' THEN
        v_target_tran := OLD.MaTran;
    ELSE
        v_target_tran := NEW.MaTran;
    END IF;

    SELECT TrangThai INTO v_trang_thai 
    FROM TRAN_DAU 
    WHERE MaTran = v_target_tran;

    IF v_trang_thai = 'DaKetThuc' THEN
        RAISE EXCEPTION 'Lỗi an toàn: Trận đấu % đã kết thúc (DaKetThuc), không được phép thêm/sửa/xóa sự kiện diễn biến!', 
            v_target_tran;
    END IF;

    IF TG_OP = 'DELETE' THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_modify_finished_events ON SU_KIEN_TRAN_DAU;
CREATE TRIGGER trg_prevent_modify_finished_events
BEFORE INSERT OR UPDATE OR DELETE
ON SU_KIEN_TRAN_DAU
FOR EACH ROW
EXECUTE FUNCTION fn_prevent_modify_finished_events();


-- >>> FILE: 03_transactions_procedures.sql <<<

-- ============================================================================
-- PHẦN 3: CÀI ĐẶT 5 GIAO DỊCH (TRANSACTION / STORED PROCEDURE) TRỌNG YẾU
-- HỆ QUẢN TRỊ: PostgreSQL (PL/pgSQL) - Tối ưu hóa Chỉ mục B-Tree & Khóa đồng thời
-- ============================================================================

-- ----------------------------------------------------------------------------
-- GIAO DỊCH 1: KHỞI TẠO LỊCH THI ĐẤU CHO MỘT TRẬN ĐẤU THUỘC VÒNG ĐẤU
-- Đảm bảo: Hai đội không trùng nhau, cặp đấu chưa từng đá trên sân nhà này, 
--          sân vận động không bị trùng giờ thi đấu (sử dụng B-Tree Index Scan).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_tao_lich_thi_dau(
    p_ma_tran VARCHAR(10),
    p_ma_vong INT,
    p_ma_doi_nha VARCHAR(10),
    p_ma_doi_khach VARCHAR(10),
    p_ma_san VARCHAR(10),
    p_ngay_gio TIMESTAMP,
    p_gia_ve DECIMAL(12, 2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_da_ton_tai INT;
    v_trung_lich_san INT;
BEGIN
    -- 1. Kiểm tra hai đội không được trùng nhau
    IF p_ma_doi_nha = p_ma_doi_khach THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Đội chủ nhà (%) và đội khách (%) không được trùng nhau!',
            p_ma_doi_nha, p_ma_doi_khach;
    END IF;

    -- Khóa bản ghi sân vận động cha (Row-level lock) để tuần tự hóa việc xếp lịch đồng thời
    PERFORM 1 FROM SAN_VAN_DONG WHERE MaSan = p_ma_san FOR NO KEY UPDATE;

    -- 2. Kiểm tra thể thức vòng tròn: Cặp đấu này trên sân nhà này đã tồn tại chưa
    SELECT COUNT(*) INTO v_da_ton_tai
    FROM TRAN_DAU
    WHERE MaDoiNha = p_ma_doi_nha AND MaDoiKhach = p_ma_doi_khach;

    IF v_da_ton_tai > 0 THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Trận đấu giữa % (sân nhà) và % (sân khách) đã được xếp lịch trước đó!',
            p_ma_doi_nha, p_ma_doi_khach;
    END IF;

    -- 3. Kiểm tra sân vận động không bị trùng giờ thi đấu (cách nhau tối thiểu 4 giờ)
    -- Sử dụng phép so sánh khoảng trực tiếp trên cột NgayGio để tận dụng chỉ mục B-Tree idx_tran_dau_san_ngaygio
    SELECT COUNT(*) INTO v_trung_lich_san
    FROM TRAN_DAU
    WHERE MaSan = p_ma_san
      AND NgayGio > p_ngay_gio - INTERVAL '4 hours'
      AND NgayGio < p_ngay_gio + INTERVAL '4 hours';

    IF v_trung_lich_san > 0 THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Sân vận động % đã có trận đấu diễn ra trong khoảng thời gian 4 giờ lân cận!',
            p_ma_san;
    END IF;

    -- 4. Thực hiện thêm trận đấu mới
    INSERT INTO TRAN_DAU (
        MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, 
        NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, 
        TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai
    ) VALUES (
        p_ma_tran, p_ma_vong, p_ma_doi_nha, p_ma_doi_khach, p_ma_san,
        p_ngay_gio, p_gia_ve, 0, 0, 0, 0, 0, 0, 0, 'ChuaDienRa'
    );
END;
$$;


-- ----------------------------------------------------------------------------
-- GIAO DỊCH 2: PHÂN CÔNG ĐỦ TỔ 4 TRỌNG TÀI CHO MỘT TRẬN ĐẤU
-- Đảm bảo: Đủ 4 trọng tài khác nhau, không ai bị trùng lịch trong cùng vòng đấu.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_phan_cong_to_trong_tai(
    p_ma_tran VARCHAR(10),
    p_tt_chinh VARCHAR(10),
    p_tt_bien1 VARCHAR(10),
    p_tt_bien2 VARCHAR(10),
    p_tt_ban VARCHAR(10)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Kiểm tra 4 trọng tài trong tổ phải hoàn toàn phân biệt
    IF p_tt_chinh IN (p_tt_bien1, p_tt_bien2, p_tt_ban) OR
       p_tt_bien1 IN (p_tt_bien2, p_tt_ban) OR
       p_tt_bien2 = p_tt_ban THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Bốn trọng tài trong tổ phân công phải là các cá nhân phân biệt!';
    END IF;

    -- Khóa bản ghi trận đấu để đảm bảo tính cô lập khi cập nhật tổ trọng tài
    PERFORM 1 FROM TRAN_DAU WHERE MaTran = p_ma_tran FOR NO KEY UPDATE;

    -- 2. Xóa phân công cũ nếu có để gán lại toàn bộ tổ trọng tài
    DELETE FROM PHAN_CONG_TRONG_TAI WHERE MaTran = p_ma_tran;

    -- 3. Thêm 4 vị trí (Trigger trg_check_phan_cong_trong_tai sẽ tự động kiểm tra vòng đấu)
    INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
    (p_ma_tran, 'Chinh', p_tt_chinh),
    (p_ma_tran, 'Bien1', p_tt_bien1),
    (p_ma_tran, 'Bien2', p_tt_bien2),
    (p_ma_tran, 'Ban', p_tt_ban);
END;
$$;


-- ----------------------------------------------------------------------------
-- GIAO DỊCH 3: ĐĂNG KÝ DANH SÁCH CẦU THỦ THI ĐẤU CHO MỘT TRẬN ĐẤU
-- Đảm bảo: Cầu thủ thuộc biên chế đội bóng vào ngày thi đấu, gán đúng số áo.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_dang_ky_cau_thu_tran(
    p_ma_tran VARCHAR(10),
    p_ma_doi VARCHAR(10),
    p_ma_cau_thu VARCHAR(10),
    p_vai_tro_thi_dau VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_so_ao INT;
    v_ngay_gio TIMESTAMP;
BEGIN
    -- Lấy ngày giờ diễn ra trận đấu
    SELECT NgayGio INTO v_ngay_gio 
    FROM TRAN_DAU 
    WHERE MaTran = p_ma_tran;

    IF v_ngay_gio IS NULL THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Không tìm thấy trận đấu %!', p_ma_tran;
    END IF;

    -- 1. Kiểm tra cầu thủ có hợp đồng còn hiệu lực tại ngày diễn ra trận đấu
    SELECT SoAo INTO v_so_ao
    FROM HOP_DONG_CAU_THU
    WHERE MaCauThu = p_ma_cau_thu
      AND MaDoiHienTai = p_ma_doi
      AND TrangThai IN ('ChinhThuc', 'ChoMuon')
      AND v_ngay_gio::DATE BETWEEN NgayBatDau AND NgayKetThuc;

    IF v_so_ao IS NULL THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Cầu thủ % không có hợp đồng thi đấu hợp lệ tại đội bóng % vào ngày diễn ra trận đấu (%)!',
            p_ma_cau_thu, p_ma_doi, v_ngay_gio::DATE;
    END IF;

    -- 2. Thực hiện đăng ký (Trigger trg_check_dang_ky_thi_dau_va_treo_gio sẽ kiểm tra 11 chính, tối đa 7 dự bị và án treo giò)
    INSERT INTO DANG_KY_THI_DAU (MaTran, MaCauThu, MaDoi, VaiTroThiDau, SoAoDangKy)
    VALUES (p_ma_tran, p_ma_cau_thu, p_ma_doi, p_vai_tro_thi_dau, v_so_ao);
END;
$$;


-- ----------------------------------------------------------------------------
-- GIAO DỊCH 4: GHI NHẬN KẾT QUẢ VÀ SỰ KIỆN TRẬN ĐẤU (HOÀN TẤT TRẬN)
-- Đảm bảo: Ghi nhận tỉ số, thẻ phạt, số lượng khán giả và đổi trạng thái sang 'DaKetThuc'
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_ghi_nhan_ket_qua_tran_dau(
    p_ma_tran VARCHAR(10),
    p_so_khach INT,
    p_ban_nha INT,
    p_ban_khach INT,
    p_the_vang_nha INT,
    p_the_vang_khach INT,
    p_the_do_nha INT,
    p_the_do_khach INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_trang_thai VARCHAR(20);
    v_ngay_gio TIMESTAMP;
BEGIN
    -- 1. Lấy thông tin trận đấu và khóa độc quyền dòng dữ liệu trận đấu (FOR UPDATE)
    SELECT TrangThai, NgayGio INTO v_trang_thai, v_ngay_gio
    FROM TRAN_DAU
    WHERE MaTran = p_ma_tran
    FOR UPDATE;

    IF v_trang_thai IS NULL THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Không tìm thấy trận đấu có mã %!', p_ma_tran;
    END IF;

    -- 2. Kiểm tra ngày giờ thi đấu không được vượt quá thời gian hiện tại
    IF v_ngay_gio > CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Lỗi giao dịch: Không thể kết thúc trận đấu chưa diễn ra (thời gian thi đấu ở tương lai)!';
    END IF;

    -- 3. Cập nhật kết quả chung cuộc và chuyển trạng thái
    -- (Trigger trg_check_khop_ban_thang_va_the sẽ kiểm tra tính khớp nối với các sự kiện đã ghi)
    UPDATE TRAN_DAU
    SET SoKhach = p_so_khach,
        BanThangNha = p_ban_nha,
        BanThangKhach = p_ban_khach,
        TheVangNha = p_the_vang_nha,
        TheVangKhach = p_the_vang_khach,
        TheDoNha = p_the_do_nha,
        TheDoKhach = p_the_do_khach,
        TrangThai = 'DaKetThuc'
    WHERE MaTran = p_ma_tran;
END;
$$;


-- ----------------------------------------------------------------------------
-- GIAO DỊCH 5: CHUYỂN NHƯỢNG HOẶC CHO MƯỢN CẦU THỦ
-- Đảm bảo: Nếu cho mượn ('ChoMuon'), hợp đồng gốc chuyển sang 'TamDung' để bảo lưu quyền sở hữu của CLB chủ quản;
--          nếu chuyển nhượng dứt đoạn ('ChinhThuc'), hợp đồng cũ chuyển sang 'ThanhLy'.
--          Nhờ Partial Unique Index, không bao giờ bị văng lỗi trùng khóa.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_chuyen_nhuong_cho_muon_cau_thu(
    p_ma_hd_moi VARCHAR(10),
    p_ma_cau_thu VARCHAR(10),
    p_ma_doi_chu_quan VARCHAR(10),
    p_ma_doi_moi VARCHAR(10),
    p_so_ao_moi INT,
    p_ngay_bat_dau DATE,
    p_ngay_ket_thuc DATE,
    p_trang_thai VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Khóa bản ghi cầu thủ để ngăn chặn hai giao dịch chuyển nhượng đồng thời cho cùng 1 cầu thủ
    PERFORM 1 FROM CAU_THU WHERE MaCauThu = p_ma_cau_thu FOR NO KEY UPDATE;
    PERFORM 1 FROM DOI_BONG WHERE MaDoi = p_ma_doi_moi FOR NO KEY UPDATE;

    -- 1. Xử lý hợp đồng cũ đang có hiệu lực của cầu thủ
    -- Nếu cho mượn: Hợp đồng gốc tạm dừng để giữ quyền sở hữu của CLB chủ quản
    -- Nếu chuyển nhượng chính thức: Hợp đồng cũ thanh lý
    IF p_trang_thai = 'ChoMuon' THEN
        UPDATE HOP_DONG_CAU_THU
        SET TrangThai = 'TamDung'
        WHERE MaCauThu = p_ma_cau_thu
          AND TrangThai IN ('ChinhThuc', 'ChoMuon')
          AND NgayKetThuc >= p_ngay_bat_dau;
    ELSE
        UPDATE HOP_DONG_CAU_THU
        SET NgayKetThuc = p_ngay_bat_dau - INTERVAL '1 day',
            TrangThai = 'ThanhLy'
        WHERE MaCauThu = p_ma_cau_thu
          AND TrangThai IN ('ChinhThuc', 'ChoMuon', 'TamDung')
          AND NgayKetThuc >= p_ngay_bat_dau;
    END IF;

    -- 2. Thêm bản ghi hợp đồng mới cho cầu thủ tại đội bóng mới
    -- (Partial Unique Index và Trigger trg_check_hop_dong_va_so_ao sẽ đảm bảo tính hợp lệ tuyệt đối)
    INSERT INTO HOP_DONG_CAU_THU (
        MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, 
        SoAo, NgayBatDau, NgayKetThuc, TrangThai
    ) VALUES (
        p_ma_hd_moi, p_ma_cau_thu, p_ma_doi_chu_quan, p_ma_doi_moi,
        p_so_ao_moi, p_ngay_bat_dau, p_ngay_ket_thuc, p_trang_thai
    );
END;
$$;


-- >>> FILE: 04_views_statistics.sql <<<

-- ============================================================================
-- PHẦN 4: VIEWS VÀ HÀM THỐNG KÊ (BẢNG XẾP HẠNG, VUA PHÁ LƯỚI, LƯƠNG TRỌNG TÀI)
-- HỆ QUẢN TRỊ: PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. VIEW BẢNG XẾP HẠNG MÙA GIẢI
-- Tiêu chí sắp xếp: Điểm -> Hiệu số -> Tổng bàn thắng -> Số trận thắng sân khách
--                   -> Tổng thẻ đỏ (ít hơn xếp trên) -> Tổng thẻ vàng (ít hơn)
-- Thể thức: Thắng = 3 điểm, Hòa = 1 điểm, Thua = 0 điểm.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_bang_xep_hang AS
WITH TranDauKetThuc AS (
    -- Thống kê khi đội đóng vai trò SÂN NHÀ
    SELECT 
        MaDoiNha AS MaDoi,
        1 AS SoTran,
        CASE WHEN BanThangNha > BanThangKhach THEN 1 ELSE 0 END AS Thang,
        CASE WHEN BanThangNha = BanThangKhach THEN 1 ELSE 0 END AS Hoa,
        CASE WHEN BanThangNha < BanThangKhach THEN 1 ELSE 0 END AS Thua,
        BanThangNha AS BanThang,
        BanThangKhach AS BanThua,
        0 AS ThangSanKhach,
        TheDoNha AS TheDo,
        TheVangNha AS TheVang
    FROM TRAN_DAU
    WHERE TrangThai = 'DaKetThuc'

    UNION ALL

    -- Thống kê khi đội đóng vai trò SÂN KHÁCH
    SELECT 
        MaDoiKhach AS MaDoi,
        1 AS SoTran,
        CASE WHEN BanThangKhach > BanThangNha THEN 1 ELSE 0 END AS Thang,
        CASE WHEN BanThangKhach = BanThangNha THEN 1 ELSE 0 END AS Hoa,
        CASE WHEN BanThangKhach < BanThangNha THEN 1 ELSE 0 END AS Thua,
        BanThangKhach AS BanThang,
        BanThangNha AS BanThua,
        CASE WHEN BanThangKhach > BanThangNha THEN 1 ELSE 0 END AS ThangSanKhach,
        TheDoKhach AS TheDo,
        TheVangKhach AS TheVang
    FROM TRAN_DAU
    WHERE TrangThai = 'DaKetThuc'
),
TongHop AS (
    SELECT 
        d.MaDoi,
        d.TenDoi,
        COALESCE(SUM(t.SoTran), 0) AS SoTranDaDau,
        COALESCE(SUM(t.Thang), 0) AS SoTranThang,
        COALESCE(SUM(t.Hoa), 0) AS SoTranHoa,
        COALESCE(SUM(t.Thua), 0) AS SoTranThua,
        COALESCE(SUM(t.BanThang), 0) AS TongBanThang,
        COALESCE(SUM(t.BanThua), 0) AS TongBanThua,
        COALESCE(SUM(t.BanThang) - SUM(t.BanThua), 0) AS HieuSo,
        COALESCE(SUM(t.Thang) * 3 + SUM(t.Hoa) * 1, 0) AS DiemSo,
        COALESCE(SUM(t.ThangSanKhach), 0) AS SoTranThangSanKhach,
        COALESCE(SUM(t.TheDo), 0) AS TongTheDo,
        COALESCE(SUM(t.TheVang), 0) AS TongTheVang
    FROM DOI_BONG d
    LEFT JOIN TranDauKetThuc t ON d.MaDoi = t.MaDoi
    GROUP BY d.MaDoi, d.TenDoi
)
SELECT 
    ROW_NUMBER() OVER (
        ORDER BY 
            DiemSo DESC, 
            HieuSo DESC, 
            TongBanThang DESC, 
            SoTranThangSanKhach DESC, 
            TongTheDo ASC, 
            TongTheVang ASC,
            TenDoi ASC
    ) AS ViTri,
    MaDoi,
    TenDoi,
    SoTranDaDau,
    SoTranThang,
    SoTranHoa,
    SoTranThua,
    TongBanThang,
    TongBanThua,
    HieuSo,
    DiemSo,
    SoTranThangSanKhach,
    TongTheDo,
    TongTheVang
FROM TongHop;


-- ----------------------------------------------------------------------------
-- 2. HÀM TRUY VẤN TOP 10 CẦU THỦ GHI NHIỀU BÀN THẮNG NHẤT (VUA PHÁ LƯỚI)
-- Lưu ý: Gom nhóm theo cầu thủ (MaCauThu, HoTen), không gom theo TenDoi để tránh
--        bị phân tách dòng nếu cầu thủ chuyển nhượng giữa mùa. Đội bóng hiện tại
--        được truy vấn độc lập từ hợp đồng mới nhất còn hiệu lực.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_top10_vua_pha_luoi()
RETURNS TABLE (
    XepHang BIGINT,
    MaCauThu VARCHAR(10),
    HoTen VARCHAR(100),
    TenDoiHienTai VARCHAR(100),
    SoBanThang BIGINT
)
LANGUAGE sql
AS $$
    WITH BanThangCuaCauThu AS (
        SELECT 
            sk.MaCauThu,
            COUNT(*) AS SoBanThang
        FROM SU_KIEN_TRAN_DAU sk
        WHERE sk.LoaiSuKien = 'BanThang'
        GROUP BY sk.MaCauThu
    ),
    DoiBongHienTai AS (
        SELECT DISTINCT ON (hd.MaCauThu)
            hd.MaCauThu,
            db.TenDoi
        FROM HOP_DONG_CAU_THU hd
        JOIN DOI_BONG db ON hd.MaDoiHienTai = db.MaDoi
        WHERE hd.TrangThai IN ('ChinhThuc', 'ChoMuon')
        ORDER BY hd.MaCauThu, hd.NgayBatDau DESC
    )
    SELECT 
        ROW_NUMBER() OVER (ORDER BY b.SoBanThang DESC, ct.HoTen ASC) AS XepHang,
        ct.MaCauThu,
        ct.HoTen,
        COALESCE(d.TenDoi, 'Tự do') AS TenDoiHienTai,
        b.SoBanThang
    FROM BanThangCuaCauThu b
    JOIN CAU_THU ct ON b.MaCauThu = ct.MaCauThu
    LEFT JOIN DoiBongHienTai d ON b.MaCauThu = d.MaCauThu
    ORDER BY b.SoBanThang DESC, ct.HoTen ASC
    LIMIT 10;
$$;


-- ----------------------------------------------------------------------------
-- 3. HÀM TÍNH LƯƠNG TRỌNG TÀI THEO THÁNG
-- Quy định thù lao: Trọng tài chính = 3 triệu/trận; Trọng tài biên = 2 triệu/trận;
--                   Trọng tài bàn = 1 triệu/trận.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_tinh_luong_trong_tai_thang(
    p_thang INT,
    p_nam INT
)
RETURNS TABLE (
    MaTrongTai VARCHAR(10),
    HoTen VARCHAR(100),
    CapBac VARCHAR(50),
    SoTranChinh BIGINT,
    SoTranBien BIGINT,
    SoTranBan BIGINT,
    TongSoTran BIGINT,
    TongLuong DECIMAL(15, 2)
)
LANGUAGE sql
AS $$
    SELECT 
        tt.MaTrongTai,
        tt.HoTen,
        tt.CapBac,
        COUNT(CASE WHEN td.MaTran IS NOT NULL AND pc.VaiTro = 'Chinh' THEN 1 END) AS SoTranChinh,
        COUNT(CASE WHEN td.MaTran IS NOT NULL AND pc.VaiTro IN ('Bien1', 'Bien2') THEN 1 END) AS SoTranBien,
        COUNT(CASE WHEN td.MaTran IS NOT NULL AND pc.VaiTro = 'Ban' THEN 1 END) AS SoTranBan,
        COUNT(td.MaTran) AS TongSoTran,
        (
            COUNT(CASE WHEN td.MaTran IS NOT NULL AND pc.VaiTro = 'Chinh' THEN 1 END) * 3000000 +
            COUNT(CASE WHEN td.MaTran IS NOT NULL AND pc.VaiTro IN ('Bien1', 'Bien2') THEN 1 END) * 2000000 +
            COUNT(CASE WHEN td.MaTran IS NOT NULL AND pc.VaiTro = 'Ban' THEN 1 END) * 1000000
        )::DECIMAL(15, 2) AS TongLuong
    FROM TRONG_TAI tt
    LEFT JOIN (
        PHAN_CONG_TRONG_TAI pc
        JOIN TRAN_DAU td ON pc.MaTran = td.MaTran
                        AND EXTRACT(MONTH FROM td.NgayGio) = p_thang
                        AND EXTRACT(YEAR FROM td.NgayGio) = p_nam
                        AND td.TrangThai = 'DaKetThuc'
    ) ON tt.MaTrongTai = pc.MaTrongTai
    GROUP BY tt.MaTrongTai, tt.HoTen, tt.CapBac
    ORDER BY TongLuong DESC, tt.HoTen ASC;
$$;


-- ----------------------------------------------------------------------------
-- 4. HÀM THỐNG KÊ DOANH THU CỦA CÁC SÂN VẬN ĐỘNG
-- Công thức: Doanh thu = Tổng (Số lượng khán giả * Giá vé mỗi trận)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_thong_ke_doanh_thu_san()
RETURNS TABLE (
    MaSan VARCHAR(10),
    TenSan VARCHAR(100),
    DiaChi VARCHAR(200),
    SucChua INT,
    SoTranDaToChuc BIGINT,
    TongKhanGia BIGINT,
    TongDoanhThu DECIMAL(18, 2)
)
LANGUAGE sql
AS $$
    SELECT 
        s.MaSan,
        s.TenSan,
        s.DiaChi,
        s.SucChua,
        COUNT(t.MaTran) AS SoTranDaToChuc,
        COALESCE(SUM(t.SoKhach), 0)::BIGINT AS TongKhanGia,
        COALESCE(SUM(t.SoKhach * t.GiaVe), 0)::DECIMAL(18, 2) AS TongDoanhThu
    FROM SAN_VAN_DONG s
    LEFT JOIN TRAN_DAU t ON s.MaSan = t.MaSan AND t.TrangThai = 'DaKetThuc'
    GROUP BY s.MaSan, s.TenSan, s.DiaChi, s.SucChua
    ORDER BY TongDoanhThu DESC, s.TenSan ASC;
$$;


-- ----------------------------------------------------------------------------
-- 5. HÀM THỐNG KÊ DIỄN BIẾN MỘT VÒNG ĐẤU CỤ THỂ
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_thong_ke_vong_dau(p_ma_vong INT)
RETURNS TABLE (
    MaTran VARCHAR(10),
    NgayGio TIMESTAMP,
    TenSan VARCHAR(100),
    DoiNha VARCHAR(100),
    DoiKhach VARCHAR(100),
    TiSo VARCHAR(20),
    TheVang INT,
    TheDo INT,
    SoKhach INT,
    TrangThai VARCHAR(20)
)
LANGUAGE sql
AS $$
    SELECT 
        t.MaTran,
        t.NgayGio,
        s.TenSan,
        dn.TenDoi AS DoiNha,
        dk.TenDoi AS DoiKhach,
        CONCAT(t.BanThangNha, ' - ', t.BanThangKhach) AS TiSo,
        (t.TheVangNha + t.TheVangKhach) AS TheVang,
        (t.TheDoNha + t.TheDoKhach) AS TheDo,
        t.SoKhach,
        t.TrangThai
    FROM TRAN_DAU t
    JOIN DOI_BONG dn ON t.MaDoiNha = dn.MaDoi
    JOIN DOI_BONG dk ON t.MaDoiKhach = dk.MaDoi
    JOIN SAN_VAN_DONG s ON t.MaSan = s.MaSan
    WHERE t.MaVong = p_ma_vong
    ORDER BY t.NgayGio ASC;
$$;


-- >>> FILE: 05_mock_data.sql <<<

-- ============================================================================
-- PHẦN 5: BỘ DỮ LIỆU MẪU ĐẦY ĐỦ CHO TRỌN VẸN MỘT MÙA GIẢI (6 ĐỘI, 30 TRẬN)
-- HỆ QUẢN TRỊ: PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. NẠP DỮ LIỆU SÂN VẬN ĐỘNG
-- Lưu ý: Sân Hàng Đẫy (SAN_HD) là sân nhà của cả 2 đội: HNFC và CAHN.
-- ----------------------------------------------------------------------------
INSERT INTO SAN_VAN_DONG (MaSan, TenSan, DiaChi, SucChua, KhuVuc) VALUES
('SAN_HD', 'Sân vận động Hàng Đẫy', 'Trịnh Hoài Đức, Đống Đa, Hà Nội', 22500, 'MienBac'),
('SAN_MD', 'Sân vận động Quốc gia Mỹ Đình', 'Lê Đức Thọ, Nam Từ Liêm, Hà Nội', 40192, 'MienBac'),
('SAN_LT', 'Sân vận động Lạch Tray', 'Lạch Tray, Ngô Quyền, Hải Phòng', 30000, 'MienBac'),
('SAN_TT', 'Sân vận động Thiên Trường', 'Đặng Xuân Thiều, TP Nam Định', 30000, 'MienBac'),
('SAN_PK', 'Sân vận động Pleiku', 'Quang Trung, TP Pleiku, Gia Lai', 12000, 'MienNam');

-- ----------------------------------------------------------------------------
-- 2. NẠP DỮ LIỆU ĐỘI BÓNG
-- ----------------------------------------------------------------------------
INSERT INTO DOI_BONG (MaDoi, TenDoi, HLV, MaSanNha) VALUES
('HNFC', 'Hà Nội FC', 'Daiki Iwamasa', 'SAN_HD'),
('CAHN', 'Công An Hà Nội', 'Alexandre Polking', 'SAN_HD'),
('VTT',  'Thể Công Viettel', 'Nguyễn Đức Thắng', 'SAN_MD'),
('HPFC', 'Hải Phòng FC', 'Chu Đình Nghiêm', 'SAN_LT'),
('NDFC', 'Thép Xanh Nam Định', 'Vũ Hồng Việt', 'SAN_TT'),
('HAGL', 'Hoàng Anh Gia Lai', 'Vũ Tiến Thành', 'SAN_PK');

-- ----------------------------------------------------------------------------
-- 3. NẠP DỮ LIỆU MÀU ÁO ĐỘI BÓNG (Mỗi đội có ít nhất 2 màu áo)
-- ----------------------------------------------------------------------------
INSERT INTO MAU_AO_DOI_BONG (MaDoi, LoaiMauAo, MoTaMau) VALUES
('HNFC', 'SanNha', 'Tím truyền thống'),
('HNFC', 'SanKhach', 'Vàng viền tím'),
('HNFC', 'Phu', 'Trắng tinh khôi'),

('CAHN', 'SanNha', 'Đỏ cờ'),
('CAHN', 'SanKhach', 'Trắng viền đỏ'),

('VTT',  'SanNha', 'Đỏ rực'),
('VTT',  'SanKhach', 'Trắng quân đội'),

('HPFC', 'SanNha', 'Đỏ hoa phượng'),
('HPFC', 'SanKhach', 'Trắng viền đỏ'),

('NDFC', 'SanNha', 'Vàng rực rỡ'),
('NDFC', 'SanKhach', 'Trắng phối xanh'),

('HAGL', 'SanNha', 'Trắng phố núi'),
('HAGL', 'SanKhach', 'Xanh lục đậm');

-- ----------------------------------------------------------------------------
-- 4. NẠP DỮ LIỆU TRỌNG TÀI (12 Trọng tài đảm bảo đủ 3 trận x 4 TT / vòng)
-- ----------------------------------------------------------------------------
INSERT INTO TRONG_TAI (MaTrongTai, HoTen, NgaySinh, QueQuan, CapBac) VALUES
('TT01', 'Ngô Duy Lân', '1984-06-12', 'Long An', 'FIFA Elite'),
('TT02', 'Hoàng Ngọc Hà', '1983-09-24', 'Hà Nội', 'FIFA'),
('TT03', 'Trần Đình Thịnh', '1982-03-15', 'Đồng Nai', 'FIFA'),
('TT04', 'Lê Vũ Linh', '1989-11-20', 'Cần Thơ', 'FIFA'),
('TT05', 'Nguyễn Viết Duẩn', '1985-07-08', 'Hà Nội', 'Quốc gia'),
('TT06', 'Mai Xuân Hùng', '1987-12-03', 'Đà Nẵng', 'Quốc gia'),
('TT07', 'Nguyễn Mạnh Hải', '1987-05-18', 'Hải Phòng', 'FIFA'),
('TT08', 'Trần Ngọc Nhớ', '1988-02-14', 'Tiền Giang', 'Quốc gia'),
('TT09', 'Phạm Hoài Tâm', '1986-10-30', 'TP Hồ Chí Minh', 'Quốc gia'),
('TT10', 'Nguyễn Trung Hậu', '1981-04-22', 'Đà Nẵng', 'FIFA Trợ lý'),
('TT11', 'Phạm Mạnh Long', '1980-08-11', 'Hải Phòng', 'FIFA Trợ lý'),
('TT12', 'Trần Duy Khánh', '1990-01-05', 'Nghệ An', 'Quốc gia');

-- ----------------------------------------------------------------------------
-- 5. NẠP DỮ LIỆU CẦU THỦ VÀ HỢP ĐỒNG (6 đội x 18 cầu thủ = 108 cầu thủ)
-- ----------------------------------------------------------------------------
-- (1) HÀ NỘI FC (HNFC) - 18 cầu thủ (Số áo từ 1 đến 35, phân biệt)
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT001', 'Bùi Tấn Trường', '1986-02-19', 'ThuMon', 'Việt Nam'),
('CT002', 'Đỗ Duy Mạnh', '1996-09-29', 'HauVe', 'Việt Nam'),
('CT003', 'Nguyễn Thành Chung', '1997-11-29', 'HauVe', 'Việt Nam'),
('CT004', 'Phạm Xuân Mạnh', '1996-03-27', 'HauVe', 'Việt Nam'),
('CT005', 'Vũ Đình Hai', '2000-01-13', 'TienVe', 'Việt Nam'),
('CT006', 'Đỗ Hùng Dũng', '1993-09-08', 'TienVe', 'Việt Nam'),
('CT007', 'Nguyễn Văn Quyết', '1991-07-01', 'TienDao', 'Việt Nam'),
('CT008', 'Phạm Tuấn Hải', '1998-05-19', 'TienDao', 'Việt Nam'),
('CT009', 'Lê Văn Xuân', '1999-02-27', 'HauVe', 'Việt Nam'),
('CT010', 'Nguyễn Văn Tùng', '2001-06-02', 'TienDao', 'Việt Nam'),
('CT011', 'Quan Văn Chuẩn', '2001-01-07', 'ThuMon', 'Việt Nam'),
('CT012', 'Đậu Văn Toàn', '1997-04-07', 'TienVe', 'Việt Nam'),
('CT013', 'Nguyễn Hai Long', '2000-08-27', 'TienVe', 'Việt Nam'),
('CT014', 'Trần Văn Kiên', '1996-05-13', 'HauVe', 'Việt Nam'),
('CT015', 'Joel Tagueu', '1993-11-06', 'TienDao', 'Cameroon'),
('CT016', 'Deni Junior', '1995-07-10', 'TienDao', 'Brazil'),
('CT017', 'Tim Hall', '1997-06-09', 'HauVe', 'Luxembourg'),
('CT018', 'Nguyễn Đức Anh', '2003-05-16', 'HauVe', 'Việt Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai) VALUES
('HD001', 'CT001', 'HNFC', 'HNFC', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD002', 'CT002', 'HNFC', 'HNFC', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD003', 'CT003', 'HNFC', 'HNFC', 16, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD004', 'CT004', 'HNFC', 'HNFC', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD005', 'CT005', 'HNFC', 'HNFC', 21, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD006', 'CT006', 'HNFC', 'HNFC', 6,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD007', 'CT007', 'HNFC', 'HNFC', 10, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD008', 'CT008', 'HNFC', 'HNFC', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD009', 'CT009', 'HNFC', 'HNFC', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD010', 'CT010', 'HNFC', 'HNFC', 11, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD011', 'CT011', 'HNFC', 'HNFC', 25, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD012', 'CT012', 'HNFC', 'HNFC', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD013', 'CT013', 'HNFC', 'HNFC', 14, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD014', 'CT014', 'HNFC', 'HNFC', 13, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD015', 'CT015', 'HNFC', 'HNFC', 15, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD016', 'CT016', 'HNFC', 'HNFC', 17, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD017', 'CT017', 'HNFC', 'HNFC', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD018', 'CT018', 'HNFC', 'HNFC', 28, '2025-01-01', '2027-12-31', 'ChinhThuc');

-- (2) CÔNG AN HÀ NỘI (CAHN) - 18 cầu thủ
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT019', 'Filip Nguyễn', '1992-09-14', 'ThuMon', 'Việt Nam'),
('CT020', 'Hồ Tấn Tài', '1997-11-06', 'HauVe', 'Việt Nam'),
('CT021', 'Bùi Hoàng Việt Anh', '1999-01-01', 'HauVe', 'Việt Nam'),
('CT022', 'Đoàn Văn Hậu', '1999-04-19', 'HauVe', 'Việt Nam'),
('CT023', 'Vũ Văn Thanh', '1996-04-14', 'HauVe', 'Việt Nam'),
('CT024', 'Nguyễn Quang Hải', '1997-04-12', 'TienVe', 'Việt Nam'),
('CT025', 'Lê Phạm Thành Long', '1996-06-05', 'TienVe', 'Việt Nam'),
('CT026', 'Hoàng Văn Toản', '2001-04-01', 'TienVe', 'Việt Nam'),
('CT027', 'Phan Văn Đức', '1996-04-11', 'TienDao', 'Việt Nam'),
('CT028', 'Geovane Magno', '1994-04-14', 'TienDao', 'Brazil'),
('CT029', 'Jeferson Elias', '1998-08-18', 'TienDao', 'Brazil'),
('CT030', 'Bùi Tiến Dũng', '1997-02-28', 'ThuMon', 'Việt Nam'),
('CT031', 'Huỳnh Tấn Sinh', '1998-04-06', 'HauVe', 'Việt Nam'),
('CT032', 'Hà Văn Phương', '2001-05-28', 'TienVe', 'Việt Nam'),
('CT033', 'La Nguyễn Bảo Trung', '2002-03-12', 'TienVe', 'Việt Nam'),
('CT034', 'Phạm Gia Hưng', '2000-09-11', 'TienDao', 'Việt Nam'),
('CT035', 'Trần Đình Trọng', '1997-04-25', 'HauVe', 'Việt Nam'),
('CT036', 'Junior Fialho', '1998-10-21', 'TienDao', 'Brazil');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai) VALUES
('HD019', 'CT019', 'CAHN', 'CAHN', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD020', 'CT020', 'CAHN', 'CAHN', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD021', 'CT021', 'CAHN', 'CAHN', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD022', 'CT022', 'CAHN', 'CAHN', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD023', 'CT023', 'CAHN', 'CAHN', 17, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD024', 'CT024', 'CAHN', 'CAHN', 19, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD025', 'CT025', 'CAHN', 'CAHN', 11, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD026', 'CT026', 'CAHN', 'CAHN', 12, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD027', 'CT027', 'CAHN', 'CAHN', 20, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD028', 'CT028', 'CAHN', 'CAHN', 10, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD029', 'CT029', 'CAHN', 'CAHN', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD030', 'CT030', 'CAHN', 'CAHN', 25, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD031', 'CT031', 'CAHN', 'CAHN', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD032', 'CT032', 'CAHN', 'CAHN', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD033', 'CT033', 'CAHN', 'CAHN', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD034', 'CT034', 'CAHN', 'CAHN', 14, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD035', 'CT035', 'CAHN', 'CAHN', 21, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD036', 'CT036', 'CAHN', 'CAHN', 30, '2025-01-01', '2027-12-31', 'ChinhThuc');

-- (3) THỂ CÔNG VIETTEL (VTT) - 18 cầu thủ
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT037', 'Trần Nguyên Mạnh', '1991-12-20', 'ThuMon', 'Việt Nam'),
('CT038', 'Bùi Tiến Dũng', '1995-10-02', 'HauVe', 'Việt Nam'),
('CT039', 'Nguyễn Thanh Bình', '2000-11-02', 'HauVe', 'Việt Nam'),
('CT040', 'Phan Tuấn Tài', '2001-01-07', 'HauVe', 'Việt Nam'),
('CT041', 'Trương Tiến Anh', '1999-04-25', 'TienVe', 'Việt Nam'),
('CT042', 'Nguyễn Hoàng Đức', '1998-01-11', 'TienVe', 'Việt Nam'),
('CT043', 'Nguyễn Đức Chiến', '1998-08-24', 'TienVe', 'Việt Nam'),
('CT044', 'Khuất Văn Khang', '2003-05-11', 'TienVe', 'Việt Nam'),
('CT045', 'Nhâm Mạnh Dũng', '2000-04-12', 'TienDao', 'Việt Nam'),
('CT046', 'Pedro Henrique', '1996-12-17', 'TienDao', 'Brazil'),
('CT047', 'Jaha', '1993-04-06', 'TienVe', 'Kosovo'),
('CT048', 'Quàng Thế Tài', '1995-02-05', 'ThuMon', 'Việt Nam'),
('CT049', 'Cao Trần Hoàng Hùng', '1999-03-03', 'HauVe', 'Việt Nam'),
('CT050', 'Nguyễn Huy Hùng', '1992-03-02', 'TienVe', 'Việt Nam'),
('CT051', 'Đinh Xuân Tiến', '2003-01-10', 'TienVe', 'Việt Nam'),
('CT052', 'Trần Danh Trung', '2000-10-03', 'TienDao', 'Việt Nam'),
('CT053', 'Dương Văn Hào', '1997-02-15', 'TienDao', 'Việt Nam'),
('CT054', 'Nguyễn Xuân Kiên', '2000-05-19', 'HauVe', 'Việt Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai) VALUES
('HD037', 'CT037', 'VTT', 'VTT', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD038', 'CT038', 'VTT', 'VTT', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD039', 'CT039', 'VTT', 'VTT', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD040', 'CT040', 'VTT', 'VTT', 12, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD041', 'CT041', 'VTT', 'VTT', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD042', 'CT042', 'VTT', 'VTT', 28, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD043', 'CT043', 'VTT', 'VTT', 21, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD044', 'CT044', 'VTT', 'VTT', 11, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD045', 'CT045', 'VTT', 'VTT', 23, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD046', 'CT046', 'VTT', 'VTT', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD047', 'CT047', 'VTT', 'VTT', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD048', 'CT048', 'VTT', 'VTT', 25, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD049', 'CT049', 'VTT', 'VTT', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD050', 'CT050', 'VTT', 'VTT', 6,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD051', 'CT051', 'VTT', 'VTT', 10, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD052', 'CT052', 'VTT', 'VTT', 19, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD053', 'CT053', 'VTT', 'VTT', 17, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD054', 'CT054', 'VTT', 'VTT', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc');

-- (4) THÉP XANH NAM ĐỊNH (NDFC) - 18 cầu thủ
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT055', 'Trần Liêm Điều', '2001-06-29', 'ThuMon', 'Việt Nam'),
('CT056', 'Dương Thanh Hào', '1991-06-23', 'HauVe', 'Việt Nam'),
('CT057', 'Trần Văn Kiên', '1996-05-13', 'HauVe', 'Việt Nam'),
('CT058', 'Nguyễn Phong Hồng Duy', '1996-06-13', 'HauVe', 'Việt Nam'),
('CT059', 'Lucas Alves', '1992-07-22', 'HauVe', 'Brazil'),
('CT060', 'Trần Văn Công', '1999-02-15', 'TienVe', 'Việt Nam'),
('CT061', 'Hendrio Araujo', '1994-05-16', 'TienVe', 'Brazil'),
('CT062', 'Nguyễn Tuấn Anh', '1995-05-16', 'TienVe', 'Việt Nam'),
('CT063', 'Nguyễn Văn Toàn', '1996-04-12', 'TienDao', 'Việt Nam'),
('CT064', 'Nguyễn Xuân Son', '1997-03-30', 'TienDao', 'Việt Nam'),
('CT065', 'Lâm Anh Quang', '1991-04-24', 'HauVe', 'Việt Nam'),
('CT066', 'Lê Vũ Quốc Nhật', '2001-01-19', 'ThuMon', 'Việt Nam'),
('CT067', 'Đinh Viết Tú', '1992-08-16', 'HauVe', 'Việt Nam'),
('CT068', 'Tô Văn Vũ', '1993-10-20', 'TienVe', 'Việt Nam'),
('CT069', 'Lý Công Hoàng Anh', '1999-09-01', 'TienVe', 'Việt Nam'),
('CT070', 'Mai Xuân Quyết', '1999-04-01', 'TienDao', 'Việt Nam'),
('CT071', 'Hoàng Minh Tuấn', '1995-08-17', 'TienDao', 'Việt Nam'),
('CT072', 'Đoàn Thanh Trường', '2000-09-08', 'TienVe', 'Việt Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai) VALUES
('HD055', 'CT055', 'NDFC', 'NDFC', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD056', 'CT056', 'NDFC', 'NDFC', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD057', 'CT057', 'NDFC', 'NDFC', 13, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD058', 'CT058', 'NDFC', 'NDFC', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD059', 'CT059', 'NDFC', 'NDFC', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD060', 'CT060', 'NDFC', 'NDFC', 16, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD061', 'CT061', 'NDFC', 'NDFC', 10, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD062', 'CT062', 'NDFC', 'NDFC', 21, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD063', 'CT063', 'NDFC', 'NDFC', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD064', 'CT064', 'NDFC', 'NDFC', 14, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD065', 'CT065', 'NDFC', 'NDFC', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD066', 'CT066', 'NDFC', 'NDFC', 25, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD067', 'CT067', 'NDFC', 'NDFC', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD068', 'CT068', 'NDFC', 'NDFC', 28, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD069', 'CT069', 'NDFC', 'NDFC', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD070', 'CT070', 'NDFC', 'NDFC', 11, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD071', 'CT071', 'NDFC', 'NDFC', 19, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD072', 'CT072', 'NDFC', 'NDFC', 18, '2025-01-01', '2027-12-31', 'ChinhThuc');

-- (5) HẢI PHÒNG FC (HPFC) - 18 cầu thủ
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT073', 'Nguyễn Đình Triệu', '1991-11-04', 'ThuMon', 'Việt Nam'),
('CT074', 'Đặng Văn Tới', '1999-01-12', 'HauVe', 'Việt Nam'),
('CT075', 'Bùi Tiến Dụng', '1998-11-23', 'HauVe', 'Việt Nam'),
('CT076', 'Phạm Trung Hiếu', '1998-09-22', 'HauVe', 'Việt Nam'),
('CT077', 'Nguyễn Văn Đạt', '1998-05-25', 'HauVe', 'Việt Nam'),
('CT078', 'Lương Xuân Trường', '1995-04-28', 'TienVe', 'Việt Nam'),
('CT079', 'Bicou Bissainthe', '1999-03-15', 'TienVe', 'Haiti'),
('CT080', 'Triệu Việt Hưng', '1997-01-19', 'TienVe', 'Việt Nam'),
('CT081', 'Nguyễn Hữu Sơn', '1996-09-27', 'TienDao', 'Việt Nam'),
('CT082', 'Lucao do Break', '1991-09-22', 'TienDao', 'Brazil'),
('CT083', 'Joseph Mpande', '1994-03-23', 'TienDao', 'Uganda'),
('CT084', 'Nguyễn Văn Toản', '1999-11-26', 'ThuMon', 'Việt Nam'),
('CT085', 'Nguyễn Nhật Minh', '2003-07-27', 'HauVe', 'Việt Nam'),
('CT086', 'Lê Mạnh Dũng', '1994-04-20', 'TienVe', 'Việt Nam'),
('CT087', 'Lương Hoàng Nam', '1997-03-02', 'TienVe', 'Việt Nam'),
('CT088', 'Nguyễn Tuấn Anh', '1999-08-16', 'TienDao', 'Việt Nam'),
('CT089', 'Dương Văn Khoa', '1994-05-06', 'HauVe', 'Việt Nam'),
('CT090', 'Nguyễn Minh Dĩ', '1998-02-17', 'TienDao', 'Việt Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai) VALUES
('HD073', 'CT073', 'HPFC', 'HPFC', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD074', 'CT074', 'HPFC', 'HPFC', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD075', 'CT075', 'HPFC', 'HPFC', 6,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD076', 'CT076', 'HPFC', 'HPFC', 17, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD077', 'CT077', 'HPFC', 'HPFC', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD078', 'CT078', 'HPFC', 'HPFC', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD079', 'CT079', 'HPFC', 'HPFC', 16, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD080', 'CT080', 'HPFC', 'HPFC', 20, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD081', 'CT081', 'HPFC', 'HPFC', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD082', 'CT082', 'HPFC', 'HPFC', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD083', 'CT083', 'HPFC', 'HPFC', 10, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD084', 'CT084', 'HPFC', 'HPFC', 25, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD085', 'CT085', 'HPFC', 'HPFC', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD086', 'CT086', 'HPFC', 'HPFC', 14, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD087', 'CT087', 'HPFC', 'HPFC', 30, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD088', 'CT088', 'HPFC', 'HPFC', 19, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD089', 'CT089', 'HPFC', 'HPFC', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD090', 'CT090', 'HPFC', 'HPFC', 11, '2025-01-01', '2027-12-31', 'ChinhThuc');

-- (6) HOÀNG ANH GIA LAI (HAGL) - 18 cầu thủ
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT091', 'Trần Trung Kiên', '2003-02-09', 'ThuMon', 'Việt Nam'),
('CT092', 'Lê Văn Sơn', '1996-12-20', 'HauVe', 'Việt Nam'),
('CT093', 'Jairo Rodrigues', '1992-12-31', 'HauVe', 'Brazil'),
('CT094', 'Dụng Quang Nho', '2000-01-01', 'HauVe', 'Việt Nam'),
('CT095', 'A Hoàng', '1995-07-31', 'HauVe', 'Việt Nam'),
('CT096', 'Trần Minh Vương', '1995-03-28', 'TienVe', 'Việt Nam'),
('CT097', 'Châu Ngọc Quang', '1996-02-01', 'TienVe', 'Việt Nam'),
('CT098', 'Marciel Silva', '1995-08-10', 'TienVe', 'Brazil'),
('CT099', 'Nguyễn Quốc Việt', '2003-05-04', 'TienDao', 'Việt Nam'),
('CT100', 'Gabriel Ferreira', '1997-10-14', 'TienDao', 'Brazil'),
('CT101', 'Trần Bảo Toàn', '2000-07-14', 'TienDao', 'Việt Nam'),
('CT102', 'Phan Đình Vũ Hải', '1994-06-06', 'ThuMon', 'Việt Nam'),
('CT103', 'Nguyễn Hữu Anh Tài', '1996-02-28', 'HauVe', 'Việt Nam'),
('CT104', 'Phan Du Học', '2001-11-01', 'HauVe', 'Việt Nam'),
('CT105', 'Nguyễn Đức Việt', '2004-01-01', 'TienVe', 'Việt Nam'),
('CT106', 'Võ Đình Lâm', '2000-01-10', 'TienVe', 'Việt Nam'),
('CT107', 'Đinh Thanh Bình', '1998-03-19', 'TienDao', 'Việt Nam'),
('CT108', 'Vũ Minh Hiếu', '2002-05-10', 'TienDao', 'Việt Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai) VALUES
('HD091', 'CT091', 'HAGL', 'HAGL', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD092', 'CT092', 'HAGL', 'HAGL', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD093', 'CT093', 'HAGL', 'HAGL', 33, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD094', 'CT094', 'HAGL', 'HAGL', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD095', 'CT095', 'HAGL', 'HAGL', 6,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD096', 'CT096', 'HAGL', 'HAGL', 10, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD097', 'CT097', 'HAGL', 'HAGL', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD098', 'CT098', 'HAGL', 'HAGL', 22, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD099', 'CT099', 'HAGL', 'HAGL', 11, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD100', 'CT100', 'HAGL', 'HAGL', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD101', 'CT101', 'HAGL', 'HAGL', 20, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD102', 'CT102', 'HAGL', 'HAGL', 25, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD103', 'CT103', 'HAGL', 'HAGL', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD104', 'CT104', 'HAGL', 'HAGL', 17, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD105', 'CT105', 'HAGL', 'HAGL', 14, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD106', 'CT106', 'HAGL', 'HAGL', 16, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD107', 'CT107', 'HAGL', 'HAGL', 19, '2025-01-01', '2027-12-31', 'ChinhThuc'),
('HD108', 'CT108', 'HAGL', 'HAGL', 28, '2025-01-01', '2027-12-31', 'ChinhThuc');

-- ----------------------------------------------------------------------------
-- 6. NẠP DỮ LIỆU VÒNG ĐẤU (10 VÒNG)
-- ----------------------------------------------------------------------------
INSERT INTO VONG_DAU (MaVong, TenVong, ThuTu) VALUES
(1, 'Vòng 1', 1),
(2, 'Vòng 2', 2),
(3, 'Vòng 3', 3),
(4, 'Vòng 4', 4),
(5, 'Vòng 5', 5),
(6, 'Vòng 6', 6),
(7, 'Vòng 7', 7),
(8, 'Vòng 8', 8),
(9, 'Vòng 9', 9),
(10, 'Vòng 10', 10);

-- ----------------------------------------------------------------------------
-- 7. NẠP LỊCH THI ĐẤU TOÀN BỘ 30 TRẬN ĐẤU CỦA MÙA GIẢI (VÒNG TRÒN 2 LƯỢT)
-- ----------------------------------------------------------------------------
-- VÒNG 1 (Ngày 2026-03-01)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR01', 1, 'HNFC', 'HPFC', 'SAN_HD', '2026-03-01 19:15:00', 80000, 15200, 2, 1, 2, 1, 0, 0, 'ChuaDienRa'),
('TR02', 1, 'CAHN', 'HAGL', 'SAN_HD', '2026-03-02 19:15:00', 80000, 12000, 3, 0, 1, 2, 0, 0, 'ChuaDienRa'),
('TR03', 1, 'VTT',  'NDFC', 'SAN_MD', '2026-03-01 18:00:00', 60000, 18500, 1, 2, 1, 1, 0, 0, 'ChuaDienRa');

-- VÒNG 2 (Ngày 2026-03-08)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR04', 2, 'NDFC', 'HNFC', 'SAN_TT', '2026-03-08 18:00:00', 70000, 22000, 3, 2, 2, 2, 0, 0, 'ChuaDienRa'),
('TR05', 2, 'HPFC', 'CAHN', 'SAN_LT', '2026-03-08 19:15:00', 70000, 19500, 0, 2, 3, 1, 0, 0, 'ChuaDienRa'),
('TR06', 2, 'HAGL', 'VTT',  'SAN_PK', '2026-03-09 17:00:00', 50000, 9800,  1, 1, 1, 2, 0, 0, 'ChuaDienRa');

-- VÒNG 3 (Ngày 2026-03-15)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR07', 3, 'HNFC', 'CAHN', 'SAN_HD', '2026-03-15 19:15:00', 100000, 21500, 2, 2, 2, 3, 1, 0, 'ChuaDienRa'),
('TR08', 3, 'VTT',  'HPFC', 'SAN_MD', '2026-03-15 18:00:00', 60000,  14000, 2, 0, 1, 1, 0, 0, 'ChuaDienRa'),
('TR09', 3, 'NDFC', 'HAGL', 'SAN_TT', '2026-03-16 18:00:00', 70000,  18000, 4, 1, 0, 1, 0, 0, 'ChuaDienRa');

-- VÒNG 4 (Ngày 2026-03-22)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR10', 4, 'HAGL', 'HNFC', 'SAN_PK', '2026-03-22 17:00:00', 50000, 10500, 0, 1, 2, 1, 0, 0, 'ChuaDienRa'),
('TR11', 4, 'CAHN', 'VTT',  'SAN_HD', '2026-03-22 19:15:00', 90000, 17000, 1, 1, 2, 2, 0, 0, 'ChuaDienRa'),
('TR12', 4, 'HPFC', 'NDFC', 'SAN_LT', '2026-03-23 18:00:00', 70000, 16000, 1, 3, 1, 2, 0, 0, 'ChuaDienRa');

-- VÒNG 5 (Ngày 2026-03-29 - Hết lượt đi)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR13', 5, 'HNFC', 'VTT',  'SAN_HD', '2026-03-29 19:15:00', 90000, 18000, 2, 1, 1, 2, 0, 0, 'ChuaDienRa'),
('TR14', 5, 'NDFC', 'CAHN', 'SAN_TT', '2026-03-29 18:00:00', 80000, 24000, 2, 1, 2, 1, 0, 0, 'ChuaDienRa'),
('TR15', 5, 'HPFC', 'HAGL', 'SAN_LT', '2026-03-30 18:00:00', 60000, 13000, 2, 0, 1, 0, 0, 0, 'ChuaDienRa');

-- LƯỢT VỀ (VÒNG 6 ĐẾN 10)
-- VÒNG 6 (Đảo ngược Vòng 1)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR16', 6, 'HPFC', 'HNFC', 'SAN_LT', '2026-04-05 18:00:00', 80000, 17500, 1, 2, 2, 2, 0, 0, 'ChuaDienRa'),
('TR17', 6, 'HAGL', 'CAHN', 'SAN_PK', '2026-04-05 17:00:00', 50000, 11000, 0, 2, 1, 1, 0, 0, 'ChuaDienRa'),
('TR18', 6, 'NDFC', 'VTT',  'SAN_TT', '2026-04-06 18:00:00', 70000, 21000, 1, 0, 1, 1, 0, 0, 'ChuaDienRa');

-- VÒNG 7 (Đảo ngược Vòng 2)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR19', 7, 'HNFC', 'NDFC', 'SAN_HD', '2026-04-12 19:15:00', 90000, 19000, 1, 1, 1, 2, 0, 0, 'ChuaDienRa'),
('TR20', 7, 'CAHN', 'HPFC', 'SAN_HD', '2026-04-13 19:15:00', 80000, 14500, 2, 1, 1, 1, 0, 0, 'ChuaDienRa'),
('TR21', 7, 'VTT',  'HAGL', 'SAN_MD', '2026-04-12 18:00:00', 60000, 12000, 3, 1, 0, 1, 0, 0, 'ChuaDienRa');

-- VÒNG 8 (Đảo ngược Vòng 3)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR22', 8, 'CAHN', 'HNFC', 'SAN_HD', '2026-04-19 19:15:00', 100000, 22000, 1, 2, 3, 2, 0, 1, 'ChuaDienRa'),
('TR23', 8, 'HPFC', 'VTT',  'SAN_LT', '2026-04-19 18:00:00', 70000,  15000, 1, 1, 2, 2, 0, 0, 'ChuaDienRa'),
('TR24', 8, 'HAGL', 'NDFC', 'SAN_PK', '2026-04-20 17:00:00', 50000,  9500,  0, 2, 1, 0, 0, 0, 'ChuaDienRa');

-- VÒNG 9 (Đảo ngược Vòng 4)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR25', 9, 'HNFC', 'HAGL', 'SAN_HD', '2026-04-26 19:15:00', 80000, 14000, 3, 0, 0, 1, 0, 0, 'ChuaDienRa'),
('TR26', 9, 'VTT',  'CAHN', 'SAN_MD', '2026-04-26 18:00:00', 80000, 16500, 2, 1, 2, 1, 0, 0, 'ChuaDienRa'),
('TR27', 9, 'NDFC', 'HPFC', 'SAN_TT', '2026-04-27 18:00:00', 70000, 23000, 2, 0, 1, 1, 0, 0, 'ChuaDienRa');

-- VÒNG 10 (Đảo ngược Vòng 5 - Vòng hạ màn)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR28', 10, 'VTT',  'HNFC', 'SAN_MD', '2026-05-03 18:00:00', 90000, 20000, 1, 1, 2, 2, 0, 0, 'ChuaDienRa'),
('TR29', 10, 'CAHN', 'NDFC', 'SAN_HD', '2026-05-03 18:00:00', 90000, 21000, 1, 1, 1, 2, 0, 0, 'ChuaDienRa'),
('TR30', 10, 'HAGL', 'HPFC', 'SAN_PK', '2026-05-03 18:00:00', 50000, 10000, 2, 1, 1, 1, 0, 0, 'ChuaDienRa');

-- ----------------------------------------------------------------------------
-- 8. NẠP PHÂN CÔNG ĐỦ 4 TRỌNG TÀI CHO 30 TRẬN ĐẤU (12 TT / VÒNG, KHÔNG TRÙNG)
-- ----------------------------------------------------------------------------
-- Vòng 1: Trận TR01 (TT01, TT02, TT03, TT04), TR02 (TT05, TT06, TT07, TT08), TR03 (TT09, TT10, TT11, TT12)
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR01', 'Chinh', 'TT01'), ('TR01', 'Bien1', 'TT02'), ('TR01', 'Bien2', 'TT03'), ('TR01', 'Ban', 'TT04'),
('TR02', 'Chinh', 'TT05'), ('TR02', 'Bien1', 'TT06'), ('TR02', 'Bien2', 'TT07'), ('TR02', 'Ban', 'TT08'),
('TR03', 'Chinh', 'TT09'), ('TR03', 'Bien1', 'TT10'), ('TR03', 'Bien2', 'TT11'), ('TR03', 'Ban', 'TT12');

-- Vòng 2
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR04', 'Chinh', 'TT02'), ('TR04', 'Bien1', 'TT01'), ('TR04', 'Bien2', 'TT04'), ('TR04', 'Ban', 'TT03'),
('TR05', 'Chinh', 'TT07'), ('TR05', 'Bien1', 'TT05'), ('TR05', 'Bien2', 'TT08'), ('TR05', 'Ban', 'TT06'),
('TR06', 'Chinh', 'TT11'), ('TR06', 'Bien1', 'TT09'), ('TR06', 'Bien2', 'TT12'), ('TR06', 'Ban', 'TT10');

-- Vòng 3
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR07', 'Chinh', 'TT03'), ('TR07', 'Bien1', 'TT04'), ('TR07', 'Bien2', 'TT01'), ('TR07', 'Ban', 'TT02'),
('TR08', 'Chinh', 'TT06'), ('TR08', 'Bien1', 'TT08'), ('TR08', 'Bien2', 'TT05'), ('TR08', 'Ban', 'TT07'),
('TR09', 'Chinh', 'TT10'), ('TR09', 'Bien1', 'TT12'), ('TR09', 'Bien2', 'TT09'), ('TR09', 'Ban', 'TT11');

-- Vòng 4
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR10', 'Chinh', 'TT04'), ('TR10', 'Bien1', 'TT03'), ('TR10', 'Bien2', 'TT02'), ('TR10', 'Ban', 'TT01'),
('TR11', 'Chinh', 'TT08'), ('TR11', 'Bien1', 'TT07'), ('TR11', 'Bien2', 'TT06'), ('TR11', 'Ban', 'TT05'),
('TR12', 'Chinh', 'TT12'), ('TR12', 'Bien1', 'TT11'), ('TR12', 'Bien2', 'TT10'), ('TR12', 'Ban', 'TT09');

-- Vòng 5
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR13', 'Chinh', 'TT01'), ('TR13', 'Bien1', 'TT03'), ('TR13', 'Bien2', 'TT04'), ('TR13', 'Ban', 'TT02'),
('TR14', 'Chinh', 'TT05'), ('TR14', 'Bien1', 'TT07'), ('TR14', 'Bien2', 'TT08'), ('TR14', 'Ban', 'TT06'),
('TR15', 'Chinh', 'TT09'), ('TR15', 'Bien1', 'TT11'), ('TR15', 'Bien2', 'TT12'), ('TR15', 'Ban', 'TT10');

-- Vòng 6
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR16', 'Chinh', 'TT02'), ('TR16', 'Bien1', 'TT04'), ('TR16', 'Bien2', 'TT01'), ('TR16', 'Ban', 'TT03'),
('TR17', 'Chinh', 'TT06'), ('TR17', 'Bien1', 'TT08'), ('TR17', 'Bien2', 'TT05'), ('TR17', 'Ban', 'TT07'),
('TR18', 'Chinh', 'TT10'), ('TR18', 'Bien1', 'TT12'), ('TR18', 'Bien2', 'TT09'), ('TR18', 'Ban', 'TT11');

-- Vòng 7
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR19', 'Chinh', 'TT03'), ('TR19', 'Bien1', 'TT01'), ('TR19', 'Bien2', 'TT02'), ('TR19', 'Ban', 'TT04'),
('TR20', 'Chinh', 'TT07'), ('TR20', 'Bien1', 'TT05'), ('TR20', 'Bien2', 'TT06'), ('TR20', 'Ban', 'TT08'),
('TR21', 'Chinh', 'TT11'), ('TR21', 'Bien1', 'TT09'), ('TR21', 'Bien2', 'TT10'), ('TR21', 'Ban', 'TT12');

-- Vòng 8
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR22', 'Chinh', 'TT01'), ('TR22', 'Bien1', 'TT02'), ('TR22', 'Bien2', 'TT03'), ('TR22', 'Ban', 'TT04'),
('TR23', 'Chinh', 'TT05'), ('TR23', 'Bien1', 'TT06'), ('TR23', 'Bien2', 'TT07'), ('TR23', 'Ban', 'TT08'),
('TR24', 'Chinh', 'TT09'), ('TR24', 'Bien1', 'TT10'), ('TR24', 'Bien2', 'TT11'), ('TR24', 'Ban', 'TT12');

-- Vòng 9
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR25', 'Chinh', 'TT04'), ('TR25', 'Bien1', 'TT01'), ('TR25', 'Bien2', 'TT02'), ('TR25', 'Ban', 'TT03'),
('TR26', 'Chinh', 'TT08'), ('TR26', 'Bien1', 'TT05'), ('TR26', 'Bien2', 'TT06'), ('TR26', 'Ban', 'TT07'),
('TR27', 'Chinh', 'TT12'), ('TR27', 'Bien1', 'TT09'), ('TR27', 'Bien2', 'TT10'), ('TR27', 'Ban', 'TT11');

-- Vòng 10
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR28', 'Chinh', 'TT02'), ('TR28', 'Bien1', 'TT03'), ('TR28', 'Bien2', 'TT01'), ('TR28', 'Ban', 'TT04'),
('TR29', 'Chinh', 'TT06'), ('TR29', 'Bien1', 'TT07'), ('TR29', 'Bien2', 'TT05'), ('TR29', 'Ban', 'TT08'),
('TR30', 'Chinh', 'TT10'), ('TR30', 'Bien1', 'TT11'), ('TR30', 'Bien2', 'TT09'), ('TR30', 'Ban', 'TT12');

-- ----------------------------------------------------------------------------
-- 8.5. NẠP DANH SÁCH ĐĂNG KÝ THI ĐẤU CHO 30 TRẬN ĐẤU (11 CHÍNH THỨC + DỰ BỊ)
-- Loại trừ 30 trường hợp cầu thủ bị treo giò ở vòng kế tiếp do nhận thẻ đỏ
-- hoặc tích lũy đủ 2 thẻ vàng ở vòng liền trước.
-- ----------------------------------------------------------------------------
INSERT INTO DANG_KY_THI_DAU (MaTran, MaCauThu, MaDoi, VaiTroThiDau, SoAoDangKy)
SELECT
    sub.MaTran,
    sub.MaCauThu,
    sub.MaDoi,
    CASE WHEN sub.rn <= 11 THEN 'ChinhThuc' ELSE 'DuBi' END AS VaiTroThiDau,
    sub.SoAo AS SoAoDangKy
FROM (
    SELECT
        t.MaTran,
        hd.MaCauThu,
        hd.MaDoiHienTai AS MaDoi,
        hd.SoAo,
        ROW_NUMBER() OVER (PARTITION BY t.MaTran, hd.MaDoiHienTai ORDER BY hd.MaCauThu) AS rn
    FROM TRAN_DAU t
    JOIN HOP_DONG_CAU_THU hd
      ON hd.MaDoiHienTai IN (t.MaDoiNha, t.MaDoiKhach)
     AND hd.TrangThai = 'ChinhThuc'
    WHERE (t.MaTran, hd.MaCauThu) NOT IN (
        ('TR10', 'CT009'), ('TR10', 'CT002'), ('TR10', 'CT006'),
        ('TR18', 'CT038'), ('TR19', 'CT003'), ('TR19', 'CT059'),
        ('TR20', 'CT074'), ('TR20', 'CT021'), ('TR21', 'CT043'),
        ('TR22', 'CT004'), ('TR22', 'CT020'), ('TR23', 'CT075'),
        ('TR24', 'CT056'), ('TR24', 'CT060'), ('TR24', 'CT094'),
        ('TR25', 'CT010'), ('TR25', 'CT014'), ('TR25', 'CT093'),
        ('TR26', 'CT022'), ('TR26', 'CT023'), ('TR26', 'CT028'),
        ('TR26', 'CT039'), ('TR26', 'CT041'), ('TR27', 'CT076'),
        ('TR27', 'CT078'), ('TR28', 'CT044'), ('TR29', 'CT025'),
        ('TR29', 'CT058'), ('TR30', 'CT095'), ('TR30', 'CT080')
    )
) sub;

-- ----------------------------------------------------------------------------
-- 9. NẠP SỰ KIỆN BÀN THẮNG & THẺ PHẠT (ĐẢM BẢO KHỚP CHÍNH XÁC KẾT QUẢ TRẬN ĐẤU)
-- ----------------------------------------------------------------------------
-- TR01: HNFC 2 - 1 HPFC (Thẻ vàng: HNFC 2, HPFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK001', 'TR01', 'CT007', 'BanThang', 23),
('SK002', 'TR01', 'CT008', 'BanThang', 67),
('SK003', 'TR01', 'CT082', 'BanThang', 81),
('SK004', 'TR01', 'CT002', 'TheVang', 44),
('SK005', 'TR01', 'CT006', 'TheVang', 75),
('SK006', 'TR01', 'CT075', 'TheVang', 89);

-- TR02: CAHN 3 - 0 HAGL (Thẻ vàng: CAHN 1, HAGL 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK007', 'TR02', 'CT024', 'BanThang', 15),
('SK008', 'TR02', 'CT028', 'BanThang', 52),
('SK009', 'TR02', 'CT029', 'BanThang', 78),
('SK010', 'TR02', 'CT023', 'TheVang', 33),
('SK011', 'TR02', 'CT094', 'TheVang', 40),
('SK012', 'TR02', 'CT096', 'TheVang', 85);

-- TR03: VTT 1 - 2 NDFC (Thẻ vàng: VTT 1, NDFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK013', 'TR03', 'CT046', 'BanThang', 30),
('SK014', 'TR03', 'CT064', 'BanThang', 45),
('SK015', 'TR03', 'CT064', 'BanThang', 88),
('SK016', 'TR03', 'CT043', 'TheVang', 62),
('SK017', 'TR03', 'CT059', 'TheVang', 71);

-- TR04: NDFC 3 - 2 HNFC (Thẻ vàng: NDFC 2, HNFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK018', 'TR04', 'CT064', 'BanThang', 12),
('SK019', 'TR04', 'CT061', 'BanThang', 55),
('SK020', 'TR04', 'CT063', 'BanThang', 90),
('SK021', 'TR04', 'CT007', 'BanThang', 35),
('SK022', 'TR04', 'CT015', 'BanThang', 82),
('SK023', 'TR04', 'CT056', 'TheVang', 20),
('SK024', 'TR04', 'CT060', 'TheVang', 77),
('SK025', 'TR04', 'CT003', 'TheVang', 41),
('SK026', 'TR04', 'CT004', 'TheVang', 84);

-- TR05: HPFC 0 - 2 CAHN (Thẻ vàng: HPFC 3, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK027', 'TR05', 'CT024', 'BanThang', 28),
('SK028', 'TR05', 'CT029', 'BanThang', 64),
('SK029', 'TR05', 'CT074', 'TheVang', 30),
('SK030', 'TR05', 'CT078', 'TheVang', 50),
('SK031', 'TR05', 'CT080', 'TheVang', 73),
('SK032', 'TR05', 'CT020', 'TheVang', 60);

-- TR06: HAGL 1 - 1 VTT (Thẻ vàng: HAGL 1, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK033', 'TR06', 'CT096', 'BanThang', 40),
('SK034', 'TR06', 'CT042', 'BanThang', 65),
('SK035', 'TR06', 'CT095', 'TheVang', 55),
('SK036', 'TR06', 'CT038', 'TheVang', 38),
('SK037', 'TR06', 'CT041', 'TheVang', 82);

-- TR07: HNFC 2 - 2 CAHN (Thẻ vàng: HNFC 2, CAHN 3; Thẻ đỏ: HNFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK038', 'TR07', 'CT008', 'BanThang', 18),
('SK039', 'TR07', 'CT016', 'BanThang', 70),
('SK040', 'TR07', 'CT027', 'BanThang', 35),
('SK041', 'TR07', 'CT024', 'BanThang', 89),
('SK042', 'TR07', 'CT002', 'TheVang', 25),
('SK043', 'TR07', 'CT006', 'TheVang', 60),
('SK044', 'TR07', 'CT009', 'TheDo', 85),
('SK045', 'TR07', 'CT021', 'TheVang', 44),
('SK046', 'TR07', 'CT025', 'TheVang', 66),
('SK047', 'TR07', 'CT028', 'TheVang', 90);

-- TR08: VTT 2 - 0 HPFC (Thẻ vàng: VTT 1, HPFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK048', 'TR08', 'CT046', 'BanThang', 22),
('SK049', 'TR08', 'CT045', 'BanThang', 76),
('SK050', 'TR08', 'CT039', 'TheVang', 50),
('SK051', 'TR08', 'CT076', 'TheVang', 80);

-- TR09: NDFC 4 - 1 HAGL (Thẻ vàng: NDFC 0, HAGL 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK052', 'TR09', 'CT064', 'BanThang', 10),
('SK053', 'TR09', 'CT064', 'BanThang', 38),
('SK054', 'TR09', 'CT061', 'BanThang', 60),
('SK055', 'TR09', 'CT063', 'BanThang', 82),
('SK056', 'TR09', 'CT099', 'BanThang', 70),
('SK057', 'TR09', 'CT093', 'TheVang', 45);

-- TR10: HAGL 0 - 1 HNFC (Thẻ vàng: HAGL 2, HNFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK058', 'TR10', 'CT007', 'BanThang', 55),
('SK059', 'TR10', 'CT092', 'TheVang', 30),
('SK060', 'TR10', 'CT097', 'TheVang', 80),
('SK061', 'TR10', 'CT014', 'TheVang', 65);

-- TR11: CAHN 1 - 1 VTT (Thẻ vàng: CAHN 2, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK062', 'TR11', 'CT029', 'BanThang', 42),
('SK063', 'TR11', 'CT042', 'BanThang', 68),
('SK064', 'TR11', 'CT022', 'TheVang', 25),
('SK065', 'TR11', 'CT024', 'TheVang', 75),
('SK066', 'TR11', 'CT040', 'TheVang', 50),
('SK067', 'TR11', 'CT044', 'TheVang', 85);

-- TR12: HPFC 1 - 3 NDFC (Thẻ vàng: HPFC 1, NDFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK068', 'TR12', 'CT082', 'BanThang', 50),
('SK069', 'TR12', 'CT064', 'BanThang', 15),
('SK070', 'TR12', 'CT064', 'BanThang', 65),
('SK071', 'TR12', 'CT068', 'BanThang', 90),
('SK072', 'TR12', 'CT081', 'TheVang', 35),
('SK073', 'TR12', 'CT058', 'TheVang', 40),
('SK074', 'TR12', 'CT062', 'TheVang', 88);

-- TR13: HNFC 2 - 1 VTT (Thẻ vàng: HNFC 1, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK075', 'TR13', 'CT008', 'BanThang', 20),
('SK076', 'TR13', 'CT015', 'BanThang', 75),
('SK077', 'TR13', 'CT046', 'BanThang', 85),
('SK078', 'TR13', 'CT005', 'TheVang', 60),
('SK079', 'TR13', 'CT038', 'TheVang', 30),
('SK080', 'TR13', 'CT047', 'TheVang', 70);

-- TR14: NDFC 2 - 1 CAHN (Thẻ vàng: NDFC 2, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK081', 'TR14', 'CT064', 'BanThang', 30),
('SK082', 'TR14', 'CT063', 'BanThang', 72),
('SK083', 'TR14', 'CT024', 'BanThang', 55),
('SK084', 'TR14', 'CT057', 'TheVang', 45),
('SK085', 'TR14', 'CT061', 'TheVang', 80),
('SK086', 'TR14', 'CT026', 'TheVang', 65);

-- TR15: HPFC 2 - 0 HAGL (Thẻ vàng: HPFC 1, HAGL 0)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK087', 'TR15', 'CT082', 'BanThang', 40),
('SK088', 'TR15', 'CT083', 'BanThang', 68),
('SK089', 'TR15', 'CT077', 'TheVang', 52);

-- VÒNG 6 ĐẾN VÒNG 10 (15 trận lượt về)
-- TR16: HPFC 1 - 2 HNFC (Vàng: HP 2, HN 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK090', 'TR16', 'CT083', 'BanThang', 25),
('SK091', 'TR16', 'CT007', 'BanThang', 50),
('SK092', 'TR16', 'CT008', 'BanThang', 85),
('SK093', 'TR16', 'CT074', 'TheVang', 30),
('SK094', 'TR16', 'CT079', 'TheVang', 70),
('SK095', 'TR16', 'CT002', 'TheVang', 40),
('SK096', 'TR16', 'CT003', 'TheVang', 88);

-- TR17: HAGL 0 - 2 CAHN (Vàng: HAGL 1, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK097', 'TR17', 'CT028', 'BanThang', 18),
('SK098', 'TR17', 'CT029', 'BanThang', 72),
('SK099', 'TR17', 'CT098', 'TheVang', 55),
('SK100', 'TR17', 'CT021', 'TheVang', 65);

-- TR18: NDFC 1 - 0 VTT (Vàng: NDFC 1, VTT 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK101', 'TR18', 'CT064', 'BanThang', 60),
('SK102', 'TR18', 'CT059', 'TheVang', 45),
('SK103', 'TR18', 'CT043', 'TheVang', 80);

-- TR19: HNFC 1 - 1 NDFC (Vàng: HN 1, NDFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK104', 'TR19', 'CT008', 'BanThang', 33),
('SK105', 'TR19', 'CT064', 'BanThang', 75),
('SK106', 'TR19', 'CT004', 'TheVang', 50),
('SK107', 'TR19', 'CT056', 'TheVang', 25),
('SK108', 'TR19', 'CT060', 'TheVang', 85);

-- TR20: CAHN 2 - 1 HPFC (Vàng: CAHN 1, HP 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK109', 'TR20', 'CT024', 'BanThang', 22),
('SK110', 'TR20', 'CT027', 'BanThang', 65),
('SK111', 'TR20', 'CT082', 'BanThang', 80),
('SK112', 'TR20', 'CT020', 'TheVang', 40),
('SK113', 'TR20', 'CT075', 'TheVang', 60);

-- TR21: VTT 3 - 1 HAGL (Vàng: VTT 0, HAGL 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK114', 'TR21', 'CT042', 'BanThang', 15),
('SK115', 'TR21', 'CT046', 'BanThang', 48),
('SK116', 'TR21', 'CT045', 'BanThang', 82),
('SK117', 'TR21', 'CT096', 'BanThang', 60),
('SK118', 'TR21', 'CT094', 'TheVang', 70);

-- TR22: CAHN 1 - 2 HNFC (Vàng: CAHN 3, HN 2; Đỏ: HNFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK119', 'TR22', 'CT029', 'BanThang', 30),
('SK120', 'TR22', 'CT007', 'BanThang', 55),
('SK121', 'TR22', 'CT016', 'BanThang', 90),
('SK122', 'TR22', 'CT022', 'TheVang', 20),
('SK123', 'TR22', 'CT023', 'TheVang', 45),
('SK124', 'TR22', 'CT028', 'TheVang', 75),
('SK125', 'TR22', 'CT006', 'TheVang', 35),
('SK126', 'TR22', 'CT014', 'TheVang', 80),
('SK127', 'TR22', 'CT010', 'TheDo', 88);

-- TR23: HPFC 1 - 1 VTT (Vàng: HP 2, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK128', 'TR23', 'CT082', 'BanThang', 35),
('SK129', 'TR23', 'CT046', 'BanThang', 70),
('SK130', 'TR23', 'CT076', 'TheVang', 25),
('SK131', 'TR23', 'CT078', 'TheVang', 65),
('SK132', 'TR23', 'CT039', 'TheVang', 40),
('SK133', 'TR23', 'CT041', 'TheVang', 82);

-- TR24: HAGL 0 - 2 NDFC (Vàng: HAGL 1, NDFC 0)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK134', 'TR24', 'CT064', 'BanThang', 20),
('SK135', 'TR24', 'CT063', 'BanThang', 65),
('SK136', 'TR24', 'CT093', 'TheVang', 50);

-- TR25: HNFC 3 - 0 HAGL (Vàng: HN 0, HAGL 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK137', 'TR25', 'CT007', 'BanThang', 15),
('SK138', 'TR25', 'CT008', 'BanThang', 42),
('SK139', 'TR25', 'CT015', 'BanThang', 78),
('SK140', 'TR25', 'CT095', 'TheVang', 60);

-- TR26: VTT 2 - 1 CAHN (Vàng: VTT 2, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK141', 'TR26', 'CT042', 'BanThang', 25),
('SK142', 'TR26', 'CT046', 'BanThang', 80),
('SK143', 'TR26', 'CT024', 'BanThang', 60),
('SK144', 'TR26', 'CT038', 'TheVang', 35),
('SK145', 'TR26', 'CT044', 'TheVang', 75),
('SK146', 'TR26', 'CT025', 'TheVang', 50);

-- TR27: NDFC 2 - 0 HPFC (Vàng: NDFC 1, HP 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK147', 'TR27', 'CT064', 'BanThang', 40),
('SK148', 'TR27', 'CT061', 'BanThang', 75),
('SK149', 'TR27', 'CT058', 'TheVang', 30),
('SK150', 'TR27', 'CT080', 'TheVang', 65);

-- TR28: VTT 1 - 1 HNFC (Vàng: VTT 2, HN 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK151', 'TR28', 'CT046', 'BanThang', 45),
('SK152', 'TR28', 'CT008', 'BanThang', 70),
('SK153', 'TR28', 'CT040', 'TheVang', 30),
('SK154', 'TR28', 'CT043', 'TheVang', 85),
('SK155', 'TR28', 'CT002', 'TheVang', 50),
('SK156', 'TR28', 'CT004', 'TheVang', 90);

-- TR29: CAHN 1 - 1 NDFC (Vàng: CAHN 1, NDFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK157', 'TR29', 'CT024', 'BanThang', 35),
('SK158', 'TR29', 'CT064', 'BanThang', 82),
('SK159', 'TR29', 'CT021', 'TheVang', 60),
('SK160', 'TR29', 'CT057', 'TheVang', 40),
('SK161', 'TR29', 'CT062', 'TheVang', 75);

-- TR30: HAGL 2 - 1 HPFC (Vàng: HAGL 1, HP 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan) VALUES
('SK162', 'TR30', 'CT096', 'BanThang', 20),
('SK163', 'TR30', 'CT100', 'BanThang', 65),
('SK164', 'TR30', 'CT082', 'BanThang', 50),
('SK165', 'TR30', 'CT092', 'TheVang', 40),
('SK166', 'TR30', 'CT074', 'TheVang', 70);

-- ----------------------------------------------------------------------------
-- 10. CHỐT KẾT QUẢ TOÀN BỘ 30 TRẬN ĐẤU (KÍCH HOẠT TRIGGER ĐỐI SOÁT SỐ LIỆU)
-- ----------------------------------------------------------------------------
UPDATE TRAN_DAU SET TrangThai = 'DaKetThuc';


-- >>> FILE: 06_distributed_simulation.sql <<<

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
