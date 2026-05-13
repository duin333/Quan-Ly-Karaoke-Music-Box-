package controller.admin;

import dal.LoaiDichVuDAO;
import dal.DichVuDAO;
import model.DichVu;
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

@WebServlet(name = "ManageServiceServlet", urlPatterns = {"/admin/manage-services"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class ManageServiceServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        DichVuDAO sDao = new DichVuDAO();
        LoaiDichVuDAO lDao = new LoaiDichVuDAO();
        String action = request.getParameter("action");

        try {
            // 1. 🛡️ Xử lý XÓA món (Chống sập khi ID null)
            if ("delete".equals(action)) {
                String idRaw = request.getParameter("id");
                if (idRaw != null) {
                    sDao.deleteService(Integer.parseInt(idRaw));
                }
                response.sendRedirect("manage-services?success=deleted");
                return;
            }

            // 2. ⚡ Xử lý BẬT/TẮT ẨN HIỆN
            if ("toggle".equals(action)) {
                String idRaw = request.getParameter("id");
                String statusRaw = request.getParameter("status");
                if (idRaw != null && statusRaw != null) {
                    sDao.updateVisibility(Integer.parseInt(idRaw), Integer.parseInt(statusRaw));
                }
                response.sendRedirect("manage-services?success=toggled");
                return;
            }
        } catch (NumberFormatException e) {
            System.err.println("Lỗi parse ID/Status: " + e.getMessage());
        }

        // 3. 🔍 Lấy tham số tìm kiếm & lọc
        String txtSearch = request.getParameter("txtSearch");
        String categoryFilter = request.getParameter("categoryFilter");

        // 4. 📦 Đổ dữ liệu ra JSP
        List<DichVu> serviceList = sDao.searchServices(txtSearch, categoryFilter);
        request.setAttribute("serviceList", serviceList);
        request.setAttribute("categoryList", lDao.getAll()); 

        request.setAttribute("lastSearch", txtSearch);
        request.setAttribute("lastCategory", categoryFilter);

        request.getRequestDispatcher("/admin/manage-services.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        DichVuDAO sDao = new DichVuDAO();
        String action = request.getParameter("action");

        try {
            // 🛡️ KIỂM TRA DỮ LIỆU ĐẦU VÀO (CHỐNG SẬP)
            String ten = request.getParameter("name");
            String giaRaw = request.getParameter("price");
            String stockRaw = request.getParameter("stock");
            String categoryIdRaw = request.getParameter("categoryId");
            
            if (ten == null || giaRaw == null || stockRaw == null || categoryIdRaw == null) {
                response.sendRedirect("manage-services?error=missing_data");
                return;
            }

            double gia = Double.parseDouble(giaRaw);
            int stock = Integer.parseInt(stockRaw);
            int categoryId = Integer.parseInt(categoryIdRaw);
            
            // Lấy trạng thái hiển thị
            int status = 1; 
            if (request.getParameter("status") != null) {
                status = Integer.parseInt(request.getParameter("status"));
            }

            // 5. 🖼️ Xử lý Logic Ảnh
            String imagePath = "";
            String imgOpt = request.getParameter("imgOpt"); 

            if ("file".equals(imgOpt)) {
                Part filePart = request.getPart("imageFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String uploadPath = getServletContext().getRealPath("/") + "assets" + File.separator + "img" + File.separator + "menu";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    
                    filePart.write(uploadPath + File.separator + fileName);
                    imagePath = "assets/img/menu/" + fileName;
                } else {
                    imagePath = request.getParameter("oldImage"); // Giữ ảnh cũ nếu không up ảnh mới
                }
            } else {
                imagePath = request.getParameter("imageLink");
                if (imagePath == null || imagePath.isEmpty()) {
                    imagePath = request.getParameter("oldImage");
                }
            }

            // 🛡️ Nếu cuối cùng vẫn không có ảnh, dùng ảnh mặc định
            if (imagePath == null || imagePath.isEmpty()) {
                imagePath = "assets/img/menu/default.jpg";
            }

            // 6. 🛡️ Thực hiện INSERT hoặc UPDATE (Dùng Constructor 8 tham số khớp Model)
            if ("update".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                // Model: maDV, tenDV, gia, soLuongTon, maLoaiDV, hinhAnh, tenLoaiDV, trangThaiHienThi
                sDao.updateService(new DichVu(id, ten, gia, stock, categoryId, imagePath, "", status));
                response.sendRedirect("manage-services?success=updated");
            } else {
                sDao.insertService(new DichVu(0, ten, gia, stock, categoryId, imagePath, "", status));
                response.sendRedirect("manage-services?success=inserted");
            }
            
        } catch (NumberFormatException e) {
            // 🛡️ CHỐNG SẬP: Redirect khi Admin nhập chữ vào ô giá/số lượng
            response.sendRedirect("manage-services?error=invalid_format");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("manage-services?error=system");
        }
    }
}