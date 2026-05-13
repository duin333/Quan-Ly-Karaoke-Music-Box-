package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.NhanVien;
import model.ChucVu;
import java.util.ArrayList;
import java.util.List;

public class NhanVienDAO {

    // Đăng nhập
    public NhanVien login(String user, String pass) {
        String sql = "SELECT * FROM NhanVien WHERE Username = ? AND Password = ? AND TrangThai = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, user);
            ps.setString(2, pass);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new NhanVien(
                        rs.getInt("MaNV"), rs.getString("TenNV"),
                        rs.getString("Username"), rs.getString("Password"),
                        rs.getInt("MaCV"), rs.getInt("TrangThai")
                    );
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    // Lấy tất cả nhân viên
    public List<NhanVien> getAllStaffAdmin() {
        List<NhanVien> list = new ArrayList<>();
        String sql = "SELECT * FROM NhanVien";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new NhanVien(
                    rs.getInt("MaNV"), rs.getString("TenNV"),
                    rs.getString("Username"), rs.getString("Password"),
                    rs.getInt("MaCV"), rs.getInt("TrangThai")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Tìm kiếm và lọc nhân viên
    public List<NhanVien> searchStaff(String txtSearch, String roleId) {
        List<NhanVien> list = new ArrayList<>();
        String sql = "SELECT * FROM NhanVien WHERE 1=1";
        if (txtSearch != null && !txtSearch.isEmpty()) sql += " AND (TenNV LIKE ? OR Username LIKE ?)";
        if (roleId != null && !roleId.isEmpty()) sql += " AND MaCV = ?";

        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int i = 1;
            if (txtSearch != null && !txtSearch.isEmpty()) {
                ps.setString(i++, "%" + txtSearch + "%");
                ps.setString(i++, "%" + txtSearch + "%");
            }
            if (roleId != null && !roleId.isEmpty()) {
                ps.setInt(i++, Integer.parseInt(roleId));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new NhanVien(
                        rs.getInt("MaNV"), rs.getString("TenNV"),
                        rs.getString("Username"), rs.getString("Password"),
                        rs.getInt("MaCV"), rs.getInt("TrangThai")
                    ));
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // Thêm nhân viên
    public boolean insertStaff(String ten, String user, String pass, int cv) {
        String sql = "INSERT INTO NhanVien (TenNV, Username, Password, MaCV, TrangThai) VALUES (?, ?, ?, ?, 1)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, ten);
            ps.setString(2, user);
            ps.setString(3, pass);
            ps.setInt(4, cv);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Cập nhật nhân viên
    public boolean updateStaff(int id, String ten, String user, String pass, int cv) {
        String sql = "UPDATE NhanVien SET TenNV = ?, Username = ?, Password = ?, MaCV = ? WHERE MaNV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, ten);
            ps.setString(2, user);
            ps.setString(3, pass);
            ps.setInt(4, cv);
            ps.setInt(5, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Khóa / Mở khóa
    public void toggleStatus(int maNV, int currentStatus) {
        String sql = "UPDATE NhanVien SET TrangThai = ? WHERE MaNV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, currentStatus == 1 ? 0 : 1);
            ps.setInt(2, maNV);
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
    }

    // Lấy danh sách chức vụ
    public List<ChucVu> getAllRoles() {
        List<ChucVu> list = new ArrayList<>();
        String sql = "SELECT * FROM ChucVu";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new ChucVu(rs.getInt("MaCV"), rs.getString("TenCV")));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}