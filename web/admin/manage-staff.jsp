<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý nhân sự - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { 
            --admin-blue: #00aeef; 
            --sidebar-width: 280px; 
        }
        body { background-color: #f0f2f5; font-family: 'Segoe UI', sans-serif; overflow-x: hidden; }
        
        /* 🛡️ MAIN PANEL */
        .main-panel { margin-left: var(--sidebar-width); padding: 40px; }
        .glass-card { background: white; border-radius: 24px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        
        /* Status Badges */
        .status-active { color: #198754; background: #e8f5e9; padding: 6px 14px; border-radius: 50px; font-size: 0.75rem; font-weight: 700; }
        .status-locked { color: #dc3545; background: #fdecea; padding: 6px 14px; border-radius: 50px; font-size: 0.75rem; font-weight: 700; }
        
        /* Table Custom */
        .table thead { background-color: #f8f9fa; }
        .table th { border: none; font-size: 0.75rem; text-transform: uppercase; color: #6c757d; padding: 15px; }
        .table td { padding: 15px; vertical-align: middle; border-bottom: 1px solid #f1f1f1; }
        
        /* Buttons */
        .btn-primary-custom { background-color: var(--admin-blue); border: none; color: white; transition: 0.3s; }
        .btn-primary-custom:hover { background-color: #0089bd; color: white; transform: translateY(-2px); }
        .text-blue-icon { color: var(--admin-blue) !important; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp">
        <jsp:param name="active" value="staff" />
    </jsp:include>

    <div class="main-panel">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold mb-1"><i class="fas fa-users-gear me-2 text-blue-icon"></i>Quản lý nhân sự</h3>
                <p class="text-muted small">Quyền hạn Admin: Quản lý thông tin và bảo mật tài khoản</p>
            </div>
            <button class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#addStaffModal">
                <i class="fas fa-plus me-2"></i>Thêm nhân sự
            </button>
        </div>

        <div class="glass-card p-4 mb-4">
            <form class="row g-3" action="manage-staff" method="GET">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 rounded-start-pill"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="txtSearch" value="${lastSearch}" class="form-control bg-light border-start-0 rounded-end-pill" placeholder="Tìm theo tên hoặc username...">
                    </div>
                </div>
                <div class="col-md-3">
                    <select name="roleFilter" class="form-select bg-light rounded-pill">
                        <option value="">-- Tất cả chức vụ --</option>
                        <option value="1" ${lastRole == '1' ? 'selected' : ''}>Admin</option>
                        <option value="2" ${lastRole == '2' ? 'selected' : ''}>Nhân viên</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-dark w-100 rounded-pill fw-bold">Lọc dữ liệu</button>
                </div>
                <div class="col-md-2">
                    <a href="manage-staff" class="btn btn-outline-secondary w-100 rounded-pill text-decoration-none text-center">Làm mới</a>
                </div>
            </form>
        </div>

        <div class="glass-card overflow-hidden">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-4">Mã NV</th>
                        <th>Họ tên</th>
                        <th>Tên đăng nhập</th>
                        <th>Mật khẩu</th>
                        <th>Chức vụ</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-end pe-4">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="nv" items="${staffList}">
                        <tr>
                            <td class="ps-4 fw-bold text-blue-icon">#${nv.maNV}</td>
                            <td><div class="fw-bold text-dark">${nv.tenNV}</div></td>
                            <td><code>${nv.username}</code></td>
                            <td><span class="text-muted small">${nv.password}</span></td>
                            <td>
                                <span class="badge bg-info bg-opacity-10 text-blue-icon px-3 rounded-pill border border-info border-opacity-25">
                                    ${nv.maCV == 1 ? 'Admin' : 'Nhân viên'}
                                </span>
                            </td>
                            <td class="text-center">
                                <span class="${nv.trangThai == 1 ? 'status-active' : 'status-locked'}">
                                    ${nv.trangThai == 1 ? 'Đang làm' : 'Đã khóa'}
                                </span>
                            </td>
                            <td class="text-end pe-4">
                                <button class="btn btn-sm btn-light rounded-circle shadow-sm me-2" 
                                        onclick="openEditModal('${nv.maNV}', '${nv.tenNV}', '${nv.username}', '${nv.password}', '${nv.maCV}')">
                                    <i class="fas fa-user-pen text-blue-icon"></i>
                                </button>
                                <a href="manage-staff?action=toggle&id=${nv.maNV}&st=${nv.trangThai}" 
                                   class="btn btn-sm ${nv.trangThai == 1 ? 'btn-light' : 'btn-dark'} rounded-circle shadow-sm">
                                    <i class="fas ${nv.trangThai == 1 ? 'fa-user-slash text-danger' : 'fa-user-check text-success'}"></i>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="addStaffModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-staff" method="POST">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-user-plus me-2 text-blue-icon"></i>Thêm nhân sự mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Họ và tên</label>
                            <input type="text" name="name" class="form-control rounded-3 bg-light border-0" placeholder="Nhập tên nhân viên" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Tên đăng nhập (Username)</label>
                            <input type="text" name="user" class="form-control rounded-3 bg-light border-0" placeholder="Ví dụ: nhanvien01" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Mật khẩu ban đầu</label>
                            <input type="password" name="pass" class="form-control rounded-3 bg-light border-0" placeholder="Nhập mật khẩu" required>
                        </div>
                        <div class="mb-0">
                            <label class="form-label small fw-bold">Phân quyền chức vụ</label>
                            <select name="role" class="form-select rounded-3 bg-light border-0">
                                <option value="2">Nhân viên</option>
                                <option value="1">Admin</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold">Lưu nhân viên</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editStaffModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-staff?action=update" method="POST">
                    <input type="hidden" name="id" id="edit-id">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-user-pen me-2 text-blue-icon"></i>Cập nhật nhân sự</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Họ và tên</label>
                            <input type="text" name="name" id="edit-name" class="form-control rounded-3 bg-light border-0" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Tên đăng nhập</label>
                            <input type="text" name="user" id="edit-user" class="form-control rounded-3 bg-light border-0" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Mật khẩu (Có thể thay đổi)</label>
                            <input type="text" name="pass" id="edit-pass" class="form-control rounded-3 bg-light border-0" required>
                        </div>
                        <div class="mb-0">
                            <label class="form-label small fw-bold">Chức vụ</label>
                            <select name="role" id="edit-role" class="form-select rounded-3 bg-light border-0">
                                <option value="1">Admin</option>
                                <option value="2">Nhân viên</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm">Cập nhật thông tin</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Hàm JS để đổ dữ liệu vào Popup Sửa
        function openEditModal(id, name, user, pass, role) {
            document.getElementById('edit-id').value = id;
            document.getElementById('edit-name').value = name;
            document.getElementById('edit-user').value = user;
            document.getElementById('edit-pass').value = pass; // Đổ mật khẩu cũ vào để sửa
            document.getElementById('edit-role').value = role;
            
            var myModal = new bootstrap.Modal(document.getElementById('editStaffModal'));
            myModal.show();
        }
    </script>
</body>
</html>