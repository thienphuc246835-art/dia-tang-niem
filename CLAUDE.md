# CLAUDE.md — Ứng dụng "Địa Tạng Niệm" (Ksitigarbha Practice App)

> Tài liệu hướng dẫn dành cho Claude Code khi làm việc trong dự án này.
> Đọc kỹ phần **Nguyên tắc Phật pháp** trước khi viết bất kỳ dòng code hay nội dung nào.

---

## 1. Tổng quan dự án

**Địa Tạng Niệm** là ứng dụng di động giúp người Phật tử thực hành tu tập theo pháp môn
trì niệm danh hiệu **Địa Tạng Vương Bồ Tát** — vị Bồ Tát phát đại nguyện:
*"Địa ngục vị không, thệ bất thành Phật; chúng sinh độ tận, phương chứng Bồ Đề."*

Danh hiệu chính để trì niệm (mặc định):

> **Nam mô Đại Nguyện Địa Tạng Vương Bồ Tát**

Các danh hiệu khác có thể chọn — **lấy nguyên văn từ bản Kinh nguồn** (xem mục 10):
- *Nam mô Địa Tạng Vương Bồ Tát*
- *Nam mô Đại Nguyện Địa Tạng Vương Bồ Tát Ma Ha Tát*
- *Nam mô Địa Tạng Bồ Tát Ma Ha Tát*
- *Đại Bi, Đại Nguyện, Đại Thánh, Đại Từ, Bổn Tôn Địa Tạng Bồ Tát Ma Ha Tát*

Danh sách danh hiệu là **dữ liệu** (không hard-code), người dùng chọn một danh hiệu cho mỗi thời niệm.

### Mục tiêu
- Giúp người dùng **đếm số biến niệm** một cách nhẹ nhàng, không xao lãng.
- Cho phép **đọc Kinh** như ebook, ngay trong ứng dụng, hoạt động offline.
- Hỗ trợ **hồi hướng công đức** cho người thân (còn sống hoặc đã khuất).
- Giao diện **tối giản, tĩnh lặng**, giúp tâm an — không gây nghiện, không gây phân tâm.

### Đối tượng người dùng
Phật tử mọi lứa tuổi, trong đó có người lớn tuổi → chữ lớn, nút lớn, thao tác ít bước.

---

## 2. Nguyên tắc Phật pháp (BẮT BUỘC TUÂN THỦ)

1. **Tôn kính**: Tên Phật, Bồ Tát, Kinh điển luôn viết hoa đúng chuẩn
   (Địa Tạng Vương Bồ Tát, Kinh Địa Tạng, Phật, Pháp, Tăng). Không dùng hình ảnh/biểu tượng Phật
   làm trang trí tùy tiện, không dùng làm icon nút bấm nhỏ, không đặt ở vị trí bất kính.
2. **Không thương mại hoá việc tu tập**: Không quảng cáo, không bán "công đức", không bán
   "hồi hướng", không có tính năng "mua lễ/cúng dường" trong app. Không popup quảng cáo.
3. **Không gamification gây dính mắc**: Không bảng xếp hạng, không so sánh người dùng với nhau,
   không huy hiệu khoe khoang. Thành tựu chỉ mang tính **tự nhắc nhở**, khiêm hạ
   (ví dụ: "Hôm nay bạn đã niệm 108 biến. Tùy hỷ công đức.").
4. **Chính xác văn bản Kinh**: Nội dung Kinh lấy từ bản nguồn ở mục 10
   (Việt dịch: **HT Thích Trí Tịnh**, ấn tống bởi **Đạo Tràng Liên Hoa**). Tuyệt đối **không tự ý
   sửa/tóm tắt/diễn giải** Kinh văn. Nếu cần chú giải, đặt ở khu vực riêng, ghi rõ là chú giải.
   - **Giữ nguyên chính tả cổ của bản dịch**: *nầy, chúng sanh, nhơn, đặng, thời, bực, hăm…*
     Không "hiện đại hoá" thành *này, chúng sinh, nhân, được…*, không sửa lỗi chính tả mà mình *nghĩ* là lỗi.
     Chỗ nghi lỗi do trích xuất PDF → ghi `TODO(buddhist-review)`, đối chiếu bản in.
   - Chuẩn hoá Unicode **NFC** cho toàn bộ văn bản tiếng Việt (tìm kiếm phải khớp dấu đúng).
