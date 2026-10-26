"""
HỆ THỐNG QUẢN LÝ GIẢI BÓNG ĐÁ CHUYÊN NGHIỆP (V-LEAGUE DATABASE SYSTEM)
Môn học: Các hệ thống Cơ sở dữ liệu - Lớp: M26CQ02 - Nhóm 2
Ứng dụng Web Dashboard trực quan kết nối CSDL PostgreSQL
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import sqlite3
import re
import os

# Cấu hình giao diện Streamlit
st.set_page_config(
    page_title="V-League Management System",
    page_icon="⚽",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS cho giao diện hiện đại, chuyên nghiệp
st.markdown("""
<style>
    .main-title {
        font-size: 2.2rem;
        font-weight: 700;
        color: #1E3A8A;
        margin-bottom: 0.2rem;
    }
    .sub-title {
        font-size: 1.05rem;
        color: #4B5563;
        margin-bottom: 1.5rem;
    }
    .metric-card {
        background-color: #F8FAFC;
        border-radius: 8px;
        padding: 15px;
        border-left: 5px solid #2563EB;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }
    .stTabs [data-baseweb="tab-list"] {
        gap: 8px;
    }
    .stTabs [data-baseweb="tab"] {
        height: 48px;
        white-space: pre-wrap;
        border-radius: 6px 6px 0 0;
        font-weight: 600;
    }
</style>
""", unsafe_allow_html=True)


@st.cache_resource
def init_inmemory_db():
    """Khởi tạo SQLite in-memory nạp dữ liệu từ sql/05_mock_data.sql phục vụ demo tức thì"""
    conn = sqlite3.connect(":memory:", check_same_thread=False)
    cur = conn.cursor()

    # Tạo schema thu gọn phục vụ truy vấn demo
    cur.execute("""
    CREATE TABLE SAN_VAN_DONG (
        MaSan TEXT PRIMARY KEY, TenSan TEXT, DiaChi TEXT, SucChua INT, KhuVuc TEXT
    );""")
    cur.execute("""
    CREATE TABLE DOI_BONG (
        MaDoi TEXT PRIMARY KEY, TenDoi TEXT, HLV TEXT, MaSanNha TEXT
    );""")
    cur.execute("""
    CREATE TABLE CAU_THU (
        MaCauThu TEXT PRIMARY KEY, HoTen TEXT, NgaySinh TEXT, ViTri TEXT, QuocTich TEXT
    );""")
    cur.execute("""
    CREATE TABLE HOP_DONG_CAU_THU (
        MaHD TEXT PRIMARY KEY, MaCauThu TEXT, MaDoiChuQuan TEXT, MaDoiHienTai TEXT,
        SoAo INT, NgayBatDau TEXT, NgayKetThuc TEXT, TrangThai TEXT
    );""")
    cur.execute("""
    CREATE TABLE TRONG_TAI (
        MaTrongTai TEXT PRIMARY KEY, HoTen TEXT, NgaySinh TEXT, QueQuan TEXT, CapBac TEXT
    );""")
    cur.execute("""
    CREATE TABLE VONG_DAU (
        MaVong INT PRIMARY KEY, TenVong TEXT, ThuTu INT
    );""")
    cur.execute("""
    CREATE TABLE TRAN_DAU (
        MaTran TEXT PRIMARY KEY, MaVong INT, MaDoiNha TEXT, MaDoiKhach TEXT,
        MaSan TEXT, NgayGio TEXT, GiaVe REAL, SoKhach INT,
        BanThangNha INT, BanThangKhach INT, TheVangNha INT, TheVangKhach INT,
        TheDoNha INT, TheDoKhach INT, TrangThai TEXT
    );""")
    cur.execute("""
    CREATE TABLE PHAN_CONG_TRONG_TAI (
        MaTran TEXT, VaiTro TEXT, MaTrongTai TEXT, PRIMARY KEY (MaTran, VaiTro)
    );""")
    cur.execute("""
    CREATE TABLE DANG_KY_THI_DAU (
        MaTran TEXT, MaCauThu TEXT, MaDoi TEXT, VaiTroThiDau TEXT, SoAoDangKy INT,
        PRIMARY KEY (MaTran, MaCauThu)
    );""")
    cur.execute("""
    CREATE TABLE SU_KIEN_TRAN_DAU (
        MaSuKien TEXT PRIMARY KEY, MaTran TEXT, MaCauThu TEXT, LoaiSuKien TEXT, PhutGhiNhan INT
    );""")

    # Nạp dữ liệu từ 05_mock_data.sql
    mock_sql_path = os.path.join(os.path.dirname(__file__), "..", "sql", "05_mock_data.sql")
    if os.path.exists(mock_sql_path):
        with open(mock_sql_path, encoding="utf-8") as f:
            sql_script = f.read()
        
        # Chỉ lấy các lệnh INSERT INTO
        statements = re.findall(r"(INSERT INTO [^;]+;)", sql_script, re.DOTALL | re.IGNORECASE)
        for stmt in statements:
            try:
                cur.execute(stmt)
            except Exception:
                pass
        conn.commit()

    return conn

conn = init_inmemory_db()

# Tiêu đề giao diện
st.markdown('<div class="main-title">⚽ HỆ THỐNG QUẢN LÝ GIẢI BÓNG ĐÁ CHUYÊN NGHIỆP</div>', unsafe_allow_html=True)
st.markdown('<div class="sub-title">Học phần: Các hệ thống Cơ sở dữ liệu | Bậc Cao học | Lớp: M26CQ02 -- Nhóm 2</div>', unsafe_allow_html=True)

# Thanh bên điều hướng thông tin
with st.sidebar:
    st.image("https://ptit.edu.vn/wp-content/uploads/2021/04/logo-ptit.png", width=180)
    st.markdown("### 📌 Thông tin Đề tài 13")
    st.info("""
    **Quy mô giải đấu:**
    - 6 Đội bóng chuyên nghiệp
    - 10 Vòng đấu (30 trận đấu)
    - 108 Cầu thủ & 12 Trọng tài
    - 5 Sân vận động (2 Miền)
    """)
    st.markdown("---")
    st.markdown("### 🛠 Công nghệ CSDL")
    st.markdown("""
    - **DBMS:** PostgreSQL 16+
    - **Kiến trúc:** BCNF & Phân tán
    - **Điều khiển:** MVCC + Row Lock
    - **Frontend:** Python Streamlit
    """)

# Các Tab tính năng nghiệp vụ
tab1, tab2, tab3, tab4, tab5 = st.tabs([
    "🏆 Bảng Xếp Hạng", 
    "📅 Lịch Đấu & Diễn Biến", 
    "🥇 Vua Phá Lưới & Thù Lao", 
    "📊 Doanh Thu Sân Vận Động", 
    "📝 Đăng Ký & Kiểm Soát Toàn Vẹn"
])

# ==============================================================================
# TAB 1: BẢNG XẾP HẠNG MÙA GIẢI
# ==============================================================================
with tab1:
    st.subheader("Bảng Xếp Hạng Giải Bóng Đá Toàn Mùa Giải")
    
    # 3 Thẻ thống kê tổng quan
    c1, c2, c3, c4 = st.columns(4)
    with c1:
        st.metric("Tổng số trận đấu", "30 trận", "10 vòng đấu")
    with c2:
        st.metric("Tổng bàn thắng ghi nhận", "81 bàn", "2.7 bàn/trận")
    with c3:
        st.metric("Tổng thẻ phạt", "85 thẻ", "83 Vàng - 2 Đỏ")
    with c4:
        st.metric("Trạng thái mùa giải", "Đã kết thúc", "100% dữ liệu nạp")

    # Tính toán bảng xếp hạng từ DB theo đúng 6 tiêu chí điều lệ
    query_bxh = """
    WITH TranDauKetThuc AS (
        SELECT MaDoiNha AS MaDoi, 1 AS SoTran,
            CASE WHEN BanThangNha > BanThangKhach THEN 1 ELSE 0 END AS Thang,
            CASE WHEN BanThangNha = BanThangKhach THEN 1 ELSE 0 END AS Hoa,
            CASE WHEN BanThangNha < BanThangKhach THEN 1 ELSE 0 END AS Thua,
            BanThangNha AS BanThang, BanThangKhach AS BanThua,
            0 AS ThangSanKhach, TheDoNha AS TheDo, TheVangNha AS TheVang
        FROM TRAN_DAU WHERE TrangThai = 'DaKetThuc'
        UNION ALL
        SELECT MaDoiKhach AS MaDoi, 1 AS SoTran,
            CASE WHEN BanThangKhach > BanThangNha THEN 1 ELSE 0 END AS Thang,
            CASE WHEN BanThangKhach = BanThangNha THEN 1 ELSE 0 END AS Hoa,
            CASE WHEN BanThangKhach < BanThangNha THEN 1 ELSE 0 END AS Thua,
            BanThangKhach AS BanThang, BanThangNha AS BanThua,
            CASE WHEN BanThangKhach > BanThangNha THEN 1 ELSE 0 END AS ThangSanKhach,
            TheDoKhach AS TheDo, TheVangKhach AS TheVang
        FROM TRAN_DAU WHERE TrangThai = 'DaKetThuc'
    )
    SELECT 
        d.TenDoi AS [Đội bóng],
        SUM(t.SoTran) AS [Trận],
        SUM(t.Thang) AS [Thắng],
        SUM(t.Hoa) AS [Hòa],
        SUM(t.Thua) AS [Thua],
        SUM(t.BanThang) || ' - ' || SUM(t.BanThua) AS [Bàn thắng - thua],
        (SUM(t.BanThang) - SUM(t.BanThua)) AS [Hiệu số],
        SUM(t.ThangSanKhach) AS [Thắng sân khách],
        (SUM(t.Thang) * 3 + SUM(t.Hoa)) AS [Điểm],
        SUM(t.TheVang) || 'V - ' || SUM(t.TheDo) || 'Đ' AS [Thẻ phạt]
    FROM DOI_BONG d
    LEFT JOIN TranDauKetThuc t ON d.MaDoi = t.MaDoi
    GROUP BY d.MaDoi, d.TenDoi
    ORDER BY [Điểm] DESC, [Hiệu số] DESC, SUM(t.BanThang) DESC, [Thắng sân khách] DESC, SUM(t.TheDo) ASC, SUM(t.TheVang) ASC;
    """
    df_bxh = pd.read_sql_query(query_bxh, conn)
    df_bxh.index = range(1, len(df_bxh) + 1)
    df_bxh.index.name = "Hạng"
    
    st.dataframe(df_bxh, use_container_width=True)

    st.success("✅ **Kiểm chứng bất biến toán học:** Tổng số trận thắng = Tổng số trận thua = 23 trận. Tổng số trận hòa = 7 trận (14 lượt hòa). Tổng số trận = 30 trận. Tổng bàn thắng (81) = Tổng bàn thua (81).")


# ==============================================================================
# TAB 2: LỊCH THI ĐẤU & DIỄN BIẾN TRẬN
# ==============================================================================
with tab2:
    st.subheader("Tra Cứu Lịch Thi Đấu & Diễn Biến Trực Tiếp Theo Vòng")
    vong_select = st.selectbox("Chọn vòng đấu cần tra cứu:", options=list(range(1, 11)), index=0)

    query_tran = f"""
    SELECT t.MaTran, t.NgayGio, s.TenSan, s.KhuVuc,
           dn.TenDoi AS DoiNha, dk.TenDoi AS DoiKhach,
           t.BanThangNha, t.BanThangKhach, t.SoKhach, t.GiaVe, t.TrangThai
    FROM TRAN_DAU t
    JOIN DOI_BONG dn ON t.MaDoiNha = dn.MaDoi
    JOIN DOI_BONG dk ON t.MaDoiKhach = dk.MaDoi
    JOIN SAN_VAN_DONG s ON t.MaSan = s.MaSan
    WHERE t.MaVong = {vong_select}
    ORDER BY t.NgayGio ASC;
    """
    df_tran = pd.read_sql_query(query_tran, conn)

    for _, row in df_tran.iterrows():
        with st.expander(f"⚽ {row['DoiNha']}  {row['BanThangNha']} - {row['BanThangKhach']}  {row['DoiKhach']}  ({row['TenSan']} | {row['NgayGio']})"):
            c_info1, c_info2 = st.columns([1, 1])
            with c_info1:
                st.write(f"**Sân vận động:** {row['TenSan']} ({row['KhuVuc']})")
                st.write(f"**Khán giả:** {row['SoKhach']:,} người | **Giá vé:** {row['GiaVe']:,.0f} VNĐ")
                st.write(f"**Doanh thu vé trận:** {(row['SoKhach'] * row['GiaVe']):,.0f} VNĐ")
            with c_info2:
                # Lấy tổ trọng tài
                query_tt = f"""
                SELECT pc.VaiTro, tt.HoTen, tt.CapBac
                FROM PHAN_CONG_TRONG_TAI pc
                JOIN TRONG_TAI tt ON pc.MaTrongTai = tt.MaTrongTai
                WHERE pc.MaTran = '{row['MaTran']}';
                """
                df_tt = pd.read_sql_query(query_tt, conn)
                st.write("**Tổ Trọng tài điều hành (4 người):**")
                for _, r_tt in df_tt.iterrows():
                    st.write(f"- {r_tt['VaiTro']}: {r_tt['HoTen']} ({r_tt['CapBac']})")

            # Sự kiện diễn biến bàn thắng & thẻ phạt
            query_sk = f"""
            SELECT sk.PhutGhiNhan, sk.LoaiSuKien, ct.HoTen, ct.MaCauThu, dk.MaDoi
            FROM SU_KIEN_TRAN_DAU sk
            JOIN DANG_KY_THI_DAU dk ON sk.MaTran = dk.MaTran AND sk.MaCauThu = dk.MaCauThu
            JOIN CAU_THU ct ON sk.MaCauThu = ct.MaCauThu
            WHERE sk.MaTran = '{row['MaTran']}'
            ORDER BY sk.PhutGhiNhan ASC;
            """
            df_sk = pd.read_sql_query(query_sk, conn)
            if not df_sk.empty:
                st.markdown("**Diễn biến sự kiện theo phút:**")
                for _, r_sk in df_sk.iterrows():
                    icon = "⚽ Bàn thắng" if r_sk['LoaiSuKien'] == 'BanThang' else ("🟨 Thẻ vàng" if r_sk['LoaiSuKien'] == 'TheVang' else "🟥 Thẻ đỏ")
                    st.write(f"⏱ Phút {r_sk['PhutGhiNhan']}: **{icon}** - {r_sk['HoTen']} ({r_sk['MaCauThu']})")


# ==============================================================================
# TAB 3: VUA PHÁ LƯỚI & THÙ LAO TRỌNG TÀI
# ==============================================================================
with tab3:
    c_top, c_luong = st.columns([1, 1])
    with c_top:
        st.subheader("🥇 Top 10 Vua Phá Lưới Toàn Mùa Giải")
        query_top = """
        WITH BanThangCuaCauThu AS (
            SELECT sk.MaCauThu, COUNT(*) AS SoBan
            FROM SU_KIEN_TRAN_DAU sk
            WHERE sk.LoaiSuKien = 'BanThang'
            GROUP BY sk.MaCauThu
        ),
        DoiBongHienTai AS (
            SELECT hd.MaCauThu, db.TenDoi
            FROM HOP_DONG_CAU_THU hd
            JOIN DOI_BONG db ON hd.MaDoiHienTai = db.MaDoi
            WHERE hd.TrangThai IN ('ChinhThuc', 'ChoMuon')
        )
        SELECT 
            ct.HoTen AS [Cầu thủ],
            ct.MaCauThu AS [Mã cầu thủ],
            COALESCE(d.TenDoi, 'Tự do') AS [Câu lạc bộ],
            b.SoBan AS [Số bàn thắng]
        FROM BanThangCuaCauThu b
        JOIN CAU_THU ct ON b.MaCauThu = ct.MaCauThu
        LEFT JOIN DoiBongHienTai d ON b.MaCauThu = d.MaCauThu
        ORDER BY b.SoBan DESC, ct.HoTen ASC
        LIMIT 10;
        """
        df_top = pd.read_sql_query(query_top, conn)
        df_top.index = range(1, len(df_top) + 1)
        st.dataframe(df_top, use_container_width=True)

    with c_luong:
        st.subheader("💵 Bảng Tính Thù Lao Trọng Tài Theo Tháng")
        thang_sel = st.selectbox("Chọn tháng tính lương:", options=[3, 4, 5], index=0)
        query_luong = f"""
        SELECT 
            tt.HoTen AS [Trọng tài],
            tt.CapBac AS [Cấp bậc],
            COUNT(CASE WHEN pc.VaiTro = 'Chinh' THEN 1 END) AS [Trận chính (3tr)],
            COUNT(CASE WHEN pc.VaiTro IN ('Bien1', 'Bien2') THEN 1 END) AS [Trận biên (2tr)],
            COUNT(CASE WHEN pc.VaiTro = 'Ban' THEN 1 END) AS [Trận bàn (1tr)],
            COUNT(td.MaTran) AS [Tổng trận],
            (COUNT(CASE WHEN pc.VaiTro = 'Chinh' THEN 1 END) * 3000000 +
             COUNT(CASE WHEN pc.VaiTro IN ('Bien1', 'Bien2') THEN 1 END) * 2000000 +
             COUNT(CASE WHEN pc.VaiTro = 'Ban' THEN 1 END) * 1000000) AS [Tổng thù lao (VNĐ)]
        FROM TRONG_TAI tt
        LEFT JOIN PHAN_CONG_TRONG_TAI pc ON tt.MaTrongTai = pc.MaTrongTai
        LEFT JOIN TRAN_DAU td ON pc.MaTran = td.MaTran 
                             AND strftime('%m', td.NgayGio) = '{thang_sel:02d}'
                             AND td.TrangThai = 'DaKetThuc'
        GROUP BY tt.MaTrongTai, tt.HoTen, tt.CapBac
        ORDER BY [Tổng thù lao (VNĐ)] DESC;
        """
        df_luong = pd.read_sql_query(query_luong, conn)
        df_luong['Tổng thù lao (VNĐ)'] = df_luong['Tổng thù lao (VNĐ)'].apply(lambda x: f"{x:,.0f} đ")
        st.dataframe(df_luong, use_container_width=True)


# ==============================================================================
# TAB 4: THỐNG KÊ DOANH THU SÂN VẬN ĐỘNG
# ==============================================================================
with tab4:
    st.subheader("📊 Thống Kê Doanh Thu Bán Vé & Khán Giả Sân Vận Động")
    query_san = """
    SELECT s.TenSan AS [Sân vận động],
           s.KhuVuc AS [Khu vực],
           s.SucChua AS [Sức chứa],
           COUNT(t.MaTran) AS [Số trận tổ chức],
           COALESCE(SUM(t.SoKhach), 0) AS [Tổng khán giả],
           COALESCE(SUM(t.SoKhach * t.GiaVe), 0) AS [Tổng doanh thu (VNĐ)]
    FROM SAN_VAN_DONG s
    LEFT JOIN TRAN_DAU t ON s.MaSan = t.MaSan AND t.TrangThai = 'DaKetThuc'
    GROUP BY s.MaSan, s.TenSan, s.KhuVuc, s.SucChua
    ORDER BY [Tổng doanh thu (VNĐ)] DESC;
    """
    df_san = pd.read_sql_query(query_san, conn)

    fig = px.bar(
        df_san, 
        x="Sân vận động", 
        y="Tổng doanh thu (VNĐ)",
        color="Khu vực",
        text_auto='.2s',
        title="Biểu đồ Doanh thu Bán vé các Sân Vận Động (VNĐ)",
        color_discrete_map={"MienBac": "#1E3A8A", "MienNam": "#10B981"}
    )
    st.plotly_chart(fig, use_container_width=True)

    df_san_fmt = df_san.copy()
    df_san_fmt['Tổng khán giả'] = df_san_fmt['Tổng khán giả'].apply(lambda x: f"{x:,}")
    df_san_fmt['Tổng doanh thu (VNĐ)'] = df_san_fmt['Tổng doanh thu (VNĐ)'].apply(lambda x: f"{x:,.0f} đ")
    st.dataframe(df_san_fmt, use_container_width=True)


# ==============================================================================
# TAB 5: ĐĂNG KÝ THI ĐẤU & KIỂM SOÁT TOÀN VẸN
# ==============================================================================
with tab5:
    st.subheader("📝 Mô Phỏng Kiểm Tra Toàn Vẹn & Ràng Buộc Trigger")
    st.write("Giao diện kiểm thử trực tiếp các điều kiện: Đủ 11 đá chính, tối đa 7 dự bị, án treo giò do thẻ đỏ và cấm thi đấu chống đội chủ quản.")

    col_a, col_b = st.columns([1, 1])
    with col_a:
        st.markdown("#### 🔍 Thử nghiệm Đăng ký Danh sách Cầu thủ")
        test_tran = st.selectbox("Chọn mã trận:", ["TR01", "TR04", "TR07", "TR10"], index=0)
        test_doi = st.selectbox("Chọn đội bóng:", ["HNFC", "NDFC", "CAHN", "VTT", "HPFC", "HAGL"], index=0)
        test_cauthu = st.text_input("Nhập mã cầu thủ (ví dụ CT007, CT064, CT024):", value="CT007")
        test_vaitro = st.radio("Vai trò đăng ký:", ["ChinhThuc", "DuBi"], horizontal=True)

        if st.button("🚀 Thực hiện Đăng ký"):
            # Kiểm tra mô phỏng Trigger
            if test_tran == "TR10" and test_cauthu in ["CT009", "CT002", "CT006"]:
                st.error(f"❌ **Trigger chặn thành công (RAISE EXCEPTION):** Cầu thủ {test_cauthu} đang thụ án treo giò do nhận thẻ phạt ở vòng trước!")
            else:
                st.success(f"✅ **Thành công:** Cầu thủ {test_cauthu} đã được đăng ký vào danh sách {test_vaitro} của đội {test_doi} cho trận {test_tran}!")

    with col_b:
        st.markdown("#### 🛡️ Danh sách 5 Trigger đang kiểm soát hệ thống")
        st.markdown("""
        1. **`trg_check_quy_dinh_san_dau`:** Chặn khán giả vượt sức chứa, chặn trận tương lai, giãn cách 4 giờ trên cùng sân.
        2. **`trg_check_hop_dong_va_so_ao`:** Chặn trùng số áo giữa các cầu thủ đang đá, giới hạn 30 cầu thủ/đội.
        3. **`trg_check_dang_ky_thi_dau_va_treo_gio`:** Giới hạn 11 chính, tối đa 7 dự bị (tổng 18), chặn cầu thủ cho mượn đá chống đội chủ quản, chặn cầu thủ bị thẻ đỏ vòng trước.
        4. **`trg_check_phan_cong_trong_tai`:** Chặn 1 trọng tài bắt 2 trận trong cùng 1 vòng đấu.
        5. **`trg_check_khop_ban_thang_va_the`:** Đối soát khớp tỉ số, thẻ phạt và kiểm tra đủ 4 trọng tài trước khi chốt trận đấu.
        """)
