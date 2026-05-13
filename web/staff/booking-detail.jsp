<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@page import="java.time.*, java.time.format.*" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết phiếu #${booking.maPhieu} - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root { --dark: #1a1a1a; --primary-orange: #ff8c00; }
        body { background-color: #f4f7f6; padding-top: 100px; font-family: 'Segoe UI', Tahoma, sans-serif; }
        .invoice-card { border: none; border-radius: 25px; overflow: hidden; box-shadow: 0 15px 35px rgba(0,0,0,0.1); background: white; }
        .header-box { background: var(--dark); color: white; border-bottom: 5px solid var(--primary-orange); }
        .header-box.bg-cancelled { background: #6c757d; border-bottom: 5px solid #343a40; }
        .grand-total { font-size: 1.8rem; color: #dc3545; font-weight: bold; }
        .section-title { border-left: 5px solid var(--primary-orange); padding-left: 15px; font-weight: bold; margin-bottom: 20px; }

        #invoice-print-area { display: none; }
        @media print {
            body * { visibility: hidden; }
            #invoice-print-area, #invoice-print-area * { visibility: visible; }
            #invoice-print-area {
                display: block !important;
                position: absolute; left: 0; top: 0; width: 80mm; padding: 5mm;
                background: white; color: black;
                font-family: 'Courier New', monospace; font-size: 13px;
            }
            .no-print { display: none !important; }
            @page { size: auto; margin: 0; }
            .bill-line { border-top: 1px dashed black; margin: 8px 0; }
            table { width: 100%; border-collapse: collapse; }
        }
    </style>
</head>
<body>

    <div class="no-print">
        <jsp:include page="navbar.jsp" />
    </div>

    <div class="container py-4 no-print">
        <div class="mb-4">
            <a href="booking-history" class="btn btn-outline-secondary rounded-pill px-3 shadow-sm">
                <i class="fas fa-arrow-left me-1"></i> Quay lại lịch sử
            </a>
        </div>

        <c:if test="${empty booking}">
            <div class="alert alert-danger rounded-4 shadow-sm p-5 text-center">
                <i class="fas fa-exclamation-triangle fa-3x mb-3"></i>
                <h3>Không tìm thấy phiếu này!</h3>
            </div>
        </c:if>

        <c:if test="${not empty booking}">
            <%
                long mins = 0; double tienG = 0;
                String displayVao = "--:--", displayTra = "--:--", displayNgay = "---";
                try {
                    model.PhieuDatPhong b = (model.PhieuDatPhong) request.getAttribute("booking");
                    DateTimeFormatter outFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
                    if (b != null && b.getGioDat() != null) {
                        String strDat = b.getGioDat().replace(" ", "T");
                        if (strDat.contains(".")) strDat = strDat.substring(0, strDat.indexOf("."));
                        LocalDateTime start = LocalDateTime.parse(strDat);
                        displayVao = start.format(outFmt);
                        displayNgay = start.format(dateFmt);
                        if (b.getGioTra() != null) {
                            String strTra = b.getGioTra().replace(" ", "T");
                            if (strTra.contains(".")) strTra = strTra.substring(0, strTra.indexOf("."));
                            LocalDateTime end = LocalDateTime.parse(strTra);
                            displayTra = end.format(outFmt);
                            mins = java.time.Duration.between(start, end).toMinutes();
                            if (mins < 0) mins = 0;
                            tienG = (mins / 60.0) * b.getGiaTheoGio();
                        }
                    }
                } catch (Exception e) { System.out.println("Lỗi parse ngày: " + e.getMessage()); }
                pageContext.setAttribute("minutes", mins);
                pageContext.setAttribute("tienGio", tienG);
                pageContext.setAttribute("strVao", displayVao);
                pageContext.setAttribute("strTra", displayTra);
                pageContext.setAttribute("strNgay", displayNgay);
            %>

            <%-- Khai báo totalDV TRƯỚC vòng lặp để dùng được ở phần in --%>
            <c:set var="totalDV" value="0" />
            <c:forEach var="item" items="${detailItems}">
                <c:set var="totalDV" value="${totalDV + (item.gia * item.soLuong)}" />
            </c:forEach>

            <div class="card invoice-card shadow-lg">
                <c:choose>
                    <c:when test="${booking.trangThai == 3}">
                        <div class="header-box p-5 text-center">
                            <h1 class="fw-bold mb-1 text-uppercase">Hóa đơn thanh toán</h1>
                            <p class="mb-0 opacity-75">Mã phiếu: #${booking.maPhieu} | Ngày: ${strNgay}</p>
                            <div class="mt-3">
                                <span class="badge bg-warning text-dark fs-5 px-4 py-2 rounded-pill">PHÒNG ${booking.tenPhong}</span>
                            </div>
                        </div>

                        <div class="card-body p-5">
                            <div class="row mb-4">
                                <div class="col-md-6 border-end">
                                    <small class="text-muted fw-bold text-uppercase">Khách hàng</small>
                                    <h5 class="fw-bold text-primary">${not empty booking.tenKH ? booking.tenKH : 'Khách lẻ'}</h5>
                                    <p class="text-muted small">SĐT: ${not empty booking.sdt ? booking.sdt : '---'}</p>
                                </div>
                                <div class="col-md-6 ps-md-4 text-md-end">
                                    <small class="text-muted fw-bold text-uppercase">Nhân viên thực hiện</small>
                                    <h5 class="fw-bold text-success">
                                        <i class="fas fa-user-check me-1"></i>${booking.nguoiXuLy}
                                    </h5>
                                </div>
                            </div>

                            <div class="row mb-5 bg-light p-4 rounded-4 border text-center">
                                <div class="col-md-4 border-end">
                                    <small class="text-muted d-block">Giờ vào</small><b>${strVao}</b>
                                </div>
                                <div class="col-md-4 border-end">
                                    <small class="text-muted d-block">Giờ ra</small><b>${strTra}</b>
                                </div>
                                <div class="col-md-4">
                                    <small class="text-muted d-block">Tổng thời gian</small>
                                    <b class="text-primary">${minutes} phút</b>
                                </div>
                            </div>

                            <h5 class="section-title">CHI TIẾT DỊCH VỤ</h5>
                            <div class="table-responsive mb-4">
                                <table class="table table-hover align-middle">
                                    <thead class="table-dark">
                                        <tr>
                                            <th>Tên món/dịch vụ</th>
                                            <th class="text-center">Số lượng</th>
                                            <th class="text-end">Đơn giá</th>
                                            <th class="text-end">Thành tiền</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="item" items="${detailItems}">
                                            <tr>
                                                <td class="fw-bold">${item.tenDV}</td>
                                                <td class="text-center">x${item.soLuong}</td>
                                                <td class="text-end"><fmt:formatNumber value="${item.gia}" />đ</td>
                                                <td class="text-end fw-bold">
                                                    <fmt:formatNumber value="${item.gia * item.soLuong}" />đ
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty detailItems}">
                                            <tr><td colspan="4" class="text-center text-muted py-4">Không có dịch vụ đi kèm.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>

                            <div class="row justify-content-end">
                                <div class="col-lg-5">
                                    <div class="p-4 rounded-4 bg-light shadow-sm">
                                        <div class="d-flex justify-content-between mb-2">
                                            <span>Tiền dịch vụ:</span>
                                            <b><fmt:formatNumber value="${totalDV}" />đ</b>
                                        </div>
                                        <div class="d-flex justify-content-between mb-3">
                                            <span>Tiền giờ (<fmt:formatNumber value="${booking.giaTheoGio}" />đ/h):</span>
                                            <b><fmt:formatNumber value="${tienGio}" />đ</b>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                            <h4 class="fw-bold mb-0">TỔNG CỘNG</h4>
                                            <span class="grand-total">
                                                <fmt:formatNumber value="${totalDV + tienGio}" />đ
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="mt-5 text-center">
                                <button class="btn btn-dark rounded-pill px-5 py-3 fw-bold" onclick="window.print()">
                                    <i class="fas fa-print me-2"></i>IN LẠI HÓA ĐƠN
                                </button>
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="header-box bg-cancelled p-5 text-center">
                            <h1 class="fw-bold mb-1 text-uppercase">Thông tin phiếu đặt</h1>
                            <p class="mb-0 opacity-75">
                                Mã phiếu: #${booking.maPhieu} | Trạng thái:
                                <span class="badge bg-danger">ĐÃ HỦY</span>
                            </p>
                        </div>
                        <div class="card-body p-5 text-center">
                            <div class="alert alert-secondary rounded-4 p-5 mb-5">
                                <i class="fas fa-ban fa-3x mb-3 opacity-25"></i>
                                <h4>Phiếu này đã bị hủy!</h4>
                                <p class="mb-0">Lý do: Khách không đến hoặc nhân viên chủ động hủy.</p>
                            </div>
                            <a href="booking-history" class="btn btn-primary rounded-pill px-5 fw-bold">
                                QUAY LẠI DANH SÁCH
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
    </div>

    <%-- KHU VỰC IN NHIỆT --%>
    <c:if test="${not empty booking && booking.trangThai == 3}">
        <div id="invoice-print-area">
            <div style="text-align:center;">
                <b style="font-size:18px;">NICE KARAOKE</b><br>
                <small>Đà Nẵng - Hotline: 0905.xxx.xxx</small>
                <div class="bill-line"></div>
                <b style="font-size:16px;">HÓA ĐƠN TÍNH TIỀN</b><br>
                <small>Mã HD: #${booking.maPhieu}</small>
            </div>
            <div style="margin-top:10px; font-size:12px; line-height:1.6;">
                <b>Phòng: ${booking.tenPhong}</b><br>
                Khách: ${not empty booking.tenKH ? booking.tenKH : 'Khách lẻ'}<br>
                Vào: ${strVao}<br>
                Ra: ${strTra}<br>
                Thời gian: ${minutes} phút<br>
                Thu ngân: ${booking.nguoiXuLy}
            </div>
            <div class="bill-line"></div>
            <table style="font-size:12px; width:100%;">
                <c:forEach var="item" items="${detailItems}">
                    <tr>
                        <td>${item.tenDV} x${item.soLuong}</td>
                        <td align="right"><fmt:formatNumber value="${item.gia * item.soLuong}" />đ</td>
                    </tr>
                </c:forEach>
            </table>
            <div class="bill-line" style="border-top:1px solid black;"></div>
            <div style="font-size:12px;">
                <div style="display:flex; justify-content:space-between;">
                    <span>Tiền dịch vụ:</span>
                    <b><fmt:formatNumber value="${totalDV}" />đ</b>
                </div>
                <div style="display:flex; justify-content:space-between;">
                    <span>Tiền giờ hát:</span>
                    <b><fmt:formatNumber value="${tienGio}" />đ</b>
                </div>
            </div>
            <div class="bill-line" style="border-top:1px solid black;"></div>
            <div style="display:flex; justify-content:space-between; font-size:15px; font-weight:bold;">
                <span>TỔNG CỘNG:</span>
                <span><fmt:formatNumber value="${totalDV + tienGio}" />đ</span>
            </div>
            <div class="bill-line"></div>
            <div style="text-align:center; font-style:italic; font-size:11px;">
                Cảm ơn quý khách! Hẹn gặp lại.
            </div>
        </div>
    </c:if>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Polling chuông navbar
        function pollNotifications() {
            fetch('${pageContext.request.contextPath}/staff/api-pending-summary')
            .then(res => res.text()).then(data => {
                if (data && data.includes("|")) {
                    let parts = data.split("|");
                    let total = (parts[0] ? parts[0].split(",").filter(x => x).length : 0)
                              + (parts[1] ? parts[1].split(",").filter(x => x).length : 0)
                              + (parts[2] ? parts[2].split(",").filter(x => x).length : 0);
                    let badge = document.getElementById('total-count');
                    if (badge) { badge.innerText = total; badge.classList.toggle('d-none', total === 0); }
                }
            });
        }

        window.onload = function() {
            pollNotifications();
            setInterval(pollNotifications, 5000);

            // ✅ Tự động in nếu vừa thanh toán xong từ payment
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('print') === 'true') {
                setTimeout(() => window.print(), 800);
            }
        };
    </script>
</body>
</html>