<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    :root { 
        --empty: #2ecc71; 
        --occupied: #e74c3c; 
        --dirty: #f1c40f; 
        --dark: #1a1a1a; 
        --primary-orange: #ff8c00; 
    }

    /* 🛡️ NAVBAR TRẠM TRƯỞNG */
    .navbar { 
        z-index: 9999 !important; 
        background-color: var(--dark) !important;
        border-bottom: 4px solid var(--primary-orange);
    }

    .navbar-brand { font-size: 1.75rem !important; font-weight: 700; }
    .nav-link { font-size: 1rem !important; transition: 0.3s; }
    .nav-link:hover { color: var(--primary-orange) !important; }

    /* Modal & Dropdown Layer */
    .modal { z-index: 10001 !important; }
    .modal-backdrop { z-index: 10000 !important; }
    .dropdown-menu { 
        z-index: 10000 !important;
        border-radius: 12px; 
        border: none; 
        box-shadow: 0 10px 30px rgba(0,0,0,0.2); 
    }

    /* Hiệu ứng rung chuông khi có thông báo mới */
    .bell-shake { animation: swing 0.5s infinite alternate; color: var(--primary-orange) !important; }
    @keyframes swing { 
        from { transform: rotate(15deg); } 
        to { transform: rotate(-15deg); } 
    }
    
    .no-print { display: block; }
    @media print { .no-print { display: none !important; } }
</style>

<nav class="navbar navbar-expand-lg navbar-dark fixed-top shadow no-print">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/staff/dashboard">
            <i class="fas fa-microphone-lines me-2 text-warning"></i>NICE <span style="color: var(--primary-orange);">KARAOKE</span>
        </a>

        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav me-auto">
                <li class="nav-item">
                    <a class="nav-link ${pageContext.request.servletPath.contains('dashboard') ? 'active fw-bold text-warning' : 'text-white'}" 
                       href="${pageContext.request.contextPath}/staff/dashboard">
                        <i class="fas fa-desktop me-1"></i> Sơ đồ trực tuyến
                    </a>
                </li>

                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" data-bs-toggle="dropdown">
                        Xử lý nghiệp vụ
                    </a>
                    <ul class="dropdown-menu shadow-lg mt-2">
                        <li>
                            <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/staff/booking">
                                <i class="fas fa-calendar-check me-2 text-primary"></i>Đặt phòng trước
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <a class="dropdown-item py-2" href="javascript:void(0)" onclick="openQuickPayment()">
                                <i class="fas fa-receipt me-2 text-success"></i>Quầy Thu Ngân
                            </a>
                        </li>
                    </ul>
                </li>

                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" data-bs-toggle="dropdown">
                        Danh mục
                    </a>
                    <ul class="dropdown-menu shadow-lg mt-2">
                        <li>
                            <a class="dropdown-item py-2" href="javascript:void(0)" onclick="openInventoryModal()">
                                <i class="fas fa-utensils me-2 text-warning"></i>Quản lý Menu (Ẩn/Hiện)
                            </a>
                        </li>
                        <li>
                            <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/staff/booking-history">
                                <i class="fas fa-history me-2 text-info"></i>Lịch sử đặt phòng
                            </a>
                        </li>
                        <li>
                            <a class="dropdown-item py-2" href="${pageContext.request.contextPath}/staff/support-history">
                                <i class="fas fa-headset me-2 text-danger"></i>Lịch sử hỗ trợ
                            </a>
                        </li>
                    </ul>
                </li>

                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle text-white" href="#" data-bs-toggle="dropdown">
                        Thống kê
                    </a>
                    <ul class="dropdown-menu shadow-lg mt-2">
                        <li>
                            <a class="dropdown-item py-2" href="javascript:void(0)" onclick="openRevenueModal()">
                                <i class="fas fa-chart-line me-2 text-info"></i>Doanh thu hôm nay
                            </a>
                        </li>
                    </ul>
                </li>
            </ul>

            <div class="d-flex align-items-center">
                <div class="position-relative me-4" style="cursor: pointer;" onclick="window.location.href='${pageContext.request.contextPath}/staff/dashboard'">
                    <i id="bell-icon" class="fas fa-bell fs-4 text-white"></i>
                    <span id="total-count" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">0</span>
                </div>

                <div class="text-white border-start ps-3 me-3 d-none d-sm-block">
                    <small class="d-block opacity-75">Đang trực:</small>
                    <span class="fw-bold text-warning">${sessionScope.auth.tenNV}</span>
                </div>

                <c:if test="${sessionScope.auth.maCV == 1}">
                    <a class="btn btn-info btn-sm rounded-pill px-3 me-3 fw-bold shadow-sm" 
                       href="${pageContext.request.contextPath}/admin/dashboard">
                        <i class="fas fa-shield-halved me-1"></i> Admin
                    </a>
                </c:if>

                <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger btn-sm rounded-pill px-3 fw-bold">Thoát</a>
            </div>
        </div>
    </div>
</nav>

<script>
    // Hàm mở nhanh quầy thu ngân (Payment/Cashier)
    function openQuickPayment() {
        if(typeof loadActiveBookings === 'function') {
            loadActiveBookings(); // Hàm này nằm trong dashboard.jsp
        } else {
            window.location.href = '${pageContext.request.contextPath}/staff/dashboard?action=payment';
        }
    }

    // Hàm mở quản lý ẩn/hiện món (Inventory/Menu)
    function openInventoryModal() {
        if(typeof loadInventory === 'function') {
            loadInventory(); // Hàm này nằm trong dashboard.jsp
        } else {
            alert("Vui lòng truy cập từ trang Sơ đồ để sử dụng chức năng này!");
        }
    }

    // Hàm xem nhanh doanh thu hôm nay (Revenue Modal)
    function openRevenueModal() {
        const today = new Date().toISOString().split('T')[0];
        fetch('${pageContext.request.contextPath}/staff/api-get-revenue?date=' + today)
            .then(res => res.text())
            .then(data => {
                // Tận dụng dữ liệu trả về để hiện thông báo nhanh
                alert("Tổng doanh thu hôm nay: " + data.replace(/<[^>]*>/g, ''));
            });
    }

    // Tự động kiểm tra thông báo gọi món & hỗ trợ mỗi 5 giây
    setInterval(() => {
        fetch('${pageContext.request.contextPath}/staff/api-pending-summary')
            .then(res => res.text())
            .then(data => {
                const parts = data.split('|');
                // Tính tổng số phòng đang gọi món + số phòng gọi hỗ trợ
                const count = (parts[0] ? parts[0].split(',').length : 0) + 
                              (parts[1] ? parts[1].split(',').length : 0);
                
                const badge = document.getElementById('total-count');
                const bell = document.getElementById('bell-icon');

                if (count > 0) {
                    badge.innerText = count;
                    badge.classList.remove('d-none');
                    bell.classList.add('bell-shake');
                } else {
                    badge.classList.add('d-none');
                    bell.classList.remove('bell-shake');
                }
            });
    }, 5000);
</script>