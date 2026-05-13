package controller.staff;

import dal.PhongDAO;
import model.LichSuHoTro;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "SupportHistoryServlet", urlPatterns = {"/staff/support-history"})
public class SupportHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 🛡️ Thiết lập Tiếng Việt cho toàn bộ phản hồi
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 1. KIỂM TRA QUYỀN TRUY CẬP (Bảo mật cho Staff)
        HttpSession session = request.getSession();
        if (session.getAttribute("auth") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 2. KHỞI TẠO DAO
        PhongDAO dao = new PhongDAO();
        
        try {
            // 3. LẤY DANH SÁCH LỊCH SỬ HỖ TRỢ
            // Nhờ hàm Getter mới trong Model LichSuHoTro, các cột thời gian 
            // sẽ tự động hiển thị dd/MM/yyyy HH:mm trên JSP.
            List<LichSuHoTro> list = dao.getAllSupportHistory();
            
            // 4. ĐẨY DỮ LIỆU SANG JSP
            request.setAttribute("listHistory", list);
            
            // Forward sang file JSP trong thư mục staff
            request.getRequestDispatcher("/staff/support-history.jsp").forward(request, response);
            
        } catch (Exception e) {
            // 🛡️ CHỐNG SẬP: Né lỗi trắng trang khi DB có sự cố
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/staff/dashboard?error=history_failed");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chuyển mọi yêu cầu POST về GET để xử lý chung một logic
        doGet(request, response);
    }
}