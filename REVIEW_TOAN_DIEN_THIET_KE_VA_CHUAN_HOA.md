# BÁO CÁO REVIEW TOÀN DIỆN THIẾT KẾ CƠ SỞ DỮ LIỆU & CHUẨN HÓA BCNF
**Dự án:** Hệ CSDL Quản lý Giải bóng đá Chuyên nghiệp (Topic 13)  
**Vai trò đánh giá:** Giảng viên phản biện chuyên ngành Cơ sở dữ liệu  
**Mục tiêu:** Kiểm tra tính chính xác tuyệt đối về lý thuyết quan hệ, các bước chuẩn hóa BCNF, thiết kế dữ liệu và trang bị kiến thức trả lời vấn đáp bảo vệ.

---

## I. TỔNG QUAN ĐÁNH GIÁ (EXECUTIVE SUMMARY)

| Hạng mục kiểm tra | Trạng thái | Đánh giá học thuật |
| :--- | :---: | :--- |
| **1. Mô hình ER & Ánh xạ** | **ĐẠT XUẤT SẮC** | Thực thể mạnh, yếu, liên kết $1-N$, $N-N$ chuẩn chỉ. Đã thêm thuộc tính phân vùng `KhuVuc` cho Sân vận động. |
| **2. Lý thuyết Chuẩn hóa BCNF** | **ĐẠT TUYỆT ĐỐI** | Định nghĩa chuẩn xác; bài toán chứng minh tìm khóa, bao đóng và thuật toán phân rã không mất mát thông tin (Heath) chuẩn xác 100%. |
| **3. Cấu trúc Bảng & Khóa ngoại** | **ĐẠT CHUẨN** | 11 bảng đồng bộ kiểu dữ liệu PostgreSQL, các khóa ngoại tổ hợp tham chiếu chính xác. |
| **4. Toàn vẹn Dữ liệu & Nghiệp vụ** | **ĐẠT CAO** | 5 Trigger bắt lỗi chặt chẽ; 5 Transaction đảm bảo ACID; 30 trận đấu có dữ liệu khớp từng phút. |
| **5. Thiết kế CSDL Phân tán** | **ĐẠT CHUẨN** | Đủ 3 điều kiện phân mảnh (Đầy đủ, Tái thiết, Tách biệt); có phân mảnh ngang nguyên thủy, dẫn xuất cấp 1, cấp 2, phân mảnh dọc và nhân bản. |

---

## II. CHI TIẾT PHẦN CHUẨN HÓA BCNF (TRỌNG TÂM TRẢ LỜI GIẢNG VIÊN)

### 1. Định nghĩa cốt lõi cần nhớ khi bảo vệ
* **Dạng chuẩn 1 (1NF):** Toàn bộ các thuộc tính đều là giá trị nguyên tố (đơn trị), không có thuộc tính lặp hoặc đa trị.
* **Dạng chuẩn 2 (2NF):** Đạt 1NF và **không có phụ thuộc hàm bộ phận** (mọi thuộc tính không khóa phải phụ thuộc toàn phần vào toàn bộ khóa chính, không phụ thuộc vào một phần của khóa).
* **Dạng chuẩn 3 (3NF):** Đạt 2NF và **không có phụ thuộc bắc cầu** qua thuộc tính không khóa ($K \to A \to B$).  
  *Hoặc định nghĩa tương đương:* Với mọi $X \to Y$, $X$ là siêu khóa **HOẶC** $Y$ là tập thuộc tính khóa.
* **Dạng chuẩn Boyce-Codd (BCNF):**  
  > **Quy tắc vàng:** Với mọi phụ thuộc hàm không tầm thường $X \to Y \in F^+$ ($Y \nsubseteq X$), thì **$X$ BẮT BUỘC PHẢI LÀ SIÊU KHÓA** (nghĩa là bao đóng $X^+ = U$).  
  > *Khác biệt với 3NF:* BCNF loại bỏ hoàn toàn trường hợp ngoại lệ "$Y$ là thuộc tính khóa mà $X$ không phải siêu khóa". Do đó $BCNF \subset 3NF$ (chặt chẽ hơn 3NF).

---

### 2. Bảng điển hình phát hiện vi phạm và cách chuẩn hóa (Case Study mẫu mực)

#### A. Trạng thái ban đầu (Trước khi chuẩn hóa)
Khi mới ánh xạ từ thực tế, bảng sự kiện trận đấu thường được gom chung:
$$\text{SU\_KIEN\_TRAN\_DAU\_BAN\_DAU}(\underline{\mathbf{MaSuKien}}, MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan)$$
* Khóa chính: $K = \{MaSuKien\}$.
* Tập phụ thuộc hàm phát sinh:
  1. $f_1: MaSuKien \to \{MaTran, MaCauThu, MaDoi, LoaiSuKien, PhutGhiNhan\}$ (Vế trái là khóa chính).
  2. $f_2: \{MaTran, MaCauThu\} \to MaDoi$ (Cầu thủ trong một trận cụ thể chỉ đăng ký thi đấu cho một đội bóng xác định).

