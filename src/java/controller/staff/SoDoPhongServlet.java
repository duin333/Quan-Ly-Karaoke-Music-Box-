package controller.staff;

import dal.PhongDAO;
import model.Phong;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "SoDoPhongServlet", urlPatterns = {"/staff/dashboard"})
public class SoDoPhongServlet extends HttpServlet {

    // ==========================================
    // HIỂN THỊ SƠ ĐỒ PHÒNG (STAFF DASHBOARD)
    // ==========================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 🛡️ Thiết lập Tiếng Việt cho toàn bộ phản hồi
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        // 1. KIỂM TRA QUYỀN TRUY CẬP (Authentication)
        HttpSession session = request.getSession();
        if (session.getAttribute("auth") == null) {
            // Nếu chưa đăng nhập, đá về trang login ngay lập tức
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // 2. LẤY DỮ LIỆU TỪ DATABASE
        // Mỗi lần chạy doGet sẽ tạo một DAO mới và tự đóng kết nối bên trong hàm
        PhongDAO dao = new PhongDAO();
        
        try {
            // Lấy danh sách phòng (Đã bao gồm supportStatus để hiện thông báo gọi nhân viên)
            List<Phong> list = dao.getAllRooms();
            
            // 3. ĐẨY DỮ LIỆU SANG GIAO DIỆN
            request.setAttribute("listRooms", list);
            request.getRequestDispatcher("/staff/dashboard.jsp").forward(request, response);
            
        } catch (Exception e) {
            // 🛡️ CHỐNG SẬP: Nếu Database có vấn đề, in lỗi và báo về trang lỗi (nếu có)
            e.printStackTrace();
            // Có thể redirect về trang báo lỗi hệ thống tại đây
        }
    }

    // ==========================================
    // CHUYỂN POST VỀ GET ĐỂ XỬ LÝ CHUNG
    // ==========================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Giúp trang web không bị lỗi 405 khi người dùng refresh sau khi submit form
        doGet(request, response);
    }
}