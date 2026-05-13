<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý loại phòng - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --admin-blue: #00aeef; --sidebar-width: 280px; }
        body { background-color: #f0f2f5; font-family: 'Segoe UI', sans-serif; overflow-x: hidden; }
        .main-panel { margin-left: var(--sidebar-width); padding: 40px; }
        .glass-card { background: white; border-radius: 24px; border: none; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        .room-thumb { width: 60px; height: 60px; object-fit: cover; border-radius: 12px; border: 2px solid #f1f1f1; }
        .btn-primary-custom { background-color: var(--admin-blue); border: none; color: white; transition: 0.3s; }
        .btn-primary-custom:hover { background-color: #0089bd; transform: translateY(-2px); color: white; }
        .text-blue-icon { color: var(--admin-blue) !important; }
        
        /* 🖼️ CSS CHO KHUNG PREVIEW */
        .image-upload-box { background: #f8f9fa; border: 1px dashed #dee2e6; border-radius: 15px; padding: 15px; position: relative; }
        .preview-container { margin-top: 15px; display: flex; align-items: center; gap: 10px; border-top: 1px solid #eee; pt: 10px; }
        .img-preview { width: 80px; height: 80px; object-fit: cover; border-radius: 10px; border: 2px solid white; box-shadow: 0 5px 15px rgba(0,0,0,0.1); display: none; }
        .hidden-input { display: none; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp"><jsp:param name="active" value="roomTypes" /></jsp:include>

    <div class="main-panel">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h3 class="fw-bold mb-1"><i class="fas fa-layer-group me-2 text-blue-icon"></i>Quản lý loại phòng</h3>
                <p class="text-muted small">Cấu hình đơn giá và xem trước hình ảnh hạng phòng</p>
            </div>
            <button class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm" data-bs-toggle="modal" data-bs-target="#addTypeModal">
                <i class="fas fa-plus me-2"></i>Thêm loại mới
            </button>
        </div>

        <div class="glass-card overflow-hidden">
            <table class="table table-hover align-middle mb-0">
                <thead>
                    <tr>
                        <th class="ps-4">Mã</th>
                        <th>Hình ảnh</th>
                        <th>Tên loại</th>
                        <th>Giá / Giờ</th>
                        <th class="text-center">Sức chứa</th>
                        <th class="text-end pe-4">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="loai" items="${typeList}">
                        <tr>
                            <td class="ps-4 fw-bold text-blue-icon">#${loai.maLoai}</td>
                            <td>
                                <c:choose>
                                    <c:when test="${loai.hinhAnh.startsWith('http')}">
                                        <img src="${loai.hinhAnh}" class="room-thumb" onerror="this.src='https://placehold.co/100x100?text=Error'">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="${pageContext.request.contextPath}/${loai.hinhAnh}" class="room-thumb" onerror="this.src='https://placehold.co/100x100?text=Error'">
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><div class="fw-bold text-dark">${loai.tenLoai}</div></td>
                            <td><span class="text-success fw-bold"><fmt:formatNumber value="${loai.giaTheoGio}" type="currency" currencySymbol="₫" /></span></td>
                            <td class="text-center"><span class="badge bg-info bg-opacity-10 text-blue-icon px-3 rounded-pill border border-info border-opacity-25">${loai.soNguoiToiDa} người</span></td>
                            <td class="text-end pe-4">
                                <button class="btn btn-sm btn-light rounded-circle shadow-sm me-2" onclick="openEditModal('${loai.maLoai}', '${loai.tenLoai}', '${loai.giaTheoGio}', '${loai.soNguoiToiDa}', '${loai.hinhAnh}')"><i class="fas fa-user-pen text-blue-icon"></i></button>
                                <a href="manage-room-types?action=delete&id=${loai.maLoai}" class="btn btn-sm btn-light rounded-circle shadow-sm" onclick="return confirm('Xóa loại phòng này?')"><i class="fas fa-trash text-danger"></i></a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="addTypeModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-room-types" method="POST" enctype="multipart/form-data">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0"><i class="fas fa-plus-circle me-2 text-blue-icon"></i>Thêm hạng phòng</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Tên loại phòng</label>
                            <input type="text" name="name" class="form-control rounded-3 bg-light border-0" required>
                        </div>
                        <div class="row mb-3">
                            <div class="col"><label class="form-label small fw-bold">Giá (vnđ/h)</label><input type="number" name="price" class="form-control rounded-3 bg-light border-0" required></div>
                            <div class="col"><label class="form-label small fw-bold">Sức chứa</label><input type="number" name="limit" class="form-control rounded-3 bg-light border-0" required></div>
                        </div>
                        
                        <div class="image-upload-box">
                            <label class="form-label small fw-bold d-block mb-2">Hình ảnh minh họa</label>
                            <div class="d-flex gap-3 mb-2">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="imageOption" id="addFileOpt" value="file" checked onclick="toggleImageInput('add', 'file')">
                                    <label class="form-check-label small" for="addFileOpt">Tải từ máy</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="imageOption" id="addLinkOpt" value="link" onclick="toggleImageInput('add', 'link')">
                                    <label class="form-check-label small" for="addLinkOpt">Dùng Link</label>
                                </div>
                            </div>
                            
                            <div id="add-file-input">
                                <input type="file" name="imageFile" id="imageFileAdd" class="form-control form-control-sm bg-white border-0" onchange="previewImage(this, 'add')">
                            </div>
                            <div id="add-link-input" class="hidden-input">
                                <input type="text" name="imageLink" id="imageLinkAdd" class="form-control form-control-sm" placeholder="Dán link ảnh..." oninput="previewLink('add')">
                            </div>

                            <div class="preview-container">
                                <img id="add-preview" src="#" class="img-preview" alt="Preview">
                                <span id="add-preview-text" class="text-muted small">Chưa có ảnh nào được chọn</span>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold">Lưu cấu hình</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editTypeModal" tabindex="-1">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content border-0 shadow-lg rounded-4">
                <form action="manage-room-types?action=update" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="id" id="edit-id">
                    <div class="modal-header border-0 p-4 pb-0">
                        <h5 class="fw-bold m-0"><i class="fas fa-pen-to-square me-2 text-blue-icon"></i>Cập nhật loại phòng</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label small fw-bold">Tên loại phòng</label>
                            <input type="text" name="name" id="edit-name" class="form-control rounded-3 bg-light border-0" required>
                        </div>
                        <div class="row mb-3">
                            <div class="col"><label class="form-label small fw-bold">Giá (vnđ/h)</label><input type="number" name="price" id="edit-price" class="form-control rounded-3 bg-light border-0" required></div>
                            <div class="col"><label class="form-label small fw-bold">Sức chứa</label><input type="number" name="limit" id="edit-limit" class="form-control rounded-3 bg-light border-0" required></div>
                        </div>

                        <div class="image-upload-box">
                            <label class="form-label small fw-bold d-block mb-2 text-blue-icon">Đổi hình ảnh</label>
                            <div class="d-flex gap-3 mb-2">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="imageOption" id="editFileOpt" value="file" onclick="toggleImageInput('edit', 'file')">
                                    <label class="form-check-label small" for="editFileOpt">Tải từ máy</label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="imageOption" id="editLinkOpt" value="link" checked onclick="toggleImageInput('edit', 'link')">
                                    <label class="form-check-label small" for="editLinkOpt">Dùng Link</label>
                                </div>
                            </div>
                            <div id="edit-file-input" class="hidden-input">
                                <input type="file" name="imageFile" id="imageFileEdit" class="form-control form-control-sm bg-white border-0" onchange="previewImage(this, 'edit')">
                            </div>
                            <div id="edit-link-input">
                                <input type="text" name="imageLink" id="edit-image-link" class="form-control form-control-sm" oninput="previewLink('edit')">
                            </div>

                            <div class="preview-container">
                                <img id="edit-preview" src="#" class="img-preview" alt="Preview">
                                <span id="edit-preview-text" class="text-muted small">Đang hiển thị ảnh cũ</span>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-0 p-4 pt-0">
                        <button type="submit" class="btn btn-primary-custom rounded-pill px-4 fw-bold shadow-sm">Cập nhật ngay</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // 1. Ẩn hiện ô nhập liệu
        function toggleImageInput(modalType, option) {
            document.getElementById(modalType + '-file-input').style.display = (option === 'file' ? 'block' : 'none');
            document.getElementById(modalType + '-link-input').style.display = (option === 'link' ? 'block' : 'none');
        }

        // 2. Preview cho File tải lên
        function previewImage(input, modalType) {
            const preview = document.getElementById(modalType + '-preview');
            const text = document.getElementById(modalType + '-preview-text');
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                    preview.style.display = 'block';
                    text.style.display = 'none';
                }
                reader.readAsDataURL(input.files[0]);
            }
        }

        // 3. Preview cho Link dán vào
        function previewLink(modalType) {
            const link = document.getElementById(modalType === 'add' ? 'imageLinkAdd' : 'edit-image-link').value;
            const preview = document.getElementById(modalType + '-preview');
            const text = document.getElementById(modalType + '-preview-text');
            if (link) {
                preview.src = link;
                preview.style.display = 'block';
                text.style.display = 'none';
            } else {
                preview.style.display = 'none';
                text.style.display = 'block';
            }
        }

        function openEditModal(id, name, price, limit, img) {
            document.getElementById('edit-id').value = id;
            document.getElementById('edit-name').value = name;
            document.getElementById('edit-price').value = price;
            document.getElementById('edit-limit').value = limit;
            
            // Xử lý ảnh cũ
            const preview = document.getElementById('edit-preview');
            const text = document.getElementById('edit-preview-text');
            const fullPath = img.startsWith('http') ? img : '${pageContext.request.contextPath}/' + img;
            
            document.getElementById('edit-image-link').value = img;
            preview.src = fullPath;
            preview.style.display = 'block';
            text.style.display = 'none';
            
            new bootstrap.Modal(document.getElementById('editTypeModal')).show();
        }
    </script>
</body>
</html>