package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.LoaiPhong;

public class LoaiPhongDAO {

    public List<LoaiPhong> getAll() {
        List<LoaiPhong> list = new ArrayList<>();
        String sql = "SELECT * FROM LoaiPhong";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new LoaiPhong(
                    rs.getInt("MaLoai"),
                    rs.getString("TenLoai"),
                    rs.getDouble("GiaTheoGio"),
                    rs.getInt("SoNguoiToiDa"),
                    rs.getString("HinhAnh")
                ));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean insert(LoaiPhong lp) {
        String sql = "INSERT INTO LoaiPhong (TenLoai, GiaTheoGio, SoNguoiToiDa, HinhAnh) VALUES (?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, lp.getTenLoai());
            ps.setDouble(2, lp.getGiaTheoGio());
            ps.setInt(3, lp.getSoNguoiToiDa());
            ps.setString(4, lp.getHinhAnh());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean update(LoaiPhong lp) {
        String sql = "UPDATE LoaiPhong SET TenLoai=?, GiaTheoGio=?, SoNguoiToiDa=?, HinhAnh=? WHERE MaLoai=?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, lp.getTenLoai());
            ps.setDouble(2, lp.getGiaTheoGio());
            ps.setInt(3, lp.getSoNguoiToiDa());
            ps.setString(4, lp.getHinhAnh());
            ps.setInt(5, lp.getMaLoai());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean delete(int id) {
        String sql = "DELETE FROM LoaiPhong WHERE MaLoai = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }
}