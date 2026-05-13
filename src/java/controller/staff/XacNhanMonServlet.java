package controller.staff;

import dal.YeuCauGoiMonDAO;
import dal.PhongDAO;
import model.YeuCauGoiMon;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "XacNhanMonServlet", urlPatterns = {"/confirm-order"})
public class XacNhanMonServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 🛡️ Đảm bảo nhận tiếng Việt (ghi chú món ăn) và trả về text chuẩn
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain;charset=UTF-8");

        String maPhong = request.getParameter("maPhong");
        String cartData = request.getParameter("cartData");

        // 1. 🛡️ CHỐNG SẬP: Kiểm tra dữ liệu đầu vào cơ bản
        if (maPhong == null || maPhong.trim().isEmpty()) {
            response.getWriter().write("invalid_room");
            return;
        }

        try {
            // 2. KIỂM TRA TRẠNG THÁI PHÒNG (Chỉ cho phép đặt khi đang sử dụng)
            PhongDAO roomDao = new PhongDAO();
            String roomStatus = roomDao.getRoomStatus(maPhong);

            if (roomStatus == null || !roomStatus.equals("Đang hát")) {
                response.getWriter().write("invalid_room_status");
                return;
            }

            // 3. BÓC TÁCH GIỎ HÀNG (Dạng: id-qty,id-qty)
            if (cartData != null && !cartData.trim().isEmpty()) {
                List<YeuCauGoiMon> list = new ArrayList<>();
                // Tách từng món bằng dấu phẩy
                String[] items = cartData.split(",");

                for (String item : items) {
                    item = item.trim();
                    if (!item.isEmpty() && item.contains("-")) {
                        try {
                            String[] parts = item.split("-");
                            if (parts.length >= 2) {
                                int id = Integer.parseInt(parts[0]);
                                int qty = Integer.parseInt(parts[1]);
                                
                                if (qty > 0) {
                                    // Tạo đối tượng yêu cầu (DAO sẽ tự lo phần Timestamp)
                                    list.add(new YeuCauGoiMon(maPhong, id, qty));
                                }
                            }
                        } catch (NumberFormatException e) {
                            // 🛡️ Bỏ qua nếu id hoặc qty không phải là số, không để sập vòng lặp
                            System.err.println("Lỗi định dạng item trong giỏ hàng: " + item);
                        }
                    }
                }

                // 4. LƯU VÀO DATABASE
                if (!list.isEmpty()) {
                    YeuCauGoiMonDAO dao = new YeuCauGoiMonDAO();
                    // insertOrderRequests sẽ gọi Batch Update hoặc Loop để lưu
                    boolean success = dao.insertOrderRequests(list);
                    response.getWriter().write(success ? "success" : "fail");
                } else {
                    response.getWriter().write("empty_cart");
                }
            } else {
                response.getWriter().write("fail");
            }
            
        } catch (Exception e) {
            // 🛡️ CHIÊU CUỐI: Bắt mọi lỗi ngoại lệ để server không bao giờ trả về lỗi 500
            e.printStackTrace();
            response.getWriter().write("error_system");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Khách không được dùng GET để đặt món
        response.sendRedirect(request.getContextPath() + "/guest/home");
    }
}