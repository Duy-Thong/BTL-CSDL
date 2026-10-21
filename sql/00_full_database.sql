-- ============================================================================
-- Há»† CÆ  Sá»ž Dá»® LIá»†U QUáº¢N LÃ GIáº¢I BÃ“NG ÄÃ CHUYÃŠN NGHIá»†P
-- MÃ”N Há»ŒC: CÃC Há»† THá»NG CÆ  Sá»ž Dá»® LIá»†U - MÃƒ Lá»šP: M26CQ02 (NHÃ“M 2)
-- PHáº¦N 1: DDL Táº O Báº¢NG, KHÃ“A CHÃNH, KHÃ“A NGOáº I VÃ€ RÃ€NG BUá»˜C TOÃ€N Váº¸N
-- Há»† QUáº¢N TRá»Š: PostgreSQL
-- ============================================================================

-- XÃ³a cÃ¡c báº£ng cÅ© náº¿u Ä‘Ã£ tá»“n táº¡i (theo thá»© tá»± phá»¥ thuá»™c khÃ³a ngoáº¡i)
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

-- 1. Báº¢NG SÃ‚N Váº¬N Äá»˜NG
CREATE TABLE SAN_VAN_DONG (
    MaSan VARCHAR(10) PRIMARY KEY,
    TenSan VARCHAR(100) NOT NULL UNIQUE,
    DiaChi VARCHAR(200) NOT NULL,
    SucChua INT NOT NULL CHECK (SucChua > 0)
);

-- 2. Báº¢NG Äá»˜I BÃ“NG
CREATE TABLE DOI_BONG (
    MaDoi VARCHAR(10) PRIMARY KEY,
    TenDoi VARCHAR(100) NOT NULL UNIQUE,
    HLV VARCHAR(100) NOT NULL,
    MaSanNha VARCHAR(10) NOT NULL REFERENCES SAN_VAN_DONG(MaSan) ON UPDATE CASCADE
);

-- 3. Báº¢NG MÃ€U ÃO Äá»˜I BÃ“NG (Tá»‘i thiá»ƒu 2 mÃ u Ã¡o má»—i Ä‘á»™i)
CREATE TABLE MAU_AO_DOI_BONG (
    MaDoi VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON DELETE CASCADE ON UPDATE CASCADE,
    LoaiMauAo VARCHAR(20) NOT NULL CHECK (LoaiMauAo IN ('SanNha', 'SanKhach', 'Phu')),
    MoTaMau VARCHAR(50) NOT NULL,
    PRIMARY KEY (MaDoi, LoaiMauAo)
);

-- 4. Báº¢NG Cáº¦U THá»¦
CREATE TABLE CAU_THU (
    MaCauThu VARCHAR(10) PRIMARY KEY,
    HoTen VARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    ViTri VARCHAR(20) NOT NULL CHECK (ViTri IN ('ThuMon', 'HauVe', 'TienVe', 'TienDao')),
    QuocTich VARCHAR(50) NOT NULL DEFAULT 'Viá»‡t Nam'
);

-- 5. Báº¢NG Há»¢P Äá»’NG Cáº¦U THá»¦ & Äá»˜I BÃ“NG THI Äáº¤U
CREATE TABLE HOP_DONG_CAU_THU (
    MaHD VARCHAR(10) PRIMARY KEY,
    MaCauThu VARCHAR(10) NOT NULL REFERENCES CAU_THU(MaCauThu) ON UPDATE CASCADE,
    MaDoiChuQuan VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    MaDoiHienTai VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    SoAo INT NOT NULL CHECK (SoAo BETWEEN 1 AND 35),
    NgayBatDau DATE NOT NULL,
    NgayKetThuc DATE NOT NULL,
    TrangThai VARCHAR(20) NOT NULL CHECK (TrangThai IN ('ChinhThuc', 'ChoMuon')),
    MucLuong DECIMAL(15, 2) DEFAULT 0 CHECK (MucLuong >= 0),
    CHECK (NgayKetThuc > NgayBatDau)
);

-- 6. Báº¢NG TRá»ŒNG TÃ€I
CREATE TABLE TRONG_TAI (
    MaTrongTai VARCHAR(10) PRIMARY KEY,
    HoTen VARCHAR(100) NOT NULL,
    NgaySinh DATE NOT NULL,
    QueQuan VARCHAR(100) NOT NULL,
    CapBac VARCHAR(50) NOT NULL DEFAULT 'Quá»‘c gia'
);

-- 7. Báº¢NG VÃ’NG Äáº¤U (10 vÃ²ng Ä‘áº¥u mÃ¹a giáº£i)
CREATE TABLE VONG_DAU (
    MaVong INT PRIMARY KEY CHECK (MaVong BETWEEN 1 AND 10),
    TenVong VARCHAR(50) NOT NULL UNIQUE,
    ThuTu INT NOT NULL UNIQUE CHECK (ThuTu BETWEEN 1 AND 10)
);

-- 8. Báº¢NG TRáº¬N Äáº¤U
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
    CHECK (MaDoiNha <> MaDoiKhach)
);

-- 9. Báº¢NG PHÃ‚N CÃ”NG TRá»ŒNG TÃ€I (Äá»§ 4 trá»ng tÃ i cho má»—i tráº­n)
CREATE TABLE PHAN_CONG_TRONG_TAI (
    MaTran VARCHAR(10) NOT NULL REFERENCES TRAN_DAU(MaTran) ON DELETE CASCADE ON UPDATE CASCADE,
    VaiTro VARCHAR(20) NOT NULL CHECK (VaiTro IN ('Chinh', 'Bien1', 'Bien2', 'Ban')),
    MaTrongTai VARCHAR(10) NOT NULL REFERENCES TRONG_TAI(MaTrongTai) ON UPDATE CASCADE,
    PRIMARY KEY (MaTran, VaiTro)
);

-- 10. Báº¢NG ÄÄ‚NG KÃ THI Äáº¤U (Tá»‘i Ä‘a 18 cáº§u thá»§ má»—i Ä‘á»™i trong tráº­n)
CREATE TABLE DANG_KY_THI_DAU (
    MaTran VARCHAR(10) NOT NULL REFERENCES TRAN_DAU(MaTran) ON DELETE CASCADE ON UPDATE CASCADE,
    MaCauThu VARCHAR(10) NOT NULL REFERENCES CAU_THU(MaCauThu) ON UPDATE CASCADE,
    MaDoi VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    LoaiDangKy VARCHAR(20) NOT NULL CHECK (LoaiDangKy IN ('ChinhThuc', 'DuBi')),
    SoAoTran INT NOT NULL CHECK (SoAoTran BETWEEN 1 AND 35),
    PRIMARY KEY (MaTran, MaCauThu)
);

-- 11. Báº¢NG Sá»° KIá»†N TRáº¬N Äáº¤U (BÃ n tháº¯ng, Tháº» vÃ ng, Tháº» Ä‘á»)
CREATE TABLE SU_KIEN_TRAN_DAU (
    MaSuKien VARCHAR(15) PRIMARY KEY,
    MaTran VARCHAR(10) NOT NULL REFERENCES TRAN_DAU(MaTran) ON DELETE CASCADE ON UPDATE CASCADE,
    MaCauThu VARCHAR(10) NOT NULL REFERENCES CAU_THU(MaCauThu) ON UPDATE CASCADE,
    MaDoi VARCHAR(10) NOT NULL REFERENCES DOI_BONG(MaDoi) ON UPDATE CASCADE,
    LoaiSuKien VARCHAR(20) NOT NULL CHECK (LoaiSuKien IN ('BanThang', 'TheVang', 'TheDo')),
    PhutGhiNhan INT NOT NULL CHECK (PhutGhiNhan BETWEEN 1 AND 120)
);

