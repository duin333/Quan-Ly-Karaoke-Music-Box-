package dal;

import java.sql.*;
import java.util.*;
import model.HoaDon;
import model.NhanVien;

public class DoanhThuDAO {

    public List<NhanVien> getAllEmployees() {
        List<NhanVien> list = new ArrayList<>();
        String sql = "SELECT MaNV, TenNV FROM NhanVien WHERE TrangThai = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                NhanVien nv = new NhanVien();
                nv.setMaNV(rs.getInt("MaNV"));
                nv.setTenNV(rs.getString("TenNV"));
                list.add(nv);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<HoaDon> getRevenueReport(String type, String date, String month, String year, String empId) {
        List<HoaDon> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT h.MaHD, h.MaPhong, nv.TenNV, h.GioKetThuc, h.TongTien "
          + "FROM HoaDon h JOIN NhanVien nv ON h.MaNV = nv.MaNV "
          + "WHERE h.TrangThai = 1"
        );
        List<Object> params = new ArrayList<>();

        if ("day".equals(type) && date != null && !date.isEmpty()) {
            sql.append(" AND DATE(h.GioKetThuc) = ?");
            params.add(date);
        } else if ("month".equals(type)) {
            sql.append(" AND MONTH(h.GioKetThuc) = ? AND YEAR(h.GioKetThuc) = ?");
            params.add(month);
            params.add(year);
        } else if ("year".equals(type)) {
            sql.append(" AND YEAR(h.GioKetThuc) = ?");
            params.add(year);
        }

        if (empId != null && !empId.equals("all")) {
            sql.append(" AND h.MaNV = ?");
            params.add(empId);
        }

        sql.append(" ORDER BY h.GioKetThuc DESC");

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new HoaDon(
                        rs.getInt("MaHD"),
                        rs.getString("MaPhong"),
                        rs.getString("TenNV"),
                        rs.getTimestamp("GioKetThuc"),
                        rs.getDouble("TongTien")
                    ));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public Map<String, Double> getChartData(String type, String date, String month, String year, String empId) {
        Map<String, Double> data = new LinkedHashMap<>();
        StringBuilder sql = new StringBuilder("SELECT DATE_FORMAT(GioKetThuc, ");
        List<Object> params = new ArrayList<>();

        if ("day".equals(type))        sql.append("'%H:00'");
        else if ("month".equals(type)) sql.append("'%d/%m'");
        else                           sql.append("'Tháng %m'");

        sql.append(") as Lbl, SUM(TongTien) as Total FROM HoaDon WHERE TrangThai = 1");

        if ("day".equals(type) && date != null && !date.isEmpty()) {
            sql.append(" AND DATE(GioKetThuc) = ?");
            params.add(date);
        } else if ("month".equals(type)) {
            sql.append(" AND MONTH(GioKetThuc) = ? AND YEAR(GioKetThuc) = ?");
            params.add(month);
            params.add(year);
        } else if ("year".equals(type)) {
            sql.append(" AND YEAR(GioKetThuc) = ?");
            params.add(year);
        }

        if (empId != null && !empId.equals("all")) {
            sql.append(" AND MaNV = ?");
            params.add(empId);
        }

        sql.append(" GROUP BY Lbl ORDER BY MIN(GioKetThuc) ASC");

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    data.put(rs.getString("Lbl"), rs.getDouble("Total"));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return data;
    }
}