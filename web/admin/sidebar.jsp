<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<style>
    :root { 
        --admin-blue: #00aeef; 
        --sidebar-dark: #121212;
        --nav-hover-bg: rgba(0, 174, 239, 0.1);
    }
    
    .sidebar { width: 280px; height: 100vh; position: fixed; top: 0; left: 0; background: var(--sidebar-dark); color: white; transition: all 0.3s; z-index: 1000; border-right: 3px solid var(--admin-blue); }
    .sidebar-brand { padding: 30px 20px; text-align: center; font-size: 1.5rem; font-weight: 800; border-bottom: 1px solid #2d2d2d; letter-spacing: 1px; }
    .nav-section-title { font-size: 0.7rem; text-transform: uppercase; padding: 25px 25px 10px; color: #5c636a; font-weight: 700; }
    
    /* 🛡️ CẤU TRÚC NAV LINK ĐỒNG BỘ */
    .nav-link-sidebar { 
        color: #cfd2d6; 
        padding: 12px 25px; 
        transition: all 0.2s ease; 
        display: flex; 
        align-items: center; 
        text-decoration: none !important; 
        cursor: pointer; 
        border-left: 4px solid transparent; /* Luôn giữ border ẩn để không bị giật khi hover */
        width: 100%;
    }

    /* Hiệu ứng HOVER & ACTIVE chung cho tất cả Menu Cha */
    .nav-link-sidebar:hover, 
    .nav-link-sidebar.active { 
        background: var(--nav-hover-bg); 
        color: var(--admin-blue) !important; 
        border-left: 4px solid var(--admin-blue); 
        font-weight: bold;
    }
    
    /* Icon mặc định */
    .nav-link-sidebar i:first-child { 
        width: 35px; 
        font-size: 1.2rem; 
    }

    /* 🛡️ STYLE CHO MENU CON (SUB-MENU) */
    .sub-menu { list-style: none; padding-left: 55px; margin: 5px 0 10px 0; }
    .sub-link { 
        color: #adb5bd; 
        text-decoration: none !important; 
        font-size: 0.9rem; 
        padding: 8px 0; 
        display: flex; 
        align-items: center;
        transition: 0.3s; 
    }
    .sub-link:hover, .sub-link.active { 
        color: var(--admin-blue) !important; 
        font-weight: 600;
    }
    .sub-link i { font-size: 0.8rem; width: 25px; }
    
    /* Tiện ích bổ sung */
    .text-blue-icon { color: var(--admin-blue) !important; }
    .rotate-icon { transition: 0.3s; margin-left: auto; font-size: 0.8rem; }
    
    /* Xoay icon khi menu con mở */
    .nav-link-sidebar[aria-expanded="true"] .rotate-icon { 
        transform: rotate(90deg); 
    }
</style>

<div class="sidebar shadow text-start">
    <div class="sidebar-brand">
        <i class="fas fa-crown text-blue-icon me-2"></i>NICE <span class="text-blue-icon">ADMIN</span>
    </div>
    
    <div class="nav flex-column mt-2">
        <a href="${pageContext.request.contextPath}/admin/dashboard" 
           class="nav-link-sidebar ${param.active == 'dashboard' ? 'active' : ''}">
            <i class="fas fa-chart-line"></i> <span>Tổng quan</span>
        </a>
        
        <div class="nav-section-title">Quản lý Tài nguyên</div>
        
        <div class="nav-item">
            <a class="nav-link-sidebar ${param.active == 'staff' || param.active == 'roles' ? 'active' : ''}" 
               data-bs-toggle="collapse" href="#menuStaff" role="button" 
               aria-expanded="${param.active == 'staff' || param.active == 'roles' ? 'true' : 'false'}">
                <i class="fas fa-user-gear"></i> <span>Nhân sự & Chức vụ</span>
                <i class="fas fa-chevron-right rotate-icon"></i>
            </a>
            <div class="collapse ${param.active == 'staff' || param.active == 'roles' ? 'show' : ''}" id="menuStaff">
                <ul class="sub-menu">
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/manage-staff" 
                           class="sub-link ${param.active == 'staff' ? 'active' : ''}">
                           <i class="fas fa-users"></i> Nhân sự
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/manage-roles" 
                           class="sub-link ${param.active == 'roles' ? 'active' : ''}">
                           <i class="fas fa-id-card-clip"></i> Chức vụ
                        </a>
                    </li>
                </ul>
            </div>
        </div>

        <div class="nav-item">
            <a class="nav-link-sidebar ${param.active == 'rooms' || param.active == 'roomTypes' ? 'active' : ''}" 
               data-bs-toggle="collapse" href="#menuRooms" role="button" 
               aria-expanded="${param.active == 'rooms' || param.active == 'roomTypes' ? 'true' : 'false'}">
                <i class="fas fa-door-open"></i> <span>Phòng & Loại phòng</span>
                <i class="fas fa-chevron-right rotate-icon"></i>
            </a>
            <div class="collapse ${param.active == 'rooms' || param.active == 'roomTypes' ? 'show' : ''}" id="menuRooms">
                <ul class="sub-menu">
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/manage-rooms" 
                           class="sub-link ${param.active == 'rooms' ? 'active' : ''}">
                           <i class="fas fa-door-closed"></i> Phòng
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/admin/manage-room-types" 
                           class="sub-link ${param.active == 'roomTypes' ? 'active' : ''}">
                           <i class="fas fa-layer-group"></i> Loại phòng
                        </a>
                    </li>
                </ul>
            </div>
        </div>
        
        <a href="${pageContext.request.contextPath}/admin/manage-services" 
           class="nav-link-sidebar ${param.active == 'services' ? 'active' : ''}">
            <i class="fas fa-utensils"></i> <span>Dịch vụ (Menu)</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/manage-inventory" 
           class="nav-link-sidebar ${param.active == 'inventory' ? 'active' : ''}">
            <i class="fas fa-boxes-packing"></i> <span>Tồn kho (Nhập hàng)</span>
        </a>

        <div class="nav-section-title" style="color: #ff8c00;">Vận hành (Staff Mode)</div>
        <a href="${pageContext.request.contextPath}/staff/dashboard" class="nav-link-sidebar text-warning">
            <i class="fas fa-desktop"></i> <span>Sơ đồ phòng</span>
        </a>
        <a href="${pageContext.request.contextPath}/staff/booking-history" class="nav-link-sidebar text-warning">
            <i class="fas fa-clock-rotate-left"></i> <span>Lịch sử đặt phòng</span>
        </a>

        <div class="nav-section-title">Báo cáo & Thống kê</div>
        <a href="${pageContext.request.contextPath}/admin/revenue-report" 
           class="nav-link-sidebar ${param.active == 'report' ? 'active' : ''}">
            <i class="fas fa-file-invoice-dollar"></i> <span>Doanh thu & Báo cáo</span>
        </a>
        
        <div class="mt-4 px-4 pb-5">
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger w-100 rounded-pill fw-bold small">
                <i class="fas fa-power-off me-2"></i>Đăng xuất
            </a>
        </div>
    </div>
</div>