<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thống Kê Doanh Thu - NICE KARAOKE</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root { --orange: #ff8000; --bg: #f0f2f5; --admin-blue: #00aeef; }
        body { background: var(--bg); font-family: 'Segoe UI', sans-serif; overflow-x: hidden; }
        
        /* Đồng bộ khoảng cách với Sidebar (280px) */
        .main-wrapper { margin-left: 280px; padding: 30px; display: flex; gap: 20px; }
        
        /* Cột trái: Bộ lọc */
        .filter-sidebar { width: 320px; background: white; border-radius: 20px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); height: fit-content; border: 1px solid #eee; }
        .filter-header { color: var(--orange); font-weight: 800; border-bottom: 3px solid var(--orange); padding-bottom: 10px; margin-bottom: 25px; text-align: center; }
        
        /* Cột phải: Nội dung báo cáo */
        .report-card { flex: 1; background: white; border-radius: 20px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #eee; }
        .nav-tabs { border: none; margin-bottom: 25px; gap: 10px; }
        .nav-link { color: #888; font-weight: 600; border: none !important; cursor: pointer; padding: 12px 25px; border-radius: 12px !important; transition: 0.3s; }
        .nav-link:hover { background: #f8f9fa; }
        .nav-link.active { color: white !important; background: var(--orange) !important; box-shadow: 0 4px 12px rgba(255, 128, 0, 0.2); }
        
        .stat-box { background: #fffaf5; border: 1px solid #ffe8cc; border-radius: 18px; padding: 20px; text-align: center; transition: 0.3s; }
        .stat-box:hover { transform: translateY(-5px); border-color: var(--orange); }
        .chart-box { background: #fdfdfd; border-radius: 20px; padding: 25px; border: 1px solid #eee; margin-top: 20px; }
        .table-custom thead { background: var(--orange); color: white; }
        .table-custom { border-radius: 15px; overflow: hidden; }
        .d-none { display: none !important; }
    </style>
</head>
<body>

    <jsp:include page="sidebar.jsp"><jsp:param name="active" value="report" /></jsp:include>

    <div class="main-wrapper">
        <div class="filter-sidebar">
            <h5 class="filter-header">BỘ LỌC DOANH THU</h5>
            <form action="revenue-report" method="GET" id="reportForm">
                <input type="hidden" name="reportType" id="reportTypeInput" value="${reportType}">
                
                <div class="mb-3">
                    <label class="form-label small fw-bold">Đối tượng thống kê:</label>
                    <select name="selectedEmp" class="form-select form-select-sm shadow-sm rounded-3">
                        <option value="all" ${sEmp == 'all' ? 'selected' : ''}>-- Tất cả nhân viên --</option>
                        <c:forEach var="e" items="${empList}">
                            <option value="${e.maNV}" ${sEmp == String.valueOf(e.maNV) ? 'selected' : ''}>
                                ${e.tenNV}
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div id="dayInput" class="time-box ${reportType == 'day' ? '' : 'd-none'}">
                    <label class="form-label small fw-bold">Chọn ngày cụ thể:</label>
                    <input type="date" name="selectedDate" value="${sDate}" class="form-control form-control-sm rounded-3">
                </div>

                <div id="monthInput" class="time-box ${reportType == 'month' ? '' : 'd-none'}">
                    <div class="row g-2">
                        <div class="col-7">
                            <label class="form-label small fw-bold">Tháng:</label>
                            <select name="selectedMonth" class="form-select form-select-sm rounded-3">
                                <c:forEach var="m" begin="1" end="12">
                                    <option value="${m}" ${sMonth == String.valueOf(m) ? 'selected' : ''}>Tháng ${m}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-5">
                            <label class="form-label small fw-bold">Năm:</label>
                            <input type="number" name="selectedYear" value="${sYear}" class="form-control form-control-sm rounded-3" min="2000" max="2100">
                        </div>
                    </div>
                </div>

                <div id="yearInput" class="time-box ${reportType == 'year' ? '' : 'd-none'}">
                    <label class="form-label small fw-bold">Chọn năm:</label>
                    <input type="number" name="selectedYear" value="${sYear}" class="form-control form-control-sm rounded-3" min="2000" max="2100">
                </div>

                <button type="submit" class="btn btn-warning w-100 fw-bold text-white mt-4 shadow-sm rounded-pill py-2" style="background: var(--orange); border: none;">
                    <i class="fas fa-filter me-2"></i>ÁP DỤNG LỌC
                </button>
            </form>
        </div>

        <div class="report-card">
            <ul class="nav nav-tabs">
                <li class="nav-item">
                    <a class="nav-link ${reportType == 'day' ? 'active' : ''}" onclick="switchTab(event, 'day')">Theo Ngày</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${reportType == 'month' ? 'active' : ''}" onclick="switchTab(event, 'month')">Theo Tháng</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link ${reportType == 'year' ? 'active' : ''}" onclick="switchTab(event, 'year')">Theo Năm</a>
                </li>
            </ul>

            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <div class="stat-box">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Tổng số hóa đơn</div>
                        <h3 class="fw-bold text-primary mb-0">${revenueList.size()}</h3>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="stat-box">
                        <div class="text-muted small fw-bold text-uppercase mb-1">Doanh thu kỳ này</div>
                        <h3 class="fw-bold text-success mb-0">
                            <fmt:formatNumber value="${totalRevenue}" pattern="#,###"/> vnđ
                        </h3>
                    </div>
                </div>
            </div>

            <div class="chart-box">
                <h6 class="text-center fw-bold mb-4" style="letter-spacing: 1px; color: #555; text-transform: uppercase;">
                    Biểu đồ doanh thu Nice Karaoke
                </h6>
                <div style="height: 350px;"><canvas id="revenueChart"></canvas></div>
            </div>

            <h6 class="mt-5 fw-bold text-muted small text-uppercase"><i class="fas fa-list-ul me-2 text-warning"></i>Chi tiết lịch sử giao dịch</h6>
            <div class="table-responsive">
                <table class="table table-hover table-sm mt-3 align-middle text-center small shadow-sm table-custom border">
                    <thead class="table-dark">
                        <tr>
                            <th>Mã HĐ</th>
                            <th>Mã Phòng</th>
                            <th>Nhân Viên</th>
                            <th>Thời Điểm Thanh Toán</th>
                            <th class="text-end pe-4">Thành Tiền</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="h" items="${revenueList}">
                            <tr>
                                <td class="fw-bold text-muted">#${h.maHD}</td>
                                <td><span class="badge bg-info text-white px-3 shadow-sm rounded-pill">${h.maPhong}</span></td>
                                <td>${h.tenNV}</td>
                                <td><fmt:formatDate value="${h.gioKetThuc}" pattern="dd/MM/yyyy HH:mm"/></td>
                                <td class="text-end pe-4 fw-bold text-success">
                                    <fmt:formatNumber value="${h.tongTien}" pattern="#,###"/> vnđ
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty revenueList}">
                            <tr><td colspan="5" class="py-5 text-muted italic">Không có dữ liệu hóa đơn nào trong khoảng thời gian này.</td></tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        // Xử lý chuyển Tab và Submit tự động
        function switchTab(event, type) {
            if (event) event.preventDefault();
            document.getElementById('reportTypeInput').value = type;
            document.getElementById('reportForm').submit();
        }

        // Khởi tạo biểu đồ
        const ctx = document.getElementById('revenueChart').getContext('2d');
        const labels = [];
        const values = [];

        <c:forEach var="entry" items="${chartData}">
            labels.push("${entry.key}");
            values.push(${entry.value});
        </c:forEach>

        if (labels.length === 0) {
            labels.push("Chưa có dữ liệu");
            values.push(0);
        }

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Doanh thu thu về (vnđ)',
                    data: values,
                    backgroundColor: 'rgba(255, 128, 0, 0.8)',
                    borderColor: '#ff8000',
                    borderWidth: 2,
                    borderRadius: 8,
                    barThickness: 35
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        callbacks: {
                            label: function(context) {
                                return ' Doanh thu: ' + context.raw.toLocaleString() + ' vnđ';
                            }
                        }
                    }
                },
                scales: {
                    x: {
                        grid: { display: false },
                        title: { 
                            display: true, 
                            text: 'Thời gian (${reportType == "day" ? "Giờ trong ngày" : (reportType == "month" ? "Các ngày trong tháng" : "Các tháng trong năm")})', 
                            font: { weight: 'bold' } 
                        }
                    },
                    y: {
                        beginAtZero: true,
                        title: { display: true, text: 'Số tiền (VNĐ)', font: { weight: 'bold' } },
                        ticks: {
                            callback: function(value) { return value.toLocaleString() + ' ₫'; }
                        }
                    }
                }
            }
        });
    </script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>