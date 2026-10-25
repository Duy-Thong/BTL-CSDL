# GIAI ĐOẠN 1: PHÂN TÍCH YÊU CẦU, THIẾT KẾ E-R VÀ CHUẨN HÓA BCNF
**Đề tài 13:** Xây dựng Hệ CSDL quản lý một giải bóng đá chuyên nghiệp  
**Môn học:** Các hệ thống CSDL - M26CQ02

---

## MỤC LỤC
1. [Khảo sát bài toán và Phân tích từ điển dữ liệu](#1-khảo-sát-bài-toán-và-phân-tích-từ-điển-dữ-liệu)
2. [Thiết kế mức quan niệm: Lược đồ thực thể liên kết (E-R)](#2-thiết-kế-mức-quan-niệm-lược-đồ-thực-thể-liên-kết-e-r)
3. [Thiết kế mức logic: Ánh xạ sang Lược đồ quan hệ](#3-thiết-kế-mức-logic-ánh-xạ-sang-lược-đồ-quan-hệ)
4. [Xác định Phụ thuộc hàm và Phân tích dạng chuẩn BCNF](#4-xác-định-phụ-thuộc-hàm-và-phân-tích-dạng-chuẩn-bcnf)
5. [Tổng kết kết quả thiết kế Giai đoạn 1](#5-tổng-kết-kết-quả-thiết-kế-giai-đoạn-1)

---

## 1. KHẢO SÁT BÀI TOÁN VÀ PHÂN TÍCH TỪ ĐIỂN DỮ LIỆU

### 1.1. Bối cảnh và Yêu cầu bài toán
Hệ thống cần quản lý một giải bóng đá chuyên nghiệp diễn ra trong một mùa giải cụ thể với các quy tắc nghiệp vụ chặt chẽ:
* **Quy mô giải đấu**: Gồm **6 đội bóng** (đảm bảo yêu cầu số chẵn $\ge 6$), thi đấu theo thể thức **vòng tròn 2 lượt** (lượt đi và lượt về).
  * Số vòng đấu: $2 \times (6 - 1) = 10$ vòng đấu.
  * Mỗi vòng có 3 cặp đấu $\rightarrow$ Tổng cộng **30 trận đấu** trong cả mùa giải.
* **Đội bóng**: Mỗi đội có 1 sân nhà cố định, sở hữu tối thiểu 2 màu áo thi đấu chính thức (sân nhà, sân khách). Một đội có tối đa 30 cầu thủ.
* **Cầu thủ & Hợp đồng**: Mỗi cầu thủ ký hợp đồng chuyên nghiệp với 1 đội bóng chủ quản, có thể thi đấu cho đội khác dưới dạng cho mượn. Tại một thời điểm, cầu thủ chỉ được thi đấu cho đúng 1 đội. Mỗi cầu thủ có một số áo thi đấu từ **1 đến 35**. Trong một đội không được có 2 cầu thủ trùng số áo.
* **Sân vận động**: Một sân có thể là sân nhà của 1 hoặc nhiều đội bóng.
* **Trọng tài**: Mỗi trận đấu được điều khiển bởi đúng **4 trọng tài** (1 trọng tài chính, 2 trọng tài biên, 1 trọng tài bàn). Trong 1 vòng đấu, mỗi trọng tài chỉ được điều khiển tối đa **1 trận đấu**.
* **Đăng ký thi đấu**: Trước mỗi trận, mỗi đội được đăng ký tối đa **18 cầu thủ** (bao gồm đội hình chính thức và dự bị).
* **Diễn biến & Kết quả**: Lưu trữ đầy đủ các sự kiện bàn thắng, thẻ vàng, thẻ đỏ của từng cầu thủ theo phút thi đấu. Tổng số bàn thắng và thẻ phạt của các cầu thủ phải khớp chính xác với tỉ số và tổng số thẻ của trận đấu.
* **Trạng thái trận đấu**: `ChuaDienRa` (lịch tương lai) hoặc `DaKetThuc` (ngày giờ $\le$ hiện tại).

---

### 1.2. Từ điển dữ liệu chi tiết (Data Dictionary)

Hệ thống được thiết kế gồm **11 thực thể / quan hệ** nhằm phản ánh đầy đủ mô hình thế giới thực và triệt tiêu dư thừa dữ liệu:

#### (1) `SAN_VAN_DONG` (Sân vận động)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaSan` | VARCHAR(10) | **PRIMARY KEY** | Mã định danh duy nhất của sân vận động |
| `TenSan` | VARCHAR(100) | NOT NULL, UNIQUE | Tên sân vận động (VD: Mỹ Đình, Hàng Đẫy) |
| `DiaChi` | VARCHAR(200) | NOT NULL | Địa chỉ, thành phố nơi đặt sân |
| `SucChua` | INT | NOT NULL, CHECK > 0 | Sức chứa tối đa khán giả của sân |
| `KhuVuc` | VARCHAR(20) | NOT NULL, CHECK IN ('MienBac', 'MienNam') | Khu vực điều hành địa lý |

#### (2) `DOI_BONG` (Đội bóng)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaDoi` | VARCHAR(10) | **PRIMARY KEY** | Mã định danh duy nhất của đội bóng |
| `TenDoi` | VARCHAR(100) | NOT NULL, UNIQUE | Tên đội bóng / Câu lạc bộ |
| `HLV` | VARCHAR(100) | NOT NULL | Họ tên huấn luyện viên trưởng |
| `MaSanNha` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Mã sân nhà cố định của đội bóng ($\rightarrow$ `SAN_VAN_DONG`) |

#### (3) `MAU_AO_DOI_BONG` (Màu áo thi đấu của đội)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaDoi` | VARCHAR(10) | **PRIMARY KEY, FOREIGN KEY** | Mã đội bóng ($\rightarrow$ `DOI_BONG`) |
| `LoaiMauAo` | VARCHAR(20) | **PRIMARY KEY** | Phân loại áo: `'SanNha'`, `'SanKhach'`, `'Phu'` |
| `MoTaMau` | VARCHAR(50) | NOT NULL | Chi tiết màu sắc (VD: Đỏ - Trắng, Xanh biển) |

#### (4) `CAU_THU` (Thông tin nhân thân cầu thủ)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaCauThu` | VARCHAR(10) | **PRIMARY KEY** | Mã định danh duy nhất của cầu thủ |
| `HoTen` | VARCHAR(100) | NOT NULL | Họ và tên cầu thủ |
| `NgaySinh` | DATE | NOT NULL | Ngày tháng năm sinh |
| `ViTri` | VARCHAR(20) | NOT NULL | Vị trí sở trường: `'ThuMon'`, `'HauVe'`, `'TienVe'`, `'TienDao'` |
| `QuocTich` | VARCHAR(50) | NOT NULL, DEFAULT 'Việt Nam' | Quốc tịch của cầu thủ |

#### (5) `HOP_DONG_CAU_THU` (Hợp đồng & Đội bóng hiện tại)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaHD` | VARCHAR(10) | **PRIMARY KEY** | Mã hợp đồng thi đấu |
| `MaCauThu` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Mã cầu thủ ký hợp đồng ($\rightarrow$ `CAU_THU`) |
| `MaDoiChuQuan` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Đội bóng sở hữu hợp đồng gốc ($\rightarrow$ `DOI_BONG`) |
| `MaDoiHienTai` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Đội bóng cầu thủ đang trực tiếp thi đấu ($\rightarrow$ `DOI_BONG`) |
| `SoAo` | INT | NOT NULL, CHECK (1..35) | Số áo thi đấu tại đội bóng hiện tại (UNIQUE theo `MaDoiHienTai`) |
| `NgayBatDau` | DATE | NOT NULL | Ngày bắt đầu hiệu lực hợp đồng/mượn |
| `NgayKetThuc` | DATE | NOT NULL, CHECK >= NgayBatDau | Ngày hết hạn hợp đồng/mượn |
| `TrangThai` | VARCHAR(20) | NOT NULL | Tình trạng: `'ChinhThuc'`, `'ChoMuon'`, `'ThanhLy'` |

#### (6) `TRONG_TAI` (Trọng tài điều khiển)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaTrongTai` | VARCHAR(10) | **PRIMARY KEY** | Mã định danh duy nhất của trọng tài |
| `HoTen` | VARCHAR(100) | NOT NULL | Họ và tên trọng tài |
| `NgaySinh` | DATE | NOT NULL | Ngày tháng năm sinh |
| `QueQuan` | VARCHAR(100) | NOT NULL | Quê quán / Đơn vị trọng tài |
| `CapBac` | VARCHAR(50) | NOT NULL | Cấp bậc trọng tài (VD: FIFA, Quốc gia) |

#### (7) `VONG_DAU` (Vòng đấu của mùa giải)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaVong` | INT | **PRIMARY KEY** | Mã định danh vòng đấu (1 đến 10) |
| `TenVong` | VARCHAR(50) | NOT NULL, UNIQUE | Tên vòng đấu (VD: Vòng 1, Vòng 2...) |
| `ThuTu` | INT | NOT NULL, UNIQUE | Thứ tự vòng đấu từ 1 đến 10 |

#### (8) `TRAN_DAU` (Trận đấu bóng đá)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaTran` | VARCHAR(10) | **PRIMARY KEY** | Mã định danh duy nhất của trận đấu |
| `MaVong` | INT | **FOREIGN KEY**, NOT NULL | Trận đấu thuộc vòng nào ($\rightarrow$ `VONG_DAU`) |
| `MaDoiNha` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Đội chủ nhà ($\rightarrow$ `DOI_BONG`) |
| `MaDoiKhach` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Đội khách ($\rightarrow$ `DOI_BONG`), CHECK <> MaDoiNha |
| `MaSan` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Sân thi đấu thực tế diễn ra trận ($\rightarrow$ `SAN_VAN_DONG`) |
| `NgayGio` | TIMESTAMP | NOT NULL | Thời gian bắt đầu trận đấu |
| `GiaVe` | DECIMAL(12,2) | NOT NULL, CHECK >= 0 | Giá vé của trận đấu (tính doanh thu) |
| `SoKhach` | INT | DEFAULT 0, CHECK >= 0 | Lượng khán giả thực tế theo dõi |
| `BanThangNha` | INT | DEFAULT 0, CHECK >= 0 | Số bàn thắng ghi nhận của đội nhà |
| `BanThangKhach`| INT | DEFAULT 0, CHECK >= 0 | Số bàn thắng ghi nhận của đội khách |
| `TheVangNha` | INT | DEFAULT 0, CHECK >= 0 | Tổng số thẻ vàng đội nhà nhận |
| `TheVangKhach`| INT | DEFAULT 0, CHECK >= 0 | Tổng số thẻ vàng đội khách nhận |
| `TheDoNha` | INT | DEFAULT 0, CHECK >= 0 | Tổng số thẻ đỏ đội nhà nhận |
| `TheDoKhach` | INT | DEFAULT 0, CHECK >= 0 | Tổng số thẻ đỏ đội khách nhận |
| `TrangThai` | VARCHAR(20) | NOT NULL | Trạng thái: `'ChuaDienRa'`, `'DaKetThuc'` |

#### (9) `PHAN_CONG_TRONG_TAI` (Tổ trọng tài làm nhiệm vụ trong trận)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaTran` | VARCHAR(10) | **PRIMARY KEY, FOREIGN KEY** | Mã trận đấu ($\rightarrow$ `TRAN_DAU`) |
| `VaiTro` | VARCHAR(20) | **PRIMARY KEY** | Vai trò: `'Chinh'`, `'Bien1'`, `'Bien2'`, `'Ban'` |
| `MaTrongTai` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Mã trọng tài được phân công ($\rightarrow$ `TRONG_TAI`, UNIQUE theo `MaTran`) |

#### (10) `DANG_KY_THI_DAU` (Danh sách 18 cầu thủ đăng ký mỗi trận)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaTran` | VARCHAR(10) | **PRIMARY KEY, FOREIGN KEY** | Mã trận đấu ($\rightarrow$ `TRAN_DAU`) |
| `MaCauThu` | VARCHAR(10) | **PRIMARY KEY, FOREIGN KEY** | Mã cầu thủ được đăng ký ($\rightarrow$ `CAU_THU`) |
| `MaDoi` | VARCHAR(10) | **FOREIGN KEY**, NOT NULL | Đội bóng mà cầu thủ đại diện thi đấu ($\rightarrow$ `DOI_BONG`) |
| `VaiTroThiDau` | VARCHAR(20) | NOT NULL | `'ChinhThuc'` (đá chính) hoặc `'DuBi'` |
| `SoAoDangKy` | INT | NOT NULL, CHECK (1..35) | Số áo cầu thủ mặc trong trận này (UNIQUE theo `MaTran, MaDoi`) |

#### (11) `SU_KIEN_TRAN_DAU` (Chi tiết diễn biến bàn thắng & thẻ phạt sau chuẩn hóa BCNF)
| Tên thuộc tính | Kiểu dữ liệu | Ràng buộc | Ý nghĩa / Diễn giải |
|---|---|---|---|
| `MaSuKien` | VARCHAR(15) | **PRIMARY KEY** | Mã định danh sự kiện |
| `MaTran` | VARCHAR(10) | **FOREIGN KEY KÉP**, NOT NULL | Tham chiếu tới `DANG_KY_THI_DAU(MaTran, MaCauThu)` |
| `MaCauThu` | VARCHAR(10) | **FOREIGN KEY KÉP**, NOT NULL | Tham chiếu tới `DANG_KY_THI_DAU(MaTran, MaCauThu)` |
| `LoaiSuKien` | VARCHAR(20) | NOT NULL | Loại sự kiện: `'BanThang'`, `'TheVang'`, `'TheDo'` |
| `PhutGhiNhan` | INT | NOT NULL, CHECK (1..120) | Phút diễn ra sự kiện trong trận đấu |

---

## 2. THIẾT KẾ MỨC QUAN NIỆM: LƯỢC ĐỒ THỰC THỂ LIÊN KẾT (E-R)

### 2.1. Phân loại các Tập thực thể
* **Tập thực thể mạnh (Strong Entities)**:
  * `SAN_VAN_DONG`: Khóa chính là `MaSan`.
  * `DOI_BONG`: Khóa chính là `MaDoi`.
  * `CAU_THU`: Khóa chính là `MaCauThu`.
  * `TRONG_TAI`: Khóa chính là `MaTrongTai`.
  * `VONG_DAU`: Khóa chính là `MaVong`.
* **Tập thực thể yếu / Thực thể quan hệ (Weak / Associative Entities)**:
  * `MAU_AO_DOI_BONG`: Thực thể phụ thuộc vào `DOI_BONG`, khóa bộ phận là `LoaiMauAo`.
  * `HOP_DONG_CAU_THU`: Thực thể quan hệ mô tả hợp đồng giữa cầu thủ và đội bóng.
  * `TRAN_DAU`: Thực thể đại diện cho cuộc đối đầu giữa 2 đội bóng trong 1 vòng đấu tại 1 sân vận động.
  * `PHAN_CONG_TRONG_TAI`: Quan hệ kết hợp nhiều - nhiều giữa `TRAN_DAU` và `TRONG_TAI` kèm thuộc tính vai trò.
  * `DANG_KY_THI_DAU`: Quan hệ kết hợp giữa `TRAN_DAU`, `DOI_BONG` và `CAU_THU`.
  * `SU_KIEN_TRAN_DAU`: Thực thể ghi nhận các biến cố (bàn thắng, thẻ phạt) theo thời gian.

### 2.2. Bản chất các Mối kết hợp (Relationships & Cardinalities)
1. **`SAN_NHA` (`SAN_VAN_DONG` - `DOI_BONG`)**:
   * Bản số: $(1, N)$. Một sân vận động có thể là sân nhà của $0, 1$ hoặc nhiều đội bóng; một đội bóng có đúng $1$ sân nhà cố định.
2. **`SO_HUU_MAU_AO` (`DOI_BONG` - `MAU_AO_DOI_BONG`)**:
   * Bản số: $(1, N)$ với $N \ge 2$. Một đội bóng bắt buộc có ít nhất 2 màu áo thi đấu.
3. **`KY_HOP_DONG` (`CAU_THU` - `HOP_DONG_CAU_THU` - `DOI_BONG`)**:
   * Một cầu thủ có thể có lịch sử hợp đồng với các đội, nhưng tại một thời điểm chỉ có 1 hợp đồng đang hiệu lực. Đội chủ quản và đội đang thi đấu có thể khác nhau (nếu cho mượn).
4. **`LICH_THI_DAU` (`VONG_DAU` - `TRAN_DAU`)**:
   * Bản số: $(1, N)$. Một vòng đấu có đúng 3 trận đấu (đối với giải 6 đội); một trận đấu thuộc về đúng 1 vòng đấu.
5. **`DOI_NHA_DOI_KHACH` (`DOI_BONG` - `TRAN_DAU`)**:
   * Mỗi trận đấu liên kết với đúng 2 đội bóng: 1 đội đóng vai trò Đội nhà (`MaDoiNha`) và 1 đội đóng vai trò Đội khách (`MaDoiKhach`).
6. **`DIEU_KHIEN` (`TRAN_DAU` - `TRONG_TAI`)**:
   * Bản số: Một trận đấu được điều khiển bởi đúng 4 trọng tài với 4 vai trò khác nhau (`Chinh`, `Bien1`, `Bien2`, `Ban`). Một trọng tài chỉ được phân công tối đa 1 trận trong cùng 1 vòng đấu.
7. **`DANH_SACH_THI_DAU` (`TRAN_DAU` - `CAU_THU`)**:
   * Bản số: $(N, M)$. Mỗi trận đấu, một đội bóng đăng ký danh sách tối đa 18 cầu thủ.
8. **`DIEN_BIEN` (`TRAN_DAU` - `SU_KIEN_TRAN_DAU` - `CAU_THU`)**:
   * Một trận đấu ghi nhận nhiều sự kiện; mỗi sự kiện gắn liền với đúng 1 cầu thủ và 1 đội bóng tại 1 thời điểm phút thi đấu cụ thể.

*(Toàn bộ mã nguồn sơ đồ E-R dạng Mermaid chi tiết để import vào Draw.io đã được trình bày tại file `docs/SO_DO_MERMAID_DRAWIO.md`)*.

---

## 3. THIẾT KẾ MỨC LOGIC: ÁNH XẠ SANG LƯỢC ĐỒ QUAN HỆ

Áp dụng quy tắc ánh xạ chuẩn từ mô hình E-R sang mô hình quan hệ:
1. Mỗi tập thực thể thông thường trở thành một lược đồ quan hệ.
2. Mối kết hợp $1-N$ được chuyển thành thuộc tính Khóa ngoại (FK) ở phía bên quan hệ có bản số nhiều ($N$).
3. Thuộc tính đa trị (`MAU_AO`) được tách thành bảng riêng có khóa chính gồm Khóa ngoại tham chiếu và thuộc tính phân biệt.
4. Mối kết hợp $N-N$ (`PHAN_CONG_TRONG_TAI`, `DANG_KY_THI_DAU`) chuyển thành quan hệ liên kết có khóa chính tổ hợp.

### Tập hợp các Lược đồ Quan hệ (Relational Schemas)
Dưới đây là định nghĩa hình thức (Ký hiệu: **in đậm gạch chân** là Khóa chính (PK), *in nghiêng* là Khóa ngoại (FK)):

1. $\text{SAN\_VAN\_DONG}(\underline{\mathbf{MaSan}}, \text{TenSan}, \text{DiaChi}, \text{SucChua}, \text{KhuVuc})$
2. $\text{DOI\_BONG}(\underline{\mathbf{MaDoi}}, \text{TenDoi}, \text{HLV}, \textit{MaSanNha})$  
   *Trong đó: $\text{MaSanNha} \rightarrow \text{SAN\_VAN\_DONG}(\text{MaSan})$*
3. $\text{MAU\_AO\_DOI\_BONG}(\underline{\mathbf{MaDoi}}, \underline{\mathbf{LoaiMauAo}}, \text{MoTaMau})$  
   *Trong đó: $\text{MaDoi} \rightarrow \text{DOI\_BONG}(\text{MaDoi})$*
4. $\text{CAU\_THU}(\underline{\mathbf{MaCauThu}}, \text{HoTen}, \text{NgaySinh}, \text{ViTri}, \text{QuocTich})$
5. $\text{HOP\_DONG\_CAU\_THU}(\underline{\mathbf{MaHD}}, \textit{MaCauThu}, \textit{MaDoiChuQuan}, \textit{MaDoiHienTai}, \text{SoAo}, \text{NgayBatDau}, \text{NgayKetThuc}, \text{TrangThai})$  
   *Trong đó: $\text{MaCauThu} \rightarrow \text{CAU\_THU}(\text{MaCauThu})$, $\text{MaDoiChuQuan}, \text{MaDoiHienTai} \rightarrow \text{DOI\_BONG}(\text{MaDoi})$*
6. $\text{TRONG\_TAI}(\underline{\mathbf{MaTrongTai}}, \text{HoTen}, \text{NgaySinh}, \text{QueQuan}, \text{CapBac})$
7. $\text{VONG\_DAU}(\underline{\mathbf{MaVong}}, \text{TenVong}, \text{ThuTu})$
8. $\text{TRAN\_DAU}(\underline{\mathbf{MaTran}}, \textit{MaVong}, \textit{MaDoiNha}, \textit{MaDoiKhach}, \textit{MaSan}, \text{NgayGio}, \text{GiaVe}, \text{SoKhach}, \text{BanThangNha}, \text{BanThangKhach}, \text{TheVangNha}, \text{TheVangKhach}, \text{TheDoNha}, \text{TheDoKhach}, \text{TrangThai})$  
   *Trong đó: $\text{MaVong} \rightarrow \text{VONG\_DAU}(\text{MaVong})$, $\text{MaDoiNha}, \text{MaDoiKhach} \rightarrow \text{DOI\_BONG}(\text{MaDoi})$, $\text{MaSan} \rightarrow \text{SAN\_VAN\_DONG}(\text{MaSan})$*
9. $\text{PHAN\_CONG\_TRONG\_TAI}(\underline{\mathbf{MaTran}}, \underline{\mathbf{VaiTro}}, \textit{MaTrongTai})$  
   *Trong đó: $\text{MaTran} \rightarrow \text{TRAN\_DAU}(\text{MaTran})$, $\text{MaTrongTai} \rightarrow \text{TRONG\_TAI}(\text{MaTrongTai})$*
10. $\text{DANG\_KY\_THI\_DAU}(\underline{\mathbf{MaTran}}, \underline{\mathbf{MaCauThu}}, \textit{MaDoi}, \text{VaiTroThiDau}, \text{SoAoDangKy})$  
   *Trong đó: $\text{MaTran} \rightarrow \text{TRAN\_DAU}(\text{MaTran})$, $\text{MaCauThu} \rightarrow \text{CAU\_THU}(\text{MaCauThu})$, $\text{MaDoi} \rightarrow \text{DOI\_BONG}(\text{MaDoi})$*
11. $\text{SU\_KIEN\_TRAN\_DAU\_BAN\_DAU}(\underline{\mathbf{MaSuKien}}, \textit{MaTran}, \textit{MaCauThu}, \textit{MaDoi}, \text{LoaiSuKien}, \text{PhutGhiNhan})$ (trước khi tách chuẩn BCNF)

---

## 4. XÁC ĐỊNH PHỤ THUỘC HÀM VÀ PHÂN TÍCH DẠNG CHUẨN BCNF

### 4.1. Định nghĩa lý thuyết Dạng chuẩn BCNF
Một lược đồ quan hệ $R$ với tập phụ thuộc hàm $F$ đạt **Dạng chuẩn BCNF** nếu và chỉ nếu:  
Với mọi phụ thuộc hàm không tầm thường $X \rightarrow Y \in F^+$ ($Y \not\subseteq X$), thì **$X$ bắt buộc phải là một siêu khóa** của $R$ ($X^+ = U$).

---

### 4.2. Khảo sát tập Phụ thuộc hàm và Kiểm chứng BCNF cho từng Lược đồ

1. **`SAN_VAN_DONG`**: $U_1 = \{\text{MaSan}, \text{TenSan}, \text{DiaChi}, \text{SucChua}, \text{KhuVuc}\}$. $F_1 = \{\text{MaSan} \rightarrow U_1, \text{TenSan} \rightarrow U_1\}$. Khóa ứng viên: $K_1 = \{\text{MaSan}\}, K_2 = \{\text{TenSan}\}$. Đạt **BCNF**.
2. **`DOI_BONG`**: $U_2 = \{\text{MaDoi}, \text{TenDoi}, \text{HLV}, \text{MaSanNha}\}$. $F_2 = \{\text{MaDoi} \rightarrow U_2, \text{TenDoi} \rightarrow U_2\}$. Khóa ứng viên: $K_1 = \{\text{MaDoi}\}, K_2 = \{\text{TenDoi}\}$. Đạt **BCNF**.
3. **`MAU_AO_DOI_BONG`**: $U_3 = \{\text{MaDoi}, \text{LoaiMauAo}, \text{MoTaMau}\}$. $F_3 = \{\{\text{MaDoi}, \text{LoaiMauAo}\} \rightarrow \text{MoTaMau}\}$. Khóa ứng viên: $K = \{\text{MaDoi}, \text{LoaiMauAo}\}$. Đạt **BCNF**.
4. **`CAU_THU`**: $U_4 = \{\text{MaCauThu}, \text{HoTen}, \text{NgaySinh}, \text{ViTri}, \text{QuocTich}\}$. $F_4 = \{\text{MaCauThu} \rightarrow U_4\}$. Khóa ứng viên: $K = \{\text{MaCauThu}\}$. Đạt **BCNF**.
5. **`HOP_DONG_CAU_THU`**: $U_5 = \{\text{MaHD}, \text{MaCauThu}, \text{MaDoiChuQuan}, \text{MaDoiHienTai}, \text{SoAo}, \text{NgayBatDau}, \text{NgayKetThuc}, \text{TrangThai}\}$.
   * $F_5 = \{\text{MaHD} \rightarrow U_5; \ \{\text{MaCauThu}, \text{MaDoiHienTai}\} \rightarrow U_5; \ \{\text{MaDoiHienTai}, \text{SoAo}\} \rightarrow U_5\}$.
   * 3 khóa ứng viên: $K_1 = \{\text{MaHD}\}, K_2 = \{\text{MaCauThu}, \text{MaDoiHienTai}\}, K_3 = \{\text{MaDoiHienTai}, \text{SoAo}\}$. Đạt **BCNF**.
6. **`TRONG_TAI`**: $U_6 = \{\text{MaTrongTai}, \text{HoTen}, \text{NgaySinh}, \text{QueQuan}, \text{CapBac}\}$. Khóa ứng viên: $K = \{\text{MaTrongTai}\}$. Đạt **BCNF**.
7. **`VONG_DAU`**: $U_7 = \{\text{MaVong}, \text{TenVong}, \text{ThuTu}\}$. 3 khóa ứng viên: $K_1 = \{\text{MaVong}\}, K_2 = \{\text{TenVong}\}, K_3 = \{\text{ThuTu}\}$. Đạt **BCNF**.
8. **`TRAN_DAU`**: $U_8$ gồm 15 thuộc tính.
   * $F_8 = \{\text{MaTran} \rightarrow U_8; \ \{\text{MaDoiNha}, \text{MaDoiKhach}\} \rightarrow U_8; \ \{\text{MaVong}, \text{MaDoiNha}\} \rightarrow U_8; \ \{\text{MaVong}, \text{MaDoiKhach}\} \rightarrow U_8\}$.
   * 4 khóa ứng viên: $K_1 = \{\text{MaTran}\}, K_2 = \{\text{MaDoiNha}, \text{MaDoiKhach}\}, K_3 = \{\text{MaVong}, \text{MaDoiNha}\}, K_4 = \{\text{MaVong}, \text{MaDoiKhach}\}$. Đạt **BCNF**.
9. **`PHAN_CONG_TRONG_TAI`**: $U_9 = \{\text{MaTran}, \text{VaiTro}, \text{MaTrongTai}\}$.
   * $F_9 = \{\{\text{MaTran}, \text{VaiTro}\} \rightarrow \text{MaTrongTai}; \ \{\text{MaTran}, \text{MaTrongTai}\} \rightarrow \text{VaiTro}\}$.
   * 2 khóa ứng viên giao nhau: $K_1 = \{\text{MaTran}, \text{VaiTro}\}, K_2 = \{\text{MaTran}, \text{MaTrongTai}\}$. Đạt **BCNF**.
10. **`DANG_KY_THI_DAU`**: $U_{10} = \{\text{MaTran}, \text{MaCauThu}, \text{MaDoi}, \text{VaiTroThiDau}, \text{SoAoDangKy}\}$.
    * $F_{10} = \{\{\text{MaTran}, \text{MaCauThu}\} \rightarrow \{\text{MaDoi}, \text{VaiTroThiDau}, \text{SoAoDangKy}\}; \ \{\text{MaTran}, \text{MaDoi}, \text{SoAoDangKy}\} \rightarrow \{\text{MaCauThu}, \text{VaiTroThiDau}\}\}$.
    * 2 khóa ứng viên: $K_1 = \{\text{MaTran}, \text{MaCauThu}\}, K_2 = \{\text{MaTran}, \text{MaDoi}, \text{SoAoDangKy}\}$. Đạt **BCNF**.
11. **`SU_KIEN_TRAN_DAU_BAN_DAU` (Phát hiện vi phạm BCNF)**:
    * Tập thuộc tính ban đầu: $U_{11} = \{\text{MaSuKien}, \text{MaTran}, \text{MaCauThu}, \text{MaDoi}, \text{LoaiSuKien}, \text{PhutGhiNhan}\}$.
    * Tập phụ thuộc hàm:
      $$f_{11.1}: \text{MaSuKien} \rightarrow U_{11} \setminus \{\text{MaSuKien}\}, \qquad f_{11.2}: \{\text{MaTran}, \text{MaCauThu}\} \rightarrow \text{MaDoi}.$$
    * Bao đóng $\{\text{MaTran}, \text{MaCauThu}\}^+ = \{\text{MaTran}, \text{MaCauThu}, \text{MaDoi}\} \neq U_{11}$. Khóa ứng viên duy nhất là $K = \{\text{MaSuKien}\}$.
    * **Kết luận**: Phụ thuộc hàm $f_{11.2}: \{\text{MaTran}, \text{MaCauThu}\} \rightarrow \text{MaDoi}$ có vế trái không phải là siêu khóa $\implies$ **Vi phạm 3NF và BCNF**.

---

### 4.3. Áp dụng Thuật toán Tách BCNF cho `SU_KIEN_TRAN_DAU_BAN_DAU`
* **Bước 1**: Chọn phụ thuộc hàm gây vi phạm $X \rightarrow Y$ với $X = \{\text{MaTran}, \text{MaCauThu}\}, Y = \{\text{MaDoi}\}$.
* **Bước 2**: Tách $U_{11}$ thành hai lược đồ con:
  * $R_1 = X \cup Y = \{\underline{\mathbf{MaTran}}, \underline{\mathbf{MaCauThu}}, \text{MaDoi}\}$ (đã nằm trọn trong quan hệ `DANG_KY_THI_DAU` có cùng khóa chính $(\text{MaTran}, \text{MaCauThu})$ nên hợp nhất trực tiếp vào `DANG_KY_THI_DAU`).
  * $R_2 = U_{11} \setminus Y = \text{SU\_KIEN\_TRAN\_DAU}(\underline{\mathbf{MaSuKien}}, \textit{MaTran}, \textit{MaCauThu}, \text{LoaiSuKien}, \text{PhutGhiNhan})$ với khóa ngoại tổ hợp $(\text{MaTran}, \text{MaCauThu}) \rightarrow \text{DANG\_KY\_THI\_DAU}(\text{MaTran}, \text{MaCauThu})$.
* **Bước 3 (Kiểm chứng)**:
  * Giao $R_1 \cap R_2 = \{\text{MaTran}, \text{MaCauThu}\}$ là khóa chính của $R_1 \implies$ Phép tách kết nối không mất mát thông tin theo định lý Heath.
  * Bảo toàn đầy đủ cả $f_{11.1}$ và $f_{11.2}$.
  * Sau khi tách, toàn bộ 11 lược đồ quan hệ của hệ thống đều đạt chuẩn **BCNF**.

---

## 5. TỔNG KẾT KẾT QUẢ THIẾT KẾ GIAI ĐOẠN 1
1. **Tính hoàn chỉnh**: Mô hình dữ liệu bao quát 100% các yêu cầu nghiệp vụ của đề bài (6 đội, vòng tròn 2 lượt 10 vòng 30 trận, 4 trọng tài/trận, tối đa 30 cầu thủ/đội, tối đa 18 người đăng ký/trận, số áo 1-35, khớp bàn thắng thẻ phạt).
2. **Tính chuẩn tắc**: Toàn bộ 11 quan hệ đều đã được chứng minh giải tích đạt **Dạng chuẩn BCNF**, triệt tiêu hoàn toàn dư thừa và dị thường cập nhật.
3. **Tính sẵn sàng**: Sơ đồ trực quan đã sẵn sàng tại `docs/SO_DO_MERMAID_DRAWIO.md` để sinh hình ảnh cho báo cáo.
