package controller.admin;

import dal.AdminDAO;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        AdminDAO adao = new AdminDAO();

        request.setAttribute("revenueToday", adao.getRevenueToday());
        request.setAttribute("occupiedRooms", adao.getOccupiedRooms());
        request.setAttribute("lowStockItems", adao.getLowStockItems());
        request.setAttribute("totalStaff", adao.countTotalStaff());

        Map<String, Integer> staffSummary = new HashMap<>();
        staffSummary.put("inactiveStaff", adao.countInactiveStaff());
        staffSummary.put("totalRoles", adao.countTotalRoles());
        request.setAttribute("staffSummary", staffSummary);

        request.setAttribute("roomBreakdown", adao.getRoomStatusBreakdown());
        request.setAttribute("totalRoomsCount", adao.countTotalRooms());
        request.setAttribute("chartData", adao.getRevenueLast7Days());

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}