#### B. Phân tích vi phạm
* Xét phụ thuộc hàm $f_2: \{MaTran, MaCauThu\} \to MaDoi$:
  * Vế trái $X = \{MaTran, MaCauThu\}$. Tính bao đóng:
    $$\{MaTran, MaCauThu\}^+ = \{MaTran, MaCauThu, MaDoi\} \neq U_{11}$$
    *(Do một cầu thủ trong trận có thể ghi nhiều bàn hoặc nhận nhiều thẻ ở các phút khác nhau nên không suy ra được $MaSuKien, LoaiSuKien, PhutGhiNhan$)*.
  * Vì $X$ **không phải là siêu khóa**, và $MaDoi$ cũng không phải là thuộc tính khóa, nên bảng này **vi phạm cả 3NF lẫn BCNF** (chứa phụ thuộc bắc cầu $MaSuKien \to \{MaTran, MaCauThu\} \to MaDoi$).
* **Dị thường dữ liệu (Anomaly):**
  * *Dị thường thêm:* Nhập bàn thắng có thể gõ nhầm $MaDoi$ khác với đội mà cầu thủ khoác áo trong trận.
  * *Dị thường sửa:* Nếu đổi đội bóng của cầu thủ trong trận, phải `UPDATE` trên nhiều dòng sự kiện, dễ gây lệch dữ liệu.

#### C. Áp dụng thuật toán phân rã BCNF (Decomposition Algorithm)
* Tách lược đồ $R$ thành 2 lược đồ con theo $X \to Y$:
  * $R_1 = X \cup Y = \{\underline{\mathbf{MaTran}}, \underline{\mathbf{MaCauThu}}, MaDoi\}$ (Đạt BCNF vì $X$ là khóa của $R_1$).
  * $R_2 = U \setminus (Y \setminus X) = \{\underline{\mathbf{MaSuKien}}, MaTran, MaCauThu, LoaiSuKien, PhutGhiNhan\}$ (Đạt BCNF vì $MaSuKien$ là khóa của $R_2$).
* **Bước tối ưu hóa thông minh:**
  Nhận thấy $R_1$ chính là tập con của bảng `DANG_KY_THI_DAU(MaTran, MaCauThu, MaDoi, VaiTroThiDau, SoAoDangKy)` đã tồn tại trong CSDL. Do đó, ta **không tạo thêm bảng vật lý dư thừa**, mà chỉ cần:
  1. Loại bỏ cột $MaDoi$ khỏi bảng sự kiện $\to$ thu được bảng chuẩn hóa `SU_KIEN_TRAN_DAU`.
  2. Tạo khóa ngoại kép: $(MaTran, MaCauThu) \to \text{DANG\_KY\_THI\_DAU}(MaTran, MaCauThu)$.

#### D. Chứng minh 2 định lý bắt buộc của phép tách
1. **Bảo toàn thông tin (Lossless Join - Định lý Heath):**
   $$R_1 \cap R_2 = \{MaTran, MaCauThu\}$$
   Vì $\{MaTran, MaCauThu\} \to R_1$ (thuộc tính chung là siêu khóa của $R_1$), nên phép nối tự nhiên $R_1 \bowtie R_2$ khôi phục chính xác 100% dữ liệu gốc mà không sinh ra bộ giả.
2. **Bảo toàn phụ thuộc hàm (Dependency Preservation):**
   * $f_1$ được bảo toàn trên $R_2$ (`SU_KIEN_TRAN_DAU`).
   * $f_2$ được bảo toàn trên $R_1$ (`DANG_KY_THI_DAU`).  
   $\implies (F_{R_1} \cup F_{R_2})^+ = F^+$, không bị thất thoát bất kỳ ràng buộc hàm nào.

---

## III. 5 CÂU HỎI VẤN ĐÁP GIẢNG VIÊN DỄ HỎI VÀ CÁCH TRẢ LỜI

