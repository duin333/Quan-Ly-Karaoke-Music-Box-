package controller.staff;

import dal.YeuCauGoiMonDAO;
import model.YeuCauGoiMon;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Servlet quản lý việc duyệt yêu cầu gọi món từ khách hàng.
 * Đã cập nhật cơ chế chống sập và đồng bộ định dạng ngày tháng mới.
 * @author Nguyễn Thái Kỳ Duyên
 */
@WebServlet(name = "QuanLyGoiMonServlet", urlPatterns = {"/staff/manage-orders"})
public class QuanLyGoiMonServlet extends HttpServlet {

    // ==========================================
    // HIỂN THỊ DANH SÁCH YÊU CẦU GỌI MÓN
    // ==========================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();
        
        // 🛡️ Lấy danh sách các món đang chờ duyệt (Trạng thái 0)
        // Lưu ý: Trong model YeuCauGoiMon, hàm getThoiGian() đã tự trả về dd/MM/yyyy HH:mm
        List<YeuCauGoiMon> list = dao.getPendingOrders();
        
        request.setAttribute("pendingList", list);
        request.getRequestDispatcher("/staff/manage-orders.jsp").forward(request, response);
    }

    // ==========================================
    // CẬP NHẬT TRẠNG THÁI YÊU CẦU GỌI MÓN (Duyệt/Hủy)
    // ==========================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();

        try {
            String maYCRaw = request.getParameter("maYC");
            String statusRaw = request.getParameter("status");

            // 🛡️ CHỐNG SẬP: Kiểm tra dữ liệu null hoặc rỗng
            if (maYCRaw != null && statusRaw != null) {
                int maYC = Integer.parseInt(maYCRaw);
                int status = Integer.parseInt(statusRaw);

                // Gọi hàm updateStatus (Hàm này có gọi Procedure sp_DuyetYeuCau để trừ kho)
                String result = dao.updateStatus(maYC, status);

                // Xử lý thông báo phản hồi dựa trên kết quả trả về từ Procedure
                if ("out_of_stock".equals(result)) {
                    request.getSession().setAttribute("errorMsg", "Lỗi: Món này đã hết hàng trong kho!");
                } else if ("success".equals(result)) {
                    request.getSession().setAttribute("successMsg", "Đã duyệt món thành công.");
                } else if ("fail".equals(result)) {
                    request.getSession().setAttribute("errorMsg", "Không thể cập nhật trạng thái đơn hàng.");
                }
            }
        } catch (NumberFormatException e) {
            // 🛡️ CHỐNG SẬP: Né lỗi khi parse ID hoặc Status không phải là số
            System.err.println("Lỗi định dạng số tại QuanLyGoiMonServlet: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Redirect về trang danh sách để cập nhật lại bảng dữ liệu
        response.sendRedirect("manage-orders");
    }
}