5. **Bản quyền & ấn tống**: Bản Kinh nguồn ghi *"This book is strictly for free distribution, it is not
   to be sold. Kinh ấn tống không được bán."* Do đó:
   - Ứng dụng **miễn phí hoàn toàn**, không thu phí, không gói trả tiền, không quảng cáo.
   - Phải **xin phép bằng văn bản** Đạo Tràng Liên Hoa trước khi phát hành lên store; lưu bằng chứng trong
     `docs/permissions/`. Trước khi có phép, chỉ dùng cho mục đích phát triển nội bộ.
   - Ghi đầy đủ nguồn trong màn hình "Giới thiệu & Nguồn Kinh" (tên đạo tràng, địa chỉ, website, phiên bản).
6. **Không cổ xúy mê tín, không tự hứa hẹn**: App **không tự đặt ra** lời hứa "niệm đủ số lần sẽ được X".
   Khi muốn nói về lợi ích tu tập, chỉ **trích nguyên văn Kinh kèm số Phẩm/đoạn**
   (ví dụ: Phẩm 6 đoạn 12, Phẩm 13 đoạn 4 — 28 điều lợi), để người đọc tự quán chiếu.
   Lời lẽ của app luôn chính tín: tu tập để tâm thanh tịnh, phát khởi từ bi, báo hiếu.
7. **Thuật ngữ**: Dùng đúng thuật ngữ Hán-Việt Phật giáo (biến niệm, hồi hướng, công đức,
   siêu độ, cầu an, pháp danh…). Khi không chắc, ghi `// TODO(buddhist-review)` để nhờ
   thầy/chuyên gia kiểm duyệt, **không tự đoán**.
8. **Quyền riêng tư**: Tên người thân, ngày mất, số niệm là dữ liệu cá nhân nhạy cảm.
   Lưu cục bộ trên thiết bị theo mặc định; không gửi đi đâu nếu người dùng không chủ động bật đồng bộ.

---

## 3. Tính năng

### 3.1. Tính năng cốt lõi (MVP)

#### A. Niệm danh hiệu & đếm số (Màn hình chính)
- Một **nút tròn lớn ở giữa màn hình** (có thể là hoa sen cách điệu/vòng tròn Enso tối giản).
- **Mỗi lần chạm = 1 biến niệm**. Số lần hiện **ngay trên nút**, chữ lớn, rõ.
- Phản hồi nhẹ nhàng: rung rất nhẹ (haptic, tắt được) + âm mõ/chuông khẽ (tắt được).
  Mặc định: **không âm thanh, chỉ rung nhẹ**.
- Hiển thị phụ (chữ nhỏ, mờ): *Tổng hôm nay* · *Tổng tích lũy* · *Vòng chuỗi hiện tại (x/108)*.
- **Chế độ chuỗi hạt 108**: sau mỗi 108 biến thì rung/chuông nhẹ báo hoàn tất một vòng.
- **Mục tiêu hằng ngày** (tùy chọn): 108 / 1.000 / 10.000 / tự đặt. Hiển thị bằng vòng tiến độ mảnh.
- **Thời khoá nhiều ngày** (tùy chọn) — dựa trên Kinh: *"niệm danh hiệu Địa Tạng Bồ Tát đủ một muôn biến"*
  (Phẩm 6 đoạn 10, 11; Phẩm 12 đoạn 7, 9, 10) và thực hành *"trong bảy ngày hoặc hai mươi mốt ngày"*
  (Phẩm 12). Ví dụ: **"Một muôn biến trong 7 ngày"** → app chia mục tiêu mỗi ngày, cộng dồn qua các ngày,
  có thể gắn với một người được hồi hướng. Hiển thị câu Kinh liên quan kèm số phẩm, không diễn giải thêm.
- **Hoàn tác (Undo)** 1 lần chạm — vì dễ bấm nhầm.
- **Đặt lại số đếm** có xác nhận.
- **Giữ màn hình sáng** (tùy chọn) khi đang niệm.
- **Chạm bất kỳ đâu trên màn hình** hoặc **nút âm lượng** để đếm (tùy chọn) — hữu ích khi nhắm mắt niệm.
- Hoạt động **nền** (đếm không mất khi khoá màn hình/chuyển app).

#### B. Đọc Kinh (E-reader)
- Kinh chính: **Kinh Địa Tạng Bồ Tát Bổn Nguyện**, Việt dịch HT Thích Trí Tịnh
  (bản ấn tống Đạo Tràng Liên Hoa — chi tiết ở mục 10).
- Cấu trúc **đúng theo bản Kinh nguồn**, gồm cả nghi thức tụng:
  1. **Khai Kinh**: Tựa Địa Tạng Bồ Tát → Văn Phát Nguyện → Kệ Khai Kinh.
  2. **Quyển Thượng** (Phẩm 1–4) → kệ & danh hiệu cuối quyển.
  3. **Quyển Trung** (Phẩm 5–9) → kệ & danh hiệu cuối quyển.
  4. **Quyển Hạ** (Phẩm 10–13) → kệ & danh hiệu cuối quyển.
  5. **Kết Kinh**: Kệ hộ pháp → Bát Nhã Tâm Kinh → Vãng Sanh Quyết Định Chơn Ngôn → Tán Phật →
     Sám Thập Phương → Phúng Kinh → Phục Nguyện → Tam Quy Y → Hồi Hướng.
