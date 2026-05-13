<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản trị hệ thống - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --admin-blue: #00aeef; --sidebar-width: 280px; }
        body { background-color: #f0f2f5; font-family: 'Segoe UI', sans-serif; overflow-x: hidden; }
        
        /* 🛡️ MAIN PANEL */
        .main-panel { margin-left: var(--sidebar-width); padding: 40px; }
        
        /* Stat Card Style */
        .stat-card { border: none; border-radius: 24px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); transition: 0.3s; background: white; border-bottom: 4px solid transparent; }
        .stat-card:hover { transform: translateY(-5px); border-bottom: 4px solid var(--admin-blue); }
        .stat-icon { width: 60px; height: 60px; border-radius: 18px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; background: rgba(0, 174, 239, 0.1); color: var(--admin-blue); }
        
        /* 🛡️ FIX NÚT QUẢN LÝ PHÒNG: Định nghĩa màu nền cho nút custom */
        .btn-primary-custom { 
            background-color: var(--admin-blue) !important; 
            color: white !important; 
            border: none; 
            transition: 0.3s;
        }
        .btn-primary-custom:hover { 
            background-color: #008dc9 !important; 
            box-shadow: 0 5px 15px rgba(0, 174, 239, 0.3);
        }

        .glass-card { background: white; border-radius: 24px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.05); margin-bottom: 30px; }
        .text-primary-custom { color: var(--admin-blue) !important; }
        
        /* Shortcuts */
        .mgmt-item { border-radius: 20px; padding: 20px; transition: 0.3s; cursor: pointer; border: 1px solid #f1f1f1; height: 100%; display: flex; flex-direction: column; align-items: center; text-align: center; }
        .mgmt-item:hover { background: #f8fdff; border-color: var(--admin-blue); transform: scale(1.02); }
        .mgmt-icon-circle { width: 50px; height: 50px; border-radius: 50%; display: flex; align-items: center; justify-content: center; margin-bottom: 12px; font-size: 1.2rem; }
        
        .badge-soft { padding: 6px 12px; border-radius: 50px; font-size: 0.7rem; font-weight: 700; text-transform: uppercase; }
        .bg-soft-blue { background: rgba(0, 174, 239, 0.1); color: var(--admin-blue); }
        .bg-soft-orange { background: rgba(255, 128, 0, 0.1); color: #ff8000; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp"><jsp:param name="active" value="dashboard" /></jsp:include>

    <div class="main-panel">
        <header class="d-flex justify-content-between align-items-center mb-5">
            <div>
                <h3 class="fw-bold mb-1">Bảng quản trị hệ thống</h3>
                <p class="text-muted small">Giám sát hoạt động của <span class="fw-bold text-primary-custom">NICE KARAOKE</span></p>
            </div>
            <div class="d-flex align-items-center gap-3">
                <div class="text-end small text-muted">
                    <i class="far fa-calendar-check me-1 text-primary-custom"></i> 
                    <fmt:formatDate value="<%= new java.util.Date() %>" pattern="EEEE, dd/MM/yyyy"/>
                </div>
                <div class="rounded-circle overflow-hidden border border-2 border-white shadow-sm" style="width: 45px; height: 45px;">
                    <img src="https://ui-avatars.com/api/?name=${auth.tenNV}&background=00aeef&color=fff" alt="Avatar" width="45">
                </div>
            </div>
        </header>

        <div class="row g-4 mb-5">
            <div class="col-md-3">
                <div class="card stat-card p-4 h-100" style="cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/admin/revenue-report'">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="text-muted tiny fw-bold mb-1 text-uppercase">Doanh thu ngày</div>
                            <h4 class="fw-bold mb-0 text-dark"><fmt:formatNumber value="${revenueToday}" pattern="#,###"/>đ</h4>
                        </div>
                        <div class="stat-icon"><i class="fas fa-wallet"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card p-4 h-100" style="cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/admin/manage-staff'">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="text-muted tiny fw-bold mb-1 text-uppercase">Nhân sự hiện có</div>
                            <h4 class="fw-bold mb-0 text-dark">${totalStaff}</h4>
                        </div>
                        <div class="stat-icon"><i class="fas fa-user-shield"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card p-4 h-100" style="cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/staff/dashboard'">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="text-muted tiny fw-bold mb-1 text-uppercase">Phòng đang hát</div>
                            <h4 class="fw-bold mb-0 text-dark">${occupiedRooms}</h4>
                        </div>
                        <div class="stat-icon"><i class="fas fa-microphone-lines"></i></div>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card stat-card p-4 h-100 border-start border-danger border-5" style="cursor:pointer;" onclick="location.href='${pageContext.request.contextPath}/admin/manage-inventory'">
                    <div class="d-flex justify-content-between">
                        <div>
                            <div class="text-muted tiny fw-bold mb-1 text-uppercase">Cảnh báo kho</div>
                            <h4 class="fw-bold mb-0 text-danger">${lowStockItems} món</h4>
                        </div>
                        <div class="stat-icon" style="background: #fff5f5; color: #dc3545;"><i class="fas fa-box-open"></i></div>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                <div class="card glass-card p-4 h-100">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-chart-area me-2 text-primary-custom"></i>Thống kê doanh thu 7 ngày qua</h5>
                    </div>
                    <div style="height: 350px;"><canvas id="revenueChart"></canvas></div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="card glass-card p-4 h-100">
                    <h5 class="fw-bold mb-4 text-dark"><i class="fas fa-users-gear me-2 text-primary-custom"></i>Nhân sự & Chức vụ</h5>
                    <div class="row g-3">
                        <div class="col-6">
                            <div class="mgmt-item" onclick="location.href='${pageContext.request.contextPath}/admin/manage-staff'">
                                <div class="mgmt-icon-circle bg-soft-blue"><i class="fas fa-user-tie"></i></div>
                                <span class="small fw-bold">Nhân viên</span>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="mgmt-item" onclick="location.href='${pageContext.request.contextPath}/admin/manage-roles'">
                                <div class="mgmt-icon-circle bg-soft-orange"><i class="fas fa-id-card-clip"></i></div>
                                <span class="small fw-bold">Chức vụ</span>
                            </div>
                        </div>
                    </div>
                    <div class="mt-4 p-3 bg-light rounded-4">
                        <div class="d-flex align-items-center justify-content-between small">
                            <span class="text-muted"><i class="fas fa-lock me-1"></i> Tài khoản bị khóa:</span>
                            <b class="text-danger">${staffSummary.inactiveStaff}</b>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-12">
                <div class="card glass-card p-4">
                    <div class="d-flex justify-content-between align-items-center mb-4 border-bottom pb-3">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-door-open me-2 text-primary-custom"></i>Quản lý Phòng & Loại phòng</h5>
                        <div class="d-flex gap-2">
                            <button class="btn btn-sm btn-primary-custom rounded-pill px-4 shadow-sm" onclick="location.href='${pageContext.request.contextPath}/admin/manage-rooms'">
                                <i class="fas fa-cog me-1"></i> Quản lý phòng
                            </button>
                            <button class="btn btn-sm btn-outline-dark rounded-pill px-4" onclick="location.href='${pageContext.request.contextPath}/admin/manage-room-types'">
                                <i class="fas fa-tags me-1"></i> Loại phòng
                            </button>
                        </div>
                    </div>
                    <div class="row g-4 text-center">
                        <div class="col-md-3">
                            <div class="p-3 bg-light rounded-4 border border-success border-opacity-25">
                                <div class="text-muted tiny fw-bold text-uppercase mb-2">Phòng sẵn sàng</div>
                                <h3 class="fw-bold text-success mb-0">${roomBreakdown['Trống'] != null ? roomBreakdown['Trống'] : 0}</h3>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="p-3 bg-light rounded-4 border border-danger border-opacity-25">
                                <div class="text-muted tiny fw-bold text-uppercase mb-2">Đang sử dụng</div>
                                <h3 class="fw-bold text-danger mb-0">${roomBreakdown['Đang hát'] != null ? roomBreakdown['Đang hát'] : 0}</h3>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="p-3 bg-light rounded-4 border border-warning border-opacity-25">
                                <div class="text-muted tiny fw-bold text-uppercase mb-2">Đang chờ dọn</div>
                                <h3 class="fw-bold text-warning mb-0">${roomBreakdown['Chờ dọn'] != null ? roomBreakdown['Chờ dọn'] : 0}</h3>
                            </div>
                        </div>
                        <div class="col-md-3">
                            <div class="p-3 bg-primary bg-opacity-10 rounded-4 border border-primary border-opacity-25">
                                <div class="text-muted tiny fw-bold text-uppercase mb-2">Tổng số phòng</div>
                                <h3 class="fw-bold text-primary mb-0">${totalRoomsCount}</h3>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        const ctx = document.getElementById('revenueChart').getContext('2d');
        const labels = []; const data = [];
        <c:forEach var="entry" items="${chartData}">
            labels.push("${entry.key}");
            data.push(${entry.value});
        </c:forEach>

        new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels.length > 0 ? labels : ["Chưa có dữ liệu"],
                datasets: [{
                    label: 'Doanh thu',
                    data: data.length > 0 ? data : [0],
                    borderColor: '#00aeef',
                    backgroundColor: 'rgba(0, 174, 239, 0.1)',
                    fill: true,
                    tension: 0.4,
                    borderWidth: 3,
                    pointRadius: 6,
                    pointBackgroundColor: '#fff',
                    pointBorderColor: '#00aeef'
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    y: { 
                        beginAtZero: true, 
                        ticks: { callback: v => v.toLocaleString() + ' ₫' }
                    }
                }
            }
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>