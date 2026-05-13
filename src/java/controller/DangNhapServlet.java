package controller;

import dal.NhanVienDAO;
import model.NhanVien;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "DangNhapServlet", urlPatterns = {"/login"})
public class DangNhapServlet extends HttpServlet {

    // ==========================================
    // HIỂN THỊ TRANG ĐĂNG NHẬP
    // ==========================================
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("login.jsp").forward(request, response);
    }

    // ==========================================
    // XỬ LÝ ĐĂNG NHẬP & PHÂN QUYỀN
    // ==========================================
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String u = request.getParameter("user");
        String p = request.getParameter("pass");

        NhanVienDAO dao = new NhanVienDAO();
        NhanVien account = dao.login(u, p);

        if (account == null) {
            request.setAttribute("mess", "Tài khoản hoặc mật khẩu không đúng!");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        } else {
            if (account.getTrangThai() == 0) {
                request.setAttribute("mess", "Tài khoản này đã bị khóa hoặc nhân viên đã nghỉ việc!");
                request.getRequestDispatcher("login.jsp").forward(request, response);
            } else {
                HttpSession session = request.getSession();
                session.setAttribute("auth", account);
                if (account.getMaCV() == 1) {
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/staff/dashboard");
                }
            }
        }
    }
}