-- Táº O CHá»ˆ Má»¤C (INDEX) Äá»‚ Tá»I Æ¯U TRUY Váº¤N
CREATE INDEX idx_tran_dau_vong ON TRAN_DAU(MaVong);
CREATE INDEX idx_tran_dau_doinha ON TRAN_DAU(MaDoiNha);
CREATE INDEX idx_tran_dau_doikhach ON TRAN_DAU(MaDoiKhach);
CREATE INDEX idx_hopdong_doihientai ON HOP_DONG_CAU_THU(MaDoiHienTai);
CREATE INDEX idx_sukien_tran ON SU_KIEN_TRAN_DAU(MaTran);
CREATE INDEX idx_dangky_tran ON DANG_KY_THI_DAU(MaTran);
-- ============================================================================
-- PHáº¦N 2: CÃ€I Äáº¶T 5 TRIGGER Báº®T BUá»˜C KIá»‚M TRA TOÃ€N Váº¸N NGHIá»†P Vá»¤
-- Há»† QUáº¢N TRá»Š: PostgreSQL (PL/pgSQL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRIGGER 1: KIá»‚M TRA Sá» ÃO Cáº¦U THá»¦ DUY NHáº¤T TRONG CÃ™NG Má»˜T Äá»˜I BÃ“NG
-- Nghiá»‡p vá»¥: CÃ¡c cáº§u thá»§ trong cÃ¹ng má»™t Ä‘á»™i khÃ´ng Ä‘Æ°á»£c trÃ¹ng sá»‘ Ã¡o.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_so_ao_duy_nhat()
RETURNS TRIGGER AS $$
DECLARE
    v_trung_so_ao INT;
BEGIN
    SELECT COUNT(*) INTO v_trung_so_ao
    FROM HOP_DONG_CAU_THU
    WHERE MaDoiHienTai = NEW.MaDoiHienTai
      AND SoAo = NEW.SoAo
      AND MaCauThu <> NEW.MaCauThu
      -- Kiá»ƒm tra thá»i háº¡n há»£p Ä‘á»“ng giao thoa
      AND NOT (NgayKetThuc < NEW.NgayBatDau OR NgayBatDau > NEW.NgayKetThuc);

    IF v_trung_so_ao > 0 THEN
        RAISE EXCEPTION 'Lá»—i nghiá»‡p vá»¥: Sá»‘ Ã¡o % Ä‘Ã£ Ä‘Æ°á»£c Ä‘Äƒng kÃ½ cho cáº§u thá»§ khÃ¡c trong Ä‘á»™i bÃ³ng %!', 
            NEW.SoAo, NEW.MaDoiHienTai;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_so_ao_duy_nhat ON HOP_DONG_CAU_THU;
CREATE TRIGGER trg_check_so_ao_duy_nhat
BEFORE INSERT OR UPDATE OF SoAo, MaDoiHienTai, NgayBatDau, NgayKetThuc
ON HOP_DONG_CAU_THU
FOR EACH ROW
EXECUTE FUNCTION fn_check_so_ao_duy_nhat();


-- ----------------------------------------------------------------------------
-- TRIGGER 2: KIá»‚M TRA GIá»šI Háº N Tá»I ÄA 30 Cáº¦U THá»¦ CHO Má»–I Äá»˜I BÃ“NG
-- Nghiá»‡p vá»¥: Má»™t Ä‘á»™i bÃ³ng chá»‰ cÃ³ tá»‘i Ä‘a 30 cáº§u thá»§ cÃ³ há»£p Ä‘á»“ng cÃ²n hiá»‡u lá»±c.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_gioi_han_30_cau_thu()
RETURNS TRIGGER AS $$
DECLARE
    v_so_luong INT;
BEGIN
    SELECT COUNT(*) INTO v_so_luong
    FROM HOP_DONG_CAU_THU
    WHERE MaDoiHienTai = NEW.MaDoiHienTai
      AND MaCauThu <> NEW.MaCauThu
      AND CURRENT_DATE BETWEEN NgayBatDau AND NgayKetThuc;

    IF v_so_luong >= 30 THEN
        RAISE EXCEPTION 'Lá»—i nghiá»‡p vá»¥: Äá»™i bÃ³ng % Ä‘Ã£ cÃ³ Ä‘á»§ tá»‘i Ä‘a 30 cáº§u thá»§ Ä‘ang thi Ä‘áº¥u!', 
            NEW.MaDoiHienTai;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_gioi_han_30_cau_thu ON HOP_DONG_CAU_THU;
CREATE TRIGGER trg_check_gioi_han_30_cau_thu
BEFORE INSERT OR UPDATE OF MaDoiHienTai
ON HOP_DONG_CAU_THU
FOR EACH ROW
EXECUTE FUNCTION fn_check_gioi_han_30_cau_thu();


-- ----------------------------------------------------------------------------
-- TRIGGER 3: Má»˜T TRá»ŒNG TÃ€I CHá»ˆ ÄIá»€U KHIá»‚N Tá»I ÄA 1 TRáº¬N TRONG Má»–I VÃ’NG Äáº¤U
-- Nghiá»‡p vá»¥: 1 trá»ng tÃ i khÃ´ng Ä‘Æ°á»£c phÃ¢n cÃ´ng cho 2 tráº­n Ä‘áº¥u trong cÃ¹ng 1 vÃ²ng.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_trong_tai_toi_da_1_tran_1_vong()
RETURNS TRIGGER AS $$
DECLARE
    v_ma_vong INT;
    v_so_tran INT;
BEGIN
    -- Láº¥y mÃ£ vÃ²ng Ä‘áº¥u cá»§a tráº­n Ä‘áº¥u Ä‘ang Ä‘Æ°á»£c phÃ¢n cÃ´ng
    SELECT MaVong INTO v_ma_vong
    FROM TRAN_DAU
    WHERE MaTran = NEW.MaTran;

    -- Kiá»ƒm tra xem trá»ng tÃ i nÃ y Ä‘Ã£ cÃ³ tráº­n nÃ o khÃ¡c trong cÃ¹ng vÃ²ng Ä‘áº¥u chÆ°a
    SELECT COUNT(*) INTO v_so_tran
    FROM PHAN_CONG_TRONG_TAI pc
    JOIN TRAN_DAU td ON pc.MaTran = td.MaTran
    WHERE pc.MaTrongTai = NEW.MaTrongTai
      AND td.MaVong = v_ma_vong
      AND td.MaTran <> NEW.MaTran;

    IF v_so_tran > 0 THEN
        RAISE EXCEPTION 'Lá»—i nghiá»‡p vá»¥: Trá»ng tÃ i % Ä‘Ã£ Ä‘Æ°á»£c phÃ¢n cÃ´ng Ä‘iá»u khiá»ƒn má»™t tráº­n Ä‘áº¥u khÃ¡c trong vÃ²ng Ä‘áº¥u sá»‘ %!', 
            NEW.MaTrongTai, v_ma_vong;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_trong_tai_toi_da_1_tran_1_vong ON PHAN_CONG_TRONG_TAI;
CREATE TRIGGER trg_check_trong_tai_toi_da_1_tran_1_vong
BEFORE INSERT OR UPDATE OF MaTrongTai, MaTran
ON PHAN_CONG_TRONG_TAI
FOR EACH ROW
EXECUTE FUNCTION fn_check_trong_tai_toi_da_1_tran_1_vong();


-- ----------------------------------------------------------------------------
-- TRIGGER 4: Má»–I Äá»˜I BÃ“NG CHá»ˆ ÄÄ‚NG KÃ Tá»I ÄA 18 Cáº¦U THá»¦ TRONG Má»˜T TRáº¬N Äáº¤U
-- Nghiá»‡p vá»¥: Giá»›i háº¡n danh sÃ¡ch Ä‘Äƒng kÃ½ thi Ä‘áº¥u cá»§a má»—i Ä‘á»™i trong 1 tráº­n lÃ  18.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_dang_ky_toi_da_18_cau_thu()
RETURNS TRIGGER AS $$
DECLARE
    v_so_cau_thu_da_dang_ky INT;
BEGIN
    SELECT COUNT(*) INTO v_so_cau_thu_da_dang_ky
    FROM DANG_KY_THI_DAU
    WHERE MaTran = NEW.MaTran
      AND MaDoi = NEW.MaDoi
      AND MaCauThu <> NEW.MaCauThu;

    IF v_so_cau_thu_da_dang_ky >= 18 THEN
        RAISE EXCEPTION 'Lá»—i nghiá»‡p vá»¥: Äá»™i bÃ³ng % Ä‘Ã£ Ä‘Äƒng kÃ½ Ä‘á»§ tá»‘i Ä‘a 18 cáº§u thá»§ cho tráº­n Ä‘áº¥u %!', 
            NEW.MaDoi, NEW.MaTran;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_dang_ky_toi_da_18_cau_thu ON DANG_KY_THI_DAU;
CREATE TRIGGER trg_check_dang_ky_toi_da_18_cau_thu
BEFORE INSERT ON DANG_KY_THI_DAU
FOR EACH ROW
EXECUTE FUNCTION fn_check_dang_ky_toi_da_18_cau_thu();


-- ----------------------------------------------------------------------------
-- TRIGGER 5: KIá»‚M TRA KHá»šP Tá»”NG BÃ€N THáº®NG VÃ€ THáºº PHáº T Vá»šI Káº¾T QUáº¢ TRáº¬N Äáº¤U
-- Nghiá»‡p vá»¥: Khi tráº­n Ä‘áº¥u káº¿t thÃºc, tá»•ng bÃ n tháº¯ng/tháº» trong báº£ng sá»± kiá»‡n 
--            pháº£i khá»›p chÃ­nh xÃ¡c vá»›i tá»‰ sá»‘ vÃ  sá»‘ tháº» ghi nháº­n trong báº£ng TRAN_DAU.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_khop_ban_thang_va_the()
RETURNS TRIGGER AS $$
DECLARE
    v_ban_nha INT;
    v_ban_khach INT;
    v_the_vang_nha INT;
    v_the_vang_khach INT;
    v_the_do_nha INT;
    v_the_do_khach INT;
BEGIN
    -- Chá»‰ kiá»ƒm tra khi tráº­n Ä‘áº¥u Ä‘Æ°á»£c chuyá»ƒn sang tráº¡ng thÃ¡i Ä‘Ã£ káº¿t thÃºc
    IF NEW.TrangThai = 'DaKetThuc' THEN
        -- Äáº¿m sá»± kiá»‡n bÃ n tháº¯ng
        SELECT COUNT(*) INTO v_ban_nha
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiNha AND LoaiSuKien = 'BanThang';

        SELECT COUNT(*) INTO v_ban_khach
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiKhach AND LoaiSuKien = 'BanThang';

        -- Äáº¿m sá»± kiá»‡n tháº» vÃ ng
        SELECT COUNT(*) INTO v_the_vang_nha
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiNha AND LoaiSuKien = 'TheVang';

        SELECT COUNT(*) INTO v_the_vang_khach
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiKhach AND LoaiSuKien = 'TheVang';

        -- Äáº¿m sá»± kiá»‡n tháº» Ä‘á»
        SELECT COUNT(*) INTO v_the_do_nha
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiNha AND LoaiSuKien = 'TheDo';

        SELECT COUNT(*) INTO v_the_do_khach
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiKhach AND LoaiSuKien = 'TheDo';

        -- So sÃ¡nh Ä‘á»‘i chiáº¿u vá»›i sá»‘ liá»‡u tráº­n Ä‘áº¥u
        IF v_ban_nha <> NEW.BanThangNha OR v_ban_khach <> NEW.BanThangKhach THEN
            RAISE EXCEPTION 'Lá»—i toÃ n váº¹n dá»¯ liá»‡u: Sá»‘ bÃ n tháº¯ng trong báº£ng sá»± kiá»‡n (NhÃ : %, KhÃ¡ch: %) khÃ´ng khá»›p vá»›i tá»‰ sá»‘ tráº­n Ä‘áº¥u (NhÃ : %, KhÃ¡ch: %)!',
                v_ban_nha, v_ban_khach, NEW.BanThangNha, NEW.BanThangKhach;
        END IF;

        IF v_the_vang_nha <> NEW.TheVangNha OR v_the_vang_khach <> NEW.TheVangKhach THEN
            RAISE EXCEPTION 'Lá»—i toÃ n váº¹n dá»¯ liá»‡u: Sá»‘ tháº» vÃ ng trong báº£ng sá»± kiá»‡n khÃ´ng khá»›p vá»›i tá»•ng tháº» vÃ ng cá»§a tráº­n Ä‘áº¥u!';
        END IF;

        IF v_the_do_nha <> NEW.TheDoNha OR v_the_do_khach <> NEW.TheDoKhach THEN
            RAISE EXCEPTION 'Lá»—i toÃ n váº¹n dá»¯ liá»‡u: Sá»‘ tháº» Ä‘á» trong báº£ng sá»± kiá»‡n khÃ´ng khá»›p vá»›i tá»•ng tháº» Ä‘á» cá»§a tráº­n Ä‘áº¥u!';
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
-- ============================================================================
-- PHáº¦N 3: CÃ€I Äáº¶T 5 GIAO Dá»ŠCH (TRANSACTION / STORED PROCEDURE) TRá»ŒNG Yáº¾U
-- Há»† QUáº¢N TRá»Š: PostgreSQL (PL/pgSQL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- GIAO Dá»ŠCH 1: KHá»žI Táº O Lá»ŠCH THI Äáº¤U CHO Má»˜T TRáº¬N Äáº¤U THUá»˜C VÃ’NG Äáº¤U
-- Äáº£m báº£o: Hai Ä‘á»™i khÃ´ng trÃ¹ng nhau, cáº·p Ä‘áº¥u chÆ°a tá»«ng Ä‘Ã¡ trÃªn sÃ¢n nhÃ  nÃ y, 
--          sÃ¢n váº­n Ä‘á»™ng khÃ´ng bá»‹ trÃ¹ng giá» thi Ä‘áº¥u.
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
    -- 1. Kiá»ƒm tra hai Ä‘á»™i khÃ´ng Ä‘Æ°á»£c trÃ¹ng nhau
    IF p_ma_doi_nha = p_ma_doi_khach THEN
        RAISE EXCEPTION 'Lá»—i giao dá»‹ch: Äá»™i chá»§ nhÃ  vÃ  Ä‘á»™i khÃ¡ch khÃ´ng Ä‘Æ°á»£c trÃ¹ng nhau!';
    END IF;

    -- 2. Kiá»ƒm tra thá»ƒ thá»©c vÃ²ng trÃ²n 2 lÆ°á»£t: Cáº·p Ä‘áº¥u nÃ y trÃªn sÃ¢n nhÃ  nÃ y Ä‘Ã£ tá»“n táº¡i chÆ°a
    SELECT COUNT(*) INTO v_da_ton_tai
    FROM TRAN_DAU
    WHERE MaDoiNha = p_ma_doi_nha AND MaDoiKhach = p_ma_doi_khach;

    IF v_da_ton_tai > 0 THEN
        RAISE EXCEPTION 'Lá»—i giao dá»‹ch: Tráº­n Ä‘áº¥u giá»¯a % (sÃ¢n nhÃ ) vÃ  % (sÃ¢n khÃ¡ch) Ä‘Ã£ Ä‘Æ°á»£c xáº¿p lá»‹ch trÆ°á»›c Ä‘Ã³!',
            p_ma_doi_nha, p_ma_doi_khach;
    END IF;

    -- 3. Kiá»ƒm tra sÃ¢n váº­n Ä‘á»™ng khÃ´ng bá»‹ trÃ¹ng giá» thi Ä‘áº¥u (cÃ¡ch nhau tá»‘i thiá»ƒu 4 tiáº¿ng)
    SELECT COUNT(*) INTO v_trung_lich_san
    FROM TRAN_DAU
    WHERE MaSan = p_ma_san
      AND ABS(EXTRACT(EPOCH FROM (NgayGio - p_ngay_gio))) < 14400;

    IF v_trung_lich_san > 0 THEN
        RAISE EXCEPTION 'Lá»—i giao dá»‹ch: SÃ¢n váº­n Ä‘á»™ng % Ä‘Ã£ cÃ³ tráº­n Ä‘áº¥u diá»…n ra trong khoáº£ng thá»i gian nÃ y!',
            p_ma_san;
    END IF;

    -- 4. Thá»±c hiá»‡n thÃªm tráº­n Ä‘áº¥u má»›i
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
-- GIAO Dá»ŠCH 2: PHÃ‚N CÃ”NG Äá»¦ Tá»” 4 TRá»ŒNG TÃ€I CHO Má»˜T TRáº¬N Äáº¤U
-- Äáº£m báº£o: Äá»§ 4 trá»ng tÃ i khÃ¡c nhau, khÃ´ng ai bá»‹ trÃ¹ng lá»‹ch trong cÃ¹ng vÃ²ng Ä‘áº¥u.
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
    -- 1. Kiá»ƒm tra 4 trá»ng tÃ i trong tá»• pháº£i hoÃ n toÃ n phÃ¢n biá»‡t
    IF p_tt_chinh IN (p_tt_bien1, p_tt_bien2, p_tt_ban) OR
       p_tt_bien1 IN (p_tt_bien2, p_tt_ban) OR
       p_tt_bien2 = p_tt_ban THEN
        RAISE EXCEPTION 'Lá»—i giao dá»‹ch: Bá»‘n trá»ng tÃ i trong tá»• phÃ¢n cÃ´ng pháº£i lÃ  cÃ¡c cÃ¡ nhÃ¢n phÃ¢n biá»‡t!';
    END IF;

    -- 2. XÃ³a phÃ¢n cÃ´ng cÅ© náº¿u cÃ³ Ä‘á»ƒ gÃ¡n láº¡i toÃ n bá»™ tá»• trá»ng tÃ i
    DELETE FROM PHAN_CONG_TRONG_TAI WHERE MaTran = p_ma_tran;

    -- 3. ThÃªm 4 vá»‹ trÃ­ (Trigger trg_check_trong_tai_toi_da_1_tran_1_vong sáº½ tá»± Ä‘á»™ng kiá»ƒm tra vÃ²ng Ä‘áº¥u)
    INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
    (p_ma_tran, 'Chinh', p_tt_chinh),
    (p_ma_tran, 'Bien1', p_tt_bien1),
    (p_ma_tran, 'Bien2', p_tt_bien2),
    (p_ma_tran, 'Ban', p_tt_ban);
END;
$$;


-- ----------------------------------------------------------------------------
-- GIAO Dá»ŠCH 3: ÄÄ‚NG KÃ DANH SÃCH Cáº¦U THá»¦ THI Äáº¤U CHO Má»˜T TRáº¬N Äáº¤U
-- Äáº£m báº£o: Cáº§u thá»§ thuá»™c biÃªn cháº¿ Ä‘á»™i bÃ³ng, gÃ¡n Ä‘Ãºng sá»‘ Ã¡o Ä‘Ã£ Ä‘Äƒng kÃ½.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_dang_ky_cau_thu_tran(
    p_ma_tran VARCHAR(10),
    p_ma_doi VARCHAR(10),
    p_ma_cau_thu VARCHAR(10),
    p_loai_dang_ky VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_so_ao INT;
    v_hop_le INT;
BEGIN
    -- 1. Kiá»ƒm tra cáº§u thá»§ cÃ³ há»£p Ä‘á»“ng cÃ²n hiá»‡u lá»±c vÃ  Ä‘ang thi Ä‘áº¥u cho Ä‘á»™i nÃ y khÃ´ng
    SELECT SoAo INTO v_so_ao
    FROM HOP_DONG_CAU_THU
    WHERE MaCauThu = p_ma_cau_thu
      AND MaDoiHienTai = p_ma_doi
      AND CURRENT_DATE BETWEEN NgayBatDau AND NgayKetThuc;

    IF v_so_ao IS NULL THEN
        RAISE EXCEPTION 'Lá»—i giao dá»‹ch: Cáº§u thá»§ % khÃ´ng thuá»™c danh sÃ¡ch thi Ä‘áº¥u há»£p lá»‡ cá»§a Ä‘á»™i bÃ³ng %!',
            p_ma_cau_thu, p_ma_doi;
    END IF;

    -- 2. Thá»±c hiá»‡n Ä‘Äƒng kÃ½ (Trigger trg_check_dang_ky_toi_da_18_cau_thu sáº½ cháº·n náº¿u vÆ°á»£t 18 ngÆ°á»i)
    INSERT INTO DANG_KY_THI_DAU (MaTran, MaCauThu, MaDoi, LoaiDangKy, SoAoTran)
    VALUES (p_ma_tran, p_ma_cau_thu, p_ma_doi, p_loai_dang_ky, v_so_ao);
END;
$$;


-- ----------------------------------------------------------------------------
-- GIAO Dá»ŠCH 4: GHI NHáº¬N Káº¾T QUáº¢ VÃ€ Sá»° KIá»†N TRáº¬N Äáº¤U (HOÃ€N Táº¤T TRáº¬N)
-- Äáº£m báº£o: Ghi nháº­n tá»‰ sá»‘, tháº» pháº¡t, sá»‘ lÆ°á»£ng khÃ¡n giáº£ vÃ  Ä‘á»•i tráº¡ng thÃ¡i sang 'DaKetThuc'
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
    -- 1. Láº¥y thÃ´ng tin tráº­n Ä‘áº¥u
    SELECT TrangThai, NgayGio INTO v_trang_thai, v_ngay_gio
    FROM TRAN_DAU
    WHERE MaTran = p_ma_tran;

    IF v_trang_thai IS NULL THEN
        RAISE EXCEPTION 'Lá»—i giao dá»‹ch: KhÃ´ng tÃ¬m tháº¥y tráº­n Ä‘áº¥u cÃ³ mÃ£ %!', p_ma_tran;
    END IF;

    -- 2. Kiá»ƒm tra ngÃ y giá» thi Ä‘áº¥u khÃ´ng Ä‘Æ°á»£c vÆ°á»£t quÃ¡ thá»i gian hiá»‡n táº¡i
    IF v_ngay_gio > CURRENT_TIMESTAMP THEN
        RAISE EXCEPTION 'Lá»—i giao dá»‹ch: KhÃ´ng thá»ƒ káº¿t thÃºc tráº­n Ä‘áº¥u chÆ°a diá»…n ra (thá»i gian thi Ä‘áº¥u á»Ÿ tÆ°Æ¡ng lai)!';
    END IF;

    -- 3. Cáº­p nháº­t káº¿t quáº£ chung cuá»™c vÃ  chuyá»ƒn tráº¡ng thÃ¡i
    -- (Trigger trg_check_khop_ban_thang_va_the sáº½ kiá»ƒm tra tÃ­nh khá»›p vá»›i cÃ¡c sá»± kiá»‡n Ä‘Ã£ ghi)
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
-- GIAO Dá»ŠCH 5: CHUYá»‚N NHÆ¯á»¢NG HOáº¶C CHO MÆ¯á»¢N Cáº¦U THá»¦
-- Äáº£m báº£o: Kiá»ƒm tra Ä‘á»™i má»›i chÆ°a quÃ¡ 30 cáº§u thá»§, sá»‘ Ã¡o má»›i chÆ°a ai mang,
--          cáº­p nháº­t Ä‘Ã³ng há»£p Ä‘á»“ng cÅ© vÃ  má»Ÿ há»£p Ä‘á»“ng má»›i.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_chuyen_nhuong_cho_muon_cau_thu(
    p_ma_hd_moi VARCHAR(10),
    p_ma_cau_thu VARCHAR(10),
    p_ma_doi_chu_quan VARCHAR(10),
    p_ma_doi_moi VARCHAR(10),
    p_so_ao_moi INT,
    p_ngay_bat_dau DATE,
    p_ngay_ket_thuc DATE,
    p_trang_thai VARCHAR(20),
    p_muc_luong DECIMAL(15, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 1. Cáº­p nháº­t ngÃ y káº¿t thÃºc cá»§a cÃ¡c há»£p Ä‘á»“ng Ä‘ang hiá»‡u lá»±c trÆ°á»›c Ä‘Ã³ vá» ngÃ y báº¯t Ä‘áº§u má»›i - 1
    UPDATE HOP_DONG_CAU_THU
    SET NgayKetThuc = p_ngay_bat_dau - INTERVAL '1 day'
    WHERE MaCauThu = p_ma_cau_thu
      AND NgayKetThuc >= p_ngay_bat_dau;

    -- 2. ThÃªm báº£n ghi há»£p Ä‘á»“ng má»›i cho cáº§u thá»§ táº¡i Ä‘á»™i bÃ³ng má»›i
    -- (CÃ¡c trigger kiá»ƒm tra sá»‘ Ã¡o duy nháº¥t vÃ  giá»›i háº¡n 30 cáº§u thá»§ sáº½ tá»± Ä‘á»™ng kiá»ƒm tra táº¡i Ä‘á»™i má»›i)
    INSERT INTO HOP_DONG_CAU_THU (
        MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, 
        SoAo, NgayBatDau, NgayKetThuc, TrangThai, MucLuong
    ) VALUES (
        p_ma_hd_moi, p_ma_cau_thu, p_ma_doi_chu_quan, p_ma_doi_moi,
        p_so_ao_moi, p_ngay_bat_dau, p_ngay_ket_thuc, p_trang_thai, p_muc_luong
    );
END;
$$;
-- ============================================================================
-- PHáº¦N 4: VIEWS VÃ€ HÃ€M THá»NG KÃŠ (Báº¢NG Xáº¾P Háº NG, VUA PHÃ LÆ¯á»šI, LÆ¯Æ NG TRá»ŒNG TÃ€I)
-- Há»† QUáº¢N TRá»Š: PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. VIEW Báº¢NG Xáº¾P Háº NG MÃ™A GIáº¢I
-- TiÃªu chÃ­ sáº¯p xáº¿p: Äiá»ƒm -> Hiá»‡u sá»‘ -> Tá»•ng bÃ n tháº¯ng -> Sá»‘ tráº­n tháº¯ng sÃ¢n khÃ¡ch
--                   -> Tá»•ng tháº» Ä‘á» (Ã­t hÆ¡n xáº¿p trÃªn) -> Tá»•ng tháº» vÃ ng (Ã­t hÆ¡n)
-- Thá»ƒ thá»©c: Tháº¯ng = 3 Ä‘iá»ƒm, HÃ²a = 1 Ä‘iá»ƒm, Thua = 0 Ä‘iá»ƒm.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_bang_xep_hang AS
WITH TranDauKetThuc AS (
    -- Thá»‘ng kÃª khi Ä‘á»™i Ä‘Ã³ng vai trÃ² SÃ‚N NHÃ€
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

    -- Thá»‘ng kÃª khi Ä‘á»™i Ä‘Ã³ng vai trÃ² SÃ‚N KHÃCH
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
-- 2. HÃ€M TRUY Váº¤N DANH SÃCH 10 Cáº¦U THá»¦ GHI NHIá»€U BÃ€N THáº®NG NHáº¤T (VUA PHÃ LÆ¯á»šI)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_top10_vua_pha_luoi()
RETURNS TABLE (
    XepHang BIGINT,
    MaCauThu VARCHAR(10),
    HoTen VARCHAR(100),
    TenDoi VARCHAR(100),
    SoBanThang BIGINT
)
LANGUAGE sql
AS $$
    SELECT 
        ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC, ct.HoTen ASC) AS XepHang,
        ct.MaCauThu,
        ct.HoTen,
        db.TenDoi,
        COUNT(*) AS SoBanThang
    FROM SU_KIEN_TRAN_DAU sk
    JOIN CAU_THU ct ON sk.MaCauThu = ct.MaCauThu
    JOIN DOI_BONG db ON sk.MaDoi = db.MaDoi
    WHERE sk.LoaiSuKien = 'BanThang'
    GROUP BY ct.MaCauThu, ct.HoTen, db.TenDoi
    ORDER BY SoBanThang DESC, ct.HoTen ASC
    LIMIT 10;
$$;


-- ----------------------------------------------------------------------------
-- 3. HÃ€M TÃNH LÆ¯Æ NG TRá»ŒNG TÃ€I THEO THÃNG
-- Quy Ä‘á»‹nh thÃ¹ lao: Trá»ng tÃ i chÃ­nh = 3 triá»‡u/tráº­n; Trá»ng tÃ i biÃªn = 2 triá»‡u/tráº­n;
--                   Trá»ng tÃ i bÃ n = 1 triá»‡u/tráº­n.
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
        COUNT(CASE WHEN pc.VaiTro = 'Chinh' THEN 1 END) AS SoTranChinh,
        COUNT(CASE WHEN pc.VaiTro IN ('Bien1', 'Bien2') THEN 1 END) AS SoTranBien,
        COUNT(CASE WHEN pc.VaiTro = 'Ban' THEN 1 END) AS SoTranBan,
        COUNT(pc.MaTran) AS TongSoTran,
        (
            COUNT(CASE WHEN pc.VaiTro = 'Chinh' THEN 1 END) * 3000000 +
            COUNT(CASE WHEN pc.VaiTro IN ('Bien1', 'Bien2') THEN 1 END) * 2000000 +
            COUNT(CASE WHEN pc.VaiTro = 'Ban' THEN 1 END) * 1000000
        )::DECIMAL(15, 2) AS TongLuong
    FROM TRONG_TAI tt
    LEFT JOIN PHAN_CONG_TRONG_TAI pc ON tt.MaTrongTai = pc.MaTrongTai
    LEFT JOIN TRAN_DAU td ON pc.MaTran = td.MaTran 
                          AND EXTRACT(MONTH FROM td.NgayGio) = p_thang
                          AND EXTRACT(YEAR FROM td.NgayGio) = p_nam
                          AND td.TrangThai = 'DaKetThuc'
    GROUP BY tt.MaTrongTai, tt.HoTen, tt.CapBac
    ORDER BY TongLuong DESC, tt.HoTen ASC;
$$;


-- ----------------------------------------------------------------------------
-- 4. HÃ€M THá»NG KÃŠ DOANH THU Cá»¦A CÃC SÃ‚N Váº¬N Äá»˜NG
-- CÃ´ng thá»©c: Doanh thu = Tá»•ng (Sá»‘ lÆ°á»£ng khÃ¡n giáº£ * GiÃ¡ vÃ© má»—i tráº­n)
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
-- 5. HÃ€M THá»NG KÃŠ DIá»„N BIáº¾N Má»˜T VÃ’NG Äáº¤U Cá»¤ THá»‚
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
-- ============================================================================
-- PHáº¦N 5: Bá»˜ Dá»® LIá»†U MáºªU Äáº¦Y Äá»¦ CHO TRá»ŒN Váº¸N Má»˜T MÃ™A GIáº¢I (6 Äá»˜I, 30 TRáº¬N)
-- Há»† QUáº¢N TRá»Š: PostgreSQL
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. Náº P Dá»® LIá»†U SÃ‚N Váº¬N Äá»˜NG
-- LÆ°u Ã½: SÃ¢n HÃ ng Äáº«y (SAN_HD) lÃ  sÃ¢n nhÃ  cá»§a cáº£ 2 Ä‘á»™i: HNFC vÃ  CAHN.
-- ----------------------------------------------------------------------------
INSERT INTO SAN_VAN_DONG (MaSan, TenSan, DiaChi, SucChua) VALUES
('SAN_HD', 'SÃ¢n váº­n Ä‘á»™ng HÃ ng Äáº«y', 'Trá»‹nh HoÃ i Äá»©c, Äá»‘ng Äa, HÃ  Ná»™i', 22500),
('SAN_MD', 'SÃ¢n váº­n Ä‘á»™ng Quá»‘c gia Má»¹ ÄÃ¬nh', 'LÃª Äá»©c Thá», Nam Tá»« LiÃªm, HÃ  Ná»™i', 40192),
('SAN_LT', 'SÃ¢n váº­n Ä‘á»™ng Láº¡ch Tray', 'Láº¡ch Tray, NgÃ´ Quyá»n, Háº£i PhÃ²ng', 30000),
('SAN_TT', 'SÃ¢n váº­n Ä‘á»™ng ThiÃªn TrÆ°á»ng', 'Äáº·ng XuÃ¢n Thiá»u, TP Nam Äá»‹nh', 30000),
('SAN_PK', 'SÃ¢n váº­n Ä‘á»™ng Pleiku', 'Quang Trung, TP Pleiku, Gia Lai', 12000);

-- ----------------------------------------------------------------------------
-- 2. Náº P Dá»® LIá»†U Äá»˜I BÃ“NG
-- ----------------------------------------------------------------------------
INSERT INTO DOI_BONG (MaDoi, TenDoi, HLV, MaSanNha) VALUES
('HNFC', 'HÃ  Ná»™i FC', 'Daiki Iwamasa', 'SAN_HD'),
('CAHN', 'CÃ´ng An HÃ  Ná»™i', 'Alexandre Polking', 'SAN_HD'),
('VTT',  'Thá»ƒ CÃ´ng Viettel', 'Nguyá»…n Äá»©c Tháº¯ng', 'SAN_MD'),
('HPFC', 'Háº£i PhÃ²ng FC', 'Chu ÄÃ¬nh NghiÃªm', 'SAN_LT'),
('NDFC', 'ThÃ©p Xanh Nam Äá»‹nh', 'VÅ© Há»“ng Viá»‡t', 'SAN_TT'),
('HAGL', 'HoÃ ng Anh Gia Lai', 'VÅ© Tiáº¿n ThÃ nh', 'SAN_PK');

-- ----------------------------------------------------------------------------
-- 3. Náº P Dá»® LIá»†U MÃ€U ÃO Äá»˜I BÃ“NG (Má»—i Ä‘á»™i cÃ³ Ã­t nháº¥t 2 mÃ u Ã¡o)
-- ----------------------------------------------------------------------------
INSERT INTO MAU_AO_DOI_BONG (MaDoi, LoaiMauAo, MoTaMau) VALUES
('HNFC', 'SanNha', 'TÃ­m truyá»n thá»‘ng'),
('HNFC', 'SanKhach', 'VÃ ng viá»n tÃ­m'),
('HNFC', 'Phu', 'Tráº¯ng tinh khÃ´i'),

('CAHN', 'SanNha', 'Äá» cá»'),
('CAHN', 'SanKhach', 'Tráº¯ng viá»n Ä‘á»'),

('VTT',  'SanNha', 'Äá» rá»±c'),
('VTT',  'SanKhach', 'Tráº¯ng quÃ¢n Ä‘á»™i'),

('HPFC', 'SanNha', 'Äá» hoa phÆ°á»£ng'),
('HPFC', 'SanKhach', 'Tráº¯ng viá»n Ä‘á»'),

('NDFC', 'SanNha', 'VÃ ng rá»±c rá»¡'),
('NDFC', 'SanKhach', 'Tráº¯ng phá»‘i xanh'),

('HAGL', 'SanNha', 'Tráº¯ng phá»‘ nÃºi'),
('HAGL', 'SanKhach', 'Xanh lá»¥c Ä‘áº­m');

-- ----------------------------------------------------------------------------
-- 4. Náº P Dá»® LIá»†U TRá»ŒNG TÃ€I (12 Trá»ng tÃ i Ä‘áº£m báº£o Ä‘á»§ 3 tráº­n x 4 TT / vÃ²ng)
-- ----------------------------------------------------------------------------
INSERT INTO TRONG_TAI (MaTrongTai, HoTen, NgaySinh, QueQuan, CapBac) VALUES
('TT01', 'NgÃ´ Duy LÃ¢n', '1984-06-12', 'Long An', 'FIFA Elite'),
('TT02', 'HoÃ ng Ngá»c HÃ ', '1983-09-24', 'HÃ  Ná»™i', 'FIFA'),
('TT03', 'Tráº§n ÄÃ¬nh Thá»‹nh', '1982-03-15', 'Äá»“ng Nai', 'FIFA'),
('TT04', 'LÃª VÅ© Linh', '1989-11-20', 'Cáº§n ThÆ¡', 'FIFA'),
('TT05', 'Nguyá»…n Viáº¿t Duáº©n', '1985-07-08', 'HÃ  Ná»™i', 'Quá»‘c gia'),
('TT06', 'Mai XuÃ¢n HÃ¹ng', '1987-12-03', 'ÄÃ  Náºµng', 'Quá»‘c gia'),
('TT07', 'Nguyá»…n Máº¡nh Háº£i', '1987-05-18', 'Háº£i PhÃ²ng', 'FIFA'),
('TT08', 'Tráº§n Ngá»c Nhá»›', '1988-02-14', 'Tiá»n Giang', 'Quá»‘c gia'),
('TT09', 'Pháº¡m HoÃ i TÃ¢m', '1986-10-30', 'TP Há»“ ChÃ­ Minh', 'Quá»‘c gia'),
('TT10', 'Nguyá»…n Trung Háº­u', '1981-04-22', 'ÄÃ  Náºµng', 'FIFA Trá»£ lÃ½'),
('TT11', 'Pháº¡m Máº¡nh Long', '1980-08-11', 'Háº£i PhÃ²ng', 'FIFA Trá»£ lÃ½'),
('TT12', 'Tráº§n Duy KhÃ¡nh', '1990-01-05', 'Nghá»‡ An', 'Quá»‘c gia');

-- ----------------------------------------------------------------------------
-- 5. Náº P Dá»® LIá»†U Cáº¦U THá»¦ VÃ€ Há»¢P Äá»’NG (6 Ä‘á»™i x 18 cáº§u thá»§ = 108 cáº§u thá»§)
-- ----------------------------------------------------------------------------
-- (1) HÃ€ Ná»˜I FC (HNFC) - 18 cáº§u thá»§ (Sá»‘ Ã¡o tá»« 1 Ä‘áº¿n 35, phÃ¢n biá»‡t)
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT001', 'BÃ¹i Táº¥n TrÆ°á»ng', '1986-02-19', 'ThuMon', 'Viá»‡t Nam'),
('CT002', 'Äá»— Duy Máº¡nh', '1996-09-29', 'HauVe', 'Viá»‡t Nam'),
('CT003', 'Nguyá»…n ThÃ nh Chung', '1997-11-29', 'HauVe', 'Viá»‡t Nam'),
('CT004', 'Pháº¡m XuÃ¢n Máº¡nh', '1996-03-27', 'HauVe', 'Viá»‡t Nam'),
('CT005', 'VÅ© ÄÃ¬nh Hai', '2000-01-13', 'TienVe', 'Viá»‡t Nam'),
('CT006', 'Äá»— HÃ¹ng DÅ©ng', '1993-09-08', 'TienVe', 'Viá»‡t Nam'),
('CT007', 'Nguyá»…n VÄƒn Quyáº¿t', '1991-07-01', 'TienDao', 'Viá»‡t Nam'),
('CT008', 'Pháº¡m Tuáº¥n Háº£i', '1998-05-19', 'TienDao', 'Viá»‡t Nam'),
('CT009', 'LÃª VÄƒn XuÃ¢n', '1999-02-27', 'HauVe', 'Viá»‡t Nam'),
('CT010', 'Nguyá»…n VÄƒn TÃ¹ng', '2001-06-02', 'TienDao', 'Viá»‡t Nam'),
('CT011', 'Quan VÄƒn Chuáº©n', '2001-01-07', 'ThuMon', 'Viá»‡t Nam'),
('CT012', 'Äáº­u VÄƒn ToÃ n', '1997-04-07', 'TienVe', 'Viá»‡t Nam'),
('CT013', 'Nguyá»…n Hai Long', '2000-08-27', 'TienVe', 'Viá»‡t Nam'),
('CT014', 'Tráº§n VÄƒn KiÃªn', '1996-05-13', 'HauVe', 'Viá»‡t Nam'),
('CT015', 'Joel Tagueu', '1993-11-06', 'TienDao', 'Cameroon'),
('CT016', 'Deni Junior', '1995-07-10', 'TienDao', 'Brazil'),
('CT017', 'Tim Hall', '1997-06-09', 'HauVe', 'Luxembourg'),
('CT018', 'Nguyá»…n Äá»©c Anh', '2003-05-16', 'HauVe', 'Viá»‡t Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai, MucLuong) VALUES
('HD001', 'CT001', 'HNFC', 'HNFC', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD002', 'CT002', 'HNFC', 'HNFC', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc', 60000000),
('HD003', 'CT003', 'HNFC', 'HNFC', 16, '2025-01-01', '2027-12-31', 'ChinhThuc', 55000000),
('HD004', 'CT004', 'HNFC', 'HNFC', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc', 50000000),
('HD005', 'CT005', 'HNFC', 'HNFC', 21, '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD006', 'CT006', 'HNFC', 'HNFC', 88, '2025-01-01', '2027-12-31', 'ChinhThuc', 65000000), -- Sá»­a láº¡i so_ao: Ä‘á» yÃªu cáº§u 1-35
('HD007', 'CT007', 'HNFC', 'HNFC', 10, '2025-01-01', '2027-12-31', 'ChinhThuc', 80000000),
('HD008', 'CT008', 'HNFC', 'HNFC', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc', 60000000),
('HD009', 'CT009', 'HNFC', 'HNFC', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD010', 'CT010', 'HNFC', 'HNFC', 11, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD011', 'CT011', 'HNFC', 'HNFC', 25, '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD012', 'CT012', 'HNFC', 'HNFC', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD013', 'CT013', 'HNFC', 'HNFC', 14, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD014', 'CT014', 'HNFC', 'HNFC', 13, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD015', 'CT015', 'HNFC', 'HNFC', 15, '2025-01-01', '2027-12-31', 'ChinhThuc', 100000000),
('HD016', 'CT016', 'HNFC', 'HNFC', 17, '2025-01-01', '2027-12-31', 'ChinhThuc', 90000000),
('HD017', 'CT017', 'HNFC', 'HNFC', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc', 85000000),
('HD018', 'CT018', 'HNFC', 'HNFC', 28, '2025-01-01', '2027-12-31', 'ChinhThuc', 20000000);

-- Sá»­a sá»‘ Ã¡o cáº§u thá»§ CT006 HÃ¹ng DÅ©ng thÃ nh sá»‘ 6 (trong khoáº£ng 1-35)
UPDATE HOP_DONG_CAU_THU SET SoAo = 6 WHERE MaHD = 'HD006';

-- (2) CÃ”NG AN HÃ€ Ná»˜I (CAHN) - 18 cáº§u thá»§
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT019', 'Filip Nguyá»…n', '1992-09-14', 'ThuMon', 'Viá»‡t Nam'),
('CT020', 'Há»“ Táº¥n TÃ i', '1997-11-06', 'HauVe', 'Viá»‡t Nam'),
('CT021', 'BÃ¹i HoÃ ng Viá»‡t Anh', '1999-01-01', 'HauVe', 'Viá»‡t Nam'),
('CT022', 'ÄoÃ n VÄƒn Háº­u', '1999-04-19', 'HauVe', 'Viá»‡t Nam'),
('CT023', 'VÅ© VÄƒn Thanh', '1996-04-14', 'HauVe', 'Viá»‡t Nam'),
('CT024', 'Nguyá»…n Quang Háº£i', '1997-04-12', 'TienVe', 'Viá»‡t Nam'),
('CT025', 'LÃª Pháº¡m ThÃ nh Long', '1996-06-05', 'TienVe', 'Viá»‡t Nam'),
('CT026', 'HoÃ ng VÄƒn Toáº£n', '2001-04-01', 'TienVe', 'Viá»‡t Nam'),
('CT027', 'Phan VÄƒn Äá»©c', '1996-04-11', 'TienDao', 'Viá»‡t Nam'),
('CT028', 'Geovane Magno', '1994-04-14', 'TienDao', 'Brazil'),
('CT029', 'Jeferson Elias', '1998-08-18', 'TienDao', 'Brazil'),
('CT030', 'BÃ¹i Tiáº¿n DÅ©ng', '1997-02-28', 'ThuMon', 'Viá»‡t Nam'),
('CT031', 'Huá»³nh Táº¥n Sinh', '1998-04-06', 'HauVe', 'Viá»‡t Nam'),
('CT032', 'HÃ  VÄƒn PhÆ°Æ¡ng', '2001-05-28', 'TienVe', 'Viá»‡t Nam'),
('CT033', 'La Nguyá»…n Báº£o Trung', '2002-03-12', 'TienVe', 'Viá»‡t Nam'),
('CT034', 'Pháº¡m Gia HÆ°ng', '2000-09-11', 'TienDao', 'Viá»‡t Nam'),
('CT035', 'Tráº§n ÄÃ¬nh Trá»ng', '1997-04-25', 'HauVe', 'Viá»‡t Nam'),
('CT036', 'Junior Fialho', '1998-10-21', 'TienDao', 'Brazil');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai, MucLuong) VALUES
('HD019', 'CT019', 'CAHN', 'CAHN', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc', 80000000),
('HD020', 'CT020', 'CAHN', 'CAHN', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc', 65000000),
('HD021', 'CT021', 'CAHN', 'CAHN', 68, '2025-01-01', '2027-12-31', 'ChinhThuc', 65000000),
('HD022', 'CT022', 'CAHN', 'CAHN', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc', 70000000),
('HD023', 'CT023', 'CAHN', 'CAHN', 17, '2025-01-01', '2027-12-31', 'ChinhThuc', 65000000),
('HD024', 'CT024', 'CAHN', 'CAHN', 19, '2025-01-01', '2027-12-31', 'ChinhThuc', 90000000),
('HD025', 'CT025', 'CAHN', 'CAHN', 11, '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD026', 'CT026', 'CAHN', 'CAHN', 12, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD027', 'CT027', 'CAHN', 'CAHN', 20, '2025-01-01', '2027-12-31', 'ChinhThuc', 55000000),
('HD028', 'CT028', 'CAHN', 'CAHN', 10, '2025-01-01', '2027-12-31', 'ChinhThuc', 95000000),
('HD029', 'CT029', 'CAHN', 'CAHN', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc', 90000000),
('HD030', 'CT030', 'CAHN', 'CAHN', 25, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD031', 'CT031', 'CAHN', 'CAHN', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD032', 'CT032', 'CAHN', 'CAHN', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD033', 'CT033', 'CAHN', 'CAHN', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc', 20000000),
('HD034', 'CT034', 'CAHN', 'CAHN', 14, '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD035', 'CT035', 'CAHN', 'CAHN', 21, '2025-01-01', '2027-12-31', 'ChinhThuc', 50000000),
('HD036', 'CT036', 'CAHN', 'CAHN', 30, '2025-01-01', '2027-12-31', 'ChinhThuc', 80000000);

-- Sá»­a sá»‘ Ã¡o CT021 BÃ¹i HoÃ ng Viá»‡t Anh thÃ nh sá»‘ 2 (1-35)
UPDATE HOP_DONG_CAU_THU SET SoAo = 2 WHERE MaHD = 'HD021';

-- (3) THá»‚ CÃ”NG VIETTEL (VTT) - 18 cáº§u thá»§
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT037', 'Tráº§n NguyÃªn Máº¡nh', '1991-12-20', 'ThuMon', 'Viá»‡t Nam'),
('CT038', 'BÃ¹i Tiáº¿n DÅ©ng', '1995-10-02', 'HauVe', 'Viá»‡t Nam'),
('CT039', 'Nguyá»…n Thanh BÃ¬nh', '2000-11-02', 'HauVe', 'Viá»‡t Nam'),
('CT040', 'Phan Tuáº¥n TÃ i', '2001-01-07', 'HauVe', 'Viá»‡t Nam'),
('CT041', 'TrÆ°Æ¡ng Tiáº¿n Anh', '1999-04-25', 'TienVe', 'Viá»‡t Nam'),
('CT042', 'Nguyá»…n HoÃ ng Äá»©c', '1998-01-11', 'TienVe', 'Viá»‡t Nam'),
('CT043', 'Nguyá»…n Äá»©c Chiáº¿n', '1998-08-24', 'TienVe', 'Viá»‡t Nam'),
('CT044', 'Khuáº¥t VÄƒn Khang', '2003-05-11', 'TienVe', 'Viá»‡t Nam'),
('CT045', 'NhÃ¢m Máº¡nh DÅ©ng', '2000-04-12', 'TienDao', 'Viá»‡t Nam'),
('CT046', 'Pedro Henrique', '1996-12-17', 'TienDao', 'Brazil'),
('CT047', 'Jaha', '1993-04-06', 'TienVe', 'Kosovo'),
('CT048', 'QuÃ ng Tháº¿ TÃ i', '1995-02-05', 'ThuMon', 'Viá»‡t Nam'),
('CT049', 'Cao Tráº§n HoÃ ng HÃ¹ng', '1999-03-03', 'HauVe', 'Viá»‡t Nam'),
('CT050', 'Nguyá»…n Huy HÃ¹ng', '1992-03-02', 'TienVe', 'Viá»‡t Nam'),
('CT051', 'Äinh XuÃ¢n Tiáº¿n', '2003-01-10', 'TienVe', 'Viá»‡t Nam'),
('CT052', 'Tráº§n Danh Trung', '2000-10-03', 'TienDao', 'Viá»‡t Nam'),
('CT053', 'DÆ°Æ¡ng VÄƒn HÃ o', '1997-02-15', 'TienDao', 'Viá»‡t Nam'),
('CT054', 'Nguyá»…n XuÃ¢n KiÃªn', '2000-05-19', 'HauVe', 'Viá»‡t Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai, MucLuong) VALUES
('HD037', 'CT037', 'VTT', 'VTT', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc', 60000000),
('HD038', 'CT038', 'VTT', 'VTT', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc', 65000000),
('HD039', 'CT039', 'VTT', 'VTT', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc', 50000000),
('HD040', 'CT040', 'VTT', 'VTT', 12, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD041', 'CT041', 'VTT', 'VTT', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD042', 'CT042', 'VTT', 'VTT', 28, '2025-01-01', '2027-12-31', 'ChinhThuc', 85000000),
('HD043', 'CT043', 'VTT', 'VTT', 21, '2025-01-01', '2027-12-31', 'ChinhThuc', 55000000),
('HD044', 'CT044', 'VTT', 'VTT', 11, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD045', 'CT045', 'VTT', 'VTT', 23, '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD046', 'CT046', 'VTT', 'VTT', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc', 95000000),
('HD047', 'CT047', 'VTT', 'VTT', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc', 80000000),
('HD048', 'CT048', 'VTT', 'VTT', 25, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD049', 'CT049', 'VTT', 'VTT', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD050', 'CT050', 'VTT', 'VTT', 6,  '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD051', 'CT051', 'VTT', 'VTT', 10, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD052', 'CT052', 'VTT', 'VTT', 19, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD053', 'CT053', 'VTT', 'VTT', 17, '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD054', 'CT054', 'VTT', 'VTT', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000);

-- (4) THÃ‰P XANH NAM Äá»ŠNH (NDFC) - 18 cáº§u thá»§
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT055', 'Tráº§n LiÃªm Äiá»u', '2001-06-29', 'ThuMon', 'Viá»‡t Nam'),
('CT056', 'DÆ°Æ¡ng Thanh HÃ o', '1991-06-23', 'HauVe', 'Viá»‡t Nam'),
('CT057', 'Tráº§n VÄƒn KiÃªn', '1996-05-13', 'HauVe', 'Viá»‡t Nam'),
('CT058', 'Nguyá»…n Phong Há»“ng Duy', '1996-06-13', 'HauVe', 'Viá»‡t Nam'),
('CT059', 'Lucas Alves', '1992-07-22', 'HauVe', 'Brazil'),
('CT060', 'Tráº§n VÄƒn CÃ´ng', '1999-02-15', 'TienVe', 'Viá»‡t Nam'),
('CT061', 'Hendrio Araujo', '1994-05-16', 'TienVe', 'Brazil'),
('CT062', 'Nguyá»…n Tuáº¥n Anh', '1995-05-16', 'TienVe', 'Viá»‡t Nam'),
('CT063', 'Nguyá»…n VÄƒn ToÃ n', '1996-04-12', 'TienDao', 'Viá»‡t Nam'),
('CT064', 'Nguyá»…n XuÃ¢n Son', '1997-03-30', 'TienDao', 'Viá»‡t Nam'),
('CT065', 'LÃ¢m Anh Quang', '1991-04-24', 'HauVe', 'Viá»‡t Nam'),
('CT066', 'LÃª VÅ© Quá»‘c Nháº­t', '2001-01-19', 'ThuMon', 'Viá»‡t Nam'),
('CT067', 'Äinh Viáº¿t TÃº', '1992-08-16', 'HauVe', 'Viá»‡t Nam'),
('CT068', 'TÃ´ VÄƒn VÅ©', '1993-10-20', 'TienVe', 'Viá»‡t Nam'),
('CT069', 'LÃ½ CÃ´ng HoÃ ng Anh', '1999-09-01', 'TienVe', 'Viá»‡t Nam'),
('CT070', 'Mai XuÃ¢n Quyáº¿t', '1999-04-01', 'TienDao', 'Viá»‡t Nam'),
('CT071', 'HoÃ ng Minh Tuáº¥n', '1995-08-17', 'TienDao', 'Viá»‡t Nam'),
('CT072', 'ÄoÃ n Thanh TrÆ°á»ng', '2000-09-08', 'TienVe', 'Viá»‡t Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai, MucLuong) VALUES
('HD055', 'CT055', 'NDFC', 'NDFC', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD056', 'CT056', 'NDFC', 'NDFC', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD057', 'CT057', 'NDFC', 'NDFC', 13, '2025-01-01', '2027-12-31', 'ChinhThuc', 50000000),
('HD058', 'CT058', 'NDFC', 'NDFC', 7,  '2025-01-01', '2027-12-31', 'ChinhThuc', 55000000),
('HD059', 'CT059', 'NDFC', 'NDFC', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc', 90000000),
('HD060', 'CT060', 'NDFC', 'NDFC', 16, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD061', 'CT061', 'NDFC', 'NDFC', 10, '2025-01-01', '2027-12-31', 'ChinhThuc', 95000000),
('HD062', 'CT062', 'NDFC', 'NDFC', 21, '2025-01-01', '2027-12-31', 'ChinhThuc', 70000000),
('HD063', 'CT063', 'NDFC', 'NDFC', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc', 75000000),
('HD064', 'CT064', 'NDFC', 'NDFC', 14, '2025-01-01', '2027-12-31', 'ChinhThuc', 120000000),
('HD065', 'CT065', 'NDFC', 'NDFC', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD066', 'CT066', 'NDFC', 'NDFC', 25, '2025-01-01', '2027-12-31', 'ChinhThuc', 20000000),
('HD067', 'CT067', 'NDFC', 'NDFC', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD068', 'CT068', 'NDFC', 'NDFC', 28, '2025-01-01', '2027-12-31', 'ChinhThuc', 55000000),
('HD069', 'CT069', 'NDFC', 'NDFC', 88, '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD070', 'CT070', 'NDFC', 'NDFC', 11, '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD071', 'CT071', 'NDFC', 'NDFC', 19, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD072', 'CT072', 'NDFC', 'NDFC', 18, '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000);

-- Sá»­a sá»‘ Ã¡o CT069 thÃ nh sá»‘ 8 (1-35)
UPDATE HOP_DONG_CAU_THU SET SoAo = 8 WHERE MaHD = 'HD069';

-- (5) Háº¢I PHÃ’NG FC (HPFC) - 18 cáº§u thá»§
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT073', 'Nguyá»…n ÄÃ¬nh Triá»‡u', '1991-11-04', 'ThuMon', 'Viá»‡t Nam'),
('CT074', 'Äáº·ng VÄƒn Tá»›i', '1999-01-12', 'HauVe', 'Viá»‡t Nam'),
('CT075', 'BÃ¹i Tiáº¿n Dá»¥ng', '1998-11-23', 'HauVe', 'Viá»‡t Nam'),
('CT076', 'Pháº¡m Trung Hiáº¿u', '1998-09-22', 'HauVe', 'Viá»‡t Nam'),
('CT077', 'Nguyá»…n VÄƒn Äáº¡t', '1998-05-25', 'HauVe', 'Viá»‡t Nam'),
('CT078', 'LÆ°Æ¡ng XuÃ¢n TrÆ°á»ng', '1995-04-28', 'TienVe', 'Viá»‡t Nam'),
('CT079', 'Bicou Bissainthe', '1999-03-15', 'TienVe', 'Haiti'),
('CT080', 'Triá»‡u Viá»‡t HÆ°ng', '1997-01-19', 'TienVe', 'Viá»‡t Nam'),
('CT081', 'Nguyá»…n Há»¯u SÆ¡n', '1996-09-27', 'TienDao', 'Viá»‡t Nam'),
('CT082', 'Lucao do Break', '1991-09-22', 'TienDao', 'Brazil'),
('CT083', 'Joseph Mpande', '1994-03-23', 'TienDao', 'Uganda'),
('CT084', 'Nguyá»…n VÄƒn Toáº£n', '1999-11-26', 'ThuMon', 'Viá»‡t Nam'),
('CT085', 'Nguyá»…n Nháº­t Minh', '2003-07-27', 'HauVe', 'Viá»‡t Nam'),
('CT086', 'LÃª Máº¡nh DÅ©ng', '1994-04-20', 'TienVe', 'Viá»‡t Nam'),
('CT087', 'LÆ°Æ¡ng HoÃ ng Nam', '1997-03-02', 'TienVe', 'Viá»‡t Nam'),
('CT088', 'Nguyá»…n Tuáº¥n Anh', '1999-08-16', 'TienDao', 'Viá»‡t Nam'),
('CT089', 'DÆ°Æ¡ng VÄƒn Khoa', '1994-05-06', 'HauVe', 'Viá»‡t Nam'),
('CT090', 'Nguyá»…n Minh DÄ©', '1998-02-17', 'TienDao', 'Viá»‡t Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai, MucLuong) VALUES
('HD073', 'CT073', 'HPFC', 'HPFC', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc', 60000000),
('HD074', 'CT074', 'HPFC', 'HPFC', 5,  '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD075', 'CT075', 'HPFC', 'HPFC', 6,  '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD076', 'CT076', 'HPFC', 'HPFC', 17, '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD077', 'CT077', 'HPFC', 'HPFC', 4,  '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD078', 'CT078', 'HPFC', 'HPFC', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc', 60000000),
('HD079', 'CT079', 'HPFC', 'HPFC', 66, '2025-01-01', '2027-12-31', 'ChinhThuc', 75000000),
('HD080', 'CT080', 'HPFC', 'HPFC', 97, '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD081', 'CT081', 'HPFC', 'HPFC', 77, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD082', 'CT082', 'HPFC', 'HPFC', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc', 90000000),
('HD083', 'CT083', 'HPFC', 'HPFC', 10, '2025-01-01', '2027-12-31', 'ChinhThuc', 85000000),
('HD084', 'CT084', 'HPFC', 'HPFC', 25, '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD085', 'CT085', 'HPFC', 'HPFC', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD086', 'CT086', 'HPFC', 'HPFC', 14, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD087', 'CT087', 'HPFC', 'HPFC', 30, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD088', 'CT088', 'HPFC', 'HPFC', 19, '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD089', 'CT089', 'HPFC', 'HPFC', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD090', 'CT090', 'HPFC', 'HPFC', 11, '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000);

-- Sá»­a sá»‘ Ã¡o trong khoáº£ng 1-35 cho HPFC
UPDATE HOP_DONG_CAU_THU SET SoAo = 16 WHERE MaHD = 'HD079';
UPDATE HOP_DONG_CAU_THU SET SoAo = 20 WHERE MaHD = 'HD080';
UPDATE HOP_DONG_CAU_THU SET SoAo = 7 WHERE MaHD = 'HD081';

-- (6) HOÃ€NG ANH GIA LAI (HAGL) - 18 cáº§u thá»§
INSERT INTO CAU_THU (MaCauThu, HoTen, NgaySinh, ViTri, QuocTich) VALUES
('CT091', 'Tráº§n Trung KiÃªn', '2003-02-09', 'ThuMon', 'Viá»‡t Nam'),
('CT092', 'LÃª VÄƒn SÆ¡n', '1996-12-20', 'HauVe', 'Viá»‡t Nam'),
('CT093', 'Jairo Rodrigues', '1992-12-31', 'HauVe', 'Brazil'),
('CT094', 'Dá»¥ng Quang Nho', '2000-01-01', 'HauVe', 'Viá»‡t Nam'),
('CT095', 'A HoÃ ng', '1995-07-31', 'HauVe', 'Viá»‡t Nam'),
('CT096', 'Tráº§n Minh VÆ°Æ¡ng', '1995-03-28', 'TienVe', 'Viá»‡t Nam'),
('CT097', 'ChÃ¢u Ngá»c Quang', '1996-02-01', 'TienVe', 'Viá»‡t Nam'),
('CT098', 'Marciel Silva', '1995-08-10', 'TienVe', 'Brazil'),
('CT099', 'Nguyá»…n Quá»‘c Viá»‡t', '2003-05-04', 'TienDao', 'Viá»‡t Nam'),
('CT100', 'Gabriel Ferreira', '1997-10-14', 'TienDao', 'Brazil'),
('CT101', 'Tráº§n Báº£o ToÃ n', '2000-07-14', 'TienDao', 'Viá»‡t Nam'),
('CT102', 'Phan ÄÃ¬nh VÅ© Háº£i', '1994-06-06', 'ThuMon', 'Viá»‡t Nam'),
('CT103', 'Nguyá»…n Há»¯u Anh TÃ i', '1996-02-28', 'HauVe', 'Viá»‡t Nam'),
('CT104', 'Phan Du Há»c', '2001-11-01', 'HauVe', 'Viá»‡t Nam'),
('CT105', 'Nguyá»…n Äá»©c Viá»‡t', '2004-01-01', 'TienVe', 'Viá»‡t Nam'),
('CT106', 'VÃµ ÄÃ¬nh LÃ¢m', '2000-01-10', 'TienVe', 'Viá»‡t Nam'),
('CT107', 'Äinh Thanh BÃ¬nh', '1998-03-19', 'TienDao', 'Viá»‡t Nam'),
('CT108', 'VÅ© Minh Hiáº¿u', '2002-05-10', 'TienDao', 'Viá»‡t Nam');

INSERT INTO HOP_DONG_CAU_THU (MaHD, MaCauThu, MaDoiChuQuan, MaDoiHienTai, SoAo, NgayBatDau, NgayKetThuc, TrangThai, MucLuong) VALUES
('HD091', 'CT091', 'HAGL', 'HAGL', 1,  '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD092', 'CT092', 'HAGL', 'HAGL', 2,  '2025-01-01', '2027-12-31', 'ChinhThuc', 45000000),
('HD093', 'CT093', 'HAGL', 'HAGL', 33, '2025-01-01', '2027-12-31', 'ChinhThuc', 75000000),
('HD094', 'CT094', 'HAGL', 'HAGL', 86, '2025-01-01', '2027-12-31', 'ChinhThuc', 40000000),
('HD095', 'CT095', 'HAGL', 'HAGL', 6,  '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD096', 'CT096', 'HAGL', 'HAGL', 10, '2025-01-01', '2027-12-31', 'ChinhThuc', 60000000),
('HD097', 'CT097', 'HAGL', 'HAGL', 8,  '2025-01-01', '2027-12-31', 'ChinhThuc', 55000000),
('HD098', 'CT098', 'HAGL', 'HAGL', 22, '2025-01-01', '2027-12-31', 'ChinhThuc', 80000000),
('HD099', 'CT099', 'HAGL', 'HAGL', 11, '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD100', 'CT100', 'HAGL', 'HAGL', 9,  '2025-01-01', '2027-12-31', 'ChinhThuc', 85000000),
('HD101', 'CT101', 'HAGL', 'HAGL', 20, '2025-01-01', '2027-12-31', 'ChinhThuc', 35000000),
('HD102', 'CT102', 'HAGL', 'HAGL', 25, '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD103', 'CT103', 'HAGL', 'HAGL', 3,  '2025-01-01', '2027-12-31', 'ChinhThuc', 25000000),
('HD104', 'CT104', 'HAGL', 'HAGL', 17, '2025-01-01', '2027-12-31', 'ChinhThuc', 20000000),
('HD105', 'CT105', 'HAGL', 'HAGL', 14, '2025-01-01', '2027-12-31', 'ChinhThuc', 20000000),
('HD106', 'CT106', 'HAGL', 'HAGL', 16, '2025-01-01', '2027-12-31', 'ChinhThuc', 20000000),
('HD107', 'CT107', 'HAGL', 'HAGL', 19, '2025-01-01', '2027-12-31', 'ChinhThuc', 30000000),
('HD108', 'CT108', 'HAGL', 'HAGL', 28, '2025-01-01', '2027-12-31', 'ChinhThuc', 20000000);

-- Sá»­a sá»‘ Ã¡o CT094 thÃ nh sá»‘ 4 (1-35)
UPDATE HOP_DONG_CAU_THU SET SoAo = 4 WHERE MaHD = 'HD094';

-- ----------------------------------------------------------------------------
-- 6. Náº P Dá»® LIá»†U VÃ’NG Äáº¤U (10 VÃ’NG)
-- ----------------------------------------------------------------------------
INSERT INTO VONG_DAU (MaVong, TenVong, ThuTu) VALUES
(1, 'VÃ²ng 1', 1),
(2, 'VÃ²ng 2', 2),
(3, 'VÃ²ng 3', 3),
(4, 'VÃ²ng 4', 4),
(5, 'VÃ²ng 5', 5),
(6, 'VÃ²ng 6', 6),
(7, 'VÃ²ng 7', 7),
(8, 'VÃ²ng 8', 8),
(9, 'VÃ²ng 9', 9),
(10, 'VÃ²ng 10', 10);

-- ----------------------------------------------------------------------------
-- 7. Náº P Lá»ŠCH THI Äáº¤U TOÃ€N Bá»˜ 30 TRáº¬N Äáº¤U Cá»¦A MÃ™A GIáº¢I (VÃ’NG TRÃ’N 2 LÆ¯á»¢T)
-- ----------------------------------------------------------------------------
-- VÃ’NG 1 (NgÃ y 2026-03-01)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR01', 1, 'HNFC', 'HPFC', 'SAN_HD', '2026-03-01 19:15:00', 80000, 15200, 2, 1, 2, 1, 0, 0, 'DaKetThuc'),
('TR02', 1, 'CAHN', 'HAGL', 'SAN_HD', '2026-03-02 19:15:00', 80000, 12000, 3, 0, 1, 2, 0, 0, 'DaKetThuc'),
('TR03', 1, 'VTT',  'NDFC', 'SAN_MD', '2026-03-01 18:00:00', 60000, 18500, 1, 2, 1, 1, 0, 0, 'DaKetThuc');

-- VÃ’NG 2 (NgÃ y 2026-03-08)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR04', 2, 'NDFC', 'HNFC', 'SAN_TT', '2026-03-08 18:00:00', 70000, 22000, 3, 2, 2, 2, 0, 0, 'DaKetThuc'),
('TR05', 2, 'HPFC', 'CAHN', 'SAN_LT', '2026-03-08 19:15:00', 70000, 19500, 0, 2, 3, 1, 0, 0, 'DaKetThuc'),
('TR06', 2, 'HAGL', 'VTT',  'SAN_PK', '2026-03-09 17:00:00', 50000, 9800,  1, 1, 1, 2, 0, 0, 'DaKetThuc');

-- VÃ’NG 3 (NgÃ y 2026-03-15)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR07', 3, 'HNFC', 'CAHN', 'SAN_HD', '2026-03-15 19:15:00', 100000, 21500, 2, 2, 2, 3, 1, 0, 'DaKetThuc'),
('TR08', 3, 'VTT',  'HPFC', 'SAN_MD', '2026-03-15 18:00:00', 60000,  14000, 2, 0, 1, 1, 0, 0, 'DaKetThuc'),
('TR09', 3, 'NDFC', 'HAGL', 'SAN_TT', '2026-03-16 18:00:00', 70000,  18000, 4, 1, 0, 1, 0, 0, 'DaKetThuc');

-- VÃ’NG 4 (NgÃ y 2026-03-22)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR10', 4, 'HAGL', 'HNFC', 'SAN_PK', '2026-03-22 17:00:00', 50000, 10500, 0, 1, 2, 1, 0, 0, 'DaKetThuc'),
('TR11', 4, 'CAHN', 'VTT',  'SAN_HD', '2026-03-22 19:15:00', 90000, 17000, 1, 1, 2, 2, 0, 0, 'DaKetThuc'),
('TR12', 4, 'HPFC', 'NDFC', 'SAN_LT', '2026-03-23 18:00:00', 70000, 16000, 1, 3, 1, 2, 0, 0, 'DaKetThuc');

-- VÃ’NG 5 (NgÃ y 2026-03-29 - Háº¿t lÆ°á»£t Ä‘i)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR13', 5, 'HNFC', 'VTT',  'SAN_HD', '2026-03-29 19:15:00', 90000, 18000, 2, 1, 1, 2, 0, 0, 'DaKetThuc'),
('TR14', 5, 'NDFC', 'CAHN', 'SAN_TT', '2026-03-29 18:00:00', 80000, 24000, 2, 1, 2, 1, 0, 0, 'DaKetThuc'),
('TR15', 5, 'HPFC', 'HAGL', 'SAN_LT', '2026-03-30 18:00:00', 60000, 13000, 2, 0, 1, 0, 0, 0, 'DaKetThuc');

-- LÆ¯á»¢T Vá»€ (VÃ’NG 6 Äáº¾N 10)
-- VÃ’NG 6 (Äáº£o ngÆ°á»£c VÃ²ng 1)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR16', 6, 'HPFC', 'HNFC', 'SAN_LT', '2026-04-05 18:00:00', 80000, 17500, 1, 2, 2, 2, 0, 0, 'DaKetThuc'),
('TR17', 6, 'HAGL', 'CAHN', 'SAN_PK', '2026-04-05 17:00:00', 50000, 11000, 0, 2, 1, 1, 0, 0, 'DaKetThuc'),
('TR18', 6, 'NDFC', 'VTT',  'SAN_TT', '2026-04-06 18:00:00', 70000, 21000, 1, 0, 1, 1, 0, 0, 'DaKetThuc');

-- VÃ’NG 7 (Äáº£o ngÆ°á»£c VÃ²ng 2)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR19', 7, 'HNFC', 'NDFC', 'SAN_HD', '2026-04-12 19:15:00', 90000, 19000, 1, 1, 1, 2, 0, 0, 'DaKetThuc'),
('TR20', 7, 'CAHN', 'HPFC', 'SAN_HD', '2026-04-13 19:15:00', 80000, 14500, 2, 1, 1, 1, 0, 0, 'DaKetThuc'),
('TR21', 7, 'VTT',  'HAGL', 'SAN_MD', '2026-04-12 18:00:00', 60000, 12000, 3, 1, 0, 1, 0, 0, 'DaKetThuc');

-- VÃ’NG 8 (Äáº£o ngÆ°á»£c VÃ²ng 3)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR22', 8, 'CAHN', 'HNFC', 'SAN_HD', '2026-04-19 19:15:00', 100000, 22000, 1, 2, 3, 2, 0, 1, 'DaKetThuc'),
('TR23', 8, 'HPFC', 'VTT',  'SAN_LT', '2026-04-19 18:00:00', 70000,  15000, 1, 1, 2, 2, 0, 0, 'DaKetThuc'),
('TR24', 8, 'HAGL', 'NDFC', 'SAN_PK', '2026-04-20 17:00:00', 50000,  9500,  0, 2, 1, 0, 0, 0, 'DaKetThuc');

-- VÃ’NG 9 (Äáº£o ngÆ°á»£c VÃ²ng 4)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR25', 9, 'HNFC', 'HAGL', 'SAN_HD', '2026-04-26 19:15:00', 80000, 14000, 3, 0, 0, 1, 0, 0, 'DaKetThuc'),
('TR26', 9, 'VTT',  'CAHN', 'SAN_MD', '2026-04-26 18:00:00', 80000, 16500, 2, 1, 2, 1, 0, 0, 'DaKetThuc'),
('TR27', 9, 'NDFC', 'HPFC', 'SAN_TT', '2026-04-27 18:00:00', 70000, 23000, 2, 0, 1, 1, 0, 0, 'DaKetThuc');

-- VÃ’NG 10 (Äáº£o ngÆ°á»£c VÃ²ng 5 - VÃ²ng háº¡ mÃ n)
INSERT INTO TRAN_DAU (MaTran, MaVong, MaDoiNha, MaDoiKhach, MaSan, NgayGio, GiaVe, SoKhach, BanThangNha, BanThangKhach, TheVangNha, TheVangKhach, TheDoNha, TheDoKhach, TrangThai) VALUES
('TR28', 10, 'VTT',  'HNFC', 'SAN_MD', '2026-05-03 18:00:00', 90000, 20000, 1, 1, 2, 2, 0, 0, 'DaKetThuc'),
('TR29', 10, 'CAHN', 'NDFC', 'SAN_HD', '2026-05-03 18:00:00', 90000, 21000, 1, 1, 1, 2, 0, 0, 'DaKetThuc'),
('TR30', 10, 'HAGL', 'HPFC', 'SAN_PK', '2026-05-03 18:00:00', 50000, 10000, 2, 1, 1, 1, 0, 0, 'DaKetThuc');

-- ----------------------------------------------------------------------------
-- 8. Náº P PHÃ‚N CÃ”NG Äá»¦ 4 TRá»ŒNG TÃ€I CHO 30 TRáº¬N Äáº¤U (12 TT / VÃ’NG, KHÃ”NG TRÃ™NG)
-- ----------------------------------------------------------------------------
-- VÃ²ng 1: Tráº­n TR01 (TT01, TT02, TT03, TT04), TR02 (TT05, TT06, TT07, TT08), TR03 (TT09, TT10, TT11, TT12)
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR01', 'Chinh', 'TT01'), ('TR01', 'Bien1', 'TT02'), ('TR01', 'Bien2', 'TT03'), ('TR01', 'Ban', 'TT04'),
('TR02', 'Chinh', 'TT05'), ('TR02', 'Bien1', 'TT06'), ('TR02', 'Bien2', 'TT07'), ('TR02', 'Ban', 'TT08'),
('TR03', 'Chinh', 'TT09'), ('TR03', 'Bien1', 'TT10'), ('TR03', 'Bien2', 'TT11'), ('TR03', 'Ban', 'TT12');

-- VÃ²ng 2
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR04', 'Chinh', 'TT02'), ('TR04', 'Bien1', 'TT01'), ('TR04', 'Bien2', 'TT04'), ('TR04', 'Ban', 'TT03'),
('TR05', 'Chinh', 'TT07'), ('TR05', 'Bien1', 'TT05'), ('TR05', 'Bien2', 'TT08'), ('TR05', 'Ban', 'TT06'),
('TR06', 'Chinh', 'TT11'), ('TR06', 'Bien1', 'TT09'), ('TR06', 'Bien2', 'TT12'), ('TR06', 'Ban', 'TT10');

-- VÃ²ng 3
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR07', 'Chinh', 'TT03'), ('TR07', 'Bien1', 'TT04'), ('TR07', 'Bien2', 'TT01'), ('TR07', 'Ban', 'TT02'),
('TR08', 'Chinh', 'TT06'), ('TR08', 'Bien1', 'TT08'), ('TR08', 'Bien2', 'TT05'), ('TR08', 'Ban', 'TT07'),
('TR09', 'Chinh', 'TT10'), ('TR09', 'Bien1', 'TT12'), ('TR09', 'Bien2', 'TT09'), ('TR09', 'Ban', 'TT11');

-- VÃ²ng 4
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR10', 'Chinh', 'TT04'), ('TR10', 'Bien1', 'TT03'), ('TR10', 'Bien2', 'TT02'), ('TR10', 'Ban', 'TT01'),
('TR11', 'Chinh', 'TT08'), ('TR11', 'Bien1', 'TT07'), ('TR11', 'Bien2', 'TT06'), ('TR11', 'Ban', 'TT05'),
('TR12', 'Chinh', 'TT12'), ('TR12', 'Bien1', 'TT11'), ('TR12', 'Bien2', 'TT10'), ('TR12', 'Ban', 'TT09');

-- VÃ²ng 5
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR13', 'Chinh', 'TT01'), ('TR13', 'Bien1', 'TT03'), ('TR13', 'Bien2', 'TT04'), ('TR13', 'Ban', 'TT02'),
('TR14', 'Chinh', 'TT05'), ('TR14', 'Bien1', 'TT07'), ('TR14', 'Bien2', 'TT08'), ('TR14', 'Ban', 'TT06'),
('TR15', 'Chinh', 'TT09'), ('TR15', 'Bien1', 'TT11'), ('TR15', 'Bien2', 'TT12'), ('TR15', 'Ban', 'TT10');

-- VÃ²ng 6
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR16', 'Chinh', 'TT02'), ('TR16', 'Bien1', 'TT04'), ('TR16', 'Bien2', 'TT01'), ('TR16', 'Ban', 'TT03'),
('TR17', 'Chinh', 'TT06'), ('TR17', 'Bien1', 'TT08'), ('TR17', 'Bien2', 'TT05'), ('TR17', 'Ban', 'TT07'),
('TR18', 'Chinh', 'TT10'), ('TR18', 'Bien1', 'TT12'), ('TR18', 'Bien2', 'TT09'), ('TR18', 'Ban', 'TT11');

-- VÃ²ng 7
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR19', 'Chinh', 'TT03'), ('TR19', 'Bien1', 'TT01'), ('TR19', 'Bien2', 'TT02'), ('TR19', 'Ban', 'TT04'),
('TR20', 'Chinh', 'TT07'), ('TR20', 'Bien1', 'TT05'), ('TR20', 'Bien2', 'TT06'), ('TR20', 'Ban', 'TT08'),
('TR21', 'Chinh', 'TT11'), ('TR21', 'Bien1', 'TT09'), ('TR21', 'Bien2', 'TT10'), ('TR21', 'Ban', 'TT12');

-- VÃ²ng 8
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR22', 'Chinh', 'TT01'), ('TR22', 'Bien1', 'TT02'), ('TR22', 'Bien2', 'TT03'), ('TR22', 'Ban', 'TT04'),
('TR23', 'Chinh', 'TT05'), ('TR23', 'Bien1', 'TT06'), ('TR23', 'Bien2', 'TT07'), ('TR23', 'Ban', 'TT08'),
('TR24', 'Chinh', 'TT09'), ('TR24', 'Bien1', 'TT10'), ('TR24', 'Bien2', 'TT11'), ('TR24', 'Ban', 'TT12');

-- VÃ²ng 9
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR25', 'Chinh', 'TT04'), ('TR25', 'Bien1', 'TT01'), ('TR25', 'Bien2', 'TT02'), ('TR25', 'Ban', 'TT03'),
('TR26', 'Chinh', 'TT08'), ('TR26', 'Bien1', 'TT05'), ('TR26', 'Bien2', 'TT06'), ('TR26', 'Ban', 'TT07'),
('TR27', 'Chinh', 'TT12'), ('TR27', 'Bien1', 'TT09'), ('TR27', 'Bien2', 'TT10'), ('TR27', 'Ban', 'TT11');

-- VÃ²ng 10
INSERT INTO PHAN_CONG_TRONG_TAI (MaTran, VaiTro, MaTrongTai) VALUES
('TR28', 'Chinh', 'TT02'), ('TR28', 'Bien1', 'TT03'), ('TR28', 'Bien2', 'TT01'), ('TR28', 'Ban', 'TT04'),
('TR29', 'Chinh', 'TT06'), ('TR29', 'Bien1', 'TT07'), ('TR29', 'Bien2', 'TT05'), ('TR29', 'Ban', 'TT08'),
('TR30', 'Chinh', 'TT10'), ('TR30', 'Bien1', 'TT11'), ('TR30', 'Bien2', 'TT09'), ('TR30', 'Ban', 'TT12');

-- ----------------------------------------------------------------------------
-- 9. Náº P Sá»° KIá»†N BÃ€N THáº®NG & THáºº PHáº T (Äáº¢M Báº¢O KHá»šP CHÃNH XÃC Káº¾T QUáº¢ TRáº¬N Äáº¤U)
-- ----------------------------------------------------------------------------
-- TR01: HNFC 2 - 1 HPFC (Tháº» vÃ ng: HNFC 2, HPFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK001', 'TR01', 'CT007', 'HNFC', 'BanThang', 23),
('SK002', 'TR01', 'CT008', 'HNFC', 'BanThang', 67),
('SK003', 'TR01', 'CT082', 'HPFC', 'BanThang', 81),
('SK004', 'TR01', 'CT002', 'HNFC', 'TheVang', 44),
('SK005', 'TR01', 'CT006', 'HNFC', 'TheVang', 75),
('SK006', 'TR01', 'CT075', 'HPFC', 'TheVang', 89);

-- TR02: CAHN 3 - 0 HAGL (Tháº» vÃ ng: CAHN 1, HAGL 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK007', 'TR02', 'CT024', 'CAHN', 'BanThang', 15),
('SK008', 'TR02', 'CT028', 'CAHN', 'BanThang', 52),
('SK009', 'TR02', 'CT029', 'CAHN', 'BanThang', 78),
('SK010', 'TR02', 'CT023', 'CAHN', 'TheVang', 33),
('SK011', 'TR02', 'CT094', 'HAGL', 'TheVang', 40),
('SK012', 'TR02', 'CT096', 'HAGL', 'TheVang', 85);

-- TR03: VTT 1 - 2 NDFC (Tháº» vÃ ng: VTT 1, NDFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK013', 'TR03', 'CT046', 'VTT',  'BanThang', 30),
('SK014', 'TR03', 'CT064', 'NDFC', 'BanThang', 45),
('SK015', 'TR03', 'CT064', 'NDFC', 'BanThang', 88),
('SK016', 'TR03', 'CT043', 'VTT',  'TheVang', 62),
('SK017', 'TR03', 'CT059', 'NDFC', 'TheVang', 71);

-- TR04: NDFC 3 - 2 HNFC (Tháº» vÃ ng: NDFC 2, HNFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK018', 'TR04', 'CT064', 'NDFC', 'BanThang', 12),
('SK019', 'TR04', 'CT061', 'NDFC', 'BanThang', 55),
('SK020', 'TR04', 'CT063', 'NDFC', 'BanThang', 90),
('SK021', 'TR04', 'CT007', 'HNFC', 'BanThang', 35),
('SK022', 'TR04', 'CT015', 'HNFC', 'BanThang', 82),
('SK023', 'TR04', 'CT056', 'NDFC', 'TheVang', 20),
('SK024', 'TR04', 'CT060', 'NDFC', 'TheVang', 77),
('SK025', 'TR04', 'CT003', 'HNFC', 'TheVang', 41),
('SK026', 'TR04', 'CT004', 'HNFC', 'TheVang', 84);

-- TR05: HPFC 0 - 2 CAHN (Tháº» vÃ ng: HPFC 3, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK027', 'TR05', 'CT024', 'CAHN', 'BanThang', 28),
('SK028', 'TR05', 'CT029', 'CAHN', 'BanThang', 64),
('SK029', 'TR05', 'CT074', 'HPFC', 'TheVang', 30),
('SK030', 'TR05', 'CT078', 'HPFC', 'TheVang', 50),
('SK031', 'TR05', 'CT080', 'HPFC', 'TheVang', 73),
('SK032', 'TR05', 'CT020', 'CAHN', 'TheVang', 60);

-- TR06: HAGL 1 - 1 VTT (Tháº» vÃ ng: HAGL 1, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK033', 'TR06', 'CT096', 'HAGL', 'BanThang', 40),
('SK034', 'TR06', 'CT042', 'VTT',  'BanThang', 65),
('SK035', 'TR06', 'CT095', 'HAGL', 'TheVang', 55),
('SK036', 'TR06', 'CT038', 'VTT',  'TheVang', 38),
('SK037', 'TR06', 'CT041', 'VTT',  'TheVang', 82);

-- TR07: HNFC 2 - 2 CAHN (Tháº» vÃ ng: HNFC 2, CAHN 3; Tháº» Ä‘á»: HNFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK038', 'TR07', 'CT008', 'HNFC', 'BanThang', 18),
('SK039', 'TR07', 'CT016', 'HNFC', 'BanThang', 70),
('SK040', 'TR07', 'CT027', 'CAHN', 'BanThang', 35),
('SK041', 'TR07', 'CT024', 'CAHN', 'BanThang', 89),
('SK042', 'TR07', 'CT002', 'HNFC', 'TheVang', 25),
('SK043', 'TR07', 'CT006', 'HNFC', 'TheVang', 60),
('SK044', 'TR07', 'CT009', 'HNFC', 'TheDo', 85),
('SK045', 'TR07', 'CT021', 'CAHN', 'TheVang', 44),
('SK046', 'TR07', 'CT025', 'CAHN', 'TheVang', 66),
('SK047', 'TR07', 'CT028', 'CAHN', 'TheVang', 90);

-- TR08: VTT 2 - 0 HPFC (Tháº» vÃ ng: VTT 1, HPFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK048', 'TR08', 'CT046', 'VTT',  'BanThang', 22),
('SK049', 'TR08', 'CT045', 'VTT',  'BanThang', 76),
('SK050', 'TR08', 'CT039', 'VTT',  'TheVang', 50),
('SK051', 'TR08', 'CT076', 'HPFC', 'TheVang', 80);

-- TR09: NDFC 4 - 1 HAGL (Tháº» vÃ ng: NDFC 0, HAGL 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK052', 'TR09', 'CT064', 'NDFC', 'BanThang', 10),
('SK053', 'TR09', 'CT064', 'NDFC', 'BanThang', 38),
('SK054', 'TR09', 'CT061', 'NDFC', 'BanThang', 60),
('SK055', 'TR09', 'CT063', 'NDFC', 'BanThang', 82),
('SK056', 'TR09', 'CT099', 'HAGL', 'BanThang', 70),
('SK057', 'TR09', 'CT093', 'HAGL', 'TheVang', 45);

-- TR10: HAGL 0 - 1 HNFC (Tháº» vÃ ng: HAGL 2, HNFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK058', 'TR10', 'CT007', 'HNFC', 'BanThang', 55),
('SK059', 'TR10', 'CT092', 'HAGL', 'TheVang', 30),
('SK060', 'TR10', 'CT097', 'HAGL', 'TheVang', 80),
('SK061', 'TR10', 'CT014', 'HNFC', 'TheVang', 65);

-- TR11: CAHN 1 - 1 VTT (Tháº» vÃ ng: CAHN 2, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK062', 'TR11', 'CT029', 'CAHN', 'BanThang', 42),
('SK063', 'TR11', 'CT042', 'VTT',  'BanThang', 68),
('SK064', 'TR11', 'CT022', 'CAHN', 'TheVang', 25),
('SK065', 'TR11', 'CT024', 'CAHN', 'TheVang', 75),
('SK066', 'TR11', 'CT040', 'VTT',  'TheVang', 50),
('SK067', 'TR11', 'CT044', 'VTT',  'TheVang', 85);

-- TR12: HPFC 1 - 3 NDFC (Tháº» vÃ ng: HPFC 1, NDFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK068', 'TR12', 'CT082', 'HPFC', 'BanThang', 50),
('SK069', 'TR12', 'CT064', 'NDFC', 'BanThang', 15),
('SK070', 'TR12', 'CT064', 'NDFC', 'BanThang', 65),
('SK071', 'TR12', 'CT068', 'NDFC', 'BanThang', 90),
('SK072', 'TR12', 'CT081', 'HPFC', 'TheVang', 35),
('SK073', 'TR12', 'CT058', 'NDFC', 'TheVang', 40),
('SK074', 'TR12', 'CT062', 'NDFC', 'TheVang', 88);

-- TR13: HNFC 2 - 1 VTT (Tháº» vÃ ng: HNFC 1, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK075', 'TR13', 'CT008', 'HNFC', 'BanThang', 20),
('SK076', 'TR13', 'CT015', 'HNFC', 'BanThang', 75),
('SK077', 'TR13', 'CT046', 'VTT',  'BanThang', 85),
('SK078', 'TR13', 'CT005', 'HNFC', 'TheVang', 60),
('SK079', 'TR13', 'CT038', 'VTT',  'TheVang', 30),
('SK080', 'TR13', 'CT047', 'VTT',  'TheVang', 70);

-- TR14: NDFC 2 - 1 CAHN (Tháº» vÃ ng: NDFC 2, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK081', 'TR14', 'CT064', 'NDFC', 'BanThang', 30),
('SK082', 'TR14', 'CT063', 'NDFC', 'BanThang', 72),
('SK083', 'TR14', 'CT024', 'CAHN', 'BanThang', 55),
('SK084', 'TR14', 'CT057', 'NDFC', 'TheVang', 45),
('SK085', 'TR14', 'CT061', 'NDFC', 'TheVang', 80),
('SK086', 'TR14', 'CT026', 'CAHN', 'TheVang', 65);

-- TR15: HPFC 2 - 0 HAGL (Tháº» vÃ ng: HPFC 1, HAGL 0)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK087', 'TR15', 'CT082', 'HPFC', 'BanThang', 40),
('SK088', 'TR15', 'CT083', 'HPFC', 'BanThang', 68),
('SK089', 'TR15', 'CT077', 'HPFC', 'TheVang', 52);

-- VÃ’NG 6 Äáº¾N VÃ’NG 10 (15 tráº­n lÆ°á»£t vá»)
-- TR16: HPFC 1 - 2 HNFC (VÃ ng: HP 2, HN 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK090', 'TR16', 'CT083', 'HPFC', 'BanThang', 25),
('SK091', 'TR16', 'CT007', 'HNFC', 'BanThang', 50),
('SK092', 'TR16', 'CT008', 'HNFC', 'BanThang', 85),
('SK093', 'TR16', 'CT074', 'HPFC', 'TheVang', 30),
('SK094', 'TR16', 'CT079', 'HPFC', 'TheVang', 70),
('SK095', 'TR16', 'CT002', 'HNFC', 'TheVang', 40),
('SK096', 'TR16', 'CT003', 'HNFC', 'TheVang', 88);

-- TR17: HAGL 0 - 2 CAHN (VÃ ng: HAGL 1, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK097', 'TR17', 'CT028', 'CAHN', 'BanThang', 18),
('SK098', 'TR17', 'CT029', 'CAHN', 'BanThang', 72),
('SK099', 'TR17', 'CT098', 'HAGL', 'TheVang', 55),
('SK100', 'TR17', 'CT021', 'CAHN', 'TheVang', 65);

-- TR18: NDFC 1 - 0 VTT (VÃ ng: NDFC 1, VTT 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK101', 'TR18', 'CT064', 'NDFC', 'BanThang', 60),
('SK102', 'TR18', 'CT059', 'NDFC', 'TheVang', 45),
('SK103', 'TR18', 'CT043', 'VTT',  'TheVang', 80);

-- TR19: HNFC 1 - 1 NDFC (VÃ ng: HN 1, NDFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK104', 'TR19', 'CT008', 'HNFC', 'BanThang', 33),
('SK105', 'TR19', 'CT064', 'NDFC', 'BanThang', 75),
('SK106', 'TR19', 'CT004', 'HNFC', 'TheVang', 50),
('SK107', 'TR19', 'CT056', 'NDFC', 'TheVang', 25),
('SK108', 'TR19', 'CT060', 'NDFC', 'TheVang', 85);

-- TR20: CAHN 2 - 1 HPFC (VÃ ng: CAHN 1, HP 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK109', 'TR20', 'CT024', 'CAHN', 'BanThang', 22),
('SK110', 'TR20', 'CT027', 'CAHN', 'BanThang', 65),
('SK111', 'TR20', 'CT082', 'HPFC', 'BanThang', 80),
('SK112', 'TR20', 'CT020', 'CAHN', 'TheVang', 40),
('SK113', 'TR20', 'CT075', 'HPFC', 'TheVang', 60);

-- TR21: VTT 3 - 1 HAGL (VÃ ng: VTT 0, HAGL 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK114', 'TR21', 'CT042', 'VTT',  'BanThang', 15),
('SK115', 'TR21', 'CT046', 'VTT',  'BanThang', 48),
('SK116', 'TR21', 'CT045', 'VTT',  'BanThang', 82),
('SK117', 'TR21', 'CT096', 'HAGL', 'BanThang', 60),
('SK118', 'TR21', 'CT094', 'HAGL', 'TheVang', 70);

-- TR22: CAHN 1 - 2 HNFC (VÃ ng: CAHN 3, HN 2; Äá»: HNFC 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK119', 'TR22', 'CT029', 'CAHN', 'BanThang', 30),
('SK120', 'TR22', 'CT007', 'HNFC', 'BanThang', 55),
('SK121', 'TR22', 'CT016', 'HNFC', 'BanThang', 90),
('SK122', 'TR22', 'CT022', 'CAHN', 'TheVang', 20),
('SK123', 'TR22', 'CT023', 'CAHN', 'TheVang', 45),
('SK124', 'TR22', 'CT028', 'CAHN', 'TheVang', 75),
('SK125', 'TR22', 'CT006', 'HNFC', 'TheVang', 35),
('SK126', 'TR22', 'CT014', 'HNFC', 'TheVang', 80),
('SK127', 'TR22', 'CT010', 'HNFC', 'TheDo', 88);

-- TR23: HPFC 1 - 1 VTT (VÃ ng: HP 2, VTT 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK128', 'TR23', 'CT082', 'HPFC', 'BanThang', 35),
('SK129', 'TR23', 'CT046', 'VTT',  'BanThang', 70),
('SK130', 'TR23', 'CT076', 'HPFC', 'TheVang', 25),
('SK131', 'TR23', 'CT078', 'HPFC', 'TheVang', 65),
('SK132', 'TR23', 'CT039', 'VTT',  'TheVang', 40),
('SK133', 'TR23', 'CT041', 'VTT',  'TheVang', 82);

-- TR24: HAGL 0 - 2 NDFC (VÃ ng: HAGL 1, NDFC 0)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK134', 'TR24', 'CT064', 'NDFC', 'BanThang', 20),
('SK135', 'TR24', 'CT063', 'NDFC', 'BanThang', 65),
('SK136', 'TR24', 'CT093', 'HAGL', 'TheVang', 50);

-- TR25: HNFC 3 - 0 HAGL (VÃ ng: HN 0, HAGL 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK137', 'TR25', 'CT007', 'HNFC', 'BanThang', 15),
('SK138', 'TR25', 'CT008', 'HNFC', 'BanThang', 42),
('SK139', 'TR25', 'CT015', 'HNFC', 'BanThang', 78),
('SK140', 'TR25', 'CT095', 'HAGL', 'TheVang', 60);

-- TR26: VTT 2 - 1 CAHN (VÃ ng: VTT 2, CAHN 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK141', 'TR26', 'CT042', 'VTT',  'BanThang', 25),
('SK142', 'TR26', 'CT046', 'VTT',  'BanThang', 80),
('SK143', 'TR26', 'CT024', 'CAHN', 'BanThang', 60),
('SK144', 'TR26', 'CT038', 'VTT',  'TheVang', 35),
('SK145', 'TR26', 'CT044', 'VTT',  'TheVang', 75),
('SK146', 'TR26', 'CT025', 'CAHN', 'TheVang', 50);

-- TR27: NDFC 2 - 0 HPFC (VÃ ng: NDFC 1, HP 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK147', 'TR27', 'CT064', 'NDFC', 'BanThang', 40),
('SK148', 'TR27', 'CT061', 'NDFC', 'BanThang', 75),
('SK149', 'TR27', 'CT058', 'NDFC', 'TheVang', 30),
('SK150', 'TR27', 'CT080', 'HPFC', 'TheVang', 65);

-- TR28: VTT 1 - 1 HNFC (VÃ ng: VTT 2, HN 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK151', 'TR28', 'CT046', 'VTT',  'BanThang', 45),
('SK152', 'TR28', 'CT008', 'HNFC', 'BanThang', 70),
('SK153', 'TR28', 'CT040', 'VTT',  'TheVang', 30),
('SK154', 'TR28', 'CT043', 'VTT',  'TheVang', 85),
('SK155', 'TR28', 'CT002', 'HNFC', 'TheVang', 50),
('SK156', 'TR28', 'CT004', 'HNFC', 'TheVang', 90);

-- TR29: CAHN 1 - 1 NDFC (VÃ ng: CAHN 1, NDFC 2)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK157', 'TR29', 'CT024', 'CAHN', 'BanThang', 35),
('SK158', 'TR29', 'CT064', 'NDFC', 'BanThang', 82),
('SK159', 'TR29', 'CT021', 'CAHN', 'TheVang', 60),
('SK160', 'TR29', 'CT057', 'NDFC', 'TheVang', 40),
('SK161', 'TR29', 'CT062', 'NDFC', 'TheVang', 75);

-- TR30: HAGL 2 - 1 HPFC (VÃ ng: HAGL 1, HP 1)
INSERT INTO SU_KIEN_TRAN_DAU (MaSuKien, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan) VALUES
('SK162', 'TR30', 'CT096', 'HAGL', 'BanThang', 20),
('SK163', 'TR30', 'CT100', 'HAGL', 'BanThang', 65),
('SK164', 'TR30', 'CT082', 'HPFC', 'BanThang', 50),
('SK165', 'TR30', 'CT092', 'HAGL', 'TheVang', 40),
('SK166', 'TR30', 'CT074', 'HPFC', 'TheVang', 70);
