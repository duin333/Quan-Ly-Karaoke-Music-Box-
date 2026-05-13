package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.LoaiPhong;
import model.Phong;
import model.LichSuHoTro;

public class PhongDAO {

    // ==========================================
    // QUẢN LÝ PHÒNG (CRUD)
    // ==========================================

    public List<Phong> getAllRooms() {
        List<Phong> list = new ArrayList<>();
        String sql = "SELECT p.*, lp.TenLoai, lp.GiaTheoGio, lp.SoNguoiToiDa, lp.HinhAnh "
                   + "FROM Phong p JOIN LoaiPhong lp ON p.MaLoai = lp.MaLoai";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LoaiPhong lp = new LoaiPhong();
                lp.setMaLoai(rs.getInt("MaLoai"));
                lp.setTenLoai(rs.getString("TenLoai"));
                lp.setGiaTheoGio(rs.getDouble("GiaTheoGio"));
                lp.setSoNguoiToiDa(rs.getInt("SoNguoiToiDa"));
                lp.setHinhAnh(rs.getString("HinhAnh"));

                // 🛡️ Cập nhật Constructor khớp với Model mới (supportStatus thay cho yeuCauHoTro)
                Phong p = new Phong(
                    rs.getString("MaPhong"), 
                    rs.getString("TenPhong"),
                    rs.getInt("MaLoai"), 
                    rs.getString("TrangThai"),
                    rs.getInt("SupportStatus"), // Lấy từ cột SupportStatus trong DB
                    rs.getString("GhiChuHoTro")
                );
                p.setLoaiPhong(lp);
                p.setTenLoai(rs.getString("TenLoai")); // Gán thêm thuộc tính phụ
                list.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public String getRoomStatus(String maPhong) {
        String sql = "SELECT TrangThai FROM Phong WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("TrangThai");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean insertRoom(String id, String name, int typeId) {
        // 🛡️ Khớp với các cột con đã ALTER trong Database
        String sql = "INSERT INTO Phong (MaPhong, TenPhong, MaLoai, TrangThai, YeuCauHoTro, GhiChuHoTro, SupportStatus) "
                   + "VALUES (?, ?, ?, 'Trống', 0, '', 0)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            ps.setString(2, name);
            ps.setInt(3, typeId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateRoom(String id, String name, int typeId, String status) {
        String sql = "UPDATE Phong SET TenPhong = ?, MaLoai = ?, TrangThai = ? WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setInt(2, typeId);
            ps.setString(3, status);
            ps.setString(4, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteRoom(String id) {
        String sql = "DELETE FROM Phong WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateRoomStatus(String maPhong, String status) {
        String sql = "UPDATE Phong SET TrangThai = ? WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setString(2, maPhong);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ==========================================
    // HỆ THỐNG HỖ TRỢ
    // ==========================================

    public int getSupportStatus(String maPhong) {
        String sql = "SELECT SupportStatus FROM Phong WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("SupportStatus");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0;
    }

    public String getSupportNote(String maPhong) {
        String sql = "SELECT GhiChuHoTro FROM Phong WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("GhiChuHoTro");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return "";
    }

    public List<String> getRoomsBySupportStatus(int status) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT MaPhong FROM Phong WHERE SupportStatus = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(rs.getString("MaPhong"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<String> getRoomsCalling() {
        List<String> list = new ArrayList<>();
        String sql = "SELECT MaPhong FROM Phong WHERE SupportStatus = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(rs.getString("MaPhong"));
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ==========================================
    // TRANSACTION — dùng 1 connection chung
    // ==========================================

    public boolean callSupport(String maPhong, String note) {
        String sql1 = "UPDATE Phong SET YeuCauHoTro = 1, SupportStatus = 1, GhiChuHoTro = ? WHERE MaPhong = ?";
        String sql2 = "INSERT INTO LichSuHoTro (MaPhong, NoiDung, TrangThai) VALUES (?, ?, 1)";
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sql1);
                 PreparedStatement ps2 = con.prepareStatement(sql2)) {
                ps1.setString(1, note);
                ps1.setString(2, maPhong);
                ps1.executeUpdate();

                ps2.setString(1, maPhong);
                ps2.setString(2, note);
                ps2.executeUpdate();

                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean acceptSupport(String maPhong, int maNV) {
        String sql1 = "UPDATE LichSuHoTro SET TrangThai = 2, MaNV = ?, ThoiGianDuyetHoTro = NOW() "
                    + "WHERE MaPhong = ? AND TrangThai = 1 "
                    + "AND MaLS = (SELECT maxId FROM (SELECT MAX(MaLS) as maxId FROM LichSuHoTro WHERE MaPhong = ?) as x)";
        String sql2 = "UPDATE Phong SET SupportStatus = 2 WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sql1);
                 PreparedStatement ps2 = con.prepareStatement(sql2)) {
                ps1.setInt(1, maNV);
                ps1.setString(2, maPhong);
                ps1.setString(3, maPhong);
                ps2.setString(1, maPhong);
                ps1.executeUpdate();
                ps2.executeUpdate();
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean completeSupport(String maPhong, int maNV) {
        String sql1 = "UPDATE LichSuHoTro SET TrangThai = 0, MaNV = ?, ThoiGianXong = NOW() "
                    + "WHERE MaPhong = ? AND TrangThai = 2 "
                    + "AND MaLS = (SELECT maxId FROM (SELECT MAX(MaLS) as maxId FROM LichSuHoTro WHERE MaPhong = ?) as x)";
        String sql2 = "UPDATE Phong SET SupportStatus = 0, YeuCauHoTro = 0, GhiChuHoTro = '' WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sql1);
                 PreparedStatement ps2 = con.prepareStatement(sql2)) {
                ps1.setInt(1, maNV);
                ps1.setString(2, maPhong);
                ps1.setString(3, maPhong);
                ps2.setString(1, maPhong);
                ps1.executeUpdate();
                ps2.executeUpdate();
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean switchRoom(String oldRoom, String newRoom) {
        String checkSql = "SELECT TrangThai FROM Phong WHERE MaPhong = ?";
        String sql1 = "UPDATE YeuCauGoiMon SET MaPhong = ? WHERE MaPhong = ? AND TrangThai != 3";
        String sql2 = "UPDATE PhieuDatPhong SET MaPhong = ? WHERE MaPhong = ? AND TrangThai = 2";
        String sql3 = "UPDATE Phong SET TrangThai = 'Chờ dọn' WHERE MaPhong = ?";
        String sql4 = "UPDATE Phong SET TrangThai = 'Đang hát' WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection()) {
            try (PreparedStatement check = con.prepareStatement(checkSql)) {
                check.setString(1, newRoom);
                try (ResultSet rs = check.executeQuery()) {
                    if (rs.next() && !"Trống".equals(rs.getString("TrangThai"))) return false;
                }
            }
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sql1);
                 PreparedStatement ps2 = con.prepareStatement(sql2);
                 PreparedStatement ps3 = con.prepareStatement(sql3);
                 PreparedStatement ps4 = con.prepareStatement(sql4)) {
                ps1.setString(1, newRoom); ps1.setString(2, oldRoom); ps1.executeUpdate();
                ps2.setString(1, newRoom); ps2.setString(2, oldRoom); ps2.executeUpdate();
                ps3.setString(1, oldRoom); ps3.executeUpdate();
                ps4.setString(1, newRoom); ps4.executeUpdate();
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ==========================================
    // LỊCH SỬ HỖ TRỢ
    // ==========================================

    public List<LichSuHoTro> getAllSupportHistory() {
        List<LichSuHoTro> list = new ArrayList<>();
        String sql = "SELECT ls.*, nv.TenNV FROM LichSuHoTro ls "
                   + "LEFT JOIN NhanVien nv ON ls.MaNV = nv.MaNV "
                   + "ORDER BY ls.ThoiGianGoi DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LichSuHoTro h = new LichSuHoTro();
                h.setMaLS(rs.getInt("MaLS"));
                h.setMaPhong(rs.getString("MaPhong"));
                h.setNoiDung(rs.getString("NoiDung"));
                h.setThoiGianGoi(rs.getTimestamp("ThoiGianGoi"));
                h.setThoiGianXong(rs.getTimestamp("ThoiGianXong"));
                h.setTrangThai(rs.getInt("TrangThai"));
                h.setTenNhanVien(rs.getString("TenNV"));
                list.add(h);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }
}