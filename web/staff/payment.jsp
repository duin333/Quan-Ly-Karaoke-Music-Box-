<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quầy Thu Ngân - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --dark: #1a1a1a; --primary-orange: #ff8c00; }
        body { background-color: #f4f7f6; padding-top: 90px; font-family: 'Segoe UI', sans-serif; }
        .sidebar-payment { height: calc(100vh - 120px); overflow-y: auto; background: white; border-radius: 20px; box-shadow: 0 5px 15px rgba(0,0,0,0.05); }
        .active-bill-area { min-height: 80vh; padding: 10px 20px; }
        .room-item-btn { border-radius: 12px; margin-bottom: 8px; transition: 0.2s; border: 1px solid #eee; width: 100%; text-align: left; background: white; padding: 12px 15px; cursor: pointer; display: block; }
        .room-item-btn:hover { background-color: #fff3cd; border-color: var(--primary-orange); }
        .room-item-btn.active { background-color: var(--primary-orange) !important; color: white !important; border-color: var(--primary-orange); }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp"/>

    <div class="container-fluid">
        <div class="row">
            <!-- CỘT TRÁI: DANH SÁCH PHÒNG ĐANG HÁT -->
            <div class="col-md-3 p-3">
                <div class="sidebar-payment p-3">
                    <h6 class="fw-bold mb-3 text-uppercase text-muted small">
                        <i class="fas fa-play-circle me-2 text-danger"></i>Phòng đang hoạt động
                    </h6>
                    <div id="list-active-rooms">
                        <div class="text-center p-3 text-muted small">Đang tìm phòng...</div>
                    </div>
                </div>
            </div>

            <!-- CỘT PHẢI: CHI TIẾT HÓA ĐƠN -->
            <div class="col-md-9 active-bill-area">
                <div id="bill-detail-content">
                    <div class="text-center mt-5 opacity-50">
                        <i class="fas fa-receipt fa-5x mb-3 text-muted"></i>
                        <h5 class="text-muted">Chọn một phòng bên trái để tính tiền!</h5>
                    </div>
                </div>

                <!-- KHU VỰC NHẬN TIỀN -->
                <div id="cash-area" class="mt-4 d-none">
                    <div class="card border-0 shadow-sm p-4 rounded-4 bg-white">
                        <div class="row align-items-center g-3">
                            <div class="col-md-6">
                                <label class="fw-bold text-muted small text-uppercase mb-2">Tiền khách đưa (VNĐ)</label>
                                <input type="number" id="inputKhachDua" class="form-control form-control-lg fw-bold text-primary"
                                       placeholder="Ví dụ: 500000" oninput="calcChange()">
                            </div>
                            <div class="col-md-6 text-end">
                                <span class="text-muted small d-block text-uppercase mb-1">Tiền thừa trả khách</span>
                                <h2 class="fw-bold text-success" id="valTienThua">0đ</h2>
                            </div>
                        </div>
                        <button class="btn btn-warning btn-lg w-100 mt-4 fw-bold py-3 rounded-pill shadow-sm"
                                onclick="submitPayment()">
                            <i class="fas fa-check-double me-2"></i>HOÀN TẤT & IN HÓA ĐƠN
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Inventory (navbar cần) -->
    <div class="modal fade" id="inventoryModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title fw-bold"><i class="fas fa-boxes me-2 text-warning"></i>QUẢN LÝ THỰC ĐƠN</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4" id="inventory-content-area"></div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const tenNV = '${sessionScope.auth.tenNV}';

        // Hàm navbar cần
        function loadInventory() {
            fetch('${pageContext.request.contextPath}/staff/api-manage-inventory')
            .then(res => res.text()).then(html => {
                document.getElementById('inventory-content-area').innerHTML = html;
                bootstrap.Modal.getOrCreateInstance(document.getElementById('inventoryModal')).show();
            });
        }

        // 1. LOAD DANH SÁCH PHÒNG
        function loadActiveBookings() {
            fetch('${pageContext.request.contextPath}/staff/api-get-active-bookings')
            .then(res => res.text()).then(html => {
                let temp = document.createElement('div');
                temp.innerHTML = html;
                let items = temp.querySelectorAll('[onclick]');

                let container = document.getElementById('list-active-rooms');
                if (items.length === 0) {
                    container.innerHTML = '<div class="text-center text-muted small py-3">Không có phòng đang hoạt động</div>';
                    return;
                }

                let result = '';
                items.forEach(item => {
                    let onclickVal = item.getAttribute('onclick');
                    let match = onclickVal.match(/loadBillDetail\('([^']+)'\)/);
                    let maPhong = match ? match[1] : '';
                    let tenPhong = item.innerText || item.textContent;
                    result += `<button class="room-item-btn" id="btn-${maPhong}"
                        onclick="loadBillDetail('${maPhong}', this)">
                        <i class="fas fa-microphone-alt me-2 text-danger"></i>${tenPhong}
                    </button>`;
                });
                container.innerHTML = result;
            });
        }

        // 2. LOAD CHI TIẾT BILL
        function loadBillDetail(maPhong, element) {
            document.querySelectorAll('.room-item-btn').forEach(btn => btn.classList.remove('active'));
            if (element) element.classList.add('active');

            document.getElementById('bill-detail-content').innerHTML =
                '<div class="text-center py-5"><div class="spinner-border text-warning"></div><p class="mt-2 text-muted">Đang tải hóa đơn...</p></div>';

            fetch('${pageContext.request.contextPath}/staff/api-checkout-summary?maPhong=' + maPhong)
            .then(res => res.text())
            .then(html => {
                document.getElementById('bill-detail-content').innerHTML = html;
                document.getElementById('cash-area').classList.remove('d-none');
                document.getElementById('inputKhachDua').value = '';
                document.getElementById('valTienThua').innerText = '0đ';

                // Gắn sự kiện onchange cho input giờ ra
                let raInput = document.getElementById('inputGioRaFull');
                if (raInput) raInput.addEventListener('change', recalculateBill);

                recalculateBill();
            })
            .catch(() => {
                document.getElementById('bill-detail-content').innerHTML =
                    '<div class="alert alert-danger">Lỗi tải dữ liệu! Thử lại nhé.</div>';
            });
        }

        // 3. TÍNH TIỀN
        function recalculateBill() {
            const vaoEl = document.getElementById('valGioVaoISO');
            const raEl  = document.getElementById('inputGioRaFull');
            const giaEl = document.getElementById('hiddenGiaPhong');
            const dvEl  = document.getElementById('hiddenTienDV');
            if (!vaoEl || !raEl || !giaEl || !dvEl) return;

            let strVao = vaoEl.value.trim().replace(' ', 'T').split('.')[0];
            let strRa  = raEl.value.trim().replace(' ', 'T').split('.')[0];
            let dateIn  = new Date(strVao);
            let dateOut = new Date(strRa);
            let diffMs  = dateOut - dateIn;

            let resTienGio  = document.getElementById('resTienGio');
            let resTongCong = document.getElementById('resTongCong');
            if (!resTienGio || !resTongCong) return;

            if (isNaN(diffMs) || diffMs < 0) {
                resTongCong.innerText = 'Lỗi giờ!';
                return;
            }

            let diffMins = Math.floor(diffMs / 60000);
            let giaPhong = parseFloat(giaEl.value) || 0;
            let tienDV   = parseFloat(dvEl.value)  || 0;
            let tienGio  = Math.round(((diffMins / 60) * giaPhong) / 1000) * 1000;
            let tongCong = tienGio + tienDV;

            resTienGio.innerText  = tienGio.toLocaleString('vi-VN') + 'đ';
            resTongCong.innerText = tongCong.toLocaleString('vi-VN') + 'đ';
            calcChange();
        }

        // 4. TIỀN THỪA
        function calcChange() {
            let resTong = document.getElementById('resTongCong');
            if (!resTong || resTong.innerText === 'Lỗi giờ!') return;
            let total    = parseInt(resTong.innerText.replace(/\D/g, '')) || 0;
            let received = parseInt(document.getElementById('inputKhachDua').value) || 0;
            document.getElementById('valTienThua').innerText =
                (received >= total ? received - total : 0).toLocaleString('vi-VN') + 'đ';
        }

        // 5. XÁC NHẬN THANH TOÁN → redirect sang booking-detail để in
        function submitPayment() {
            let maPhieuEl  = document.getElementById('hiddenMaPhieu');
            let maPhongEl  = document.getElementById('hiddenMaPhong');
            let raEl       = document.getElementById('inputGioRaFull');
            let tongEl     = document.getElementById('resTongCong');

            if (!maPhieuEl || !maPhongEl || !raEl || !tongEl) {
                alert("Vui lòng chọn phòng và tải hóa đơn trước!"); return;
            }
            if (!raEl.value || tongEl.innerText === 'Lỗi giờ!') {
                alert("Giờ ra không hợp lệ!"); return;
            }
            if (!confirm("Xác nhận thanh toán phòng " + maPhongEl.value + "?")) return;

            let gioRa   = raEl.value.trim();
            let tongTien = tongEl.innerText;

            fetch('${pageContext.request.contextPath}/staff/confirm-payment', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maPhieu=' + maPhieuEl.value
                    + '&maPhong=' + maPhongEl.value
                    + '&gioRa='   + encodeURIComponent(gioRa)
                    + '&tongTien=' + encodeURIComponent(tongTien)
            })
            .then(res => res.text())
            .then(data => {
                if (data.trim() === 'success') {
                    // ✅ Redirect sang booking-detail với ?print=true để tự in
                    window.location.href = '${pageContext.request.contextPath}/staff/booking-detail?id='
                        + maPhieuEl.value + '&print=true';
                } else {
                    alert("Lỗi thanh toán: " + data);
                }
            })
            .catch(() => alert("Lỗi kết nối!"));
        }

        window.onload = function() {
            loadActiveBookings();
            setInterval(loadActiveBookings, 15000);

            // Tự động chọn phòng nếu URL có ?maPhong=xxx
            const urlParams = new URLSearchParams(window.location.search);
            const maPhongParam = urlParams.get('maPhong');
            if (maPhongParam) {
                setTimeout(() => {
                    let btn = document.getElementById('btn-' + maPhongParam);
                    if (btn) btn.click();
                }, 1000);
            }
        };
    </script>
</body>
</html>