<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý phòng - NICE KARAOKE</title>
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
        
        /* Status Badges - ĐÃ ĐỒNG BỘ MÀU VÀ STYLE VỚI STAFF */
        .status-active { color: #198754; background: #e8f5e9; padding: 6px 14px; border-radius: 50px; font-size: 0.75rem; font-weight: 700; }
        .status-busy { color: #dc3545; background: #fdecea; padding: 6px 14px; border-radius: 50px; font-size: 0.75rem; font-weight: 700; }
        .status-cleaning { color: #fd7e14; background: #fff4e6; padding: 6px 14px; border-radius: 50px; font-size: 0.75rem; font-weight: 700; }
        
        /* Table Custom */
        .table thead { background-color: #f8f9fa; }
        .table th { border: none; font-size: 0.75rem; text-transform: uppercase; color: #6c757d; padding: 15px; }
        .table td { padding: 15px; vertical-align: middle; border-bottom: 1px solid #f1f1f1; }
        
        /* Button & Input Custom */
        .btn-primary-custom { background-color: var(--admin-blue); border: none; color: white; transition: 0.3s; }
        .btn-primary-custom:hover { background-color: #0089bd; color: white; transform: translateY(-2px); }
        .form-control:focus, .form-select:focus { border-color: var(--admin-blue); box-shadow: 0 0 0 0.25rem rgba(0, 174, 239, 0.1); }
        .text-blue-icon { color: var(--admin-blue) !important; }

        /* Chuông hỗ trợ nhấp nháy */
        .ring-bell { color: #dc3545; animation: ring 0.5s infinite; cursor: help; }
        @keyframes ring {
            0% { transform: rotate(0); }
            25% { transform: rotate(15deg); }
            50% { transform: rotate(0); }
            75% { transform: rotate(-15deg); }
            100% { transform: rotate(0); }
        }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp">
        <jsp:param name="active" value="rooms" />
    </jsp:include>

    <div class="main-panel">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold mb-1"><i class="fas fa-door-open me-2 text-blue-icon"></i>Quản lý phòng</h3>
                <p class="text-muted small">Kiểm soát danh sách phòng và trạng thái vận hành hệ thống</p>
            </div>
            <button class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                <i class="fas fa-plus me-2"></i>Thêm phòng mới
            </button>
        </div>

        <div class="glass-card p-4 mb-4">
            <form action="manage-rooms" method="GET" class="row g-3">
                <div class="col-md-4">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 rounded-start-pill"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="txtSearch" value="${lastSearch}" class="form-control bg-light border-start-0 rounded-end-pill" placeholder="Tìm tên phòng...">
                    </div>
                </div>
                <div class="col-md-3">
                    <select name="typeFilter" class="form-select bg-light rounded-pill">
                        <option value="">-- Tất cả loại phòng --</option>
                        <c:forEach var="loai" items="${typeList}">
                            <option value="${loai.maLoai}" ${lastType == loai.maLoai ? 'selected' : ''}>${loai.tenLoai}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <select name="statusFilter" class="form-select bg-light rounded-pill">
                        <option value="">-- Tất cả trạng thái --</option>
                        <option value="Trống" ${lastStatus == 'Trống' ? 'selected' : ''}>Trống</option>
                        <option value="Đang hát" ${lastStatus == 'Đang hát' ? 'selected' : ''}>Đang hát</option>
                        <option value="Chờ dọn" ${lastStatus == 'Chờ dọn' ? 'selected' : ''}>Chờ dọn</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-dark w-100 rounded-pill fw-bold">Lọc dữ liệu</button>
                </div>
            </form>
        </div>

        <div class="glass-card overflow-hidden">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-4">Mã Phòng</th>
                        <th>Tên phòng</th>
                        <th>Loại phòng</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-center">Hỗ trợ</th>
                        <th class="text-end pe-4">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="p" items="${roomList}">
                        <tr>
                            <td class="ps-4 fw-bold text-blue-icon">${p.maPhong}</td>
                            <td><div class="fw-bold text-dark">${p.tenPhong}</div></td>
                            <td>
                                <span class="badge bg-info bg-opacity-10 text-blue-icon px-3 rounded-pill border border-info border-opacity-25">
                                    ${p.tenLoai}
                                </span>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${p.trangThai == 'Trống'}"><span class="status-active">Trống</span></c:when>
                                    <c:when test="${p.trangThai == 'Đang hát'}"><span class="status-busy">Đang hát</span></c:when>
                                    <c:otherwise><span class="status-cleaning">Chờ dọn</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <c:if test="${p.yeuCauHoTro == 1}">
                                    <i class="fas fa-bell ring-bell" title="${p.ghiChuHoTro}"></i>
                                </c:if>
                                <c:if test="${p.yeuCauHoTro == 0}">
                                    <i class="fas fa-bell-slash text-muted opacity-25"></i>
                                </c:if>
                            </td>
                            <td class="text-end pe-4">
                                <button class="btn btn-sm btn-light rounded-circle shadow-sm me-2" 
                                        onclick="openEditRoomModal('${p.maPhong}', '${p.tenPhong}', '${p.maLoai}', '${p.trangThai}')">
                                    <i class="fas fa-user-pen text-blue-icon"></i>
                                </button>
                                <a href="manage-rooms?action=delete&id=${p.maPhong}" 
                                   class="btn btn-sm btn-light rounded-circle shadow-sm" 
                                   onclick="return confirm('Bạn có chắc chắn muốn xóa phòng này?')">
                                    <i class="fas fa-trash text-danger"></i>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty roomList}">
                        <tr>
                            <td colspan="6" class="py-5 text-center text-muted">
                                <i class="fas fa-door-closed fa-3x mb-3 opacity-25"></i>
                                <p>Không tìm thấy phòng nào phù hợp.</p>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="addRoomModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-rooms" method="POST">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-plus-circle me-2 text-blue-icon"></i>Thêm phòng mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Mã phòng</label>
                            <input type="text" name="roomId" class="form-control rounded-3 bg-light border-0" placeholder="Ví dụ: P101" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Tên phòng</label>
                            <input type="text" name="roomName" class="form-control rounded-3 bg-light border-0" placeholder="Ví dụ: Phòng 101" required>
                        </div>
                        <div class="mb-0">
                            <label class="form-label small fw-bold">Loại phòng</label>
                            <select name="typeId" class="form-select rounded-3 bg-light border-0">
                                <c:forEach var="loai" items="${typeList}">
                                    <option value="${loai.maLoai}">${loai.tenLoai}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm">Lưu phòng</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editRoomModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-rooms?action=update" method="POST">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-pen-to-square me-2 text-blue-icon"></i>Cập nhật phòng</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <input type="hidden" name="roomId" id="edit-room-id">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Tên phòng</label>
                            <input type="text" name="roomName" id="edit-room-name" class="form-control rounded-3 bg-light border-0" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Loại phòng</label>
                            <select name="typeId" id="edit-room-type" class="form-select rounded-3 bg-light border-0">
                                <c:forEach var="loai" items="${typeList}">
                                    <option value="${loai.maLoai}">${loai.tenLoai}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="mb-0">
                            <label class="form-label small fw-bold">Trạng thái vận hành</label>
                            <select name="status" id="edit-room-status" class="form-select rounded-3 bg-light border-0">
                                <option value="Trống">Trống</option>
                                <option value="Đang hát">Đang hát</option>
                                <option value="Chờ dọn">Chờ dọn</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm">Cập nhật</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function openEditRoomModal(id, name, type, status) {
            document.getElementById('edit-room-id').value = id;
            document.getElementById('edit-room-name').value = name;
            document.getElementById('edit-room-type').value = type;
            document.getElementById('edit-room-status').value = status;
            var editModal = new bootstrap.Modal(document.getElementById('editRoomModal'));
            editModal.show();
        }
    </script>
</body>
</html>