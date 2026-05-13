package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.LoaiDichVu;

public class LoaiDichVuDAO {

    public List<LoaiDichVu> getAll() {
        List<LoaiDichVu> list = new ArrayList<>();
        String sql = "SELECT * FROM LoaiDichVu";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new LoaiDichVu(rs.getInt("MaLoaiDV"), rs.getString("TenLoaiDV")));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}