- **Mục lục 3 cấp**: Quyển → Phẩm → đoạn có tiêu đề đánh số (vd. *"5) BÀ LA MÔN NỮ CỨU MẸ"*).
  Bản Kinh có khoảng 59 đoạn có tiêu đề như vậy — dùng làm điểm nhảy nhanh và đơn vị trích dẫn.
- **Hai chế độ đọc**:
  - *Đọc Kinh*: đọc tự do, chỉ Kinh văn 13 phẩm.
  - *Tụng theo nghi thức*: đi tuần tự từ Khai Kinh → Kết Kinh. Cho phép **tụng theo quyển**
    (thói quen phổ biến: mỗi thời tụng một quyển), app nhớ đã tụng tới quyển nào.
    Hoàn tất một quyển/một bộ được ghi vào nhật ký và có thể hồi hướng.
- **Chỉ dẫn lặp lại trong Kinh** như *(3 lần)*, *(21 lần)*, *(1 lạy)* hiển thị thành nhãn nhỏ, mờ
  bên phải câu (không trộn vào Kinh văn); khi tụng theo nghi thức có thể chạm để đếm 1/3, 2/3, 3/3.
- **Kệ, danh sách, thần chú** (vd. danh sách cõi Trời ở Phẩm 1, 28 điều lợi ở Phẩm 13, Bát Nhã Tâm Kinh)
  hiển thị theo dòng thơ/danh sách, giữ nguyên ngắt dòng của bản gốc; văn xuôi thì tự chảy theo màn hình.
- Tính năng đọc:
  - Cỡ chữ, giãn dòng, font (serif dễ đọc), căn lề.
  - Chế độ **Sáng / Sepia (giấy ngả) / Tối**.
  - **Đánh dấu trang**, **ghi nhớ vị trí đọc cuối**, thanh tiến độ.
  - **Tìm kiếm** trong Kinh.
  - **Ghi chú / tô đậm** cá nhân (lưu cục bộ).
  - Hiển thị song ngữ **Hán – Việt** (tùy chọn, giai đoạn sau).
  - Cuộn dọc mượt hoặc lật trang (chọn trong cài đặt).
- Hoạt động **100% offline** (nội dung Kinh đóng gói sẵn trong app).
- Cấu trúc nội dung Kinh lưu dạng dữ liệu (JSON/Markdown), **tách khỏi code** để dễ kiểm duyệt.

#### C. Hồi hướng công đức
- Sau khi kết thúc một thời niệm/đọc Kinh, hiện màn hình **"Hồi hướng"**.
- Người dùng **chọn/nhập người thân** để hồi hướng:
  - Họ tên (hoặc pháp danh), quan hệ (cha, mẹ, ông bà, con, bạn bè, oan gia trái chủ,
    chúng sinh pháp giới…).
  - **Trạng thái**: *Còn sống (cầu an)* hoặc *Đã khuất (siêu độ / cầu siêu)*.
  - Với người đã khuất: ngày mất (dương/âm lịch) để nhắc ngày giỗ.
- Có thể chọn **nhiều người cùng lúc**, hoặc "Pháp giới chúng sinh".
- Hiển thị **bài kệ hồi hướng** lấy **nguyên văn từ cuối bản Kinh nguồn**:
  > *Nguyện đem công đức nầy,*
  > *Hướng về khắp tất cả,*
  > *Đệ tử và chúng sanh,*
  > *Đều trọn thành Phật đạo.*

  Có thể chọn thêm bài **Phúng Kinh** (Hán-Việt) cũng trong Kết Kinh.
  Phần **tên người được hồi hướng** hiển thị *tách riêng* phía trên bài kệ (vd. "Hồi hướng cho: Mẹ — Nguyễn Thị A"),
  **không chèn tên vào giữa câu kệ**. Mọi lời văn hồi hướng tự soạn thêm phải qua kiểm duyệt.
- Hồi hướng gắn với **loại công đức**: niệm danh hiệu (số biến), tụng Kinh (quyển/bộ), thời khoá nhiều ngày.
- Lưu **nhật ký hồi hướng**: đã hồi hướng cho ai, số biến niệm, ngày nào.
- Quản lý danh sách người thân (thêm/sửa/xoá), xoá hoàn toàn khi người dùng yêu cầu.

### 3.2. Tính năng đề xuất thêm

