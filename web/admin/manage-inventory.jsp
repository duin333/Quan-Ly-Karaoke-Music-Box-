<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý kho hàng - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --admin-blue: #00aeef; --sidebar-width: 280px; }
        body { background-color: #f0f2f5; font-family: 'Segoe UI', sans-serif; overflow-x: hidden; }
        .main-panel { margin-left: var(--sidebar-width); padding: 40px; }
        .glass-card { background: white; border-radius: 24px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        
        /* Cảnh báo kho */
        .stock-low { color: #dc3545; background: #fdecea; padding: 6px 14px; border-radius: 50px; font-weight: 700; font-size: 0.75rem; border: 1px solid #f5c2c7; }
        .stock-ok { color: #198754; background: #e8f5e9; padding: 6px 14px; border-radius: 50px; font-weight: 700; font-size: 0.75rem; border: 1px solid #badbcc; }
        
        .service-img { width: 50px; height: 50px; object-fit: cover; border-radius: 10px; }
        .btn-primary-custom { background-color: var(--admin-blue); border: none; color: white; transition: 0.3s; }
        .btn-primary-custom:hover { background-color: #0089bd; transform: translateY(-2px); color: white; }
        .text-blue-icon { color: var(--admin-blue) !important; }
        .table th { border: none; font-size: 0.75rem; text-transform: uppercase; color: #6c757d; padding: 15px; }
        .table td { padding: 15px; vertical-align: middle; border-bottom: 1px solid #f1f1f1; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp"><jsp:param name="active" value="inventory" /></jsp:include>

    <div class="main-panel">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold mb-1"><i class="fas fa-boxes-stacked me-2 text-blue-icon"></i>Quản lý kho hàng</h3>
                <p class="text-muted small">Theo dõi tồn kho và thực hiện nhập hàng vào hệ thống</p>
            </div>
            <div class="d-flex gap-2">
                <c:if test="${param.success == 'true'}">
                    <div class="alert alert-success py-2 px-3 rounded-pill mb-0 small shadow-sm"><i class="fas fa-check-circle me-1"></i> Nhập kho thành công!</div>
                </c:if>
            </div>
        </div>

        <div class="glass-card p-4 mb-4">
            <form action="manage-inventory" method="GET" class="row g-3">
                <div class="col-md-5">
                    <input type="text" name="txtSearch" value="${param.txtSearch}" class="form-control rounded-pill bg-light border-0 px-4" placeholder="Tìm tên mặt hàng...">
                </div>
                <div class="col-md-4">
                    <select name="categoryFilter" class="form-select rounded-pill bg-light border-0">
                        <option value="">-- Tất cả chủng loại --</option>
                        <c:forEach var="c" items="${categoryList}">
                            <option value="${c.maLoaiDV}" ${param.categoryFilter == c.maLoaiDV ? 'selected' : ''}>${c.tenLoaiDV}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-dark w-100 rounded-pill fw-bold">Kiểm kê</button>
                </div>
            </form>
        </div>

        <div class="glass-card overflow-hidden">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-4">Mặt hàng</th>
                        <th>Phân loại</th>
                        <th class="text-center">Tồn thực tế</th>
                        <th class="text-center">Trạng thái</th>
                        <th class="text-end pe-4">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="i" items="${inventoryList}">
                        <tr>
                            <td class="ps-4">
                                <div class="d-flex align-items-center gap-3">
                                    <img src="${i.hinhAnh.startsWith('http') ? i.hinhAnh : pageContext.request.contextPath.concat('/').concat(i.hinhAnh)}" 
                                         class="service-img" onerror="this.src='https://placehold.co/100x100?text=Item'">
                                    <div class="fw-bold text-dark">${i.tenDV}</div>
                                </div>
                            </td>
                            <td><span class="badge bg-light text-muted border px-3 rounded-pill">${i.tenLoaiDV}</span></td>
                            <td class="text-center fw-bold fs-5">${i.soLuongTon}</td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${i.soLuongTon < 10}">
                                        <span class="stock-low"><i class="fas fa-exclamation-triangle me-1"></i> Sắp hết hàng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="stock-ok"><i class="fas fa-check-circle me-1"></i> Ổn định</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end pe-4">
                                <button class="btn btn-primary-custom btn-sm rounded-pill px-3 fw-bold" 
                                        onclick="openImportModal('${i.maDV}', '${i.tenDV}', '${i.soLuongTon}')">
                                    <i class="fas fa-plus me-1"></i> Nhập thêm
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="importModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-inventory" method="POST">
                    <input type="hidden" name="maDV" id="import-id">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0"><i class="fas fa-truck-ramp-box me-2 text-blue-icon"></i>Phiếu nhập kho nhanh</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="text-center mb-4">
                            <h6 class="text-muted mb-1">Mặt hàng nhập:</h6>
                            <h4 class="fw-bold text-dark" id="import-name">---</h4>
                        </div>
                        
                        <div class="row g-3">
                            <div class="col-6">
                                <label class="form-label small fw-bold">Tồn hiện tại</label>
                                <input type="text" id="import-current" class="form-control rounded-3 bg-light border-0 text-center fw-bold" readonly>
                            </div>
                            <div class="col-6">
                                <label class="form-label small fw-bold text-primary">Số lượng nhập thêm</label>
                                <input type="number" name="quantity" class="form-control rounded-3 border-primary text-center fw-bold" min="1" value="1" required>
                            </div>
                        </div>
                        
                        <div class="mt-4 p-3 rounded-3 bg-light small text-muted">
                            <i class="fas fa-info-circle me-1"></i> Hệ thống sẽ tự động cộng dồn số lượng nhập vào số tồn hiện tại.
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom w-100 rounded-pill py-2 fw-bold shadow-sm">XÁC NHẬN NHẬP KHO</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function openImportModal(id, name, current) {
            document.getElementById('import-id').value = id;
            document.getElementById('import-name').innerText = name;
            document.getElementById('import-current').value = current;
            new bootstrap.Modal(document.getElementById('importModal')).show();
        }
    </script>
</body>
</html>