package controller.admin;

import dal.DoanhThuDAO;
import model.HoaDon;
import model.NhanVien;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RevenueReportServlet", urlPatterns = {"/admin/revenue-report"})
public class RevenueReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        DoanhThuDAO dao = new DoanhThuDAO();
        
        // 1. Lấy tham số lọc từ Request
        String type = request.getParameter("reportType"); // day, month, year
        if (type == null || type.isEmpty()) {
            type = "day"; // Mặc định là xem theo ngày
        }
        
        String date = request.getParameter("selectedDate");
        String month = request.getParameter("selectedMonth");
        String year = request.getParameter("selectedYear");
        String empId = request.getParameter("selectedEmp"); // Sẽ nhận vào là "all" hoặc ID (String)

        // 2. Xử lý thời gian động (Bỏ Hard-code)
        LocalDate now = LocalDate.now(); 
        
        // Gán giá trị mặc định nếu người dùng chưa chọn
        if (date == null || date.isEmpty()) {
            date = now.toString(); // yyyy-MM-dd
        }
        if (month == null || month.isEmpty()) {
            month = String.valueOf(now.getMonthValue());
        }
        if (year == null || year.isEmpty()) {
            year = String.valueOf(now.getYear());
        }
        if (empId == null || empId.isEmpty()) {
            empId = "all";
        }

        // 3. Load danh sách nhân viên cho ComboBox (Luôn phải load để hiện lên giao diện)
        List<NhanVien> empList = dao.getAllEmployees();
        request.setAttribute("empList", empList);

        // 4. Lấy dữ liệu từ DAO (Sử dụng các hàm an toàn đã viết)
        List<HoaDon> list = dao.getRevenueReport(type, date, month, year, empId);
        Map<String, Double> chartData = dao.getChartData(type, date, month, year, empId);
        
        // Tính tổng tiền nhanh từ danh sách
        double total = list.stream().mapToDouble(HoaDon::getTongTien).sum();

        // 5. Đẩy toàn bộ dữ liệu ra JSP
        request.setAttribute("revenueList", list);
        request.setAttribute("totalRevenue", total);
        request.setAttribute("chartData", chartData);
        
        // Gửi lại các giá trị đã chọn để giữ trạng thái trên Form (Tránh bị reset khi load lại trang)
        request.setAttribute("reportType", type);
        request.setAttribute("sDate", date);
        request.setAttribute("sMonth", month);
        request.setAttribute("sYear", year);
        request.setAttribute("sEmp", empId);

        // 6. Chuyển hướng sang trang hiển thị
        request.getRequestDispatcher("/admin/revenue-report.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response); // Chuyển POST sang GET để xử lý chung một logic lọc
    }
}