**Ưu tiên cao (phiên bản 1.1)**
| Tính năng | Mô tả |
|---|---|
| **Lịch Thập Trai** | Theo Kinh (Phẩm 6 đoạn 12): mười ngày trai âm lịch **1, 8, 14, 15, 18, 23, 24, 28, 29, 30** — ngày nên tụng Kinh. Đánh dấu nhẹ trên lịch, nhắc tùy chọn. Tháng thiếu (không có ngày 30) xử lý thế nào → `TODO(buddhist-review)`, đừng tự đoán. |
| **Lịch Phật giáo** | Lịch âm, mùng 1 – rằm, ngày vía (đặc biệt **vía Địa Tạng Vương Bồ Tát 30/7 âm lịch** — tháng thiếu là 29/7; tháng 7 Vu Lan). Ngày vía là truyền thống, không có trong Kinh → ghi rõ nguồn khác. |
| **Hồi hướng 49 ngày** | Theo Kinh (Phẩm 7): người mất *"trong bốn mươi chín ngày"* trông chờ thân quyến tu phước. Khi thêm người mới mất, app tạo lịch **7 tuần thất** (tuần 1 → chung thất ngày 49), nhắc mỗi tuần, gợi ý tụng Kinh/niệm danh hiệu và hồi hướng. Giọng văn nhẹ nhàng, an ủi. |
| **Nhắc giờ tu tập** | Thông báo theo giờ do người dùng chọn (sáng/tối), lời nhắc ngắn gọn, không thúc ép. |
| **Nhật ký tu tập** | Biểu đồ đơn giản theo ngày/tuần/tháng: số biến niệm, thời gian, số ngày liên tục (chỉ cho riêng mình). |
| **Nhắc ngày giỗ** | Dựa trên ngày mất người thân đã lưu, nhắc trước 1–3 ngày để làm công đức hồi hướng. |
| **Widget màn hình chính** | Hiển thị số đã niệm hôm nay; chạm để mở nhanh màn hình niệm. |
| **Sao lưu & khôi phục** | Xuất/nhập file dữ liệu (JSON) hoặc đồng bộ tuỳ chọn có mã hoá. |

**Ưu tiên trung bình (phiên bản 1.2+)**
| Tính năng | Mô tả |
|---|---|
| **Nghe Kinh / niệm Phật audio** | Âm thanh tụng Kinh, niệm danh hiệu có thể lặp, tuỳ chọn tốc độ; chạy nền. |
| **Máy niệm Phật tự động** | Phát tiếng niệm danh hiệu liên tục, đếm tự động theo nhịp. |
| **Chế độ Thiền / Tĩnh tâm** | Hẹn giờ ngồi thiền với chuông đầu–cuối, màn hình tối giản. |
| **Sám hối & Phát nguyện** | Mở nhanh *Văn Phát Nguyện* và *Sám Thập Phương* có sẵn trong bản Kinh; bài khác phải kiểm duyệt. |
| **Xưng danh hiệu chư Phật** | Từ Phẩm 9: đọc lần lượt các danh hiệu Phật trong phẩm, mỗi danh hiệu một màn hình, chạm để sang. |
| **Lời dạy mỗi ngày** | Một đoạn trích nguyên văn từ Kinh mỗi ngày, ghi rõ Phẩm/đoạn, chạm để mở đúng vị trí trong Kinh. |
| **Tiểu sử & Đại nguyện Địa Tạng Vương** | Giới thiệu ngắn về Ngài, đối chiếu với Kinh. |
| **Đa ngôn ngữ** | Tiếng Việt (mặc định), Hán, Anh. |
| **Chế độ đọc cho người lớn tuổi** | Chữ rất lớn, tương phản cao, ít chạm. |

**Ý tưởng mở rộng**
- Hướng dẫn tu tập cho người mới: cách niệm, cách hồi hướng, nghi thức cơ bản.
- Mục **Thiện nghiệp trong ngày** (phóng sanh, bố thí, ăn chay) tự ghi nhận, không chấm điểm.
- Hộp **Chia sẻ công đức** (chia sẻ app, không chia sẻ số liệu cá nhân).

### 3.3. Ngoài phạm vi (KHÔNG làm)
- Quảng cáo, mua sắm, bán vật phẩm, "dịch vụ cúng bái trả phí".
- Bảng xếp hạng, so sánh, thi đua số lần niệm.
- Mạng xã hội / bình luận công khai.
- Thu thập dữ liệu cá nhân để phân tích/quảng cáo.

---

## 4. Thiết kế giao diện (UI/UX)

### Triết lý
Tối giản, tĩnh lặng, "ít mà sâu" — lấy cảm hứng từ **thiền, Enso, không gian chùa, giấy dó, gỗ, hoa sen**.
Mỗi màn hình chỉ có **một việc chính**. Nhiều khoảng trắng (negative space). Không hiệu ứng loè loẹt.

