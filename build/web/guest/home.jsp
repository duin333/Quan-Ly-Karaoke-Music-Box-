<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NICE KARAOKE - Trải nghiệm âm nhạc đỉnh cao</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        body { background-color: #f4f7f6; padding-bottom: 90px; font-family: 'Segoe UI', sans-serif; }
        .navbar-brand { font-weight: 700; letter-spacing: 1px; }
        .card-room { border: none; border-radius: 15px; transition: transform 0.3s; overflow: hidden; position: relative; }
        .card-room:hover { transform: translateY(-5px); }
        .room-status { position: absolute; top: 10px; right: 10px; padding: 5px 12px; border-radius: 20px; font-size: 0.8rem; font-weight: bold; z-index: 10; }
        .price-tag { color: #e74c3c; font-weight: bold; font-size: 1.1rem; }
        .item-out-of-stock { opacity: 0.7; filter: grayscale(0.8); }
        .stock-badge { font-size: 0.7rem; padding: 2px 8px; border-radius: 10px; }
        .menu-img { width: 75px; height: 75px; object-fit: cover; border-radius: 15px; }
        .item-hidden { filter: grayscale(1) !important; opacity: 0.5; pointer-events: none; background-color: #eeeeee !important; }
        #cart-bar { position: fixed; bottom: 0; left: 0; right: 0; background: #fff; box-shadow: 0 -2px 15px rgba(0,0,0,0.15); padding: 15px; z-index: 1050; display: none; cursor: pointer; border-radius: 20px 20px 0 0; }
        .cart-item { display: flex; justify-content: space-between; align-items: center; padding: 12px 0; border-bottom: 1px solid #eee; }
        .btn-support { position: fixed; bottom: 100px; right: 20px; z-index: 1000; width: 65px; height: 65px; border-radius: 50%; display: flex; flex-direction: column; align-items: center; justify-content: center; font-size: 0.65rem; font-weight: bold; box-shadow: 0 4px 15px rgba(0,0,0,0.3); transition: all 0.3s; border: 3px solid white; }
        .status-waiting { background: #f1c40f !important; color: #000 !important; animation: pulse-yellow 1s infinite; }
        .status-coming { background: #2ecc71 !important; color: #fff !important; }
        @keyframes pulse-yellow {
            0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(241, 196, 15, 0.7); }
            70% { transform: scale(1.1); box-shadow: 0 0 0 10px rgba(241, 196, 15, 0); }
            100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(241, 196, 15, 0); }
        }
    </style>
</head>
<body>

    <nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm sticky-top">
        <div class="container">
            <a class="navbar-brand" href="#"><i class="fas fa-microphone-alt me-2 text-warning"></i>NICE KARAOKE</a>
            <span class="text-white fw-bold"><i class="fas fa-couch me-1"></i> ${maPhong}</span>
        </div>
    </nav>

    <button id="btn-support-trigger" onclick="handleSupportClick()" class="btn btn-danger btn-support">
        <i class="fas fa-bell fa-lg mb-1"></i>
        <span>HỖ TRỢ</span>
    </button>

    <div class="container mt-4">
        <ul class="nav nav-tabs nav-justified mb-4 bg-white shadow-sm rounded-pill p-1 border-0" role="tablist">
            <li class="nav-item">
                <button class="nav-link rounded-pill fw-bold" data-bs-toggle="tab" data-bs-target="#rooms" type="button">Phòng</button>
            </li>
            <li class="nav-item">
                <%-- Tab Gọi Món active mặc định --%>
                <button class="nav-link active rounded-pill fw-bold" data-bs-toggle="tab" data-bs-target="#menu" type="button">Gọi Món</button>
            </li>
            <li class="nav-item">
                <button class="nav-link rounded-pill fw-bold" id="invoice-tab-btn" data-bs-toggle="tab" data-bs-target="#invoice" type="button">Nhật Ký & Hóa Đơn</button>
            </li>
        </ul>

        <div class="tab-content">
            <%-- Tab Phòng: bỏ show active --%>
            <div class="tab-pane fade" id="rooms" role="tabpanel">
                <div class="row g-3">
                    <c:forEach var="r" items="${listRooms}">
                        <div class="col-6 col-md-4 col-lg-3">
                            <div class="card card-room shadow-sm h-100">
                                <%-- Sửa: dùng eq thay == --%>
                                <span class="room-status ${r.trangThai eq 'Trống' ? 'bg-success' : 'bg-danger'} text-white">${r.trangThai}</span>
                                <img src="${pageContext.request.contextPath}/${r.loaiPhong.hinhAnh}" class="card-img-top" style="height: 140px; object-fit: cover;">
                                <div class="card-body p-2 text-center">
                                    <h6 class="fw-bold mb-1">${r.tenPhong}</h6>
                                    <div class="price-tag"><fmt:formatNumber value="${r.loaiPhong.giaTheoGio}" type="number"/>đ/h</div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <%-- Tab Gọi Món: thêm show active --%>
            <div class="tab-pane fade show active" id="menu" role="tabpanel">
                <div class="card border-0 shadow-sm p-3 rounded-4">
                    <div class="list-group list-group-flush">
                        <c:forEach var="dv" items="${listDV}">
                            <%-- Sửa: dùng eq và le thay == và <= --%>
                            <div class="list-group-item d-flex align-items-center px-0 py-3 ${dv.soLuongTon le 0 ? 'item-out-of-stock' : ''} ${dv.trangThaiHienThi eq 0 ? 'item-hidden' : ''}">
                                <img src="${pageContext.request.contextPath}/${dv.hinhAnh}" class="menu-img me-3 shadow-sm" onerror="this.src='${pageContext.request.contextPath}/assets/img/menu/default.jpg'">
                                <div class="flex-grow-1">
                                    <h6 class="mb-0 fw-bold">${dv.tenDV}</h6>
                                    <small class="text-danger fw-bold"><fmt:formatNumber value="${dv.gia}" type="number"/>đ</small>
                                    <%-- Sửa: dùng gt và le thay > và <= --%>
                                    <c:if test="${dv.soLuongTon gt 0 and dv.soLuongTon le 5}">
                                        <span class="stock-badge bg-warning text-dark ms-2">Sắp hết</span>
                                    </c:if>
                                </div>

                                <c:choose>
                                    <%-- Sửa: dùng eq thay == --%>
                                    <c:when test="${dv.trangThaiHienThi eq 0}">
                                        <button class="btn btn-secondary rounded-pill btn-sm px-2 shadow-sm" disabled>Tạm ngưng</button>
                                    </c:when>
                                    <%-- Sửa: dùng gt thay > --%>
                                    <c:when test="${dv.soLuongTon gt 0}">
                                        <button onclick="addToCart(${dv.maDV}, '${dv.tenDV}', ${dv.gia})" class="btn btn-primary rounded-pill btn-sm px-3 shadow-sm">+ Chọn</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-secondary rounded-pill btn-sm px-2 shadow-sm" disabled>Hết hàng</button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="invoice" role="tabpanel">
                <div id="invoice-tab-content">
                    <div class="text-center py-5">
                        <div class="spinner-border text-primary spinner-border-sm"></div>
                        <p class="mt-2 text-muted small">Đang cập nhật dữ liệu...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="cart-bar" onclick="showCartModal()">
        <div class="container d-flex justify-content-between align-items-center">
            <div id="cart-info" class="text-primary fw-bold"></div>
            <div class="btn btn-danger fw-bold rounded-pill px-4 shadow">XEM GIỎ HÀNG</div>
        </div>
    </div>

    <div class="modal fade" id="cartModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0" style="border-radius: 25px;">
                <div class="modal-header border-0 pb-0">
                    <h5 class="modal-title fw-bold text-primary"><i class="fas fa-shopping-basket me-2"></i>Món đã chọn</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div id="cart-list-details"></div>
                    <div class="d-flex justify-content-between mt-4 p-3 bg-light rounded-4">
                        <span class="fw-bold text-secondary">Tổng cộng:</span>
                        <span id="modal-total-price" class="fw-bold text-danger fs-5">0đ</span>
                    </div>
                </div>
                <div class="modal-footer border-0 pt-0">
                    <button type="button" onclick="submitOrder()" class="btn btn-danger w-100 fw-bold py-3 rounded-pill shadow">XÁC NHẬN GỌI MÓN</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        const currentMaPhong = '${maPhong}';
        let currentSupportStatus = 0;

        function formatMoney(num) { return (num || 0).toLocaleString('vi-VN') + 'đ'; }

        function updateCartBar() {
            let cart = JSON.parse(localStorage.getItem('karaokeCart')) || [];
            let bar = document.getElementById('cart-bar');
            if (cart.length > 0) {
                bar.style.display = 'block';
                let totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
                let totalPrice = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
                document.getElementById('cart-info').innerHTML = '<i class="fas fa-utensils me-2"></i>' + totalItems + ' món | ' + formatMoney(totalPrice);
                document.getElementById('modal-total-price').innerText = formatMoney(totalPrice);
                let html = "";
                cart.forEach(item => {
                    html += `<div class="cart-item">
                        <div><h6 class="mb-0 fw-bold">\${item.name}</h6><small class="text-muted">\${formatMoney(item.price)}</small></div>
                        <div class="cart-item-qty">
                            <button class="btn btn-sm btn-outline-secondary rounded-circle" onclick="changeQty(\${item.id},-1); event.stopPropagation();">-</button>
                            <b class="px-2">\${item.quantity}</b>
                            <button class="btn btn-sm btn-outline-secondary rounded-circle" onclick="changeQty(\${item.id},1); event.stopPropagation();">+</button>
                            <i class="fas fa-trash text-danger ms-3" onclick="removeItem(\${item.id}); event.stopPropagation();"></i>
                        </div></div>`;
                });
                document.getElementById('cart-list-details').innerHTML = html;
            } else {
                bar.style.display = 'none';
                let m = bootstrap.Modal.getInstance(document.getElementById('cartModal'));
                if (m) m.hide();
            }
        }

        function addToCart(id, name, price) {
            let cart = JSON.parse(localStorage.getItem('karaokeCart')) || [];
            let item = cart.find(i => i.id === id);
            if (item) item.quantity += 1; else cart.push({ id, name, price, quantity: 1 });
            localStorage.setItem('karaokeCart', JSON.stringify(cart));
            updateCartBar();
        }

        function changeQty(id, delta) {
            let cart = JSON.parse(localStorage.getItem('karaokeCart')) || [];
            let item = cart.find(i => i.id === id);
            if (item) { item.quantity += delta; if (item.quantity <= 0) { removeItem(id); return; } }
            localStorage.setItem('karaokeCart', JSON.stringify(cart));
            updateCartBar();
        }

        function removeItem(id) {
            let cart = JSON.parse(localStorage.getItem('karaokeCart')) || [];
            cart = cart.filter(i => i.id !== id);
            localStorage.setItem('karaokeCart', JSON.stringify(cart));
            updateCartBar();
        }

        function showCartModal() { new bootstrap.Modal(document.getElementById('cartModal')).show(); }

        function submitOrder() {
            let cart = JSON.parse(localStorage.getItem('karaokeCart')) || [];
            if (cart.length === 0) return;
            let rawData = cart.map(i => `\${i.id}-\${i.quantity}`).join(",") + ",";
            fetch('${pageContext.request.contextPath}/confirm-order', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maPhong=' + encodeURIComponent(currentMaPhong) + '&cartData=' + rawData
            }).then(res => res.text()).then(data => {
                if (data.trim() === "success") {
                    alert("✅ Đã gửi đơn hàng!");
                    localStorage.removeItem('karaokeCart');
                    updateCartBar();
                    document.getElementById('invoice-tab-btn').click();
                } else if (data.trim() === "invalid_room_status") {
                    alert("🚨 Phòng này chưa nhận phòng hoặc không ở trạng thái Đang hát!");
                } else {
                    alert("Lỗi: " + data);
                }
            }).catch(() => alert("🚨 Lỗi kết nối Server!"));
        }

        function loadProvisionalInvoice() {
            fetch('${pageContext.request.contextPath}/guest/api-get-invoice?maPhong=' + currentMaPhong)
            .then(res => res.text()).then(html => {
                document.getElementById('invoice-tab-content').innerHTML = html;
            });
        }
        document.getElementById('invoice-tab-btn').addEventListener('shown.bs.tab', loadProvisionalInvoice);

        function handleSupportClick() {
            if (currentSupportStatus === 0) {
                let note = prompt("Vấn đề bạn cần hỗ trợ: (Mic rè, đổi phòng...)");
                if (note === null) return;
                fetch('${pageContext.request.contextPath}/staff/api-call-support', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'maPhong=' + currentMaPhong + '&action=call&note=' + encodeURIComponent(note || '')
                }).then(res => res.text()).then(data => {
                    if (data.trim() === "success") {
                        alert("🔔 Đã gửi yêu cầu! Nhân viên sẽ đến ngay.");
                        checkSupportStatus();
                    } else {
                        alert("Gửi yêu cầu thất bại, thử lại nhé!");
                    }
                });
            } else if (currentSupportStatus === 1) {
                alert("Vui lòng đợi, nhân viên đang tiếp nhận yêu cầu.");
            } else {
                alert("Nhân viên đang trên đường đến phòng bạn!");
            }
        }

        function checkSupportStatus() {
            fetch('${pageContext.request.contextPath}/staff/api-pending-summary')
            .then(res => res.text())
            .then(data => {
                const btn = document.getElementById('btn-support-trigger');
                const label = btn.querySelector('span');
                if (!data || !data.includes("|")) return;
                let parts = data.split("|");
                let waiting = (parts[1] && parts[1].trim() !== "") ? parts[1].split(",").map(s => s.trim()) : [];
                let coming  = (parts[2] && parts[2].trim() !== "") ? parts[2].split(",").map(s => s.trim()) : [];

                if (coming.includes(currentMaPhong)) {
                    currentSupportStatus = 2;
                    btn.className = "btn btn-support status-coming";
                    label.innerText = "ĐANG ĐẾN";
                } else if (waiting.includes(currentMaPhong)) {
                    currentSupportStatus = 1;
                    btn.className = "btn btn-support status-waiting";
                    label.innerText = "ĐANG ĐỢI";
                } else {
                    currentSupportStatus = 0;
                    btn.className = "btn btn-danger btn-support";
                    label.innerText = "HỖ TRỢ";
                }
            }).catch(() => {});
        }

        window.onload = function() {
            updateCartBar();
            checkSupportStatus();
            setInterval(checkSupportStatus, 5000);
        };
    </script>
</body>
</html>