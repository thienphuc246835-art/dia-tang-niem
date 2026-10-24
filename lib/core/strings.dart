/// User-facing Vietnamese strings, kept out of widgets (CLAUDE.md section 7).
// TODO: migrate to flutter gen-l10n (.arb) when a second language is added.
abstract final class S {
  static const appName = 'Địa Tạng Niệm';

  // Tabs
  static const tabChant = 'Niệm';
  static const tabSutra = 'Kinh';
  static const tabDedication = 'Hồi hướng';
  static const tabMore = 'Thêm';

  // Chant
  static const unitBien = 'biến';
  static const today = 'Hôm nay';
  static const lifetime = 'Tích lũy';
  static const round = 'Vòng';
  static const dailyGoal = 'Mục tiêu hôm nay';
  static const undo = 'Hoàn tác';
  static const reset = 'Đặt lại';
  static const finish = 'Hoàn tất & hồi hướng';
  static const resetConfirmTitle = 'Đặt lại số đếm?';
  static const resetConfirmBody =
      'Số biến của thời niệm này sẽ về 0. Tổng hôm nay và tổng tích lũy vẫn được giữ.';
  static const cancel = 'Thôi';
  static const confirm = 'Đồng ý';
  static const chooseMantra = 'Chọn danh hiệu';
  static const chantButtonHint = 'Chạm để niệm một biến';
  // Wording as requested by the user. Khai Kinh (khai_kinh.json) has the same
  // vow in the other order: "Địa ngục vị không, thệ bất thành Phật, Chúng sinh
  // độ tận phương chứng Bồ Đề".
  // TODO(buddhist-review): confirm wording/order and the attribution line.
  static const greatVow =
      'Chúng sinh độ tận, phương chứng Bồ Đề;\nĐịa ngục vị không, thệ bất thành Phật.';
  static const roundComplete = 'Tròn một chuỗi 108 biến. Tùy hỷ công đức.';
  static const goalReached = 'Đã đủ mục tiêu hôm nay. Tùy hỷ công đức.';
  static const nothingToFinish = 'Thời niệm này chưa có biến nào.';

  // Plans
  static const plans = 'Thời khoá nhiều ngày';
  static const planNew = 'Lập thời khoá mới';
  static const planTarget = 'Số biến';
  static const planDays = 'Số ngày';
  static const planPersons = 'Hồi hướng cho';
  static const planStart = 'Bắt đầu thời khoá';
  static const planActive = 'Thời khoá đang hành trì';
  static const planEnd = 'Kết thúc thời khoá';
  static const planNone = 'Chưa có thời khoá nào.';
  static const planDone = 'Đã viên mãn';

  // Sutra
  static const continueReading = 'Tiếp tục đọc';
  static const ritualTitle = 'Tụng theo nghi thức';
  static const ritualHint =
      'Mỗi thời tụng gồm Khai Kinh, một quyển và Kết Kinh. Ứng dụng nhớ quyển đã tụng.';
  static const ritualFull = 'Trọn bộ';
  static const ritualNext = 'Lần trước đã tụng';
  static const tableOfContents = 'Mục lục';
  static const search = 'Tìm trong Kinh';
  static const searchHint = 'Nhập chữ cần tìm';
  static const searchEmpty = 'Không tìm thấy.';
  static const bookmarks = 'Đánh dấu';
  static const bookmarksEmpty = 'Chưa có đánh dấu nào.';
  static const bookmarkAdded = 'Đã đánh dấu đoạn này.';
  static const bookmarkRemoved = 'Đã bỏ đánh dấu.';
  static const readerSettings = 'Hiển thị';
  static const fontSize = 'Cỡ chữ';
  static const lineHeight = 'Giãn dòng';
  static const readerAuto = 'Tự động';
  static const readerLight = 'Sáng';
  static const readerSepia = 'Giấy';
  static const readerDark = 'Tối';
  static const finishRecitation = 'Hoàn tất thời tụng';
  static const chapter = 'Phẩm';
  static const timesSuffix = 'lần';
  static const prostrationSuffix = 'lạy';
  static const sutraSource = 'Nguồn Kinh';

