package controller.guest;

import dal.YeuCauGoiMonDAO;
import dal.PhongDAO;
import dal.DichVuDAO;
import model.Phong;
import model.DichVu;
import model.YeuCauGoiMon;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "GuestHomeServlet", urlPatterns = {"/guest/home"})
public class GuestHomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        PhongDAO roomDao = new PhongDAO();
        YeuCauGoiMonDAO orderDao = new YeuCauGoiMonDAO();
        DichVuDAO dichVuDao = new DichVuDAO();
        HttpSession session = request.getSession();

        String maPhong = request.getParameter("maPhong");
        if (maPhong == null || maPhong.isEmpty()) {
            maPhong = (String) session.getAttribute("maPhongHienTai");
            if (maPhong == null) maPhong = "P101";
        }
        session.setAttribute("maPhongHienTai", maPhong);

        // Dùng getAllServices thay vì searchServicesByName để lấy đủ món
        // JSP sẽ tự xử lý hiển thị/ẩn dựa theo TrangThaiHienThi và SoLuongTon
        List<DichVu> listDV = dichVuDao.getAllServices();
        List<YeuCauGoiMon> listOrders = orderDao.getOrdersByRoomForGuest(maPhong);
        List<Phong> listRooms = roomDao.getAllRooms();

        request.setAttribute("maPhong", maPhong);
        request.setAttribute("listDV", listDV);
        request.setAttribute("listOrders", listOrders);
        request.setAttribute("listRooms", listRooms);

        request.getRequestDispatcher("/guest/home.jsp").forward(request, response);
    }
}