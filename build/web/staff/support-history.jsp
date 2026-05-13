<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Nhật ký hỗ trợ - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --dark: #1a1a1a; --primary-orange: #ff8c00; --success: #2ecc71; }
        body { background-color: #f4f7f6; padding-top: 100px; font-family: 'Segoe UI', Tahoma, sans-serif; }
        
        .card-history { border-radius: 20px; border: none; overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.08); background: white; }
        .table thead { background: var(--dark); color: white; }
        
        /* Hiệu ứng nhấp nháy cho ca đang đợi */
        .pulse-red { animation: pulse-animation 1.5s infinite; background-color: #dc3545 !important; }
        @keyframes pulse-animation {
            0% { box-shadow: 0 0 0 0px rgba(220, 53, 69, 0.7); }
            100% { box-shadow: 0 0 0 12px rgba(220, 53, 69, 0); }
        }
        
        .badge-status { font-size: 0.75rem; font-weight: 700; letter-spacing: 0.5px; }
    </style>
</head>
<body>

    <jsp:include page="navbar.jsp">
        <jsp:param name="active" value="category" />
    </jsp:include>

    <div class="container-fluid px-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="fw-bold text-dark mb-0">
                <i class="fas fa-headset text-danger me-2"></i>NHẬT KÝ HỖ TRỢ PHÒNG HÁT
            </h4>
            <a href="${pageContext.request.contextPath}/staff/dashboard" class="btn btn-dark rounded-pill px-4 shadow-sm">
                <i class="fas fa-arrow-left me-2"></i>Quay lại sơ đồ
            </a>
        </div>

        <div class="card card-history shadow-sm">
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="text-center">
                            <tr class="py-3">
                                <th class="ps-4">ID</th>
                                <th>Phòng</th>
                                <th>Nội dung sự cố</th>
                                <th>Thời gian gọi</th>
                                <th>Nhân viên tiếp nhận</th>
                                <th>Hoàn tất lúc</th>
                                <th class="pe-4">Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody class="text-center">
                            <c:if test="${empty listHistory}">
                                <tr>
                                    <td colspan="7" class="py-5 text-muted">
                                        <i class="fas fa-clipboard-list fa-3x d-block mb-3 opacity-25"></i>
                                        Chưa có yêu cầu hỗ trợ nào được ghi lại!
                                    </td>
                                </tr>
                            </c:if>

                            <c:forEach var="h" items="${listHistory}">
                                <tr>
                                    <td class="ps-4 text-muted small">#${h.maLS}</td>
                                    <td><span class="badge bg-primary px-3 py-2 rounded-pill">PHÒNG ${h.maPhong}</span></td>
                                    <td class="text-start fw-bold">
                                        <c:out value="${not empty h.noiDung ? h.noiDung : 'Yêu cầu hỗ trợ nhanh'}" />
                                    </td>
                                    <td>
                                        <div class="fw-bold text-dark"><fmt:formatDate value="${h.thoiGianGoi}" pattern="HH:mm"/></div>
                                        <small class="text-muted"><fmt:formatDate value="${h.thoiGianGoi}" pattern="dd/MM/yyyy"/></small>
                                    </td>
                                    <td class="text-primary fw-bold">
                                        <i class="fas fa-user-check me-1"></i> 
                                        ${not empty h.tenNhanVien ? h.tenNhanVien : '<span class="text-muted">---</span>'}
                                    </td>
                                    <td class="text-success fw-bold">
                                        <c:choose>
                                            <c:when test="${not empty h.thoiGianXong}">
                                                <fmt:formatDate value="${h.thoiGianXong}" pattern="HH:mm - dd/MM/yyyy"/>
                                            </c:when>
                                            <c:otherwise><span class="text-muted">---</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="pe-4">
                                        <c:choose>
                                            <c:when test="${h.trangThai == 0}">
                                                <span class="badge bg-success badge-status px-3 py-2 rounded-pill">HOÀN TẤT</span>
                                            </c:when>
                                            <c:when test="${h.trangThai == 1}">
                                                <span class="badge pulse-red badge-status px-3 py-2 rounded-pill text-white">ĐANG ĐỢI</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-warning text-dark badge-status px-3 py-2 rounded-pill">ĐANG ĐẾN</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="inventoryModal" tabindex="-1" aria-hidden="true"><div class="modal-dialog modal-lg modal-dialog-centered"><div class="modal-content shadow-lg"><div class="modal-header border-0 bg-dark text-white p-4"><h5 class="modal-title fw-bold">QUẢN LÝ THỰC ĐƠN</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div><div class="modal-body p-4" id="inventory-content-area"></div></div></div></div>
    <div class="modal fade" id="revenueModal" tabindex="-1" aria-hidden="true"><div class="modal-dialog modal-sm modal-dialog-centered"><div class="modal-content border-0 shadow-lg"><div class="modal-header bg-info text-white border-0"><h5 class="modal-title fw-bold">DOANH THU</h5><button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button></div><div class="modal-body p-4"><input type="date" id="revenueDate" class="form-control mb-3" onchange="fetchRevenue()"><div id="revenue-result-container"></div></div></div></div></div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 🛡️ CHUÔNG THÔNG BÁO (Tách 3 phần đồng bộ hệ thống)
        function pollNotifications() {
            fetch('${pageContext.request.contextPath}/staff/api-pending-summary')
            .then(res => res.text()).then(data => {
                if (data && data.includes("|")) {
                    let parts = data.split("|");
                    // parts[0]: Món ăn, parts[1]: Chờ hỗ trợ, parts[2]: Nhân viên đang đến
                    let o = (parts[0] && parts[0].trim() !== "") ? parts[0].split(",").length : 0;
                    let w = (parts[1] && parts[1].trim() !== "") ? parts[1].split(",").length : 0;
                    let c = (parts[2] && parts[2].trim() !== "") ? parts[2].split(",").length : 0;
                    
                    let total = o + w + c;
                    let badge = document.getElementById('total-count');
                    if(badge) {
                        badge.innerText = total;
                        badge.classList.toggle('d-none', total === 0);
                    }
                }
            }).catch(e => console.error("Lỗi Polling tại Support History: ", e));
        }

        // Logic Navbar Modals (Copy từ Dashboard để đồng bộ)
        function openInventoryModal() { 
            bootstrap.Modal.getOrCreateInstance(document.getElementById('inventoryModal')).show(); 
            fetch('${pageContext.request.contextPath}/staff/api-manage-inventory').then(res => res.text()).then(html => document.getElementById('inventory-content-area').innerHTML = html); 
        }
        
        function openRevenueModal() { 
            document.getElementById('revenueDate').value = new Date().toISOString().split('T')[0]; 
            fetchRevenue(); 
            bootstrap.Modal.getOrCreateInstance(document.getElementById('revenueModal')).show(); 
        }
        
        function fetchRevenue() { 
            let date = document.getElementById('revenueDate').value;
            fetch('${pageContext.request.contextPath}/staff/api-get-revenue?date=' + date)
                .then(res => res.text()).then(html => document.getElementById('revenue-result-container').innerHTML = html); 
        }

        window.onload = function() { 
            pollNotifications(); 
            setInterval(pollNotifications, 5000); 
        };
    </script>
</body>
</html>