### Bảng màu (đề xuất, định nghĩa thành design tokens)
| Vai trò | Sáng | Tối |
|---|---|---|
| Nền | `#F7F3EA` (giấy dó/kem) | `#16130F` (mực/than) |
| Chữ chính | `#2B2620` (nâu mực) | `#E9E2D0` |
| Chữ phụ | `#7A7266` | `#9A917F` |
| Nhấn (vàng đồng — kim sắc) | `#B08D3E` | `#C9A75A` |
| Nhấn phụ (xanh rêu/lá sen) | `#6B7F5E` | `#7E9470` |
| Đường viền mảnh | `#E3DCCB` | `#2A251E` |

- Tránh đỏ chói, neon, gradient rực rỡ. Màu vàng đồng dùng **tiết chế**.
- Hỗ trợ tự động theo hệ thống (Sáng/Tối) + chọn thủ công. Đảm bảo độ tương phản WCAG AA.

### Chữ
- Tiêu đề & Kinh văn: font **serif** thanh lịch có hỗ trợ tiếng Việt đầy đủ dấu
  (ví dụ *Noto Serif*, *Source Serif 4*, *Lora*). Hán văn: *Noto Serif TC/SC*.
- UI phụ: *Noto Sans* / *Inter*, cỡ chữ tối thiểu 16sp, hỗ trợ cỡ chữ hệ thống.

### Bố cục
- **Điều hướng dưới (3–4 mục):** `Niệm` · `Kinh` · `Hồi hướng` · `Thêm` (lịch, nhật ký, cài đặt).
- Màn hình **Niệm**: nền trống, danh hiệu ở trên (chữ thư pháp/serif mờ), nút tròn đếm ở giữa,
  số liệu phụ ở dưới. Không có thanh công cụ rối rắm.
- Chuyển cảnh: mờ dần (fade) chậm, không trượt mạnh; hoạt ảnh nhẹ như gợn nước/hoa sen nở khi đạt 108.
- Biểu tượng: nét mảnh, đơn giản (line icons). Không dùng emoji trong UI chính.
- Giọng văn: ôn hoà, ngắn gọn, khiêm cung. Ví dụ: "Nam Mô A Di Đà Phật", "Tùy hỷ công đức".

### Khả năng truy cập
- Nút chạm tối thiểu 48×48dp (nút niệm ≥ 200dp).
- Hỗ trợ screen reader (TalkBack/VoiceOver) với nhãn rõ ràng.
- Hỗ trợ giảm chuyển động (reduce motion).

---

## 5. Kiến trúc kỹ thuật

### Công nghệ đề xuất
- **Flutter (Dart)** — một codebase cho Android + iOS, hiệu năng tốt, UI tuỳ biến cao.
  *(Nếu người dùng yêu cầu khác — React Native/Kotlin/Swift — hãy hỏi lại trước khi đổi.)*
- **Quản lý trạng thái:** Riverpod 3 (`Notifier`/`NotifierProvider`, không dùng codegen).
- **Lưu trữ cục bộ:** MVP dùng `shared_preferences` + JSON qua lớp `LocalStore` (chạy được cả web).
  Các repository chỉ gọi `LocalStore`, nên khi dữ liệu lớn có thể chuyển sang `drift` (SQLite) mà không sửa feature.
- **Điều hướng:** `go_router`.
- **Âm thanh:** `just_audio` + `audio_service` (chạy nền).
- **Thông báo:** `flutter_local_notifications`.
- **Lịch âm:** thư viện/thuật toán lịch âm Việt Nam (múi giờ UTC+7), kiểm thử kỹ.
- **Widget màn hình chính:** `home_widget`.
- **Kiểm thử:** `flutter_test`, `mocktail`, `integration_test`.

### Cấu trúc thư mục (feature-first)
```
lib/
  main.dart
  app/                    # MaterialApp, router, theme
  core/
    theme/                # colors, typography, tokens
    utils/                # lunar calendar, formatters
    widgets/              # widget dùng chung
  features/
    chant/                # màn hình niệm & đếm
      data/ domain/ presentation/
    sutra/                # đọc Kinh
    dedication/           # hồi hướng & người thân
    journal/              # nhật ký tu tập
    calendar/             # lịch Phật giáo
    settings/
assets/
  sutra/
    dia_tang/
      meta.json           # nguồn, dịch giả, phiên bản, giấy phép
      khai_kinh.json
      quyen_thuong.json   # Phẩm 1–4 + kệ cuối quyển
      quyen_trung.json    # Phẩm 5–9 + kệ cuối quyển
      quyen_ha.json       # Phẩm 10–13 + kệ cuối quyển
      ket_kinh.json
    mantras.json          # danh sách danh hiệu để trì niệm
  fonts/
  audio/
  images/
source/
  kinh_dia_tang.pdf       # bản gốc để đối chiếu — KHÔNG đóng gói vào app
tools/
  sutra_import/           # script chuyển PDF → JSON (chạy một lần, rồi hiệu đính tay)
docs/
  permissions/            # thư xin phép / chấp thuận của Đạo Tràng Liên Hoa
test/
```

