<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt phòng trước - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --dark: #1a1a1a; --primary-orange: #ff8c00; }
        body { background-color: #f4f7f6; padding-top: 90px; font-family: 'Segoe UI', sans-serif; }
        .booking-card { border-radius: 25px; border: none; box-shadow: 0 15px 35px rgba(0,0,0,0.1); background: white; overflow: hidden; }
        .card-header-custom { background: var(--dark); color: white; padding: 30px; border-bottom: 5px solid var(--primary-orange); }
        .form-label { font-weight: 600; color: #495057; margin-bottom: 8px; }
        .form-control, .form-select { border-radius: 12px; padding: 12px 15px; border: 1px solid #dee2e6; transition: 0.3s; }
        .form-control:focus, .form-select:focus { border-color: var(--primary-orange); box-shadow: 0 0 0 0.25rem rgba(255,140,0,0.15); }
        .input-group-text { background-color: #f8f9fa; }
        .btn-submit { background: linear-gradient(135deg, var(--primary-orange), #e67e22); color: white; border-radius: 15px; font-weight: 700; padding: 15px; width: 100%; border: none; text-transform: uppercase; letter-spacing: 1px; transition: 0.3s; }
        .btn-submit:hover { transform: translateY(-3px); box-shadow: 0 8px 20px rgba(230,126,34,0.4); color: white; }

        /* Bảng danh sách đặt phòng */
        .table-booking thead { background: var(--dark); color: white; }
        .table-booking tbody tr { cursor: pointer; transition: 0.2s; }
        .table-booking tbody tr:hover { background: #fff3e0; }
        .table-booking tbody tr.selected { background: #fff3e0; border-left: 4px solid var(--primary-orange); }
        .badge-status { font-size: 0.8rem; padding: 6px 12px; border-radius: 20px; }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp"/>

    <div class="container-fluid px-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold text-dark m-0">
                <i class="fas fa-calendar-check me-2 text-primary"></i>QUẢN LÝ ĐẶT PHÒNG TRƯỚC
            </h4>
        </div>

        <div class="row g-4">
            <!-- CỘT TRÁI: FORM TẠO PHIẾU -->
            <div class="col-lg-5">
                <div class="card booking-card">
                    <div class="card-header-custom text-center">
                        <h5 class="fw-bold mb-1"><i class="fas fa-file-invoice me-2 text-warning"></i>TẠO PHIẾU ĐẶT MỚI</h5>
                        <p class="mb-0 opacity-75 small">Khách gọi điện hoặc đặt qua Fanpage</p>
                    </div>
                    <div class="card-body p-4">

                        <!-- BƯỚC 1: TÌM KHÁCH HÀNG -->
                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-phone me-1 text-primary"></i>Số điện thoại khách</label>
                            <div class="input-group">
                                <input type="tel" id="inputSdt" class="form-control" placeholder="0905xxxxxx" maxlength="10">
                                <button class="btn btn-primary px-3" onclick="lookupCustomer()">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                            <div id="customerInfo" class="mt-2"></div>
                        </div>

                        <!-- BƯỚC 2: TÊN KHÁCH (nếu khách mới) -->
                        <div class="mb-4" id="newCustomerSection" style="display:none;">
                            <label class="form-label"><i class="fas fa-user me-1 text-success"></i>Tên khách hàng mới</label>
                            <div class="input-group">
                                <input type="text" id="inputTenKH" class="form-control" placeholder="Nguyễn Văn A">
                                <button class="btn btn-success px-3" onclick="addNewCustomer()">
                                    <i class="fas fa-plus"></i> Thêm
                                </button>
                            </div>
                        </div>

                        <!-- BƯỚC 3: CHỌN PHÒNG VÀ GIỜ -->
                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-door-open me-1 text-warning"></i>Chọn phòng trống</label>
                            <select id="selectPhong" class="form-select">
                                <option value="">-- Chọn phòng --</option>
                                <c:forEach var="p" items="${availableRooms}">
                                    <option value="${p.maPhong}">
                                        ${p.tenPhong} - ${p.loaiPhong.tenLoai} (<fmt:formatNumber value="${p.loaiPhong.giaTheoGio}" type="number"/>đ/h)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="mb-4">
                            <label class="form-label"><i class="fas fa-calendar-alt me-1 text-danger"></i>Thời gian khách đến</label>
                            <input type="datetime-local" id="inputGioDat" class="form-control">
                        </div>

                        <!-- NÚT TẠO PHIẾU -->
                        <button class="btn btn-submit" onclick="createBooking()">
                            <i class="fas fa-file-invoice me-2"></i>XÁC NHẬN LƯU PHIẾU
                        </button>
                        <p class="text-muted small text-center mt-2">
                            <i class="fas fa-info-circle me-1"></i>Phiếu tự hủy nếu khách không đến sau 30 phút
                        </p>
                    </div>
                </div>
            </div>

            <!-- CỘT PHẢI: DANH SÁCH PHIẾU ĐẶT HÔM NAY -->
            <div class="col-lg-7">
                <div class="card border-0 shadow-sm rounded-4">
                    <div class="card-header bg-dark text-white rounded-top-4 d-flex justify-content-between align-items-center">
                        <h6 class="fw-bold mb-0"><i class="fas fa-list me-2 text-warning"></i>PHIẾU ĐẶT HÔM NAY</h6>
                        <div class="d-flex gap-2 align-items-center">
                            <input type="date" id="filterDate" class="form-control form-control-sm" style="width:150px;" onchange="loadBookings()">
                            <button class="btn btn-warning btn-sm fw-bold rounded-pill px-3" onclick="loadBookings()">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                        </div>
                    </div>
                    <div class="card-body p-0">
                        <div class="table-responsive">
                            <table class="table table-booking align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th class="ps-3">#</th>
                                        <th>Khách hàng</th>
                                        <th>SĐT</th>
                                        <th>Phòng</th>
                                        <th>Giờ đặt</th>
                                    </tr>
                                </thead>
                                <tbody id="bookingTableBody">
                                    <tr><td colspan="5" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- PANEL HÀNH ĐỘNG KHI CHỌN PHIẾU -->
                <div id="actionPanel" class="card border-0 shadow-sm rounded-4 mt-3" style="display:none;">
                    <div class="card-body p-4">
                        <h6 class="fw-bold mb-3">
                            <i class="fas fa-tasks me-2 text-primary"></i>
                            Phiếu #<span id="selectedMaPhieu" class="text-primary"></span> — Phòng <span id="selectedMaPhong" class="text-danger"></span>
                        </h6>
                        <div class="d-flex gap-2">
                            <button class="btn btn-success fw-bold rounded-pill px-4 flex-grow-1" onclick="checkIn()">
                                <i class="fas fa-sign-in-alt me-2"></i>NHẬN PHÒNG (CHECK-IN)
                            </button>
                            <button class="btn btn-outline-danger fw-bold rounded-pill px-4" onclick="cancelBooking()">
                                <i class="fas fa-times me-2"></i>HỦY
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let selectedMaKH = null;
        let selectedMaPhieu = null;
        let selectedMaPhong = null;

        // Khởi tạo giờ mặc định và load danh sách
        window.onload = function() {
            const now = new Date();
            now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
            document.getElementById('inputGioDat').value = now.toISOString().slice(0, 16);
            document.getElementById('inputGioDat').min = now.toISOString().slice(0, 16);
            document.getElementById('filterDate').value = now.toISOString().split('T')[0];
            loadBookings();
        };

        // 1. TÌM KIẾM KHÁCH HÀNG THEO SĐT
        function lookupCustomer() {
            let sdt = document.getElementById('inputSdt').value.trim();
            if (sdt.length < 10) { alert("Vui lòng nhập đủ 10 số điện thoại!"); return; }

            fetch('${pageContext.request.contextPath}/staff/api-customer?sdt=' + sdt)
            .then(res => res.json())
            .then(data => {
                if (data) {
                    selectedMaKH = data.maKH;
                    document.getElementById('customerInfo').innerHTML =
                        `<div class="alert alert-success py-2 mb-0 rounded-3">
                            <i class="fas fa-check-circle me-2"></i>
                            <b>Khách cũ:</b> ${data.tenKH} — SĐT: ${data.sdt}
                        </div>`;
                    document.getElementById('newCustomerSection').style.display = 'none';
                } else {
                    selectedMaKH = null;
                    document.getElementById('customerInfo').innerHTML =
                        `<div class="alert alert-warning py-2 mb-0 rounded-3">
                            <i class="fas fa-user-plus me-2"></i>Số mới, vui lòng nhập tên khách!
                        </div>`;
                    document.getElementById('newCustomerSection').style.display = 'block';
                }
            })
            .catch(() => {
                document.getElementById('customerInfo').innerHTML =
                    `<div class="alert alert-danger py-2 mb-0">Lỗi kết nối!</div>`;
            });
        }

        // 2. THÊM KHÁCH MỚI
        function addNewCustomer() {
            let tenKH = document.getElementById('inputTenKH').value.trim();
            let sdt = document.getElementById('inputSdt').value.trim();
            if (!tenKH) { alert("Vui lòng nhập tên khách hàng!"); return; }

            fetch('${pageContext.request.contextPath}/staff/api-add-customer', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'tenKH=' + encodeURIComponent(tenKH) + '&sdt=' + sdt
            })
            .then(res => res.json())
            .then(data => {
                if (data && data.maKH) {
                    selectedMaKH = data.maKH;
                    document.getElementById('customerInfo').innerHTML =
                        `<div class="alert alert-success py-2 mb-0 rounded-3">
                            <i class="fas fa-check-circle me-2"></i>
                            <b>Đã thêm:</b> ${data.tenKH} — MaKH: ${data.maKH}
                        </div>`;
                    document.getElementById('newCustomerSection').style.display = 'none';
                } else {
                    alert("Thêm khách thất bại! SĐT có thể đã tồn tại.");
                }
            });
        }

        // 3. TẠO PHIẾU ĐẶT
        function createBooking() {
            if (!selectedMaKH) { alert("Vui lòng tìm hoặc thêm khách hàng trước!"); return; }
            let maPhong = document.getElementById('selectPhong').value;
            let gioDat = document.getElementById('inputGioDat').value;
            if (!maPhong) { alert("Vui lòng chọn phòng!"); return; }
            if (!gioDat) { alert("Vui lòng chọn thời gian!"); return; }

            fetch('${pageContext.request.contextPath}/staff/api-create-booking', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maKH=' + selectedMaKH + '&maPhong=' + maPhong + '&gioDat=' + encodeURIComponent(gioDat)
            })
            .then(res => res.text())
            .then(result => {
                if (result.trim() === 'success') {
                    alert("✅ Đã tạo phiếu đặt thành công!");
                    // Reset form
                    selectedMaKH = null;
                    document.getElementById('inputSdt').value = '';
                    document.getElementById('inputTenKH').value = '';
                    document.getElementById('customerInfo').innerHTML = '';
                    document.getElementById('newCustomerSection').style.display = 'none';
                    document.getElementById('selectPhong').value = '';
                    loadBookings();
                } else {
                    alert("Tạo phiếu thất bại! Vui lòng thử lại.");
                }
            });
        }

        // 4. LOAD DANH SÁCH PHIẾU ĐẶT
        function loadBookings() {
            let date = document.getElementById('filterDate').value;
            fetch('${pageContext.request.contextPath}/staff/api-get-waiting-bookings?date=' + date)
            .then(res => res.text())
            .then(html => {
                document.getElementById('bookingTableBody').innerHTML = html;
                document.getElementById('actionPanel').style.display = 'none';
            });
        }

        // 5. CHỌN PHIẾU ĐẶT
        function selectBooking(row, maPhieu, maPhong) {
            document.querySelectorAll('.table-booking tbody tr').forEach(r => r.classList.remove('selected'));
            row.classList.add('selected');
            selectedMaPhieu = maPhieu;
            selectedMaPhong = maPhong;
            document.getElementById('selectedMaPhieu').innerText = maPhieu;
            document.getElementById('selectedMaPhong').innerText = maPhong;
            document.getElementById('actionPanel').style.display = 'block';
            document.getElementById('actionPanel').scrollIntoView({ behavior: 'smooth' });
        }

        // 6. CHECK-IN
        function checkIn() {
            if (!selectedMaPhieu) return;
            if (!confirm("Xác nhận nhận phòng " + selectedMaPhong + " cho phiếu #" + selectedMaPhieu + "?")) return;

            fetch('${pageContext.request.contextPath}/staff/api-checkin', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maPhieu=' + selectedMaPhieu + '&maPhong=' + selectedMaPhong
            })
            .then(res => res.text())
            .then(result => {
                if (result.trim() === 'success') {
                    alert("✅ Check-in thành công! Phòng " + selectedMaPhong + " đang hát.");
                    selectedMaPhieu = null;
                    selectedMaPhong = null;
                    document.getElementById('actionPanel').style.display = 'none';
                    loadBookings();
                } else {
                    alert("Check-in thất bại! Phòng có thể đã có khách.");
                }
            });
        }

        // 7. HỦY PHIẾU
        function cancelBooking() {
            if (!selectedMaPhieu) return;
            if (!confirm("Hủy phiếu #" + selectedMaPhieu + "?")) return;

            fetch('${pageContext.request.contextPath}/staff/api-cancel', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maPhieu=' + selectedMaPhieu
            })
            .then(res => res.text())
            .then(result => {
                if (result.trim() === 'success') {
                    alert("Đã hủy phiếu #" + selectedMaPhieu);
                    selectedMaPhieu = null;
                    selectedMaPhong = null;
                    document.getElementById('actionPanel').style.display = 'none';
                    loadBookings();
                } else {
                    alert("Hủy thất bại!");
                }
            });
        }

        // Tự động reload danh sách mỗi 30 giây
        setInterval(loadBookings, 30000);
    </script>
</body>
</html>