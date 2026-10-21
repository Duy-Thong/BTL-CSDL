# GIAI ĐOẠN 3: PHÂN TÍCH VÀ THIẾT KẾ CƠ SỞ DỮ LIỆU PHÂN TÁN
**Đề tài 13:** Xây dựng Hệ CSDL quản lý một giải bóng đá chuyên nghiệp  
**Môn học:** Các hệ thống CSDL - M26CQ02 (Nhóm 2)  
**Mô hình kiến trúc:** 3 Trạm (1 Trạm Trung tâm điều hành + 2 Chi nhánh khu vực)

---

## MỤC LỤC
1. [Khảo sát bài toán và Giả thuyết phân tán theo chi nhánh](#1-khảo-sát-bài-toán-và-giả-thuyết-phân-tán-theo-chi-nhánh)
2. [Thiết kế phân mảnh dữ liệu (Fragmentation Design)](#2-thiết-kế-phân-mảnh-dữ-liệu-fragmentation-design)
   * [2.1. Phân mảnh ngang nguyên thủy](#21-phân-mảnh-ngang-nguyên-thủy)
   * [2.2. Phân mảnh ngang dẫn xuất](#22-phân-mảnh-ngang-dẫn-xuất)
   * [2.3. Phân mảnh dọc](#23-phân-mảnh-dọc)
   * [2.4. Nhân bản dữ liệu](#24-nhân-bản-dữ-liệu)
3. [Chứng minh tính đúng đắn của phân mảnh](#3-chứng-minh-tính-đúng-đắn-của-phân-mảnh)
4. [Định vị dữ liệu và Ma trận phân phối](#4-định-vị-dữ-liệu-và-ma-trận-phân-phối)
5. [Sơ đồ kiến trúc CSDL Phân tán tổng quát](#5-sơ-đồ-kiến-trúc-csdl-phân-tán-tổng-quát)
6. [Kịch bản mô phỏng phân tán trên PostgreSQL bằng postgres_fdw](#6-kịch-bản-mô-phỏng-phân-tán-trên-postgresql-bằng-postgres_fdw)

---

## 1. KHẢO SÁT BÀI TOÁN VÀ GIẢ THUYẾT PHÂN TÁN THEO CHI NHÁNH

### 1.1. Bối cảnh bài toán phân tán
Trong thực tế tổ chức giải bóng đá chuyên nghiệp quốc gia, các trận đấu diễn ra phân bố tại nhiều tỉnh thành trên cả nước. Việc tập trung toàn bộ dữ liệu tại một máy chủ duy nhất sẽ bộc lộ các nhược điểm:
* Tăng nghẽn đường truyền mạng diện rộng khi các ban tổ chức trận đấu tại địa phương đồng thời gửi dữ liệu đăng ký danh sách thi đấu và cập nhật diễn biến sự kiện trực tiếp.
* Nếu máy chủ trung tâm gặp sự cố, toàn bộ hoạt động kiểm tra, đăng ký trận đấu tại các sân đều bị tê liệt.
* Chi phí truy vấn dữ liệu cục bộ cao do mọi thao tác kiểm tra danh sách cầu thủ, màu áo, trọng tài đều phải gửi qua mạng về máy chủ trung tâm.

### 1.2. Giả thuyết cấu hình hệ thống phân tán
Hệ thống được thiết kế theo mô hình phân tán gồm **3 Trạm (Sites)** kết nối qua mạng máy tính:
* **Site 0 (Trạm Trung tâm - Trụ sở Ban tổ chức giải đấu)**:
  * Đặt tại trụ sở Liên đoàn Bóng đá.
  * Vai trò: Quản lý tổng thể giải đấu, theo dõi toàn bộ các trận đấu trên cả nước, lưu trữ thông tin hợp đồng tài chính bảo mật (mức lương cầu thủ, thù lao chi trả), tổng hợp bảng xếp hạng và vua phá lưới toàn quốc.
* **Site 1 (Chi nhánh Miền Bắc - Ban điều hành khu vực phía Bắc)**:
  * Trụ sở điều hành đặt tại Hà Nội.
  * Vai trò: Quản lý trực tiếp các sân vận động và tổ chức các trận đấu diễn ra tại khu vực phía Bắc:
    * Sân Hàng Đẫy (`SAN_HD`), Sân Quốc gia Mỹ Đình (`SAN_MD`), Sân Lạch Tray (`SAN_LT`), Sân Thiên Trường (`SAN_TT`).
    * Thực hiện tiếp nhận danh sách đăng ký 18 cầu thủ trước trận, phân công tổ trọng tài tại các sân miền Bắc, cập nhật diễn biến bàn thắng và thẻ phạt trực tiếp tại các trận đấu trên các sân này.
* **Site 2 (Chi nhánh Miền Trung và Nam - Ban điều hành khu vực phía Nam)**:
  * Trụ sở điều hành đặt tại TP Pleiku / TP Hồ Chí Minh.
  * Vai trò: Quản lý các sân vận động và tổ chức các trận đấu diễn ra tại khu vực phía Nam:
    * Sân Pleiku (`SAN_PK`).
    * Thực hiện quản lý điều hành các trận đấu tổ chức trên sân Pleiku.

### 1.3. Bảng số liệu giả định tần suất ứng dụng và truy vấn
Xét chu kỳ 1 vòng đấu (3 trận diễn ra vào cuối tuần):
| Ứng dụng | Mô tả thao tác | Tần suất tại Site 1 | Tần suất tại Site 2 | Tần suất tại Site 0 |
|---|---|:---:|:---:|:---:|
| **App 1** | Tra cứu thông tin đội bóng, cầu thủ, màu áo | 800 lần | 300 lần | 100 lần |
| **App 2** | Đăng ký 18 cầu thủ trước trận đấu | 20 lần | 10 lần | 0 lần |
| **App 3** | Cập nhật tỉ số, sự kiện bàn thắng, thẻ phạt theo phút | 150 lần | 50 lần | 10 lần |
| **App 4** | Thống kê doanh thu vé sân và tính lương trọng tài | 10 lần | 5 lần | 50 lần |
| **App 5** | Quản lý hợp đồng tài chính, mức lương cầu thủ | 0 lần | 0 lần | 80 lần |

$\rightarrow$ **Nhận xét**: 
* Các thao tác điều hành trận đấu (`TRAN_DAU`, `DANG_KY_THI_DAU`, `SU_KIEN_TRAN_DAU`) mang tính địa phương cao, diễn ra trực tiếp tại sân vận động tổ chức trận.
* Thông tin danh mục (`DOI_BONG`, `CAU_THU`, `TRONG_TAI`) được đọc rất nhiều tại các chi nhánh nhưng rất ít khi thay đổi.
* Thông tin lương (`MucLuong`) chỉ được xử lý tập trung tại Ban tổ chức trung tâm.

---

## 2. THIẾT KẾ PHÂN MẢNH DỮ LIỆU (FRAGMENTATION DESIGN)

### 2.1. Phân mảnh ngang nguyên thủy (Primary Horizontal Fragmentation)

#### (1) Phân mảnh quan hệ `SAN_VAN_DONG`
* **Vị từ cơ sở**:
  * $p_1$: `MaSan IN ('SAN_HD', 'SAN_MD', 'SAN_LT', 'SAN_TT')` (Khu vực phía Bắc)
  * $p_2$: `MaSan IN ('SAN_PK')` (Khu vực phía Nam)
* **Tập các mảnh**:
  $$\text{SAN\_VAN\_DONG}_1 = \sigma_{p_1}(\text{SAN\_VAN\_DONG})$$
  $$\text{SAN\_VAN\_DONG}_2 = \sigma_{p_2}(\text{SAN\_VAN\_DONG})$$
* **Định vị**:
  * $\text{SAN\_VAN\_DONG}_1$ được định vị tại **Site 1**.
  * $\text{SAN\_VAN\_DONG}_2$ được định vị tại **Site 2**.

#### (2) Phân mảnh quan hệ `TRAN_DAU`
* **Tiêu chí**: Phân mảnh theo địa điểm diễn ra trận đấu (trận đấu tổ chức trên sân miền Bắc thuộc thẩm quyền quản lý của Chi nhánh miền Bắc; trận đấu trên sân miền Nam thuộc Chi nhánh miền Nam).
* **Vị từ cơ sở**:
  * $q_1$: `MaSan IN ('SAN_HD', 'SAN_MD', 'SAN_LT', 'SAN_TT')`
  * $q_2$: `MaSan IN ('SAN_PK')`
* **Tập các mảnh**:
  $$\text{TRAN\_DAU}_1 = \sigma_{q_1}(\text{TRAN\_DAU})$$
  $$\text{TRAN\_DAU}_2 = \sigma_{q_2}(\text{TRAN\_DAU})$$
* **Định vị**:
  * $\text{TRAN\_DAU}_1$ định vị tại **Site 1** (quản lý 25 trận đấu diễn ra tại các sân Hàng Đẫy, Mỹ Đình, Lạch Tray, Thiên Trường).
  * $\text{TRAN\_DAU}_2$ định vị tại **Site 2** (quản lý 5 trận đấu diễn ra tại sân Pleiku).

---

### 2.2. Phân mảnh ngang dẫn xuất (Derived Horizontal Fragmentation)
Phân mảnh ngang dẫn xuất áp dụng toán tử bán kết nối (Semi-join $\ltimes$) dựa trên khóa ngoại `MaTran` tham chiếu đến quan hệ chủ `TRAN_DAU`:

#### (1) Phân mảnh quan hệ `PHAN_CONG_TRONG_TAI`
Tổ trọng tài phân công cho trận đấu nào sẽ được lưu trữ cục bộ tại chi nhánh quản lý trận đấu đó:
$$\text{PHAN\_CONG\_TRONG\_TAI}_1 = \text{PHAN\_CONG\_TRONG\_TAI} \ltimes_{\text{MaTran}} \text{TRAN\_DAU}_1$$
$$\text{PHAN\_CONG\_TRONG\_TAI}_2 = \text{PHAN\_CONG\_TRONG\_TAI} \ltimes_{\text{MaTran}} \text{TRAN\_DAU}_2$$
* $\text{PHAN\_CONG\_TRONG\_TAI}_1$ định vị tại **Site 1**.
* $\text{PHAN\_CONG\_TRONG\_TAI}_2$ định vị tại **Site 2**.

#### (2) Phân mảnh quan hệ `DANG_KY_THI_DAU`
Danh sách 18 cầu thủ đăng ký thi đấu của mỗi trận được lưu trữ tại chi nhánh tổ chức trận đấu:
$$\text{DANG\_KY\_THI\_DAU}_1 = \text{DANG\_KY\_THI\_DAU} \ltimes_{\text{MaTran}} \text{TRAN\_DAU}_1$$
$$\text{DANG\_KY\_THI\_DAU}_2 = \text{DANG\_KY\_THI\_DAU} \ltimes_{\text{MaTran}} \text{TRAN\_DAU}_2$$
* $\text{DANG\_KY\_THI\_DAU}_1$ định vị tại **Site 1**.
* $\text{DANG\_KY\_THI\_DAU}_2$ định vị tại **Site 2**.

#### (3) Phân mảnh quan hệ `SU_KIEN_TRAN_DAU`
Chi tiết các sự kiện bàn thắng, thẻ phạt phát sinh trên sân được cập nhật và lưu trữ trực tiếp tại chi nhánh tổ chức trận đấu:
$$\text{SU\_KIEN\_TRAN\_DAU}_1 = \text{SU\_KIEN\_TRAN\_DAU} \ltimes_{\text{MaTran}} \text{TRAN\_DAU}_1$$
$$\text{SU\_KIEN\_TRAN\_DAU}_2 = \text{SU\_KIEN\_TRAN\_DAU} \ltimes_{\text{MaTran}} \text{TRAN\_DAU}_2$$
* $\text{SU\_KIEN\_TRAN\_DAU}_1$ định vị tại **Site 1**.
* $\text{SU\_KIEN\_TRAN\_DAU}_2$ định vị tại **Site 2**.

---

### 2.3. Phân mảnh dọc (Vertical Fragmentation)

Áp dụng cho quan hệ `HOP_DONG_CAU_THU`:
* **Mục đích**: Tách biệt thông tin chuyên môn thi đấu (cần công khai cho các chi nhánh kiểm tra số áo, tư cách thi đấu) và thông tin tài chính mật (mức lương, chỉ phục vụ kế toán Ban tổ chức tại Trung tâm).
* **Toán tử chiếu**:
  * **Mảnh 1 (Chuyên môn thi đấu)**:
    $$\text{HOP\_DONG\_THI\_DAU} = \pi_{\text{MaHD}, \text{MaCauThu}, \text{MaDoiChuQuan}, \text{MaDoiHienTai}, \text{SoAo}, \text{NgayBatDau}, \text{NgayKetThuc}, \text{TrangThai}}(\text{HOP\_DONG\_CAU\_THU})$$
  * **Mảnh 2 (Bảo mật tài chính)**:
    $$\text{HOP\_DONG\_TAI\_CHINH} = \pi_{\text{MaHD}, \text{MucLuong}}(\text{HOP\_DONG\_CAU\_THU})$$
* **Định vị**:
  * $\text{HOP\_DONG\_THI\_DAU}$ được nhân bản tại **Site 1, Site 2** và lưu tại **Site 0**.
  * $\text{HOP\_DONG\_TAI\_CHINH}$ **chỉ lưu trữ duy nhất tại Site 0 (Trạm Trung tâm)**.

---

### 2.4. Nhân bản dữ liệu (Data Replication)

Các bảng danh mục dùng chung có tần suất đọc cực lớn (App 1) nhưng hầu như không thay đổi trong suốt mùa giải được thiết kế **Nhân bản toàn phần (Full Replication)** trên cả 3 trạm:
* `DOI_BONG`
* `MAU_AO_DOI_BONG`
* `CAU_THU`
* `TRONG_TAI`
* `VONG_DAU`

**Lợi ích**: Khi thực hiện các phép kết nối (JOIN) giữa trận đấu với tên đội bóng, tên sân, tên trọng tài, tên cầu thủ, hệ thống thực hiện hoàn toàn cục bộ (Local Join), loại bỏ 100% độ trễ truyền thông qua mạng.

---

## 3. CHỨNG MINH TÍNH ĐÚNG ĐẮN CỦA PHÂN MẢNH

Theo lý thuyết cơ sở dữ liệu phân tán, một thiết kế phân mảnh được coi là chuẩn xác nếu thỏa mãn ba quy tắc cốt lõi:

### 3.1. Tính đầy đủ (Completeness)
* **Đối với phân mảnh ngang `SAN_VAN_DONG` và `TRAN_DAU`**:
  Tập vị từ $\{p_1, p_2\}$ và $\{q_1, q_2\}$ là đầy đủ vì mọi sân vận động trong giải đều thuộc về một trong hai miền Bắc hoặc Nam:
  $$\text{dom}(\text{MaSan}) = \{\text{'SAN\_HD'}, \text{'SAN\_MD'}, \text{'SAN\_LT'}, \text{'SAN\_TT'}\} \cup \{\text{'SAN\_PK'}\}$$
  Do đó, mọi bộ dữ liệu $t \in \text{TRAN\_DAU}$ đều thỏa mãn hoặc $q_1$ hoặc $q_2$, nghĩa là không có trận đấu nào bị bỏ sót ngoài 2 mảnh.
* **Đối với phân mảnh ngang dẫn xuất**:
  Mọi bản ghi trong `PHAN_CONG_TRONG_TAI`, `DANG_KY_THI_DAU`, `SU_KIEN_TRAN_DAU` đều có khóa ngoại `MaTran` tham chiếu đến một trận đấu hợp lệ. Vì `TRAN_DAU` thỏa mãn tính đầy đủ nên các phân mảnh dẫn xuất cũng bảo toàn tính đầy đủ.
* **Đối với phân mảnh dọc `HOP_DONG_CAU_THU`**:
  Tập thuộc tính của quan hệ ban đầu là:
  $$U = \{\text{MaHD}, \text{MaCauThu}, \text{MaDoiChuQuan}, \text{MaDoiHienTai}, \text{SoAo}, \text{NgayBatDau}, \text{NgayKetThuc}, \text{TrangThai}, \text{MucLuong}\}$$
  Ta có: $\text{attrs}(\text{HOP\_DONG\_THI\_DAU}) \cup \text{attrs}(\text{HOP\_DONG\_TAI\_CHINH}) = U$.  
  Mọi thuộc tính đều xuất hiện trong ít nhất một mảnh.

### 3.2. Tính tái thiết được (Reconstruction)
* **Đối với các mảnh ngang**: Quan hệ ban đầu được tái thiết trọn vẹn thông qua phép hợp tập hợp:
  $$\text{SAN\_VAN\_DONG} = \text{SAN\_VAN\_DONG}_1 \cup \text{SAN\_VAN\_DONG}_2$$
  $$\text{TRAN\_DAU} = \text{TRAN\_DAU}_1 \cup \text{TRAN\_DAU}_2$$
  $$\text{PHAN\_CONG\_TRONG\_TAI} = \text{PHAN\_CONG\_TRONG\_TAI}_1 \cup \text{PHAN\_CONG\_TRONG\_TAI}_2$$
  $$\text{DANG\_KY\_THI\_DAU} = \text{DANG\_KY\_THI\_DAU}_1 \cup \text{DANG\_KY\_THI\_DAU}_2$$
  $$\text{SU\_KIEN\_TRAN\_DAU} = \text{SU\_KIEN\_TRAN\_DAU}_1 \cup \text{SU\_KIEN\_TRAN\_DAU}_2$$
* **Đối với phân mảnh dọc**: Do cả hai mảnh đều chứa thuộc tính khóa chính `MaHD`, quan hệ ban đầu được tái thiết qua phép kết nối tự nhiên không mất mát thông tin:
  $$\text{HOP\_DONG\_CAU\_THU} = \text{HOP\_DONG\_THI\_DAU} \bowtie_{\text{MaHD}} \text{HOP\_DONG\_TAI\_CHINH}$$

### 3.3. Tính tách biệt (Disjointness)
* Đối với phân mảnh ngang: Vì $q_1 \wedge q_2 = \text{FALSE}$ (một sân vận động không thể vừa thuộc miền Bắc vừa thuộc miền Nam), nên:
  $$\text{TRAN\_DAU}_1 \cap \text{TRAN\_DAU}_2 = \emptyset$$
  Tương tự, các mảnh dẫn xuất không chứa các bản ghi trùng lặp giữa các site.
* Đối với phân mảnh dọc: Giao của hai tập thuộc tính đúng bằng khóa chính:
  $$\text{attrs}(\text{HOP\_DONG\_THI\_DAU}) \cap \text{attrs}(\text{HOP\_DONG\_TAI\_CHINH}) = \{\text{MaHD}\}$$
  Đảm bảo tính tách biệt của các thuộc tính không khóa.

---

## 4. ĐỊNH VỊ DỮ LIỆU VÀ MA TRẬN PHÂN PHỐI

Ma trận phân phối các mảnh dữ liệu trên toàn bộ 3 trạm của hệ thống:

| Tên quan hệ / Mảnh dữ liệu | Site 0 (Trung tâm) | Site 1 (Chi nhánh Bắc) | Site 2 (Chi nhánh Nam) | Kiểu phân tán |
|---|:---:|:---:|:---:|---|
| `SAN_VAN_DONG_1` | Xem / Quản lý | **Gốc (Đọc/Ghi)** | Không | Phân mảnh ngang |
| `SAN_VAN_DONG_2` | Xem / Quản lý | Không | **Gốc (Đọc/Ghi)** | Phân mảnh ngang |
| `DOI_BONG` | **Gốc (Đọc/Ghi)** | Nhân bản (Đọc) | Nhân bản (Đọc) | Nhân bản toàn phần |
| `MAU_AO_DOI_BONG` | **Gốc (Đọc/Ghi)** | Nhân bản (Đọc) | Nhân bản (Đọc) | Nhân bản toàn phần |
| `CAU_THU` | **Gốc (Đọc/Ghi)** | Nhân bản (Đọc) | Nhân bản (Đọc) | Nhân bản toàn phần |
| `TRONG_TAI` | **Gốc (Đọc/Ghi)** | Nhân bản (Đọc) | Nhân bản (Đọc) | Nhân bản toàn phần |
| `VONG_DAU` | **Gốc (Đọc/Ghi)** | Nhân bản (Đọc) | Nhân bản (Đọc) | Nhân bản toàn phần |
| `TRAN_DAU_1` | Tổng hợp | **Gốc (Đọc/Ghi)** | Không | Phân mảnh ngang |
| `TRAN_DAU_2` | Tổng hợp | Không | **Gốc (Đọc/Ghi)** | Phân mảnh ngang |
| `PHAN_CONG_TRONG_TAI_1` | Xem | **Gốc (Đọc/Ghi)** | Không | Phân mảnh dẫn xuất |
| `PHAN_CONG_TRONG_TAI_2` | Xem | Không | **Gốc (Đọc/Ghi)** | Phân mảnh dẫn xuất |
| `DANG_KY_THI_DAU_1` | Xem | **Gốc (Đọc/Ghi)** | Không | Phân mảnh dẫn xuất |
| `DANG_KY_THI_DAU_2` | Xem | Không | **Gốc (Đọc/Ghi)** | Phân mảnh dẫn xuất |
| `SU_KIEN_TRAN_DAU_1` | Xem / Tổng hợp | **Gốc (Đọc/Ghi)** | Không | Phân mảnh dẫn xuất |
| `SU_KIEN_TRAN_DAU_2` | Xem / Tổng hợp | Không | **Gốc (Đọc/Ghi)** | Phân mảnh dẫn xuất |
| `HOP_DONG_THI_DAU` | **Gốc** | Nhân bản (Đọc) | Nhân bản (Đọc) | Phân mảnh dọc |
| `HOP_DONG_TAI_CHINH` | **Độc quyền (Bảo mật)** | Không | Không | Phân mảnh dọc |

---

## 5. SƠ ĐỒ KIẾN TRÚC CSDL PHÂN TÁN TỔNG QUÁT

```mermaid
flowchart TD
    subgraph Site0["TRẠM TRUNG TÂM (SITE 0) - LIÊN ĐOÀN BÓNG ĐÁ"]
        DB0[("Database: csdl_trungtam")]
        GlobalViews["Khung nhìn toàn cục: vw_BangXepHang, vw_DoanhThu"]
        SecFrag["Mảnh bảo mật: HOP_DONG_TAI_CHINH (MucLuong)"]
        CentralCatalog["Danh mục gốc: DOI_BONG, CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    subgraph Site1["CHI NHÁNH MIỀN BẮC (SITE 1)"]
        DB1[("Database: csdl_chinhanh_bac")]
        Frag1_San["SAN_VAN_DONG_1 (Hàng Đẫy, Mỹ Đình, Lạch Tray, Thiên Trường)"]
        Frag1_Tran["TRAN_DAU_1 (25 trận đấu miền Bắc)"]
        Frag1_PK["PHAN_CONG_TRONG_TAI_1, DANG_KY_1, SU_KIEN_1"]
        Replica1["Bản sao tra cứu: DOI_BONG, CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    subgraph Site2["CHI NHÁNH MIỀN NAM (SITE 2)"]
        DB2[("Database: csdl_chinhanh_nam")]
        Frag2_San["SAN_VAN_DONG_2 (Pleiku)"]
        Frag2_Tran["TRAN_DAU_2 (5 trận đấu sân Pleiku)"]
        Frag2_PK["PHAN_CONG_TRONG_TAI_2, DANG_KY_2, SU_KIEN_2"]
        Replica2["Bản sao tra cứu: DOI_BONG, CAU_THU, TRONG_TAI, VONG_DAU"]
    end

    %% Liên kết mạng phân tán
    Site0 <== "Đồng bộ danh mục & Thu thập báo cáo" ==> Site1
    Site0 <== "Đồng bộ danh mục & Thu thập báo cáo" ==> Site2
    Site1 <-. "Truy vấn phân tán liên trạm (FDW)" .-> Site2
```

---

## 6. KỊCH BẢN MÔ PHỎNG PHÂN TÁN TRÊN POSTGRESQL BẰNG POSTGRES_FDW

PostgreSQL hỗ trợ mạnh mẽ cơ chế phân tán thông qua tiện ích mở rộng **`postgres_fdw` (Foreign Data Wrapper)**. Cơ chế này tương đương với `Linked Server` trên SQL Server nhưng có ưu điểm nhẹ hơn, chuẩn hóa và hoạt động ổn định trên mạng máy tính.

Tệp kịch bản mô phỏng phân tán đã được tạo sẵn tại: [`sql/06_distributed_simulation.sql`](file:///d:/Learning/CSDL/sql/06_distributed_simulation.sql).

### Các bước cài đặt mô phỏng trên 1 máy tính:
1. Tạo 3 Schema hoặc 3 Database riêng biệt: `site0_trungtam`, `site1_mienbac`, `site2_miennam`.
2. Trên `site1_mienbac`, lưu trữ các mảnh `_1`.
3. Trên `site2_miennam`, lưu trữ các mảnh `_2`.
4. Trên `site0_trungtam`:
   * Kích hoạt `CREATE EXTENSION postgres_fdw;`
   * Định nghĩa máy chủ ngoại vi (`CREATE SERVER site1_server...`, `CREATE SERVER site2_server...`)
   * Tạo bảng ngoại vi ánh xạ tới Site 1 và Site 2.
   * Tạo View toàn cục kết hợp (Global View):
     ```sql
     CREATE VIEW vw_global_tran_dau AS
     SELECT * FROM foreign_tran_dau_site1
     UNION ALL
     SELECT * FROM foreign_tran_dau_site2;
     ```
   * Khi người dùng truy vấn `SELECT * FROM vw_global_tran_dau`, hệ thống tự động phân rã truy vấn, gửi yêu cầu song song đến cả Site 1 và Site 2, sau đó ghép nối kết quả trả về trong suốt hoàn toàn!
