package dal;

import java.sql.*;
import java.util.*;

public class AdminDAO {

    public double getRevenueToday() {
        String sql = "SELECT SUM(TongTien) FROM HoaDon WHERE DATE(GioKetThuc) = CURDATE() AND TrangThai = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getDouble(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getOccupiedRooms() {
        String sql = "SELECT COUNT(*) FROM Phong WHERE TrangThai = 'Đang hát'";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int getLowStockItems() {
        String sql = "SELECT COUNT(*) FROM DichVu WHERE SoLuongTon < 10";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countTotalStaff() {
        String sql = "SELECT COUNT(*) FROM NhanVien WHERE TrangThai = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public Map<String, Double> getRevenueLast7Days() {
        Map<String, Double> data = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(GioKetThuc, '%d/%m') as Date, SUM(TongTien) as Total "
                   + "FROM HoaDon WHERE GioKetThuc >= DATE_SUB(CURDATE(), INTERVAL 6 DAY) "
                   + "AND TrangThai = 1 GROUP BY Date ORDER BY MIN(GioKetThuc) ASC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) data.put(rs.getString("Date"), rs.getDouble("Total"));
        } catch (SQLException e) { e.printStackTrace(); }
        return data;
    }

    public int countInactiveStaff() {
        String sql = "SELECT COUNT(*) FROM NhanVien WHERE TrangThai = 0";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public int countTotalRoles() {
        String sql = "SELECT COUNT(*) FROM ChucVu";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public Map<String, Integer> getRoomStatusBreakdown() {
        Map<String, Integer> breakdown = new HashMap<>();
        String sql = "SELECT TrangThai, COUNT(*) FROM Phong GROUP BY TrangThai";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) breakdown.put(rs.getString(1), rs.getInt(2));
        } catch (SQLException e) { e.printStackTrace(); }
        return breakdown;
    }

    public int countTotalRooms() {
        String sql = "SELECT COUNT(*) FROM Phong";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }
}