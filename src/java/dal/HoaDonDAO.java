package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class HoaDonDAO {

    public double getMonthlyRevenue(int month, int year) {
        String sql = "SELECT SUM(TongTien) FROM HoaDon "
                   + "WHERE MONTH(GioKetThuc) = ? AND YEAR(GioKetThuc) = ? AND TrangThai = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, month);
            ps.setInt(2, year);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
}