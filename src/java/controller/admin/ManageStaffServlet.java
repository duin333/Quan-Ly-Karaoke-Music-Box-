package controller.admin;

import dal.NhanVienDAO;
import model.NhanVien;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ManageStaffServlet", urlPatterns = {"/admin/manage-staff"})
public class ManageStaffServlet extends HttpServlet {

    // doGet: Xử lý Hiển thị danh sách, Tìm kiếm, Lọc và Khóa/Mở khóa tài khoản
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        NhanVienDAO dao = new NhanVienDAO();
        String action = request.getParameter("action");

        // 1. 🛡️ Xử lý Khóa/Mở khóa (Có bảo vệ parse số)
        if ("toggle".equals(action)) {
            try {
                String idStr = request.getParameter("id");
                String stStr = request.getParameter("st");
                if (idStr != null && stStr != null) {
                    int id = Integer.parseInt(idStr);
                    int st = Integer.parseInt(stStr);
                    dao.toggleStatus(id, st);
                }
            } catch (NumberFormatException e) {
                System.err.println("Lỗi parse ID/Status nhân viên: " + e.getMessage());
            }
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?msg=StatusUpdated");
            return;
        }

        // 2. 🔍 Xử lý Tìm kiếm & Lọc
        String txtSearch = request.getParameter("txtSearch");
        String roleFilter = request.getParameter("roleFilter");

        // DAO đã tự quản lý kết nối nên gọi cực kỳ an toàn
        List<NhanVien> list = dao.searchStaff(txtSearch, roleFilter);
        
        // Đẩy dữ liệu ra JSP
        request.setAttribute("staffList", list);
        request.setAttribute("lastSearch", txtSearch);
        request.setAttribute("lastRole", roleFilter);
        
        request.getRequestDispatcher("/admin/manage-staff.jsp").forward(request, response);
    }

    // doPost: Xử lý Thêm mới và Cập nhật
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        NhanVienDAO dao = new NhanVienDAO();
        String action = request.getParameter("action");
        
        try {
            // Lấy thông tin chung từ Form
            String name = request.getParameter("name");
            String user = request.getParameter("user");
            String pass = request.getParameter("pass");
            String roleRaw = request.getParameter("role");

            // 🛡️ CHỐNG SẬP: Kiểm tra dữ liệu rỗng trước khi xử lý
            if (name == null || user == null || pass == null || roleRaw == null || name.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/manage-staff?msg=MissingData");
                return;
            }

            int role = Integer.parseInt(roleRaw);

            // 3. 🛡️ Xử lý CẬP NHẬT
            if ("update".equals(action)) {
                String idRaw = request.getParameter("id");
                if (idRaw != null) {
                    int id = Integer.parseInt(idRaw);
                    boolean success = dao.updateStaff(id, name, user, pass, role);
                    String msg = success ? "UpdateSuccess" : "UpdateError";
                    response.sendRedirect(request.getContextPath() + "/admin/manage-staff?msg=" + msg);
                }
            } 
            // 4. 🛡️ Xử lý THÊM MỚI
            else {
                boolean success = dao.insertStaff(name, user, pass, role);
                String msg = success ? "AddSuccess" : "AddError";
                response.sendRedirect(request.getContextPath() + "/admin/manage-staff?msg=" + msg);
            }

        } catch (NumberFormatException e) {
            // 🛡️ CHỐNG SẬP: Né lỗi khi parse role hoặc ID
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?msg=InvalidFormat");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/admin/manage-staff?msg=SystemError");
        }
    }
}