### Mô hình dữ liệu chính
```
ChantSession   { id, date, count, durationSec, mantraId, planId?, dedicationIds[] }
ChantPlan      { id, mantraId, targetCount, days, startDate, personIds[] }   // vd. 10.000 biến / 7 ngày
RecitationLog  { id, date, sutraId, scope(volume|full|section), volumeId?, durationSec }
DailyStat      { date, totalCount }                 // tổng hợp để truy vấn nhanh
Person         { id, name, dharmaName?, relation, status(alive|deceased), deathDateSolar?, deathDateLunar?, note? }
MemorialPlan   { id, personId, startDate }          // 49 ngày; 7 mốc tuần thất tính từ startDate
Dedication     { id, sourceType(chant|recitation|plan), sourceId, personIds[], verseId, createdAt }
Bookmark       { id, sutraId, blockId, note? }
Highlight      { id, sutraId, blockId, startOffset, endOffset, color }
SutraMeta      { id, title, translatorVi, translatorHan, publisher, edition, year, license, permissionNote }
Settings       { theme, fontSize, haptic, sound, keepAwake, dailyGoal, defaultMantraId, reminders[] }
```

### Schema nội dung Kinh (JSON)
```
Volume   { id, title, chapters[], closing: Block[] }          // closing = kệ + danh hiệu cuối quyển
Chapter  { id, number, title, sections[] }                    // vd. 1, "THẦN THÔNG TRÊN CUNG TRỜI ĐAO LỢI"
Section  { id, number?, title?, blocks[] }                    // "5) BÀ LA MÔN NỮ CỨU MẸ"
Block    { id, type, text, repeat?, prostrations? }
  type: prose | verse | list_item | invocation | mantra | heading
  repeat: số lần đọc ghi trong Kinh "(3 lần)", "(21 lần)"; prostrations: "(1 lạy)"
```
- `blockId` **ổn định** (vd. `q1.p1.s5.b3`) — bookmark, highlight, trích dẫn đều trỏ vào đây;
  đổi nội dung khi hiệu đính không được làm đổi ID.

### Quy trình nhập Kinh từ PDF (`tools/sutra_import/`)
Văn bản trích xuất từ PDF có nhiều "rác" phải làm sạch, rồi **hiệu đính tay đối chiếu bản in**:
- Bỏ tiêu đề chạy & số trang: `KINH ĐỊA TẠNG - QUYỂN THƯỢNG`, `PHẨM 1  5`, `KHAI KINH  3`…
- Bỏ ký hiệu ngăn phẩm `❖`, trang bìa, trang mục lục.
- Gộp dòng bị ngắt giữa câu trong văn xuôi; **giữ ngắt dòng** trong kệ/danh sách/thần chú.
- Thu gọn khoảng trắng kép (`Ta  nghe  như`) → một khoảng trắng; chuẩn hoá NFC.
- Tách `(3 lần)`, `(1 lạy)` khỏi câu thành trường `repeat`/`prostrations`.
- Nhận diện đoạn có tiêu đề bằng mẫu `^\d+\)\s+[CHỮ HOA]+\.` → `Section`.
- Test tự động: đủ 3 quyển, 13 phẩm, đúng tiêu đề phẩm (mục 10), không block rỗng,
  không còn sót tiêu đề chạy/số trang.

### Quy tắc kỹ thuật quan trọng
- **Bộ đếm phải bền vững:** ghi (debounce ngắn) xuống DB sau mỗi lần chạm/nhóm lần chạm để
  không mất dữ liệu khi app bị kill. Không bao giờ để mất số niệm của người dùng.
- **Độ trễ chạm < 50ms**; không chạy tác vụ nặng trên UI thread.
- **Offline-first**: mọi tính năng cốt lõi chạy không cần mạng.
- **Nội dung Kinh tách khỏi code**, có schema và test kiểm tra tính toàn vẹn (đủ phẩm, không rỗng).
- **Không nhúng SDK theo dõi/quảng cáo.** Nếu cần crash reporting, chỉ dùng loại ẩn danh và cho phép tắt.
- **Quyền hạn tối thiểu:** chỉ xin quyền thông báo khi người dùng bật nhắc nhở.
- Mã hoá dữ liệu sao lưu nếu người dùng chọn đồng bộ đám mây.

