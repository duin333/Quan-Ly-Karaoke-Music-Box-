<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sơ đồ trực tuyến - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --empty: #2ecc71; --occupied: #e74c3c; --dirty: #f1c40f; --dark: #1a1a1a; --primary-orange: #ff8c00; }
        body { background-color: #f4f7f6; padding-top: 90px; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        
        /* ROOM CARD CUSTOM */
        .room-card { border-radius: 20px; border: none; transition: all 0.3s ease; position: relative; color: white; min-height: 180px; cursor: pointer; display: flex; flex-direction: column; justify-content: center; align-items: center; overflow: visible; }
        .room-card:hover { transform: translateY(-8px); box-shadow: 0 12px 24px rgba(0,0,0,0.15); }
        .bg-empty { background: linear-gradient(135deg, #2ecc71, #27ae60); }
        .bg-occupied { background: linear-gradient(135deg, #e74c3c, #c0392b); }
        .bg-dirty { background: linear-gradient(135deg, #f1c40f, #f39c12); }
        
        /* BADGE & BUTTON */
        .order-badge { position: absolute; top: -10px; right: -10px; background: white; border-radius: 50%; width: 48px; height: 48px; display: flex; align-items: center; justify-content: center; border: 3px solid #ff4757; z-index: 10; box-shadow: 0 4px 8px rgba(0,0,0,0.2); }
        .serve-btn { position: absolute; bottom: 10px; right: 10px; background: rgba(255,255,255,0.25); border: 1px solid rgba(255,255,255,0.4); color: white; border-radius: 12px; padding: 6px 12px; transition: 0.2s; }
        .serve-btn:hover { background: white; color: var(--occupied); transform: scale(1.1); }

        /* TRẠNG THÁI HỖ TRỢ - CYBER ALERT STYLE */
        .support-shake { animation: shake-animation 0.6s infinite; border: 5px solid #fff200 !important; box-shadow: 0 0 25px rgba(255, 242, 0, 0.6) !important; }
        .support-coming { border: 5px solid #00aeef !important; box-shadow: 0 0 25px rgba(0, 174, 239, 0.7) !important; animation: pulse-blue 1.5s infinite; }

        @keyframes shake-animation { 
            0% { transform: rotate(0deg); } 10% { transform: rotate(3deg); } 
            20% { transform: rotate(-3deg); } 30% { transform: rotate(0deg); } 
        }
        @keyframes pulse-blue { 0% { opacity: 1; } 50% { opacity: 0.8; } 100% { opacity: 1; } }
        
        .modal-content { border-radius: 20px; border: none; }
        .modal-header { background: #1a1a1a; color: white; border-bottom: 3px solid var(--primary-orange); }
        #suggestBox { max-height: 250px; overflow-y: auto; border-radius: 10px; }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp">
        <jsp:param name="active" value="dashboard" />
    </jsp:include>

    <div class="container-fluid px-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold text-dark m-0"><i class="fas fa-layer-group me-2 text-primary"></i>SƠ ĐỒ PHÒNG TRỰC TUYẾN</h4>
            <div class="badge bg-dark p-2 rounded-pill px-3">
                <i class="fas fa-user-clock me-1 text-warning"></i> Chào, ${sessionScope.auth.tenNV}
            </div>
        </div>

        <div class="row g-4">
            <c:if test="${not empty listRooms}">
                <c:forEach var="p" items="${listRooms}">
                    <div class="col-6 col-md-4 col-lg-3 col-xl-2">
                        <div id="card-${p.maPhong}" class="card room-card p-4 shadow-sm ${p.trangThai == 'Trống' ? 'bg-empty' : (p.trangThai == 'Đang hát' ? 'bg-occupied' : 'bg-dirty')}" 
                             onclick="handleRoomClick('${p.maPhong}', '${p.trangThai}')">
                            
                            <div id="badge-${p.maPhong}" class="order-badge d-none">
                                <i class="fas fa-utensils text-danger fs-4"></i>
                            </div>

                            <i class="fas ${p.trangThai == 'Trống' ? 'fa-door-open' : (p.trangThai == 'Đang hát' ? 'fa-microphone-alt' : 'fa-broom')} fs-1 mb-3"></i>
                            <h5 class="fw-bold mb-0 text-uppercase">${p.tenPhong}</h5>
                            <small class="opacity-75 fw-bold" style="font-size: 0.75rem;">${p.trangThai}</small>
                            
                            <c:if test="${p.trangThai == 'Đang hát'}">
                                <button class="serve-btn shadow-sm" onclick="event.stopPropagation(); viewServeList('${p.maPhong}')">
                                    <i class="fas fa-concierge-bell"></i>
                                </button>
                            </c:if>
                        </div>
                    </div>
                </c:forEach>
            </c:if>
        </div>
    </div>

    <div class="modal fade" id="orderModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content shadow-lg">
                <div class="modal-header">
                    <h5 class="modal-title fw-bold">PHÒNG: <span id="modalRoomId" class="text-warning"></span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4" id="modal-content-area">
                    </div>
                <div class="modal-footer bg-light border-0">
                    <button class="btn btn-success w-100 py-2 fw-bold rounded-pill" onclick="goToCheckout()">
                        <i class="fas fa-cash-register me-2"></i>TIẾN HÀNH THANH TOÁN
                    </button>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="serveModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold">KHAY PHỤC VỤ: <span id="serveRoomId"></span></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4" id="serve-content-area"></div>
            </div>
        </div>
    </div>

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

    <div class="modal fade" id="revenueModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-sm modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-info text-white">
                    <h5 class="modal-title fw-bold">XEM DOANH THU</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4 text-center">
                    <input type="date" id="revenueDate" class="form-control mb-3" onchange="fetchRevenue()">
                    <div id="revenue-result-container"></div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Modal Đổi Phòng -->
    <div class="modal fade" id="switchRoomModal" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header bg-dark text-white">
                    <h5 class="modal-title fw-bold"><i class="fas fa-exchange-alt me-2 text-warning"></i>ĐỔI PHÒNG</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body p-4">
                    <p>Chuyển khách từ phòng <strong id="switchFromRoom" class="text-danger"></strong> sang:</p>
                    <select id="switchToRoom" class="form-select mb-3">
                        <c:forEach var="p" items="${listRooms}">
                            <c:if test="${p.trangThai == 'Trống'}">
                                <option value="${p.maPhong}">${p.tenPhong}</option>
                            </c:if>
                        </c:forEach>
                    </select>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-warning fw-bold rounded-pill px-4" onclick="confirmSwitchRoom()">
                        <i class="fas fa-exchange-alt me-2"></i>XÁC NHẬN ĐỔI PHÒNG
                    </button>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        let currentMaPhong = "";
        let isEditingMode = false;

        // 🛡️ 1. THÔNG BÁO & RUNG CHUÔNG (Chống sập & Khớp 3 mảng)
        function pollNotifications() {
            fetch('${pageContext.request.contextPath}/staff/api-pending-summary')
            .then(res => res.text())
            .then(data => {
                if (!data || !data.includes("|")) return;
                
                let parts = data.split("|");
                let orderRooms = (parts[0] && parts[0].trim() !== "") ? parts[0].split(",") : [];
                let supportWaiting = (parts[1] && parts[1].trim() !== "") ? parts[1].split(",") : [];
                let supportComing = (parts[2] && parts[2].trim() !== "") ? parts[2].split(",") : [];

                // Reset giao diện trước khi cập nhật mới
                document.querySelectorAll('.room-card').forEach(c => c.classList.remove('support-shake', 'support-coming'));
                document.querySelectorAll('.order-badge').forEach(b => b.classList.add('d-none'));

                // Hiển thị Badge cho phòng có món ăn chưa duyệt
                orderRooms.forEach(id => {
                    let b = document.getElementById('badge-' + id.trim());
                    if (b) b.classList.remove('d-none');
                });

                // Hiển thị Rung vàng cho phòng ĐANG ĐỢI
                supportWaiting.forEach(id => {
                    let c = document.getElementById('card-' + id.trim());
                    if (c) c.classList.add('support-shake');
                });

                // Hiển thị Viền xanh cho phòng ĐANG ĐẾN
                supportComing.forEach(id => {
                    let c = document.getElementById('card-' + id.trim());
                    if (c) c.classList.add('support-coming');
                });

                // Cập nhật tổng số trên Navbar
                let total = new Set([...orderRooms, ...supportWaiting, ...supportComing]).size;
                if (new Set([...orderRooms, ...supportWaiting, ...supportComing]).has("")) total--;
                
                let badgeNavbar = document.getElementById('total-count');
                if (badgeNavbar) {
                    badgeNavbar.innerText = total;
                    badgeNavbar.classList.toggle('d-none', total <= 0);
                }
            }).catch(e => console.error("Lỗi thông báo:", e));
        }

        // 🛡️ 2. XỬ LÝ CLICK PHÒNG
        function handleRoomClick(maPhong, trangThai) {
            if (trangThai === 'Trống') {
                if (confirm("Lập phiếu thuê mới cho phòng " + maPhong + "?")) {
                    window.location.href = '${pageContext.request.contextPath}/staff/booking?maPhong=' + maPhong;
                }
            } else if (trangThai === 'Đang hát') {
                isEditingMode = false;
                viewOrder(maPhong);
            } else if (trangThai === 'Chờ dọn') {
                if (confirm("Xác nhận phòng " + maPhong + " đã dọn xong?")) {
                    updateRoomStatus(maPhong, 'Trống');
                }
            }
        }

        // 🛡️ 3. XỬ LÝ ĐƠN HÀNG AJAX
        function viewOrder(maPhong) {
            currentMaPhong = maPhong;
            document.getElementById('modalRoomId').innerText = maPhong;
            document.getElementById('modal-content-area').innerHTML = '<div class="text-center py-4"><div class="spinner-border text-primary"></div></div>';
            
            fetch('${pageContext.request.contextPath}/staff/api-get-room-orders?maPhong=' + maPhong)
            .then(res => res.text()).then(html => {
                document.getElementById('modal-content-area').innerHTML = html;
                syncEditMode();
                bootstrap.Modal.getOrCreateInstance(document.getElementById('orderModal')).show();
            });
        }

        function refreshOrderContent() {
            fetch('${pageContext.request.contextPath}/staff/api-get-room-orders?maPhong=' + currentMaPhong)
            .then(res => res.text()).then(html => {
                document.getElementById('modal-content-area').innerHTML = html;
                syncEditMode();
            });
        }

        function toggleAdvancedTools() { isEditingMode = !isEditingMode; syncEditMode(); }

        function syncEditMode() {
            document.querySelectorAll('.advanced-edit, #advanced-panel').forEach(el => {
                isEditingMode ? el.classList.remove('d-none') : el.classList.add('d-none');
            });
            document.querySelectorAll('.static-qty').forEach(el => {
                isEditingMode ? el.classList.add('d-none') : el.classList.remove('d-none');
            });
        }

        function handleSupportAction(maPhong, action) {
            fetch('${pageContext.request.contextPath}/staff/api-call-support', {
                method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maPhong=' + maPhong + '&action=' + action
            }).then(() => { refreshOrderContent(); pollNotifications(); });
        }

        function approveAll(maPhong) {
            if (!confirm("Duyệt toàn bộ yêu cầu của phòng này?")) return;
            fetch('${pageContext.request.contextPath}/staff/process-order-all', {
                method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'maPhong=' + maPhong
            }).then(() => { 
                bootstrap.Modal.getInstance(document.getElementById('orderModal')).hide();
                pollNotifications(); 
            });
        }

        function deleteItem(maYC) {
            if (confirm("Bạn muốn xóa món này?")) {
                fetch('${pageContext.request.contextPath}/staff/api-order-update', {
                    method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=delete-item&maYC=' + maYC
                }).then(() => refreshOrderContent());
            }
        }

        function changeQty(maYC, newQty) {
            if (newQty < 1) return deleteItem(maYC);
            fetch('${pageContext.request.contextPath}/staff/api-order-update', {
                method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=update-qty&maYC=' + maYC + '&qty=' + newQty
            }).then(() => refreshOrderContent());
        }

        function searchAndSuggest(maPhong) {
            let txt = document.getElementById('searchFood').value;
            if (txt.length < 1) { document.getElementById('suggestBox').style.display = 'none'; return; }
            fetch('${pageContext.request.contextPath}/staff/api-search-services', {
                method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'txt=' + encodeURIComponent(txt) + '&maPhong=' + maPhong
            }).then(res => res.text()).then(html => {
                let box = document.getElementById('suggestBox');
                box.innerHTML = html; box.style.display = 'block';
            });
        }

        function addItemToOrder(maPhong, maDV) {
            fetch('${pageContext.request.contextPath}/staff/api-order-update', {
                method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=add-item&maPhong=' + maPhong + '&maDV=' + maDV
            }).then(() => {
                document.getElementById('searchFood').value = '';
                refreshOrderContent();
            });
        }

        // 🛡️ 4. THANH TOÁN & DOANH THU
        function goToCheckout() {
            window.location.href = '${pageContext.request.contextPath}/staff/payment.jsp?maPhong=' + currentMaPhong;
        }

        function fetchRevenue() {
            let date = document.getElementById('revenueDate').value;
            // Hiện hiệu ứng chờ để nhân viên không tưởng bị lag
            document.getElementById('revenue-result-container').innerHTML = '<div class="spinner-border spinner-border-sm text-info"></div> Đang tính...';

            fetch('${pageContext.request.contextPath}/staff/api-get-revenue?date=' + date)
            .then(res => res.text())
            .then(html => {
                document.getElementById('revenue-result-container').innerHTML = html;
            }).catch(err => {
                document.getElementById('revenue-result-container').innerHTML = '<span class="text-danger">Lỗi kết nối!</span>';
            });
        }

        function updateRoomStatus(maPhong, status) {
            fetch('${pageContext.request.contextPath}/staff/update-room-status-api?maPhong=' + maPhong + '&status=' + status)
            .then(() => location.reload());
        }

        function viewServeList(maPhong) {
            currentMaPhong = maPhong;
            document.getElementById('serveRoomId').innerText = maPhong;
            fetch('${pageContext.request.contextPath}/staff/api-get-room-serve-list?maPhong=' + maPhong)
            .then(res => res.text()).then(html => {
                document.getElementById('serve-content-area').innerHTML = html;
                bootstrap.Modal.getOrCreateInstance(document.getElementById('serveModal')).show();
            });
        }

        function confirmServed(maYC) {
            fetch('${pageContext.request.contextPath}/staff/api-order-update', {
                method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=confirm-served&maYC=' + maYC
            }).then(() => viewServeList(currentMaPhong));
        }

        // Khởi chạy vòng lặp polling
        window.onload = function() {
            pollNotifications();
            setInterval(pollNotifications, 5000);
        };
        
        function openSwitchRoom(maPhong) {
            currentMaPhong = maPhong;
            document.getElementById('switchFromRoom').innerText = maPhong;
            bootstrap.Modal.getOrCreateInstance(document.getElementById('switchRoomModal')).show();
        }

        function confirmSwitchRoom() {
            let newRoom = document.getElementById('switchToRoom').value;
            if (!newRoom) { alert("Không có phòng trống!"); return; }

            fetch('${pageContext.request.contextPath}/staff/api-switch-room', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'old=' + currentMaPhong + '&new=' + newRoom
            })
            .then(res => res.text())
            .then(result => {
                if (result === 'success') {
                    bootstrap.Modal.getInstance(document.getElementById('switchRoomModal')).hide();
                    bootstrap.Modal.getInstance(document.getElementById('orderModal')).hide();
                    location.reload();
                } else {
                    alert("Đổi phòng thất bại! Phòng đó có thể đã có khách.");
                }
            });
        }
    </script>
</body>
</html>