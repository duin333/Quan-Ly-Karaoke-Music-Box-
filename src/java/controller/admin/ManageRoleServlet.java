package controller.admin;

import dal.ChucVuDAO;
import model.ChucVu;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ManageRoleServlet", urlPatterns = {"/admin/manage-roles"})
public class ManageRoleServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        ChucVuDAO dao = new ChucVuDAO();
        
        String action = request.getParameter("action");
        
        // 🛡️ Bọc try-catch để tránh sập khi parse ID hoặc lỗi xóa ràng buộc
        try {
            if ("delete".equals(action)) {
                String idStr = request.getParameter("id");
                if (idStr != null) {
                    int id = Integer.parseInt(idStr);
                    // Lưu ý: Nếu xóa không được (do có nhân viên đang giữ chức vụ), 
                    // DAO nên trả về false thay vì văng Exception.
                    dao.deleteRole(id); 
                    response.sendRedirect("manage-roles?success=deleted");
                    return;
                }
            }
        } catch (NumberFormatException e) {
            // Né lỗi sập khi ID không hợp lệ
            System.err.println("Lỗi parse ID chức vụ: " + e.getMessage());
        }

        List<ChucVu> list = dao.getAllRoles();
        request.setAttribute("roleList", list);
        request.getRequestDispatcher("/admin/manage-roles.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        ChucVuDAO dao = new ChucVuDAO();
        String action = request.getParameter("action");
        String name = request.getParameter("roleName");

        try {
            if (name != null && !name.trim().isEmpty()) {
                if ("update".equals(action)) {
                    int id = Integer.parseInt(request.getParameter("id"));
                    dao.updateRole(id, name);
                    response.sendRedirect("manage-roles?success=updated");
                } else {
                    dao.insertRole(name);
                    response.sendRedirect("manage-roles?success=inserted");
                }
            } else {
                response.sendRedirect("manage-roles?error=empty_name");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect("manage-roles?error=invalid_id");
        }
    }
}