---

## 6. Lộ trình phát triển

1. **Giai đoạn 0 — Nền tảng:** khởi tạo dự án, theme, design tokens, điều hướng.
2. **Giai đoạn 1 — MVP:** màn hình Niệm (đếm, 108, mục tiêu ngày, undo) + lưu bền vững.
3. **Giai đoạn 2:** Nhập Kinh từ PDF → JSON + hiệu đính; E-reader (mục lục 3 cấp, cỡ chữ, sáng/sepia/tối,
   bookmark, vị trí đọc cuối); chế độ tụng theo nghi thức / theo quyển.
4. **Giai đoạn 3:** Hồi hướng & quản lý người thân, nhật ký hồi hướng, thời khoá nhiều ngày, hồi hướng 49 ngày.
5. **Giai đoạn 4:** Nhật ký thống kê, lịch Thập Trai & lịch Phật giáo, nhắc giờ & ngày giỗ.
6. **Giai đoạn 5:** Audio, widget, sao lưu, đa ngôn ngữ.
7. **Kiểm duyệt:** nhờ Tăng/Ni hoặc cư sĩ am hiểu duyệt nội dung Kinh, văn hồi hướng, thuật ngữ trước khi phát hành.

---

## 7. Quy ước code

- Ngôn ngữ code (tên biến, hàm, class, comment): **tiếng Anh**. Chuỗi hiển thị cho người dùng: **tiếng Việt**,
  hiện đặt trong `lib/core/strings.dart` (lớp `S`); chuyển sang `.arb` (gen-l10n) khi thêm ngôn ngữ thứ hai.
- Tuân thủ `flutter_lints`; chạy `dart format` và `flutter analyze` trước khi commit.
- Mỗi feature có test cho logic cốt lõi (đếm, vòng 108, mục tiêu ngày, lịch âm, hồi hướng).
- Widget nhỏ, tái sử dụng; tránh logic nghiệp vụ trong widget.
- Đặt tên theo ngữ nghĩa: `ChantCounter`, `DedicationSheet`, `SutraReader`, `LunarCalendar`.
- Commit nhỏ, thông điệp rõ ràng (Conventional Commits: `feat:`, `fix:`, `docs:`…).
- Mọi nội dung tôn giáo mới thêm vào phải kèm **nguồn** và đánh dấu cần kiểm duyệt.

## 8. Lệnh thường dùng
```bash
flutter pub get
flutter run
dart analyze            # xem lưu ý đường dẫn bên dưới
dart format lib test
flutter test
flutter build web --release --no-tree-shake-icons
flutter build apk --release
flutter build appbundle --release
# Nhập lại Kinh từ PDF (ghi đè assets/sutra/dia_tang/*.json — chỉ làm khi cần, rồi hiệu đính lại):
python -I tools/sutra_import/import_pdf.py source/kinh_dia_tang.pdf assets/sutra/dia_tang
```

**Lưu ý đường dẫn có dấu:** thư mục dự án hiện có dấu tiếng Việt (`Địa Tạng Vương Bồ Tát`), làm hỏng một số công cụ:
`flutter analyze` (lỗi LSP) và bước nén phông biểu tượng khi build (phải thêm `--no-tree-shake-icons`).
`dart analyze` và `flutter test` vẫn chạy được, nhưng phải gọi từ junction không dấu `C:\src\dtn`.
Gradle cũng không chạy được từ đường dẫn có dấu: APK hiện được build từ bản sao `C:\src\dia_tang_niem_build`
(`robocopy <dự án> C:\src\dia_tang_niem_build /MIR /XD build .dart_tool .idea source`, rồi `flutter build apk --release --no-tree-shake-icons`).
SDK/JDK: `C:\src\android-sdk`, `C:\src\jdk17`. APK đã build để ở `dist/` (ký bằng khoá debug — chỉ để cài thử).
**Khuyến nghị:** chuyển dự án sang đường dẫn không dấu (vd. `C:\Projects\dia_tang_niem`) trước khi build Android/iOS.

## 8b. Trạng thái hiện tại (21/10/2026)
- **Đã làm:**
  - Niệm: đếm, vòng 108, mục tiêu ngày, hoàn tác, đặt lại, chạm bất kỳ đâu, phím Space/Enter, giữ màn hình sáng.
  - Thời khoá nhiều ngày.
  - Đọc Kinh: mục lục 3 cấp, tụng theo nghi thức/theo quyển kèm đếm *(3 lần)*, tìm kiếm không dấu,
    đánh dấu (nhấn giữ đoạn Kinh), nhớ vị trí đọc, cỡ chữ/giãn dòng, giao diện Tự động/Sáng/Giấy/Tối.
  - Hồi hướng: người thân, nhật ký, 49 ngày.
  - Lịch Thập Trai/âm lịch/vía/ngày giỗ, nhật ký tu tập, cài đặt, trang Nguồn Kinh.
