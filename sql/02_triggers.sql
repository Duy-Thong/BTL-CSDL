-- ============================================================================
-- PHẦN 2: CÀI ĐẶT 5 TRIGGER BẮT BUỘC KIỂM TRA TOÀN VẸN NGHIỆP VỤ
-- HỆ QUẢN TRỊ: PostgreSQL (PL/pgSQL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRIGGER 1: KIỂM TRA SỐ ÁO CẦU THỦ DUY NHẤT TRONG CÙNG MỘT ĐỘI BÓNG
-- Nghiệp vụ: Các cầu thủ trong cùng một đội không được trùng số áo.
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
      -- Kiểm tra thời hạn hợp đồng giao thoa
      AND NOT (NgayKetThuc < NEW.NgayBatDau OR NgayBatDau > NEW.NgayKetThuc);

    IF v_trung_so_ao > 0 THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Số áo % đã được đăng ký cho cầu thủ khác trong đội bóng %!', 
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
-- TRIGGER 2: KIỂM TRA GIỚI HẠN TỐI ĐA 30 CẦU THỦ CHO MỖI ĐỘI BÓNG
-- Nghiệp vụ: Một đội bóng chỉ có tối đa 30 cầu thủ có hợp đồng còn hiệu lực.
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
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Đội bóng % đã có đủ tối đa 30 cầu thủ đang thi đấu!', 
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
-- TRIGGER 3: MỘT TRỌNG TÀI CHỈ ĐIỀU KHIỂN TỐI ĐA 1 TRẬN TRONG MỖI VÒNG ĐẤU
-- Nghiệp vụ: 1 trọng tài không được phân công cho 2 trận đấu trong cùng 1 vòng.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_check_trong_tai_toi_da_1_tran_1_vong()
RETURNS TRIGGER AS $$
DECLARE
    v_ma_vong INT;
    v_so_tran INT;
BEGIN
    -- Lấy mã vòng đấu của trận đấu đang được phân công
    SELECT MaVong INTO v_ma_vong
    FROM TRAN_DAU
    WHERE MaTran = NEW.MaTran;

    -- Kiểm tra xem trọng tài này đã có trận nào khác trong cùng vòng đấu chưa
    SELECT COUNT(*) INTO v_so_tran
    FROM PHAN_CONG_TRONG_TAI pc
    JOIN TRAN_DAU td ON pc.MaTran = td.MaTran
    WHERE pc.MaTrongTai = NEW.MaTrongTai
      AND td.MaVong = v_ma_vong
      AND td.MaTran <> NEW.MaTran;

    IF v_so_tran > 0 THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Trọng tài % đã được phân công điều khiển một trận đấu khác trong vòng đấu số %!', 
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
-- TRIGGER 4: MỖI ĐỘI BÓNG CHỈ ĐĂNG KÝ TỐI ĐA 18 CẦU THỦ TRONG MỘT TRẬN ĐẤU
-- Nghiệp vụ: Giới hạn danh sách đăng ký thi đấu của mỗi đội trong 1 trận là 18.
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
        RAISE EXCEPTION 'Lỗi nghiệp vụ: Đội bóng % đã đăng ký đủ tối đa 18 cầu thủ cho trận đấu %!', 
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
-- TRIGGER 5: KIỂM TRA KHỚP TỔNG BÀN THẮNG VÀ THẺ PHẠT VỚI KẾT QUẢ TRẬN ĐẤU
-- Nghiệp vụ: Khi trận đấu kết thúc, tổng bàn thắng/thẻ trong bảng sự kiện 
--            phải khớp chính xác với tỉ số và số thẻ ghi nhận trong bảng TRAN_DAU.
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
    -- Chỉ kiểm tra khi trận đấu được chuyển sang trạng thái đã kết thúc
    IF NEW.TrangThai = 'DaKetThuc' THEN
        -- Đếm sự kiện bàn thắng
        SELECT COUNT(*) INTO v_ban_nha
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiNha AND LoaiSuKien = 'BanThang';

        SELECT COUNT(*) INTO v_ban_khach
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiKhach AND LoaiSuKien = 'BanThang';

        -- Đếm sự kiện thẻ vàng
        SELECT COUNT(*) INTO v_the_vang_nha
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiNha AND LoaiSuKien = 'TheVang';

        SELECT COUNT(*) INTO v_the_vang_khach
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiKhach AND LoaiSuKien = 'TheVang';

        -- Đếm sự kiện thẻ đỏ
        SELECT COUNT(*) INTO v_the_do_nha
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiNha AND LoaiSuKien = 'TheDo';

        SELECT COUNT(*) INTO v_the_do_khach
        FROM SU_KIEN_TRAN_DAU
        WHERE MaTran = NEW.MaTran AND MaDoi = NEW.MaDoiKhach AND LoaiSuKien = 'TheDo';

        -- So sánh đối chiếu với số liệu trận đấu
        IF v_ban_nha <> NEW.BanThangNha OR v_ban_khach <> NEW.BanThangKhach THEN
            RAISE EXCEPTION 'Lỗi toàn vẹn dữ liệu: Số bàn thắng trong bảng sự kiện (Nhà: %, Khách: %) không khớp với tỉ số trận đấu (Nhà: %, Khách: %)!',
                v_ban_nha, v_ban_khach, NEW.BanThangNha, NEW.BanThangKhach;
        END IF;

        IF v_the_vang_nha <> NEW.TheVangNha OR v_the_vang_khach <> NEW.TheVangKhach THEN
            RAISE EXCEPTION 'Lỗi toàn vẹn dữ liệu: Số thẻ vàng trong bảng sự kiện không khớp với tổng thẻ vàng của trận đấu!';
        END IF;

        IF v_the_do_nha <> NEW.TheDoNha OR v_the_do_khach <> NEW.TheDoKhach THEN
            RAISE EXCEPTION 'Lỗi toàn vẹn dữ liệu: Số thẻ đỏ trong bảng sự kiện không khớp với tổng thẻ đỏ của trận đấu!';
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
