package controller.admin;

import dal.LoaiDichVuDAO;
import dal.DichVuDAO;
import model.DichVu;
import model.NhanVien; // Để lấy MaNV ghi log
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "ManageInventoryServlet", urlPatterns = {"/admin/manage-inventory"})
public class ManageInventoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DichVuDAO sDao = new DichVuDAO();
        LoaiDichVuDAO lDao = new LoaiDichVuDAO();

        String txt = request.getParameter("txtSearch");
        String cat = request.getParameter("categoryFilter");

        // Lấy danh sách món để hiển thị trong kho
        List<DichVu> list = sDao.searchServices(txt, cat);
        
        request.setAttribute("inventoryList", list);
        request.setAttribute("categoryList", lDao.getAll());
        request.getRequestDispatcher("/admin/manage-inventory.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        DichVuDAO sDao = new DichVuDAO();
        
        try {
            // 🛡️ CHỐNG SẬP: Kiểm tra dữ liệu đầu vào
            String maDVStr = request.getParameter("maDV");
            String qtyStr = request.getParameter("quantity");

            if (maDVStr != null && qtyStr != null) {
                int maDV = Integer.parseInt(maDVStr);
                int quantity = Integer.parseInt(qtyStr);

                // Thực hiện cộng dồn kho
                if (sDao.addStock(maDV, quantity)) {
                    // 🛡️ CYBERSECURITY: Ghi log hành động nhập hàng
                    HttpSession session = request.getSession();
                    NhanVien admin = (NhanVien) session.getAttribute("auth");
                    if (admin != null) {
                        // Giả sử Duyên đã có AdminDAO.insertLog(maNV, hanhDong, ip)
                        // adao.insertLog(admin.getMaNV(), "Nhập hàng MaDV: " + maDV + ", SL: " + quantity, request.getRemoteAddr());
                    }
                    
                    response.sendRedirect("manage-inventory?success=true");
                } else {
                    response.sendRedirect("manage-inventory?error=db");
                }
            } else {
                response.sendRedirect("manage-inventory?error=missing");
            }
        } catch (NumberFormatException e) {
            // 🛡️ CHỐNG SẬP: Nếu parse lỗi thì redirect về chứ không để trắng trang
            response.sendRedirect("manage-inventory?error=invalid_format");
        }
    }
}