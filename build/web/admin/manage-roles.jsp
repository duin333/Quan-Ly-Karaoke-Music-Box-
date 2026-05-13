<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý chức vụ - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --admin-blue: #00aeef; --sidebar-width: 280px; }
        body { background-color: #f0f2f5; font-family: 'Segoe UI', sans-serif; overflow-x: hidden; }
        .main-panel { margin-left: var(--sidebar-width); padding: 40px; }
        .glass-card { background: white; border-radius: 24px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        .btn-primary-custom { background-color: var(--admin-blue); border: none; color: white; transition: 0.3s; }
        .btn-primary-custom:hover { background-color: #0089bd; color: white; transform: translateY(-2px); }
        .text-blue-icon { color: var(--admin-blue) !important; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp"><jsp:param name="active" value="roles" /></jsp:include>

    <div class="main-panel">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold mb-1"><i class="fas fa-id-card-clip me-2 text-blue-icon"></i>Quản lý chức vụ</h3>
                <p class="text-muted small">Thiết lập các vai trò nhân sự trong hệ thống</p>
            </div>
            <button class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#addRoleModal">
                <i class="fas fa-plus me-2"></i>Thêm chức vụ
            </button>
        </div>

        <div class="glass-card overflow-hidden">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th class="ps-4">Mã CV</th>
                        <th>Tên chức vụ</th>
                        <th class="text-end pe-4">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="r" items="${roleList}">
                        <tr>
                            <td class="ps-4 fw-bold text-blue-icon">#${r.maCV}</td>
                            <td><span class="fw-bold text-dark">${r.tenCV}</span></td>
                            <td class="text-end pe-4">
                                <button class="btn btn-sm btn-light rounded-circle shadow-sm me-2" 
                                        onclick="openEditRoleModal('${r.maCV}', '${r.tenCV}')">
                                    <i class="fas fa-pen-to-square text-blue-icon"></i>
                                </button>
                                <c:if test="${r.maCV > 2}">
                                    <a href="manage-roles?action=delete&id=${r.maCV}" 
                                       class="btn btn-sm btn-light rounded-circle shadow-sm" 
                                       onclick="return confirm('Xóa chức vụ này?')">
                                        <i class="fas fa-trash text-danger"></i>
                                    </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="addRoleModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-roles" method="POST">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0">Thêm chức vụ mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <label class="form-label small fw-bold">Tên chức vụ</label>
                        <input type="text" name="roleName" class="form-control rounded-3 bg-light border-0" placeholder="Ví dụ: Tiếp tân, Bảo vệ..." required>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold">Lưu lại</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editRoleModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-roles?action=update" method="POST">
                    <input type="hidden" name="id" id="edit-role-id">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0">Cập nhật chức vụ</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <label class="form-label small fw-bold">Tên chức vụ</label>
                        <input type="text" name="roleName" id="edit-role-name" class="form-control rounded-3 bg-light border-0" required>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold">Cập nhật</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function openEditRoleModal(id, name) {
            document.getElementById('edit-role-id').value = id;
            document.getElementById('edit-role-name').value = name;
            var modal = new bootstrap.Modal(document.getElementById('editRoleModal'));
            modal.show();
        }
    </script>
</body>
</html>