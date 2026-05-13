package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.ChucVu;

public class ChucVuDAO {

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

    public boolean insertRole(String name) {
        String sql = "INSERT INTO ChucVu (TenCV) VALUES (?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateRole(int id, String name) {
        String sql = "UPDATE ChucVu SET TenCV = ? WHERE MaCV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteRole(int id) {
        String sql = "DELETE FROM ChucVu WHERE MaCV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}