  // Dedication
  static const dedicate = 'Hồi hướng';
  static const dedicateLater = 'Để sau';
  static const dedicateFor = 'Hồi hướng cho';
  static const dharmaRealm = 'Pháp giới chúng sanh';
  static const dedicationDone = 'Đã hồi hướng. Tùy hỷ công đức.';
  static const persons = 'Người thân';
  static const personAdd = 'Thêm người thân';
  static const personEdit = 'Sửa thông tin';
  static const personName = 'Họ tên';
  static const personDharmaName = 'Pháp danh (nếu có)';
  static const personRelation = 'Quan hệ';
  static const personNote = 'Ghi chú';
  static const alive = 'Còn sống (cầu an)';
  static const deceased = 'Đã khuất (cầu siêu)';
  static const groupAlive = 'Cầu an';
  static const groupDeceased = 'Cầu siêu';
  static const deathDate = 'Ngày mất (dương lịch)';
  static const chooseDate = 'Chọn ngày';
  static const save = 'Lưu';
  static const delete = 'Xoá';
  static const deletePersonTitle = 'Xoá người này?';
  static const deletePersonBody =
      'Thông tin và tên trong nhật ký hồi hướng sẽ bị xoá hoàn toàn khỏi máy.';
  static const personsEmpty =
      'Chưa có ai trong danh sách. Hãy thêm người thân để hồi hướng.';
  static const dedicationLog = 'Nhật ký hồi hướng';
  static const dedicationLogEmpty = 'Chưa có lần hồi hướng nào.';
  static const removedPerson = '(đã xoá)';
  static const memorial49 = 'Hồi hướng 49 ngày';
  static const memorialRule = 'Cách tính: ngày mất là ngày thứ nhất.';
  static const memorialWeek = 'Tuần thứ';
  static const memorialFinal = 'Chung thất (ngày 49)';
  static const inMemorialPeriod = 'Đang trong 49 ngày';

  // More
  static const calendar = 'Lịch Phật giáo';
  static const journal = 'Nhật ký tu tập';
  static const settings = 'Cài đặt';
  static const about = 'Giới thiệu & Nguồn Kinh';

  // Calendar
  static const thapTrai = 'Ngày Thập Trai';
  static const viaDiaTang = 'Vía Đức Địa Tạng Vương Bồ Tát';
  static const viaNote = 'Ngày vía theo truyền thống, không ghi trong Kinh.';
  static const ram = 'Rằm';
  static const mungMot = 'Mùng một';
  static const anniversary = 'Ngày giỗ';
  static const leap = 'nhuận';
  static const shortMonthNote =
      'Tháng thiếu không có ngày 30. Cách tính ngày trai thay thế xin thỉnh ý quý Thầy.';
  static const weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  // Journal
  static const last7Days = '7 ngày qua';
  static const streak = 'Ngày liên tục';
  static const recitations = 'Thời tụng Kinh';
  static const recitationsEmpty = 'Chưa có thời tụng nào.';
  static const last30Days = '30 ngày qua';

  // Settings
  static const theme = 'Giao diện';
  static const themeSystem = 'Theo máy';
  static const themeLight = 'Sáng';
  static const themeDark = 'Tối';
  static const haptic = 'Rung nhẹ khi niệm';
  static const keepAwake = 'Giữ màn hình sáng khi niệm';
  static const tapAnywhere = 'Chạm bất kỳ đâu để đếm';
  static const tapAnywhereHint = 'Hữu ích khi nhắm mắt niệm.';
  static const dailyGoalSetting = 'Mục tiêu mỗi ngày';
  static const noGoal = 'Không đặt';
  static const defaultMantra = 'Danh hiệu mặc định';
  static const clearData = 'Xoá toàn bộ dữ liệu';
  static const clearDataBody =
      'Mọi số đếm, người thân, nhật ký và đánh dấu sẽ bị xoá vĩnh viễn khỏi máy này.';
  static const privacyNote =
      'Mọi dữ liệu chỉ lưu trên máy này. Ứng dụng không gửi dữ liệu đi đâu.';

  static const freeDistribution =
      'Ứng dụng miễn phí, không quảng cáo — như Kinh ấn tống.';
}
