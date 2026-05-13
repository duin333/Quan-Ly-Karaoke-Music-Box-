package controller.staff;

import dal.YeuCauGoiMonDAO;
import model.PhieuDatPhong;
import model.YeuCauGoiMon;
import java.io.IOException;
import java.util.ArrayList; 
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "HistoryServlet", urlPatterns = {"/staff/booking-history", "/staff/booking-detail"})
public class HistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String path = request.getServletPath();
        YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();
        response.setCharacterEncoding("UTF-8");

        // 🛡️ 1. XỬ LÝ TRANG DANH SÁCH LỊCH SỬ
        if (path.contains("booking-history")) {
            try {
                // Lấy tất cả phiếu (DAO đã tự đóng kết nối)
                List<PhieuDatPhong> historyList = dao.getPaidBookings();
                
                // Gửi danh sách sang JSP (JSP gọi ${item.gioDat} sẽ tự ra dd/MM/yyyy)
                request.setAttribute("historyList", historyList);
                request.getRequestDispatcher("/staff/history.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect(request.getContextPath() + "/staff/dashboard?error=system");
            }
        } 
        
        // 🛡️ 2. XỬ LÝ TRANG CHI TIẾT PHIẾU
        else if (path.contains("booking-detail")) {
            try {
                String idStr = request.getParameter("id");
                if (idStr == null || idStr.isEmpty()) {
                    response.sendRedirect("booking-history");
                    return;
                }
                
                int maPhieu = Integer.parseInt(idStr);
                
                // Lấy thông tin phiếu
                PhieuDatPhong pdp = dao.getPaidBookingById(maPhieu);
                
                if (pdp != null) {
                    List<YeuCauGoiMon> detailItems = new ArrayList<>();
                    
                    // Nếu đã thanh toán, đi lấy danh sách món
                    if (pdp.getTrangThai() == 3 || pdp.getTrangThai() == 4) {
                        // 🛡️ CẬP NHẬT QUAN TRỌNG: 
                        // Ta dùng getGioDatRaw().toString() để gửi định dạng yyyy-MM-dd xuống SQL
                        // Tránh việc gửi định dạng dd/MM/yyyy làm SQL không tìm thấy dữ liệu.
                        String rawGioDat = (pdp.getGioDatRaw() != null) ? pdp.getGioDatRaw().toString() : null;
                        String rawGioTra = (pdp.getGioTraRaw() != null) ? pdp.getGioTraRaw().toString() : null;

                        detailItems = dao.getItemsByBookingId(
                                pdp.getMaPhieu(), 
                                pdp.getMaPhong(), 
                                rawGioDat, 
                                rawGioTra
                        );
                    }
                    
                    request.setAttribute("booking", pdp);
                    request.setAttribute("detailItems", detailItems);
                    request.getRequestDispatcher("/staff/history-detail.jsp").forward(request, response);
                } else {
                    response.sendRedirect("booking-history?error=notfound");
                }
            } catch (NumberFormatException e) {
                response.sendRedirect("booking-history?error=invalid_id");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("booking-history?error=system");
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}