package controller.staff;

import dal.YeuCauGoiMonDAO;
import dal.PhongDAO; 
import dal.DichVuDAO;
import model.YeuCauGoiMon;
import model.DichVu;
import model.PhieuDatPhong;
import model.NhanVien;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(urlPatterns = {
    "/staff/api-pending-summary", 
    "/staff/api-get-room-orders", 
    "/staff/api-get-room-serve-list",
    "/staff/process-order",
    "/staff/process-order-all",
    "/guest/api-get-invoice",           
    "/staff/api-manage-inventory",
    "/staff/update-service-stock",
    "/staff/api-checkout-summary",    
    "/staff/confirm-payment",
    "/staff/api-get-active-bookings",
    "/staff/api-get-revenue",           
    "/staff/update-room-status-api",
    "/staff/api-order-update",          
    "/staff/api-search-services",
    "/staff/api-call-support",
    "/staff/api-switch-room",
    "/staff/api-toggle-service-status"
})
public class OrderApiServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();
        PhongDAO rDao = new PhongDAO();
        String path = request.getServletPath();
        response.setContentType("text/html;charset=UTF-8");

        // 1. CHUÔNG THÔNG BÁO
        if (path.contains("api-pending-summary")) {
            List<YeuCauGoiMon> list = dao.getPendingOrders();
            Set<String> uniqueRooms = new HashSet<>();
            for (YeuCauGoiMon yc : list) uniqueRooms.add(yc.getMaPhong());
            String roomsStr = String.join(",", uniqueRooms);

            List<String> supportWaiting = rDao.getRoomsBySupportStatus(1);
            List<String> supportComing = rDao.getRoomsBySupportStatus(2);
            
            String waitingStr = String.join(",", supportWaiting);
            String comingStr = String.join(",", supportComing);
            
            response.getWriter().write(roomsStr + "|" + waitingStr + "|" + comingStr);
        } 
        
        // 2. LẤY MÓN CHỜ DUYỆT (Staff)
        else if (path.contains("api-get-room-orders")) {
            String maPhong = request.getParameter("maPhong");
            List<YeuCauGoiMon> list = dao.getOrdersByRoom(maPhong); 
            StringBuilder sb = new StringBuilder();
            int supportStatus = rDao.getSupportStatus(maPhong); 
            String supportNote = rDao.getSupportNote(maPhong);

            if (supportStatus > 0) {
                String alertClass = (supportStatus == 1) ? "alert-danger" : "alert-warning";
                String statusText = (supportStatus == 1) ? "ĐANG GỌI HỖ TRỢ" : "ĐANG XỬ LÝ SỰ CỐ";
                String btnText = (supportStatus == 1) ? "TIẾP NHẬN (ĐANG ĐẾN)" : "HOÀN THÀNH XỬ LÝ";
                String action = (supportStatus == 1) ? "accept" : "complete";

                sb.append("<div class='alert ").append(alertClass).append(" shadow-sm rounded-4 p-3 mb-3'>");
                sb.append("  <div class='d-flex justify-content-between align-items-center'>");
                sb.append("    <div><strong class='d-block text-uppercase'>").append(statusText).append("</strong>");
                sb.append("    <small>Lý do: ").append(supportNote.isEmpty() ? "<span class='text-decoration-underline'>Trống (Vui lòng gọi xác nhận)</span>" : supportNote).append("</small></div>");
                sb.append("    <button class='btn btn-sm btn-dark rounded-pill px-3' onclick='handleSupportAction(\"").append(maPhong).append("\", \"").append(action).append("\")'>").append(btnText).append("</button>");
                sb.append("  </div></div>");
            }

            sb.append("<div class='d-flex justify-content-between align-items-center mb-3'>");
            sb.append("  <h6 class='mb-0 fw-bold text-dark'><i class='fas fa-clipboard-list me-2'></i>Yêu cầu mới từ khách</h6>");
            sb.append("  <div class='d-flex gap-2'>"); 
            sb.append("    <button type='button' class='btn btn-sm btn-outline-secondary rounded-pill px-3 shadow-none' onclick='openSwitchRoom(\"").append(maPhong).append("\")'>");
            sb.append("      <i class='fas fa-exchange-alt me-1'></i>Đổi phòng</button>");
            sb.append("    <button type='button' class='btn btn-sm btn-outline-primary rounded-pill px-3 shadow-none' onclick='toggleAdvancedTools()'>");
            sb.append("      <i class='fas fa-edit me-1'></i>Cập nhật đơn</button>");
            sb.append("  </div></div>");

            double totalPending = 0;
            if (list.isEmpty()) {
                sb.append("<div class='text-center py-4 text-muted small'>Không có món mới chờ duyệt.</div>");
            } else {
                sb.append("<table class='table align-middle table-sm'><tbody>");
                for (YeuCauGoiMon yc : list) {
                    totalPending += (yc.getGia() * yc.getSoLuong());
                    sb.append("<tr><td><div class='fw-bold'>").append(yc.getTenDV()).append("</div><small class='text-muted'>").append(String.format("%,.0f", yc.getGia())).append("đ</small></td>");
                    sb.append("<td class='text-center'><span class='static-qty fw-bold text-primary'>x").append(yc.getSoLuong()).append("</span>");
                    sb.append("<div class='advanced-edit d-none btn-group btn-group-sm align-items-center'>"); 
                    sb.append("<button type='button' class='btn btn-light border btn-sm' onclick='changeQty(").append(yc.getMaYC()).append(",").append(yc.getSoLuong()-1).append(")'>-</button>");
                    sb.append("<input type='number' class='form-control form-control-sm text-center d-inline-block' style='width: 50px; font-weight: bold;' value='").append(yc.getSoLuong()).append("' onchange='changeQty(").append(yc.getMaYC()).append(", this.value)'>");                   
                    sb.append("<button type='button' class='btn btn-light border btn-sm' onclick='changeQty(").append(yc.getMaYC()).append(",").append(yc.getSoLuong()+1).append(")'>+</button></div></td>");
                    sb.append("<td class='text-end'><div class='d-flex gap-1 justify-content-end'>");
                    sb.append("<button type='button' class='btn btn-success btn-sm' onclick='processSingle(").append(yc.getMaYC()).append(", 1)'><i class='fas fa-check'></i></button>");
                    sb.append("<button type='button' class='btn btn-outline-danger btn-sm' onclick='deleteItem(").append(yc.getMaYC()).append(")'><i class='fas fa-trash-can'></i></button></div></td></tr>");
                }
                sb.append("</tbody></table>");
            }

            sb.append("<div id='advanced-panel' class='d-none mt-3 p-3 bg-light rounded-3 border border-primary border-opacity-25 shadow-sm'>");
            sb.append("  <label class='small fw-bold text-primary mb-2'><i class='fas fa-search-plus me-1'></i>Thêm món nhanh:</label>");
            sb.append("  <div class='position-relative mb-2'>");
            sb.append("    <input type='text' id='searchFood' class='form-control form-control-sm' placeholder='Gõ tên món...' onkeyup='searchAndSuggest(\"").append(maPhong).append("\")' autocomplete='off'>");
            sb.append("    <div id='suggestBox' class='list-group mt-1 shadow-lg' style='position:absolute; z-index:1100; width:100%; display:none;'></div></div>");
            sb.append("  <textarea id='orderNote' class='form-control form-control-sm' rows='2' placeholder='Ghi chú cho bếp...' onchange='updateOrderNote(\"").append(maPhong).append("\")'></textarea></div>");

            sb.append("<div class='mt-3 d-flex justify-content-between align-items-center p-3 bg-dark text-white rounded-3 shadow'>");
            sb.append("  <div>Tạm tính: <span class='text-warning fw-bold fs-5'>").append(String.format("%,.0f", totalPending)).append("đ</span></div>");
            sb.append("  <button class='btn btn-warning fw-bold rounded-pill px-4' onclick='approveAll(\"").append(maPhong).append("\")'>DUYỆT TOÀN BỘ</button></div>");

            response.getWriter().write(sb.toString());
        }

        // 3. KHAY PHỤC VỤ (Giao món)
        else if (path.contains("api-get-room-serve-list")) {
            String maPhong = request.getParameter("maPhong");
            List<YeuCauGoiMon> list = dao.getItemsToServe(maPhong);
            StringBuilder sb = new StringBuilder("<h6 class='fw-bold mb-3 text-primary'><i class='fas fa-concierge-bell me-2'></i>Danh sách chờ phục vụ</h6>");
            if (list.isEmpty()) sb.append("<div class='text-center py-4 text-muted'>Đã phục vụ hết các món.</div>");
            else {
                sb.append("<div class='list-group shadow-none'>");
                for (YeuCauGoiMon yc : list) {
                    sb.append("<div class='list-group-item d-flex justify-content-between align-items-center border-start-0 border-end-0 px-0'>");
                    sb.append("<div><div class='fw-bold'>").append(yc.getTenDV()).append("</div><span class='badge bg-light text-primary border'>Số lượng: ").append(yc.getSoLuong()).append("</span></div>");
                    sb.append("<button type='button' class='btn btn-primary btn-sm rounded-pill px-3 shadow-sm' onclick='confirmServed(").append(yc.getMaYC()).append(")'>GIAO XONG</button></div>");
                }
                sb.append("</div>");
            }
            response.getWriter().write(sb.toString());
        }

        // 4. NHẬT KÝ GỌI MÓN (Guest)
        else if (path.contains("api-get-invoice")) {
            String maPhong = request.getParameter("maPhong");
            List<YeuCauGoiMon> list = dao.getOrdersByRoomForGuest(maPhong); 
            StringBuilder sb = new StringBuilder();
            
            if (list.isEmpty()) {
                sb.append("<div class='text-center py-5 text-muted'><p>Bạn chưa gọi món nào.</p></div>");
            } else {
                sb.append("<div class='invoice-box shadow-sm'><h5 class='fw-bold border-bottom pb-3 text-primary'><i class='fas fa-history me-2'></i>NHẬT KÝ GỌI MÓN</h5>");
                sb.append("<table class='table table-sm table-borderless align-middle' style='font-size: 13px;'><thead><tr class='text-muted border-bottom' style='font-size: 11px;'><th>GIỜ</th><th>TÊN MÓN / TRẠNG THÁI</th><th class='text-center'>SL</th><th class='text-end'>ĐƠN GIÁ</th><th class='text-end'>TỔNG</th></tr></thead><tbody>");
                double totalBill = 0;
                for (YeuCauGoiMon yc : list) {
                    double lineTotal = yc.getGia() * yc.getSoLuong();
                    // 🛡️ Dùng trực tiếp hàm Getter đã format trong Model
                    String timeStr = yc.getThoiGian(); 
                    if (timeStr != null && timeStr.contains(" ")) timeStr = timeStr.split(" ")[1]; // Chỉ lấy HH:mm
                    
                    String statusBadge = "";
                    if(yc.getTrangThai() == 0) statusBadge = "<span class='badge bg-secondary' style='font-size:9px'>Chờ duyệt</span>";
                    else if(yc.getTrangThai() == 1) statusBadge = "<span class='badge bg-warning text-dark' style='font-size:9px'>Bếp đang làm</span>";
                    else if(yc.getTrangThai() == 4) { statusBadge = "<span class='badge bg-success' style='font-size:9px'>Đã phục vụ</span>"; totalBill += lineTotal; }
                    
                    sb.append("<tr><td class='text-muted'>").append(timeStr).append("</td><td><div class='fw-bold'>").append(yc.getTenDV()).append("</div>").append(statusBadge).append("</td><td class='text-center'>").append(yc.getSoLuong()).append("</td><td class='text-end text-muted'>").append(String.format("%,.0f", yc.getGia())).append("</td><td class='text-end fw-bold'>").append(String.format("%,.0f", lineTotal)).append("</td></tr>");
                }
                sb.append("</tbody></table><div class='mt-4 p-3 bg-light rounded-4 border-top border-primary border-3'><div class='d-flex justify-content-between align-items-center'><span class='fw-bold text-uppercase text-secondary small'>Tổng tiền đã dùng:</span><span class='text-danger fw-bold fs-4'>").append(String.format("%,.0f", totalBill)).append("đ</span></div></div></div>");
            }
            response.getWriter().write(sb.toString());
        }

        // 5. SƠ KẾT THANH TOÁN (Summary) - 🚩 ĐIỂM SỬA QUAN TRỌNG
        else if (path.contains("api-checkout-summary")) {
            String maPhong = request.getParameter("maPhong");
            PhieuDatPhong pdp = dao.getActiveBooking(maPhong);
            if (pdp != null) {
                List<YeuCauGoiMon> services = dao.getApprovedOrdersByRoom(maPhong); 
                HttpSession session = request.getSession();
                NhanVien auth = (NhanVien) session.getAttribute("auth");
                String tenNV = (auth != null) ? auth.getTenNV() : "Hệ thống";
                String tenKH = pdp.getTenKH() != null ? pdp.getTenKH() : "Khách lẻ";

                // 🛡️ Dùng getGioDatRaw() để lấy Timestamp gốc cho việc parse
                Timestamp startTs = pdp.getGioDatRaw();
                String displayStart = pdp.getGioDat(); // Lấy bản đẹp dd/MM/yyyy

                StringBuilder sb = new StringBuilder("<div class='card border-0 shadow-sm rounded-4 p-4'>");
                sb.append("<h4 class='fw-bold text-primary mb-1'>").append(pdp.getTenPhong()).append("</h4>");
                sb.append("<div class='mb-3 small text-muted border-bottom pb-2'>Khách: <b>").append(tenKH).append("</b> | Thu ngân: <b>").append(tenNV).append("</b></div>");
                sb.append("<div class='row g-3 mb-4 bg-light p-3 rounded-3 border'><div class='col-md-6 border-end'><label class='small text-muted fw-bold d-block'>GIỜ VÀO</label><span class='fw-bold'>").append(displayStart).append("</span></div><div class='col-md-6'><label class='small text-muted fw-bold d-block text-primary'>GIỜ RA</label><input type='datetime-local' id='inputGioRaFull' class='form-control form-control-sm fw-bold border-primary' value='").append(LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"))).append("' onchange='recalculateBill()'></div></div>");
                
                sb.append("<table class='table table-sm small'><thead><tr class='table-light'><th>Tên món</th><th class='text-center'>SL</th><th class='text-end'>Tiền</th></tr></thead><tbody>");
                double tienDV = 0;
                for(YeuCauGoiMon yc : services) {
                    double line = yc.getGia() * yc.getSoLuong(); tienDV += line;
                    sb.append("<tr><td>").append(yc.getTenDV()).append("</td><td class='text-center'>x").append(yc.getSoLuong()).append("</td><td class='text-end'>").append(String.format("%,.0f", line)).append("đ</td></tr>");
                }
                sb.append("</tbody></table>");
                sb.append("<div class='border-top pt-3 text-end'>Dịch vụ: <b id='resTienDV'>").append(String.format("%,.0f", tienDV)).append("đ</b><br>Giờ hát: <b id='resTienGio'>0đ</b><div class='p-3 bg-danger text-white rounded-3 mt-3 text-center'><h3 id='resTongCong' class='fw-bold mb-0'>0đ</h3></div></div>");
                
                // 🛡️ Gửi chuỗi ISO (yyyy-MM-ddTHH:mm) để JS tính toán không bị lỗi NaN
                String isoStart = (startTs != null) ? startTs.toString().replace(" ", "T").split("\\.")[0] : "";
                sb.append("<input type='hidden' id='valGioVaoISO' value='").append(isoStart).append("'>");
                sb.append("<input type='hidden' id='hiddenGiaPhong' value='").append(pdp.getGiaTheoGio()).append("'>");
                sb.append("<input type='hidden' id='hiddenTienDV' value='").append(tienDV).append("'>");
                sb.append("<input type='hidden' id='hiddenMaPhieu' value='").append(pdp.getMaPhieu()).append("'>");
                sb.append("<input type='hidden' id='hiddenMaPhong' value='").append(pdp.getMaPhong()).append("'></div>");
                response.getWriter().write(sb.toString());
            }
        }

        // 6. QUẢN LÝ MENU
        else if (path.contains("api-manage-inventory")) {
            List<DichVu> list = dao.getAllServices();
            StringBuilder sb = new StringBuilder("<table class='table table-hover align-middle'>");
            sb.append("<thead class='table-dark'><tr><th>Tên món</th><th class='text-center'>Tồn</th><th class='text-center'>Menu</th></tr></thead><tbody>");
            for (DichVu dv : list) {
                sb.append("<tr><td>").append(dv.getTenDV()).append("</td><td class='text-center'>").append(dv.getSoLuongTon()).append("</td><td class='text-center'>");
                sb.append("<div class='form-check form-switch d-inline-block'>");
                sb.append("<input class='form-check-input' type='checkbox' role='switch' ").append(dv.getTrangThaiHienThi() == 1 ? "checked " : "");
                sb.append("onchange='toggleServiceStatus(").append(dv.getMaDV()).append(", this.checked ? 1 : 0)'></div>");
                sb.append("<div class='small fw-bold ").append(dv.getTrangThaiHienThi()==1?"text-success":"text-danger").append("'>").append(dv.getTrangThaiHienThi()==1?"HIỆN":"ẨN").append("</div></td></tr>");
            }
            response.getWriter().write(sb.append("</tbody></table>").toString());
        }

        // 7. CÁC API PHỤ KHÁC
        else if (path.contains("api-get-active-bookings")) {
            List<PhieuDatPhong> list = dao.getAllActiveBookings();
            for (PhieuDatPhong p : list) response.getWriter().write("<div class='list-group-item' onclick=\"loadBillDetail('"+p.getMaPhong()+"')\">"+p.getTenPhong()+"</div>");
        }
        else if (path.contains("api-get-revenue")) {
            response.getWriter().write("<div class='text-center p-3'><h2 class='text-danger fw-bold'>" + String.format("%,.0f", dao.getRevenueByDate(request.getParameter("date"))) + "đ</h2></div>");
        }
        else if (path.contains("update-room-status-api")) {
            rDao.updateRoomStatus(request.getParameter("maPhong"), request.getParameter("status"));
            response.getWriter().write("success");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();
        PhongDAO rDao = new PhongDAO();
        PrintWriter out = response.getWriter();
        String path = request.getServletPath();
        HttpSession session = request.getSession();
        NhanVien auth = (NhanVien) session.getAttribute("auth");
        int maNV = (auth != null) ? auth.getMaNV() : 0;

        // 1. THANH TOÁN
        if (path.contains("confirm-payment")) {
            try {
                int maPhieu = Integer.parseInt(request.getParameter("maPhieu"));
                String maPhong = request.getParameter("maPhong");
                String gioRa = request.getParameter("gioRa");
                // Xử lý chuỗi tiền từ giao diện gửi lên
                String tienRaw = request.getParameter("tongTien").replaceAll("[^0-9]", "");
                double tongTien = Double.parseDouble(tienRaw);
                out.print(dao.confirmPayment(maPhieu, maPhong, gioRa, maNV, tongTien) ? "success" : "fail");
            } catch (Exception e) { out.print("error"); }
        }

        // 2. HỖ TRỢ
        else if (path.contains("api-call-support")) {
            String act = request.getParameter("action");
            String p = request.getParameter("maPhong");
            String note = request.getParameter("note");

            if ("call".equals(act)) {  // ← THÊM CASE NÀY
                out.print(rDao.callSupport(p, note != null ? note : "") ? "success" : "fail");
            } else if ("accept".equals(act)) {
                out.print(rDao.acceptSupport(p, maNV) ? "success" : "fail");
            } else if ("complete".equals(act)) {
                out.print(rDao.completeSupport(p, maNV) ? "success" : "fail");
            }
        }

        // 3. ĐỔI PHÒNG
        else if (path.contains("api-switch-room")) {
            out.print(rDao.switchRoom(request.getParameter("old"), request.getParameter("new")) ? "success" : "fail");
        }

        // 4. CẬP NHẬT ĐƠN
        else if (path.contains("api-order-update")) {
            String action = request.getParameter("action");
            try {
                if ("update-qty".equals(action)) dao.updateOrderQuantity(Integer.parseInt(request.getParameter("maYC")), Integer.parseInt(request.getParameter("qty")));
                else if ("delete-item".equals(action)) dao.deleteOrderRequest(Integer.parseInt(request.getParameter("maYC")));
                else if ("add-item".equals(action)) dao.addSingleOrderForStaff(request.getParameter("maPhong"), Integer.parseInt(request.getParameter("maDV")), 1);
                else if ("confirm-served".equals(action)) dao.confirmServed(Integer.parseInt(request.getParameter("maYC")));
                out.print("success");
            } catch (Exception e) { out.print("error"); }
        }

        // 5. TÌM KIẾM DỊCH VỤ
        else if (path.contains("api-search-services")) {
            List<DichVu> results = dao.searchServicesByName(request.getParameter("txt"));
            String p = request.getParameter("maPhong");
            if (results.isEmpty()) out.println("<div class='list-group-item text-muted small'>Không tìm thấy...</div>");
            else {
                for (DichVu dv : results) out.println("<a href='#' class='list-group-item list-group-item-action py-2' onclick=\"addItemToOrder('"+p+"', "+dv.getMaDV()+")\">"+dv.getTenDV()+"</a>");
            }
        }

        // 6. DUYỆT ĐƠN
        else if (path.contains("process-order-all")) out.print(dao.updateAllStatusByRoom(request.getParameter("maPhong"), 1) ? "success" : "fail");
        else if (path.contains("process-order")) {
            out.print(dao.updateStatus(Integer.parseInt(request.getParameter("maYC")), Integer.parseInt(request.getParameter("status"))));
        }

        // 7. ẨN HIỆN & NHẬP KHO
        else if (path.contains("api-toggle-service-status")) {
            DichVuDAO sDao = new DichVuDAO();
            out.print(sDao.updateVisibility(Integer.parseInt(request.getParameter("maDV")), Integer.parseInt(request.getParameter("status"))) ? "success" : "fail");
        }
        else if (path.contains("update-service-stock")) {
            out.print(dao.updateServiceStock(Integer.parseInt(request.getParameter("maDV")), Integer.parseInt(request.getParameter("quantity"))) ? "success" : "fail");
        }
    }
}