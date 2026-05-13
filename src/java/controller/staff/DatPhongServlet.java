package controller.staff;

import dal.YeuCauGoiMonDAO;
import model.Phong;
import model.KhachHang;
import model.PhieuDatPhong;
import model.NhanVien;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "DatPhongServlet", urlPatterns = {
    "/staff/booking",
    "/staff/api-customer",
    "/staff/api-create-booking",
    "/staff/api-add-customer",
    "/staff/api-get-waiting-bookings",
    "/staff/api-checkin",
    "/staff/api-cancel"
})
public class DatPhongServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String path = request.getServletPath();
        YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();
        // Đảm bảo phản hồi luôn là UTF-8
        response.setCharacterEncoding("UTF-8");

        try {
            // 1. TRANG CHÍNH: HIỂN THỊ GIAO DIỆN ĐẶT PHÒNG
            if (path.equals("/staff/booking")) {
                List<Phong> listRooms = dao.getAvailableRooms();
                request.setAttribute("availableRooms", listRooms);
                request.getRequestDispatcher("/staff/booking.jsp").forward(request, response);
            } 
            
            // 2. API: LẤY DANH SÁCH CHỜ THEO NGÀY (Dùng AJAX gọi vào đây)
            else if (path.equals("/staff/api-get-waiting-bookings")) {
                response.setContentType("text/html;charset=UTF-8");
                PrintWriter out = response.getWriter();
                
                // Tự động dọn dẹp phiếu quá hạn 30p
                dao.autoCancelExpiredBookings(); 

                String filterDate = request.getParameter("date");
                if (filterDate == null || filterDate.isEmpty()) {
                    filterDate = java.time.LocalDate.now().toString();
                }

                List<PhieuDatPhong> list = dao.getWaitingBookingsByDate(filterDate); 

                if (list.isEmpty()) {
                    out.println("<tr><td colspan='5' class='text-center text-muted py-4'>Không có phiếu đặt nào trong ngày " + filterDate + "</td></tr>");
                } else {
                    for (PhieuDatPhong b : list) {
                        // onclick để JS bắt được MaPhieu và MaPhong
                        out.println("<tr onclick=\"selectBooking(this, '" + b.getMaPhieu() + "', '" + b.getMaPhong() + "')\">");
                        out.println("<td class='fw-bold text-primary'>#" + b.getMaPhieu() + "</td>");
                        out.println("<td>" + b.getTenKH() + "</td>");
                        out.println("<td>" + b.getSdt() + "</td>");
                        out.println("<td><span class='badge bg-dark'>" + b.getMaPhong() + "</span></td>");
                        
                        // 🛡️ ĐÃ CẬP NHẬT: Vì con muốn hiện ngày/tháng/năm hết, 
                        // nên mình dùng luôn hàm getGioDat() đã format trong Model.
                        out.println("<td class='fw-bold text-danger'>" + b.getGioDat() + "</td>");
                        out.println("</tr>");
                    }
                }
            } 
            
            // 3. API: TÌM KHÁCH HÀNG THEO SĐT (Trả về JSON)
            else if (path.equals("/staff/api-customer")) {
                response.setContentType("application/json;charset=UTF-8");
                String sdt = request.getParameter("sdt");
                KhachHang kh = dao.getCustomerByPhone(sdt);
                
                if (kh != null) {
                    response.getWriter().write("{\"maKH\":" + kh.getMaKH() + ", \"tenKH\":\"" + kh.getTenKH() + "\", \"sdt\":\"" + kh.getSdt() + "\"}");
                } else {
                    response.getWriter().write("null");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Nhận tên tiếng Việt không bị lỗi font
        request.setCharacterEncoding("UTF-8");
        
        String path = request.getServletPath();
        YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            // 4. API: LẬP PHIẾU ĐẶT PHÒNG MỚI
            if (path.equals("/staff/api-create-booking")) {
                int maKH = Integer.parseInt(request.getParameter("maKH"));
                String maPhong = request.getParameter("maPhong");
                String gioDat = request.getParameter("gioDat");
                
                // 🛡️ CHIÊU CHỐNG SẬP: Nếu gioDat lấy từ datetime-local có chữ "T", 
                // ta phải đổi thành dấu cách và thêm giây để DAO/Database nhận đúng.
                if (gioDat != null && gioDat.contains("T")) {
                    gioDat = gioDat.replace("T", " ") + ":00";
                }
                
                String result = dao.insertBooking(maKH, maPhong, gioDat);
                out.write(result); 
            } 
            
            // 5. API: THÊM KHÁCH HÀNG MỚI NHANH
            else if (path.equals("/staff/api-add-customer")) {
                String tenKH = request.getParameter("tenKH");
                String sdt = request.getParameter("sdt");
                boolean success = dao.insertCustomer(tenKH, sdt);
                
                if (success) {
                    KhachHang kh = dao.getCustomerByPhone(sdt);
                    response.setContentType("application/json;charset=UTF-8");
                    out.write("{\"maKH\":" + kh.getMaKH() + ", \"tenKH\":\"" + kh.getTenKH() + "\", \"sdt\":\"" + kh.getSdt() + "\"}");
                } else {
                    out.write("fail");
                }
            } 
            
            // 6. API: KHÁCH NHẬN PHÒNG (CHECK-IN)
            else if (path.equals("/staff/api-checkin")) {
                int maPhieu = Integer.parseInt(request.getParameter("maPhieu"));
                String maPhong = request.getParameter("maPhong");
                
                boolean ok = dao.checkInBooking(maPhieu, maPhong);
                out.write(ok ? "success" : "fail");
            } 
            
            // 7. API: HỦY PHIẾU ĐẶT
            else if (path.equals("/staff/api-cancel")) {
                int maPhieu = Integer.parseInt(request.getParameter("maPhieu"));
                
                // Lấy MaNV từ Session để biết ai là người thực hiện hủy
                HttpSession session = request.getSession();
                NhanVien auth = (NhanVien) session.getAttribute("auth");
                int maNV = (auth != null) ? auth.getMaNV() : 1; 

                boolean ok = dao.cancelBooking(maPhieu, maNV);
                out.write(ok ? "success" : "fail");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.write("error");
        }
    }
}