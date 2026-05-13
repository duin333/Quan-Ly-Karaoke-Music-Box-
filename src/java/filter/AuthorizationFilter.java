package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import java.io.IOException;
import model.NhanVien;

@WebFilter(urlPatterns = {"/*"}) 
public class AuthorizationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Có thể dùng để cấu hình các tham số ban đầu nếu cần
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession();
        
        // Lấy thông tin nhân viên từ session
        NhanVien user = (NhanVien) session.getAttribute("auth");
        
        // Lấy đường dẫn hiện tại khách đang truy cập
        String path = req.getServletPath();

        // --- TRƯỜNG HỢP 1: CÁC TRANG CÔNG KHAI (KHÔNG CHẶN) ---
        // 🛡️ Đã bổ sung /logout vào danh sách này
        if (path.equals("/login") || 
            path.equals("/logout") || 
            path.endsWith("login.jsp") || 
            path.startsWith("/guest/") || 
            path.startsWith("/assets/")) {
            
            chain.doFilter(request, response); // Cho phép đi tiếp
            return;
        }

        // --- TRƯỜNG HỢP 2: KHU VỰC ADMIN (/admin/*) ---
        if (path.startsWith("/admin/")) {
            if (user != null && user.getMaCV() == 1) {
                chain.doFilter(request, response); // Là Admin (Role 1) -> Cho qua
            } else {
                // Không phải Admin -> Đuổi về trang login kèm cảnh báo
                res.sendRedirect(req.getContextPath() + "/login.jsp?msg=NoAdminPermission");
            }
            return;
        }

        // --- TRƯỜNG HỢP 3: KHU VỰC NHÂN VIÊN (/staff/*) ---
        if (path.startsWith("/staff/")) {
            // Admin (Role 1) và Nhân viên (Role 2) đều có quyền vào khu vực này
            if (user != null && (user.getMaCV() == 1 || user.getMaCV() == 2)) {
                chain.doFilter(request, response);
            } else {
                // Chưa đăng nhập hoặc không đủ quyền -> Đẩy về login
                res.sendRedirect(req.getContextPath() + "/login.jsp?msg=PleaseLogin");
            }
            return;
        }

        // Mặc định cho các link khác (như trang chủ gốc) đi qua
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Giải phóng tài nguyên khi Filter bị hủy (khi dừng server)
    }
}