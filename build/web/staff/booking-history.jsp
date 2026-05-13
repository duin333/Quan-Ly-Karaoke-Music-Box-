<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lịch sử đặt phòng - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --dark: #1a1a1a; --primary-orange: #ff8c00; }
        body { background-color: #f4f7f6; padding-top: 100px; font-family: 'Segoe UI', Tahoma, sans-serif; }
        .card-history { border-radius: 25px; border: none; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.05); background: white; }
        .table thead { background-color: var(--dark); color: white; border: none; }
        .badge-room { font-size: 0.85rem; padding: 6px 12px; border-radius: 10px; background-color: #f8f9fa; color: var(--dark); font-weight: 600; border: 1px solid #dee2e6; }
        .status-paid { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .status-cancelled { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .status-expired { background-color: #fff3cd; color: #856404; border: 1px solid #ffeeba; }
        .table tbody tr:hover { background-color: #fff9f0; transition: 0.2s; }
        .btn-view { border-radius: 12px; font-weight: 600; transition: all 0.3s; }
    </style>
</head>
<body>

    <!-- 🛡️ NHÚNG NAVBAR: Đảm bảo file navbar.jsp đã dùng maCV để không bị trắng trang -->
    <jsp:include page="navbar.jsp">
        <jsp:param name="active" value="category" />
    </jsp:include>

    <div class="container-fluid px-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold text-dark mb-0">
                <i class="fas fa-history text-primary me-2"></i>LỊCH SỬ ĐẶT PHÒNG & THANH TOÁN
            </h4>
            <a href="${pageContext.request.contextPath}/staff/dashboard" class="btn btn-dark rounded-pill px-4 shadow-sm">
                <i class="fas fa-arrow-left me-2"></i>Quay lại sơ đồ
            </a>
        </div>

        <div class="card card-history shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0 text-center">
                        <thead>
                            <tr class="py-3">
                                <th class="ps-4">Mã Phiếu</th>
                                <th>Phòng</th>
                                <th>Khách hàng</th>
                                <th>Giờ Vào</th>
                                <th>Giờ Ra</th>
                                <th>Trạng thái</th>
                                <th>Ngày lập</th>
                                <th class="text-end pe-4">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:if test="${empty historyList}">
                                <tr><td colspan="8" class="text-center py-5 text-muted">Chưa có dữ liệu lịch sử nhen Duyên!</td></tr>
                            </c:if>
                            
                            <c:forEach var="h" items="${historyList}">
                                <tr>
                                    <td class="ps-4 fw-bold text-primary">#${h.maPhieu}</td>
                                    <td><span class="badge-room text-uppercase">${h.tenPhong}</span></td>
                                    <td class="text-start">
                                        <div class="fw-bold">${not empty h.tenKH ? h.tenKH : 'Khách vãng lai'}</div>
                                        <small class="text-muted">${not empty h.sdt ? h.sdt : '---'}</small>
                                    </td>
                                    
                                    <%-- 🛡️ CHỐNG SẬP: Cắt chuỗi an toàn --%>
                                    <td>
                                        <i class="far fa-clock text-muted me-1"></i>
                                        <b>${(not empty h.gioDat && h.gioDat.length() >= 16) ? h.gioDat.substring(11, 16) : '--:--'}</b>
                                    </td>
                                    <td>
                                        <i class="far fa-clock text-muted me-1"></i>
                                        <b>${(not empty h.gioTra && h.gioTra.length() >= 16) ? h.gioTra.substring(11, 16) : '--:--'}</b>
                                    </td>
                                    
                                    <td>
                                        <c:choose>
                                            <c:when test="${h.trangThai == 3}">
                                                <span class="badge rounded-pill status-paid px-3 py-2"><i class="fas fa-check-circle me-1"></i>Hoàn thành</span>
                                            </c:when>
                                            <c:when test="${h.trangThai == 4}">
                                                <span class="badge rounded-pill status-cancelled px-3 py-2"><i class="fas fa-times-circle me-1"></i>Đã hủy</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge rounded-pill status-expired px-3 py-2"><i class="fas fa-clock-rotate-left me-1"></i>Quá hạn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    
                                    <td class="text-muted small">
                                        <i class="far fa-calendar-alt me-1"></i>
                                        ${(not empty h.gioDat && h.gioDat.length() >= 10) ? h.gioDat.substring(0, 10) : '---'}
                                    </td>
                                    
                                    <td class="text-end pe-4">
                                        <!-- 🛡️ ĐƯỜNG DẪN CHI TIẾT (Phải khớp với booking-detail.jsp) -->
                                        <a href="booking-detail?id=${h.maPhieu}" class="btn btn-sm btn-primary btn-view px-3 shadow-sm">
                                            <i class="fas fa-eye me-1"></i> Chi tiết
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- MODAL NAVBAR (Dùng chung cho cả hệ thống) -->
    <div class="modal fade" id="inventoryModal" tabindex="-1"><div class="modal-dialog modal-lg modal-dialog-centered"><div class="modal-content shadow-lg"><div class="modal-header border-0 bg-dark text-white p-4"><h5 class="modal-title fw-bold">QUẢN LÝ THỰC ĐƠN</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div><div class="modal-body p-4" id="inventory-content-area"></div></div></div></div>
    <div class="modal fade" id="revenueModal" tabindex="-1"><div class="modal-dialog modal-sm modal-dialog-centered"><div class="modal-content border-0 shadow-lg"><div class="modal-header bg-info text-white border-0"><h5 class="modal-title fw-bold">DOANH THU</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div><div class="modal-body p-4"><input type="date" id="revenueDate" class="form-control mb-3" onchange="fetchRevenue()"><div id="revenue-result-container"></div></div></div></div></div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 🛡️ CHUÔNG BÁO ĐỒNG BỘ 3 PHẦN
        function pollNotifications() {
            fetch('${pageContext.request.contextPath}/staff/api-pending-summary')
            .then(res => res.text()).then(data => {
                if (data && data.includes("|")) {
                    let parts = data.split("|");
                    let total = (parts[0] ? parts[0].split(",").filter(x => x).length : 0) + 
                                (parts[1] ? parts[1].split(",").filter(x => x).length : 0) +
                                (parts[2] ? parts[2].split(",").filter(x => x).length : 0);
                    let badge = document.getElementById('total-count');
                    if(badge) { badge.innerText = total; badge.classList.toggle('d-none', total === 0); }
                }
            }).catch(e => console.log("Lỗi polling history: ", e));
        }

        // JS Modals (Gom chung một kiểu để không bị lỗi)
        function openInventoryModal() { bootstrap.Modal.getOrCreateInstance(document.getElementById('inventoryModal')).show(); fetch('${pageContext.request.contextPath}/staff/api-manage-inventory').then(res => res.text()).then(html => document.getElementById('inventory-content-area').innerHTML = html); }
        function openRevenueModal() { document.getElementById('revenueDate').value = new Date().toISOString().split('T')[0]; fetchRevenue(); bootstrap.Modal.getOrCreateInstance(document.getElementById('revenueModal')).show(); }
        function fetchRevenue() { fetch('${pageContext.request.contextPath}/staff/api-get-revenue?date=' + document.getElementById('revenueDate').value).then(res => res.text()).then(html => document.getElementById('revenue-result-container').innerHTML = html); }

        window.onload = function() { pollNotifications(); setInterval(pollNotifications, 5000); };
    </script>
</body>
</html>