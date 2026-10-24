# Địa Tạng Niệm

Ứng dụng tu tập theo Đức Địa Tạng Vương Bồ Tát: niệm danh hiệu, đọc và tụng Kinh Địa Tạng
(Việt dịch HT Thích Trí Tịnh, bản ấn tống Đạo Tràng Liên Hoa), hồi hướng cho người thân.
Miễn phí, không quảng cáo, dữ liệu chỉ lưu trên máy.

Hướng dẫn chi tiết cho người phát triển: [CLAUDE.md](CLAUDE.md).

## Chạy thử

```bash
flutter pub get
flutter run -d chrome        # xem nhanh trên trình duyệt
flutter run                  # trên điện thoại Android/iOS đã kết nối
flutter test
```

Flutter SDK đã cài tại `C:\src\flutter` — thêm `C:\src\flutter\bin` vào PATH.
Thư mục dự án có dấu tiếng Việt gây lỗi cho một số công cụ; xem mục 8 trong CLAUDE.md.

## Trước khi phát hành

- Xin phép Đạo Tràng Liên Hoa bằng văn bản (lưu ở `docs/permissions/`).
- Hiệu đính Kinh văn trong `assets/sutra/dia_tang/` đối chiếu bản in.
- Giải quyết các mục `TODO(buddhist-review)` cùng quý Thầy.
