package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.DichVu;

public class DichVuDAO {

    // Lấy tất cả món (dùng cho trang khách)
    public List<DichVu> getAllServices() {
        List<DichVu> list = new ArrayList<>();
        String sql = "SELECT d.*, l.TenLoaiDV FROM DichVu d "
                   + "JOIN LoaiDichVu l ON d.MaLoaiDV = l.MaLoaiDV";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new DichVu(
                    rs.getInt("MaDV"), rs.getString("TenDV"),
                    rs.getDouble("Gia"), rs.getInt("SoLuongTon"),
                    rs.getInt("MaLoaiDV"), rs.getString("HinhAnh"),
                    rs.getString("TenLoaiDV"), rs.getInt("TrangThaiHienThi")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<DichVu> searchServices(String txtSearch, String categoryFilter) {
        List<DichVu> list = new ArrayList<>();
        String sql = "SELECT d.*, l.TenLoaiDV FROM DichVu d "
                   + "JOIN LoaiDichVu l ON d.MaLoaiDV = l.MaLoaiDV WHERE 1=1";
        if (txtSearch != null && !txtSearch.isEmpty()) sql += " AND d.TenDV LIKE ?";
        if (categoryFilter != null && !categoryFilter.isEmpty()) sql += " AND d.MaLoaiDV = ?";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int i = 1;
            if (txtSearch != null && !txtSearch.isEmpty()) ps.setString(i++, "%" + txtSearch + "%");
            if (categoryFilter != null && !categoryFilter.isEmpty()) ps.setInt(i++, Integer.parseInt(categoryFilter));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new DichVu(
                        rs.getInt("MaDV"), rs.getString("TenDV"),
                        rs.getDouble("Gia"), rs.getInt("SoLuongTon"),
                        rs.getInt("MaLoaiDV"), rs.getString("HinhAnh"),
                        rs.getString("TenLoaiDV"), rs.getInt("TrangThaiHienThi")
                    ));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean insertService(DichVu d) {
        String sql = "INSERT INTO DichVu (TenDV, Gia, SoLuongTon, MaLoaiDV, HinhAnh, TrangThaiHienThi) VALUES (?, ?, ?, ?, ?, 1)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, d.getTenDV());
            ps.setDouble(2, d.getGia());
            ps.setInt(3, d.getSoLuongTon());
            ps.setInt(4, d.getMaLoaiDV());
            ps.setString(5, d.getHinhAnh());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateService(DichVu d) {
        String sql = "UPDATE DichVu SET TenDV = ?, Gia = ?, SoLuongTon = ?, MaLoaiDV = ?, HinhAnh = ?, TrangThaiHienThi = ? WHERE MaDV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, d.getTenDV());
            ps.setDouble(2, d.getGia());
            ps.setInt(3, d.getSoLuongTon());
            ps.setInt(4, d.getMaLoaiDV());
            ps.setString(5, d.getHinhAnh());
            ps.setInt(6, d.getTrangThaiHienThi());
            ps.setInt(7, d.getMaDV());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateVisibility(int maDV, int status) {
        String sql = "UPDATE DichVu SET TrangThaiHienThi = ? WHERE MaDV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, maDV);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteService(int maDV) {
        String sql = "DELETE FROM DichVu WHERE MaDV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, maDV);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean addStock(int maDV, int quantityToAdd) {
        String sql = "UPDATE DichVu SET SoLuongTon = SoLuongTon + ? WHERE MaDV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantityToAdd);
            ps.setInt(2, maDV);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}