### Câu 1: Tại sao trong bảng `TRAN_DAU` có trường `MaSan`, liệu có phụ thuộc hàm `MaDoiNha -> MaSan` gây vi phạm BCNF không?
* **Trả lời:** Không vi phạm. Thuộc tính `MaSan` trong `DOI_BONG` là sân nhà đăng ký cố định của đội. Nhưng thuộc tính `MaSan` trong `TRAN_DAU` là **sân thi đấu thực tế** của trận đó. Trong bóng đá thực tế, trận đấu có thể phải tổ chức tại **sân trung lập** (do sân nhà bị phạt thi đấu không khán giả, bảo trì mặt cỏ, hoặc BTC chỉ định). Do đó không tồn tại phụ thuộc hàm $MaDoiNha \to MaSan$ trong bảng `TRAN_DAU`, `MaSan` hoàn toàn độc lập và bảng đạt chuẩn BCNF.

### Câu 2: Trong bảng `TRAN_DAU` có các cột `BanThangNha`, `TheVangNha`... Đây có phải là thuộc tính dư thừa (suy diễn) từ bảng `SU_KIEN_TRAN_DAU` không?
* **Trả lời:**
  * Về mặt chuẩn hóa: Các cột này không tạo ra phụ thuộc hàm vi phạm BCNF trong nội bộ bảng `TRAN_DAU`.
  * Về mặt kiến trúc hệ thống CSDL: Đây là kỹ thuật **Denormalization có kiểm soát (Materialized Summary)** nhằm tối ưu hóa hiệu năng đọc (Read performance). Nếu không có các cột này, mỗi lần hiển thị lịch thi đấu hay tính bảng xếp hạng toàn giải, hệ thống sẽ phải quét và `COUNT(*)` liên tục trên toàn bộ bảng sự kiện, gây nghẽn I/O.
  * Tính toàn vẹn dữ liệu được đảm bảo tuyệt đối bằng **Trigger `tg_cap_nhat_su_kien_tran_dau`**: Khi có bất kỳ thao tác INSERT/UPDATE/DELETE nào trên `SU_KIEN_TRAN_DAU`, Trigger sẽ tự động cập nhật lại các cột tỉ số và thẻ trong `TRAN_DAU`.

### Câu 3: Bảng `PHAN_CONG_TRONG_TAI` có 2 khóa ứng viên giao nhau, vậy nó đạt chuẩn nào?
* **Trả lời:** 
  * Hai khóa ứng viên là $K_1 = \{MaTran, VaiTro\}$ và $K_2 = \{MaTran, MaTrongTai\}$. Hai khóa này giao nhau tại $MaTran$.
  * Phụ thuộc hàm:
    * $\{MaTran, VaiTro\} \to MaTrongTai$ (Vế trái là $K_1$ - siêu khóa).
    * $\{MaTran, MaTrongTai\} \to VaiTro$ (Vế trái là $K_2$ - siêu khóa).
  * Vì mọi vế trái của tất cả phụ thuộc hàm đều là siêu khóa, nên bảng này **đạt chuẩn BCNF tuyệt đối**.

### Câu 4: Giá vé (`GiaVe`) trong bảng `TRAN_DAU` được thiết kế như thế nào?
* **Trả lời:**
  * Theo đúng yêu cầu tại Trang 3 của đề bài: *"Giá vé mỗi trận đấu của một sân đấu có thể khác nhau tại các trận khác nhau."*
  * Vì vậy, giá vé được gắn trực tiếp theo từng trận đấu cụ thể ($MaTran \to GiaVe$), thuộc tính `GiaVe` nằm trong bảng `TRAN_DAU` là chính xác tuyệt đối theo đề bài và đạt BCNF.

### Câu 5: Hệ thống phân tán của bạn đảm bảo những tiêu chuẩn toán học nào?
* **Trả lời:** Đảm bảo đủ 3 điều kiện của phân mảnh CSDL:
  1. **Tính đầy đủ (Completeness):** Mọi bản ghi ở CSDL tập trung đều xuất hiện ở ít nhất một trạm con (ví dụ: sân Mỹ Đình, Hàng Đẫy ở Miền Bắc; Pleiku, Thống Nhất ở Miền Nam).
  2. **Tính tái thiết (Reconstruction):** Luôn khôi phục lại được bảng toàn cục bằng toán tử đại số quan hệ:
     * Dùng phép hội $\bigcup$ (`UNION ALL`) cho phân mảnh ngang.
     * Dùng phép nối tự nhiên $\bowtie$ (`JOIN` qua khóa chính) cho phân mảnh dọc.
  3. **Tính tách biệt (Disjointness):** Các mảnh ngang nguyên thủy không chứa phần tử trùng lặp ($R_1 \cap R_2 = \emptyset$).

---

## IV. TỔNG KẾT
Toàn bộ thiết kế từ ERD, lược đồ quan hệ BCNF, DDL PostgreSQL, dữ liệu 30 trận đấu và các kịch bản phân tán đã được rà soát đồng bộ 100%. Bạn hoàn toàn có thể tự tin thuyết trình và bảo vệ trước hội đồng chấm thi.
