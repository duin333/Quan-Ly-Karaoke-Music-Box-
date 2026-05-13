package controller.admin;

import dal.LoaiPhongDAO;
import model.LoaiPhong;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "ManageRoomTypeServlet", urlPatterns = {"/admin/manage-room-types"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 10,      // 10MB
    maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ManageRoomTypeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        LoaiPhongDAO dao = new LoaiPhongDAO();
        String action = request.getParameter("action");
        
        try {
            if ("delete".equals(action)) {
                String idRaw = request.getParameter("id");
                if (idRaw != null) {
                    dao.delete(Integer.parseInt(idRaw));
                }
                response.sendRedirect("manage-room-types?success=deleted");
                return;
            }
        } catch (NumberFormatException e) {
            // Chống sập khi ID không hợp lệ
            System.err.println("Lỗi parse ID loại phòng: " + e.getMessage());
        }

        request.setAttribute("typeList", dao.getAll());
        request.getRequestDispatcher("/admin/manage-room-types.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        LoaiPhongDAO dao = new LoaiPhongDAO();
        String action = request.getParameter("action");

        try {
            // 1. Lấy và kiểm tra các thông tin cơ bản (🛡️ CHỐNG SẬP)
            String name = request.getParameter("name");
            String priceRaw = request.getParameter("price");
            String limitRaw = request.getParameter("limit");
            
            if (name == null || priceRaw == null || limitRaw == null) {
                response.sendRedirect("manage-room-types?error=missing_data");
                return;
            }

            double price = Double.parseDouble(priceRaw);
            int limit = Integer.parseInt(limitRaw);
            String imagePath = "";

            // 2. Xử lý chọn ảnh (File hoặc Link)
            String imgOption = request.getParameter("imageOption"); 
            if ("file".equals(imgOption)) {
                Part filePart = request.getPart("imageFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    // Lưu vào thư mục assets/img/rooms trong project
                    String uploadPath = getServletContext().getRealPath("/") + "assets" + File.separator + "img" + File.separator + "rooms";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    
                    filePart.write(uploadPath + File.separator + fileName);
                    imagePath = "assets/img/rooms/" + fileName;
                } else {
                    // Nếu update mà không chọn file mới, lấy lại link ảnh cũ từ hidden field
                    imagePath = request.getParameter("oldImage"); 
                }
            } else {
                imagePath = request.getParameter("imageLink");
            }

            // 3. Thực hiện lưu vào DB
            if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Sử dụng Constructor 5 tham số của Model LoaiPhong
                dao.update(new LoaiPhong(id, name, price, limit, imagePath));
                response.sendRedirect("manage-room-types?success=updated");
            } else {
                dao.insert(new LoaiPhong(0, name, price, limit, imagePath));
                response.sendRedirect("manage-room-types?success=inserted");
            }
            
        } catch (NumberFormatException e) {
            // 🛡️ CHỐNG SẬP: Khi nhập sai định dạng số (giá, số người)
            response.sendRedirect("manage-room-types?error=invalid_number");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-room-types?error=system");
        }
    }
}