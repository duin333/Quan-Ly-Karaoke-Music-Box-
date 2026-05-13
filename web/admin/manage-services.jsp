<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý thực đơn - NICE KARAOKE</title>
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
        
        /* Status Badges - Đã cập nhật Ẩn/Hiện */
        .status-active { color: #198754; background: #e8f5e9; padding: 6px 14px; border-radius: 50px; font-size: 0.75rem; font-weight: 700; border: 1px solid #c8e6c9; }
        .status-locked { color: #dc3545; background: #fdecea; padding: 6px 14px; border-radius: 50px; font-size: 0.75rem; font-weight: 700; border: 1px solid #ffcdd2; }
        
        /* Table Custom */
        .table thead { background-color: #f8f9fa; }
        .table th { border: none; font-size: 0.75rem; text-transform: uppercase; color: #6c757d; padding: 15px; }
        .table td { padding: 15px; vertical-align: middle; border-bottom: 1px solid #f1f1f1; }
        
        /* Image Style */
        .service-img { width: 55px; height: 55px; object-fit: cover; border-radius: 12px; border: 2px solid #fff; box-shadow: 0 4px 10px rgba(0,0,0,0.05); }
        
        /* Button & Input Custom */
        .btn-primary-custom { background-color: var(--admin-blue); border: none; color: white; transition: 0.3s; }
        .btn-primary-custom:hover { background-color: #0089bd; transform: translateY(-2px); color: white; }
        .form-control:focus, .form-select:focus { border-color: var(--admin-blue); box-shadow: 0 0 0 0.25rem rgba(0, 174, 239, 0.1); }
        .text-blue-icon { color: var(--admin-blue) !important; }

        /* Preview Box */
        .image-upload-box { background: #f8f9fa; border: 1px dashed #dee2e6; border-radius: 15px; padding: 15px; }
        .preview-img { width: 80px; height: 80px; object-fit: cover; border-radius: 10px; display: none; border: 2px solid white; box-shadow: 0 5px 15px rgba(0,0,0,0.1); }
        .hidden-input { display: none; }
        
        /* Hover hàng table */
        .table-hover tbody tr:hover { background-color: #f8fdff; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp">
        <jsp:param name="active" value="services" />
    </jsp:include>

    <div class="main-panel">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold mb-1"><i class="fas fa-utensils me-2 text-blue-icon"></i>Quản lý thực đơn</h3>
                <p class="text-muted small">Cập nhật giá bán, hình ảnh và kiểm soát trạng thái hiển thị món</p>
            </div>
            <button class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#addServiceModal">
                <i class="fas fa-plus me-2"></i>Thêm món mới
            </button>
        </div>

        <div class="glass-card p-4 mb-4">
            <form action="manage-services" method="GET" class="row g-3">
                <div class="col-md-5">
                    <div class="input-group">
                        <span class="input-group-text bg-light border-end-0 rounded-start-pill"><i class="fas fa-search text-muted"></i></span>
                        <input type="text" name="txtSearch" value="${lastSearch}" class="form-control bg-light border-start-0 rounded-end-pill" placeholder="Tìm tên món ăn, đồ uống...">
                    </div>
                </div>
                <div class="col-md-4">
                    <select name="categoryFilter" class="form-select bg-light rounded-pill">
                        <option value="">-- Tất cả loại dịch vụ --</option>
                        <c:forEach var="c" items="${categoryList}">
                            <option value="${c.maLoaiDV}" ${lastCategory == c.maLoaiDV ? 'selected' : ''}>${c.tenLoaiDV}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-3">
                    <button type="submit" class="btn btn-dark w-100 rounded-pill fw-bold shadow-sm">Lọc thực đơn</button>
                </div>
            </form>
        </div>

        <div class="glass-card overflow-hidden">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-4">Ảnh</th>
                        <th>Tên dịch vụ</th>
                        <th>Phân loại</th>
                        <th>Giá bán</th>
                        <th class="text-center">Tồn kho</th>
                        <th class="text-center">Menu (Ẩn/Hiện)</th>
                        <th class="text-end pe-4">Thao tác</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="s" items="${serviceList}">
                        <tr>
                            <td class="ps-4">
                                <c:set var="imgPath" value="${s.hinhAnh.startsWith('http') ? s.hinhAnh : pageContext.request.contextPath.concat('/').concat(s.hinhAnh)}" />
                                <img src="${imgPath}" class="service-img" onerror="this.src='https://placehold.co/100x100?text=Karaoke'">
                            </td>
                            <td><div class="fw-bold text-dark">${s.tenDV}</div></td>
                            <td>
                                <span class="badge bg-info bg-opacity-10 text-blue-icon px-3 rounded-pill border border-info border-opacity-25">
                                    ${s.tenLoaiDV}
                                </span>
                            </td>
                            <td><span class="text-success fw-bold"><fmt:formatNumber value="${s.gia}" type="currency" currencySymbol="₫" /></span></td>
                            <td class="text-center">
                                <span class="${s.soLuongTon < 10 ? 'status-locked' : 'status-active'}">
                                    ${s.soLuongTon}
                                </span>
                            </td>
                            <td class="text-center">
                                <c:choose>
                                    <c:when test="${s.trangThaiHienThi == 1}">
                                        <a href="manage-services?action=toggle&id=${s.maDV}&status=0" title="Bấm để ẩn món này">
                                            <span class="status-active"><i class="fas fa-eye me-1"></i> ĐANG HIỆN</span>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="manage-services?action=toggle&id=${s.maDV}&status=1" title="Bấm để hiện món này">
                                            <span class="status-locked"><i class="fas fa-eye-slash me-1"></i> ĐANG ẨN</span>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end pe-4">
                                <button class="btn btn-sm btn-light rounded-circle shadow-sm me-2" 
                                        onclick="openEditModal('${s.maDV}', '${s.tenDV}', '${s.gia}', '${s.soLuongTon}', '${s.maLoaiDV}', '${s.hinhAnh}', '${s.trangThaiHienThi}')">
                                    <i class="fas fa-pen-to-square text-blue-icon"></i>
                                </button>
                                <a href="manage-services?action=delete&id=${s.maDV}" class="btn btn-sm btn-light rounded-circle shadow-sm" onclick="return confirm('Xóa vĩnh viễn món này khỏi menu?')">
                                    <i class="fas fa-trash text-danger"></i>
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty serviceList}">
                        <tr>
                            <td colspan="7" class="py-5 text-center text-muted">
                                <i class="fas fa-utensils fa-3x mb-3 opacity-25"></i>
                                <p>Không tìm thấy món ăn nào phù hợp.</p>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="addServiceModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-services" method="POST" enctype="multipart/form-data">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-plus-circle me-2 text-blue-icon"></i>Thêm món mới</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Tên món</label>
                            <input type="text" name="name" class="form-control rounded-3 bg-light border-0" placeholder="Ví dụ: Bia Tiger Lon" required>
                        </div>
                        <div class="row mb-3">
                            <div class="col"><label class="form-label small fw-bold">Giá bán</label><input type="number" name="price" class="form-control rounded-3 bg-light border-0" required></div>
                            <div class="col"><label class="form-label small fw-bold">Tồn kho</label><input type="number" name="stock" class="form-control rounded-3 bg-light border-0" required></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col">
                                <label class="form-label small fw-bold">Phân loại</label>
                                <select name="categoryId" class="form-select rounded-3 bg-light border-0">
                                    <c:forEach var="c" items="${categoryList}"><option value="${c.maLoaiDV}">${c.tenLoaiDV}</option></c:forEach>
                                </select>
                            </div>
                            <div class="col">
                                <label class="form-label small fw-bold">Trạng thái ban đầu</label>
                                <select name="status" class="form-select rounded-3 bg-light border-0 text-success fw-bold">
                                    <option value="1">Hiển thị ngay</option>
                                    <option value="0">Tạm ẩn</option>
                                </select>
                            </div>
                        </div>
                        <div class="image-upload-box">
                            <label class="form-label small fw-bold d-block mb-2">Hình ảnh món ăn</label>
                            <div class="d-flex gap-3 mb-2 small">
                                <div class="form-check"><input class="form-check-input" type="radio" name="imgOpt" id="addF" value="file" checked onclick="toggleImg('add','file')"><label class="form-check-label" for="addF">Tải lên</label></div>
                                <div class="form-check"><input class="form-check-input" type="radio" name="imgOpt" id="addL" value="link" onclick="toggleImg('add','link')"><label class="form-check-label" for="addL">Dùng Link</label></div>
                            </div>
                            <div id="add-f-in"><input type="file" name="imageFile" class="form-control form-control-sm bg-white" onchange="preImg(this,'add')"></div>
                            <div id="add-l-in" class="hidden-input"><input type="text" name="imageLink" id="add-link-val" class="form-control form-control-sm" placeholder="Nhập URL ảnh..." oninput="preLink('add')"></div>
                            <div class="mt-3 d-flex align-items-center gap-3">
                                <img id="add-pre" src="#" class="preview-img" alt="Preview">
                                <span id="add-pre-txt" class="text-muted small">Chưa chọn ảnh</span>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold">Lưu món ăn</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editServiceModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-services?action=update" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="id" id="edit-id">
                    <input type="hidden" name="oldImage" id="edit-old-img">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0 text-dark"><i class="fas fa-pen-to-square me-2 text-blue-icon"></i>Cập nhật món ăn</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3"><label class="form-label small fw-bold">Tên món</label><input type="text" name="name" id="edit-name" class="form-control rounded-3 bg-light border-0" required></div>
                        <div class="row mb-3">
                            <div class="col"><label class="form-label small fw-bold">Giá bán</label><input type="number" name="price" id="edit-price" class="form-control rounded-3 bg-light border-0" required></div>
                            <div class="col"><label class="form-label small fw-bold">Tồn kho</label><input type="number" name="stock" id="edit-stock" class="form-control rounded-3 bg-light border-0" required></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col">
                                <label class="form-label small fw-bold">Phân loại</label>
                                <select name="categoryId" id="edit-cate" class="form-select rounded-3 bg-light border-0">
                                    <c:forEach var="c" items="${categoryList}"><option value="${c.maLoaiDV}">${c.tenLoaiDV}</option></c:forEach>
                                </select>
                            </div>
                            <div class="col">
                                <label class="form-label small fw-bold">Trạng thái</label>
                                <select name="status" id="edit-status" class="form-select rounded-3 bg-light border-0 fw-bold">
                                    <option value="1" class="text-success">Đang hiển thị</option>
                                    <option value="0" class="text-danger">Tạm ẩn món</option>
                                </select>
                            </div>
                        </div>
                        <div class="image-upload-box">
                            <label class="form-label small fw-bold d-block mb-2">Đổi hình ảnh</label>
                            <div class="d-flex gap-3 mb-2 small">
                                <div class="form-check"><input class="form-check-input" type="radio" name="imgOpt" id="editF" value="file" onclick="toggleImg('edit','file')"><label class="form-check-label" for="editF">Tải lên</label></div>
                                <div class="form-check"><input class="form-check-input" type="radio" name="imgOpt" id="editL" value="link" checked onclick="toggleImg('edit','link')"><label class="form-check-label" for="editL">Dùng Link</label></div>
                            </div>
                            <div id="edit-f-in" class="hidden-input"><input type="file" name="imageFile" class="form-control form-control-sm bg-white" onchange="preImg(this,'edit')"></div>
                            <div id="edit-l-in"><input type="text" name="imageLink" id="edit-link-val" class="form-control form-control-sm" oninput="preLink('edit')"></div>
                            <div class="mt-3 d-flex align-items-center gap-3">
                                <img id="edit-pre" src="#" class="preview-img" alt="Preview">
                                <span id="edit-pre-txt" class="text-muted small">Đang hiện ảnh cũ</span>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold">Cập nhật ngay</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleImg(m, opt) {
            document.getElementById(m+'-f-in').style.display = (opt==='file'?'block':'none');
            document.getElementById(m+'-l-in').style.display = (opt==='link'?'block':'none');
        }
        function preImg(input, m) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = e => { 
                    document.getElementById(m+'-pre').src = e.target.result;
                    document.getElementById(m+'-pre').style.display = 'block';
                    document.getElementById(m+'-pre-txt').style.display = 'none';
                };
                reader.readAsDataURL(input.files[0]);
            }
        }
        function preLink(m) {
            const link = document.getElementById(m==='add'?'add-link-val':'edit-link-val').value;
            if(link) {
                document.getElementById(m+'-pre').src = link;
                document.getElementById(m+'-pre').style.display = 'block';
                document.getElementById(m+'-pre-txt').style.display = 'none';
            }
        }
        // ✅ Cập nhật hàm mở Modal sửa: Thêm trạng thái (status)
        function openEditModal(id, name, price, stock, cateId, img, status) {
            document.getElementById('edit-id').value = id;
            document.getElementById('edit-name').value = name;
            document.getElementById('edit-price').value = price;
            document.getElementById('edit-stock').value = stock;
            document.getElementById('edit-cate').value = cateId;
            document.getElementById('edit-link-val').value = img;
            document.getElementById('edit-old-img').value = img;
            document.getElementById('edit-status').value = status;
            
            // Đổi màu text select status theo giá trị
            const statusSelect = document.getElementById('edit-status');
            statusSelect.className = 'form-select rounded-3 bg-light border-0 fw-bold ' + (status == 1 ? 'text-success' : 'text-danger');
            
            const pre = document.getElementById('edit-pre');
            pre.src = img.startsWith('http') ? img : '${pageContext.request.contextPath}/' + img;
            pre.style.display = 'block';
            document.getElementById('edit-pre-txt').style.display = 'none';
            
            new bootstrap.Modal(document.getElementById('editServiceModal')).show();
        }
    </script>
</body>
</html>