package controller.admin;

import dal.PhongDAO;
import dal.LoaiPhongDAO;
import model.Phong;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ManageRoomServlet", urlPatterns = {"/admin/manage-rooms"})
public class ManageRoomServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        PhongDAO dao = new PhongDAO(); 
        LoaiPhongDAO lpDao = new LoaiPhongDAO();
        
        // 1. 🛡️ Xử lý hành động XÓA phòng (Chống sập khi ID null)
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            String id = request.getParameter("id");
            if (id != null && !id.trim().isEmpty()) {
                // Lưu ý: Nếu phòng đang có khách hoặc có lịch sử, 
                // DB sẽ báo lỗi Foreign Key, trang vẫn an toàn vì DAO dùng kết nối riêng.
                dao.deleteRoom(id); 
            }
            response.sendRedirect(request.getContextPath() + "/admin/manage-rooms?success=deleted");
            return;
        }

        // 2. 🔍 Lấy các tham số Tìm kiếm & Lọc
        String txtSearch = request.getParameter("txtSearch");
        String typeFilter = request.getParameter("typeFilter");
        String statusFilter = request.getParameter("statusFilter");

        // 3. Gọi dữ liệu từ DAO
        // Má giữ nguyên getAllRooms của con để đảm bảo tính ổn định cao nhất
        List<Phong> list = dao.getAllRooms();

        // 4. 📦 Đẩy dữ liệu ra JSP
        request.setAttribute("roomList", list);           
        request.setAttribute("typeList", lpDao.getAll()); 
        
        // Giữ trạng thái lọc trên UI
        request.setAttribute("lastSearch", txtSearch);
        request.setAttribute("lastType", typeFilter);
        request.setAttribute("lastStatus", statusFilter);
        
        request.getRequestDispatcher("/admin/manage-rooms.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        PhongDAO dao = new PhongDAO();
        
        String action = request.getParameter("action");
        String id = request.getParameter("roomId");
        String name = request.getParameter("roomName");
        String typeIdRaw = request.getParameter("typeId");

        try {
            // 🛡️ CHỐNG SẬP: Kiểm tra dữ liệu bắt buộc
            if (id == null || id.trim().isEmpty() || name == null || name.trim().isEmpty()) {
                response.sendRedirect("manage-rooms?error=missing_data");
                return;
            }

            int typeId = 0;
            if (typeIdRaw != null && !typeIdRaw.isEmpty()) {
                typeId = Integer.parseInt(typeIdRaw);
            }

            // 5. 🛡️ Xử lý CẬP NHẬT
            if ("update".equals(action)) {
                String status = request.getParameter("status"); 
                // Cập nhật thông tin phòng (DAO đã tự đóng kết nối)
                dao.updateRoom(id, name, typeId, status);
                response.sendRedirect(request.getContextPath() + "/admin/manage-rooms?success=updated");
            } 
            // 6. 🛡️ Xử lý THÊM MỚI
            else {
                dao.insertRoom(id, name, typeId);
                response.sendRedirect(request.getContextPath() + "/admin/manage-rooms?success=inserted");
            }
            
        } catch (NumberFormatException e) {
            // 🛡️ CHỐNG SẬP: Tránh lỗi khi nhập mã loại phòng không phải là số
            response.sendRedirect("manage-rooms?error=invalid_type");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-rooms?error=system");
        }
    }
}