- **Chưa làm:** nhắc nhở (thông báo), widget, sao lưu, audio, ghi chú/tô màu, đếm bằng nút âm lượng
  (cần code native), Xưng danh hiệu chư Phật, Lời dạy mỗi ngày.
- **Chờ kiểm duyệt (`TODO(buddhist-review)`):**
  - Người dịch từ chữ Hán.
  - Ngày trai thay thế trong tháng thiếu.
  - Cách tính tuần thất.
  - Hiệu đính toàn bộ Kinh văn (`meta.json: proofread=false`).

## 9. Khi làm việc với Claude Code
- Trước khi thêm tính năng mới, đối chiếu với **mục 2 (Nguyên tắc Phật pháp)** và **mục 3.3 (Ngoài phạm vi)**.
- Không tự soạn hay sửa Kinh văn, bài văn hồi hướng, sám hối. Nếu cần nội dung mẫu để dev/test, dùng
  chuỗi giả rõ ràng (`[PLACEHOLDER_SUTRA_TEXT]`) và ghi `TODO(buddhist-review)`.
- Nếu có điều chưa chắc về giáo lý/nghi thức, **hỏi người dùng** thay vì đoán.
- Ưu tiên đơn giản: nếu một tính năng làm giao diện rối hơn, hãy bỏ hoặc cất vào mục "Thêm".
- Khi cần nội dung Kinh, **đọc từ `assets/sutra/`** (đã hiệu đính), không trích lại từ PDF hay từ trí nhớ.

---

## 10. Bản Kinh nguồn

| Mục | Thông tin (theo trang bìa bản PDF) |
|---|---|
| Tên Kinh | Kinh Địa Tạng Bồ Tát Bổn Nguyện |
| Hán dịch | Tam Tạng Pháp Sư Pháp Đăng *(ghi đúng như bản in; các bản khác thường ghi Thật Xoa Nan Đà — `TODO(buddhist-review)` trước khi hiển thị)* |
| Việt dịch | HT Thích Trí Tịnh |
| Ấn tống | Đạo Tràng Liên Hoa — Lien Hoa Buddhist Temple, 5043 Excalibur Dr, San Antonio, TX 78218, USA · daotranglienhoa.com |
| Phiên bản | Version 5.0 · PL 2570 – DL 2026 · 159 trang PDF |
| Điều kiện | Ấn tống, **không được bán** |
| File gốc | `source/kinh_dia_tang.pdf` |

### Mục lục 13 phẩm
| Quyển | Phẩm | Tiêu đề |
|---|---|---|
| Thượng | 1 | Thần Thông Trên Cung Trời Đao Lợi |
| | 2 | Phân Thân Tập Hội |
| | 3 | Quán Chúng Sanh Nghiệp Duyên |
| | 4 | Nghiệp Cảm Của Chúng Sanh |
| Trung | 5 | Danh Hiệu Của Địa Ngục |
| | 6 | Như Lai Tán Thán |
| | 7 | Lợi Ích Cả Kẻ Còn Người Mất |
| | 8 | Các Vua Diêm La Khen Ngợi |
| | 9 | Xưng Danh Hiệu Chư Phật |
| Hạ | 10 | So Sánh Nhân Duyên Công Đức Của Sự Bố Thí |
| | 11 | Địa Thần Hộ Pháp |
| | 12 | Thấy Nghe Được Lợi Ích |
| | 13 | Dặn Dò Cứu Độ Nhơn Thiên |

### Đoạn Kinh làm căn cứ cho tính năng
| Tính năng | Căn cứ trong Kinh |
|---|---|
| Mục tiêu "một muôn biến" | Phẩm 6 đoạn 10, 11; Phẩm 12 đoạn 7, 9, 10 |
| Thời khoá 7 / 21 ngày | Phẩm 12 |
| Lịch Thập Trai | Phẩm 6 đoạn 12 — "Ngày thập trai tụng kinh được phước" |
| Hồi hướng 49 ngày, công đức cho người mất | Phẩm 7 — "Lợi ích cả kẻ còn người mất" |
| Xưng danh hiệu chư Phật | Phẩm 9 |
| Kệ hồi hướng, Phúng Kinh, Sám Thập Phương | Phần Kết Kinh |

---

*Nam Mô Đại Nguyện Địa Tạng Vương Bồ Tát. Nguyện đem công đức này, hướng về khắp tất cả.*
