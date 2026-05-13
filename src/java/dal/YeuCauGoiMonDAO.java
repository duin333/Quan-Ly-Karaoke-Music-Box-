package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import model.*;

public class YeuCauGoiMonDAO {

    // ==========================================
    // DỊCH VỤ & THỰC ĐƠN
    // ==========================================

    public List<DichVu> getAllServices() {
        List<DichVu> list = new ArrayList<>();
        String sql = "SELECT * FROM DichVu";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                DichVu dv = new DichVu();
                dv.setMaDV(rs.getInt("MaDV"));
                dv.setTenDV(rs.getString("TenDV"));
                dv.setGia(rs.getDouble("Gia"));
                dv.setSoLuongTon(rs.getInt("SoLuongTon"));
                dv.setMaLoaiDV(rs.getInt("MaLoaiDV"));
                dv.setHinhAnh(rs.getString("HinhAnh"));
                dv.setTrangThaiHienThi(rs.getInt("TrangThaiHienThi"));
                list.add(dv);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateServiceStock(int maDV, int quantity) {
        String sql = "UPDATE DichVu SET SoLuongTon = ? WHERE MaDV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, maDV);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean toggleServiceVisibility(int maDV, int status) {
        String sql = "UPDATE DichVu SET TrangThaiHienThi = ? WHERE MaDV = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setInt(2, maDV);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<DichVu> searchServicesByName(String txt) {
        List<DichVu> list = new ArrayList<>();
        String sql = "SELECT * FROM DichVu WHERE TenDV LIKE ? AND SoLuongTon > 0 AND TrangThaiHienThi = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, "%" + txt + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DichVu dv = new DichVu();
                    dv.setMaDV(rs.getInt("MaDV"));
                    dv.setTenDV(rs.getString("TenDV"));
                    dv.setGia(rs.getDouble("Gia"));
                    dv.setSoLuongTon(rs.getInt("SoLuongTon"));
                    list.add(dv);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    // ==========================================
    // QUẢN LÝ YÊU CẦU GỌI MÓN
    // ==========================================

    public boolean insertOrderRequests(List<YeuCauGoiMon> list) {
        String sql = "INSERT INTO YeuCauGoiMon (MaPhong, MaDV, SoLuong, TrangThai) VALUES (?, ?, ?, 0)";
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                for (YeuCauGoiMon yc : list) {
                    ps.setString(1, yc.getMaPhong());
                    ps.setInt(2, yc.getMaDV());
                    ps.setInt(3, yc.getSoLuong());
                    ps.addBatch();
                }
                ps.executeBatch();
                con.commit();
                return true;
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
                return false;
            }
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<YeuCauGoiMon> getPendingOrders() {
        List<YeuCauGoiMon> list = new ArrayList<>();
        String sql = "SELECT * FROM YeuCauGoiMon WHERE TrangThai = 0 ORDER BY ThoiGian DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                YeuCauGoiMon yc = new YeuCauGoiMon();
                yc.setMaYC(rs.getInt("MaYC"));
                yc.setMaPhong(rs.getString("MaPhong"));
                yc.setMaDV(rs.getInt("MaDV"));
                yc.setSoLuong(rs.getInt("SoLuong"));
                yc.setThoiGian(rs.getTimestamp("ThoiGian"));
                list.add(yc);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<YeuCauGoiMon> getOrdersByRoom(String maPhong) {
        List<YeuCauGoiMon> list = new ArrayList<>();
        String sql = "SELECT yc.*, dv.TenDV, dv.Gia FROM YeuCauGoiMon yc "
                   + "JOIN DichVu dv ON yc.MaDV = dv.MaDV "
                   + "WHERE yc.MaPhong = ? AND yc.TrangThai = 0";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    YeuCauGoiMon yc = new YeuCauGoiMon();
                    yc.setMaYC(rs.getInt("MaYC"));
                    yc.setMaPhong(rs.getString("MaPhong"));
                    yc.setTenDV(rs.getString("TenDV"));
                    yc.setGia(rs.getDouble("Gia"));
                    yc.setSoLuong(rs.getInt("SoLuong"));
                    list.add(yc);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public String updateStatus(int maYC, int status) {
        if (status == 2) {
            String sql = "UPDATE YeuCauGoiMon SET TrangThai = 2, ThoiGianDuyet = NOW() WHERE MaYC = ?";
            try (Connection con = DBContext.getConnection();
                 PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, maYC);
                return ps.executeUpdate() > 0 ? "success" : "fail";
            } catch (SQLException e) { return "error"; }
        }
        String sql = "{CALL sp_DuyetYeuCau(?, ?)}";
        try (Connection con = DBContext.getConnection();
             CallableStatement cs = con.prepareCall(sql)) {
            cs.setInt(1, maYC);
            cs.registerOutParameter(2, Types.VARCHAR);
            cs.execute();
            return cs.getString(2);
        } catch (SQLException e) { e.printStackTrace(); return "error"; }
    }

    public boolean updateAllStatusByRoom(String maPhong, int status) {
        String sql = "UPDATE YeuCauGoiMon SET TrangThai = ? WHERE MaPhong = ? AND TrangThai = 0";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, status);
            ps.setString(2, maPhong);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public List<YeuCauGoiMon> getOrdersByRoomForGuest(String maPhong) {
        List<YeuCauGoiMon> list = new ArrayList<>();
        String sql = "SELECT yc.*, dv.TenDV, dv.Gia FROM YeuCauGoiMon yc "
                   + "JOIN DichVu dv ON yc.MaDV = dv.MaDV "
                   + "JOIN PhieuDatPhong pdp ON yc.MaPhong = pdp.MaPhong "
                   + "WHERE yc.MaPhong = ? AND pdp.TrangThai = 2 AND yc.TrangThai != 3 "
                   + "ORDER BY yc.ThoiGian DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    YeuCauGoiMon yc = new YeuCauGoiMon();
                    yc.setMaYC(rs.getInt("MaYC"));
                    yc.setTenDV(rs.getString("TenDV"));
                    yc.setGia(rs.getDouble("Gia"));
                    yc.setSoLuong(rs.getInt("SoLuong"));
                    yc.setTrangThai(rs.getInt("TrangThai"));
                    yc.setThoiGian(rs.getTimestamp("ThoiGian"));
                    list.add(yc);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<YeuCauGoiMon> getApprovedOrdersByRoom(String maPhong) {
        List<YeuCauGoiMon> list = new ArrayList<>();
        String sql = "SELECT dv.TenDV, dv.Gia, SUM(yc.SoLuong) AS TongSoLuong "
                   + "FROM YeuCauGoiMon yc JOIN DichVu dv ON yc.MaDV = dv.MaDV "
                   + "WHERE yc.MaPhong = ? AND yc.TrangThai = 4 "
                   + "GROUP BY dv.MaDV, dv.TenDV, dv.Gia";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    YeuCauGoiMon yc = new YeuCauGoiMon();
                    yc.setTenDV(rs.getString("TenDV"));
                    yc.setGia(rs.getDouble("Gia"));
                    yc.setSoLuong(rs.getInt("TongSoLuong"));
                    list.add(yc);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public List<YeuCauGoiMon> getItemsToServe(String maPhong) {
        List<YeuCauGoiMon> list = new ArrayList<>();
        String sql = "SELECT yc.*, dv.TenDV FROM YeuCauGoiMon yc "
                   + "JOIN DichVu dv ON yc.MaDV = dv.MaDV "
                   + "WHERE yc.MaPhong = ? AND yc.TrangThai = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    YeuCauGoiMon yc = new YeuCauGoiMon();
                    yc.setMaYC(rs.getInt("MaYC"));
                    yc.setTenDV(rs.getString("TenDV"));
                    yc.setSoLuong(rs.getInt("SoLuong"));
                    list.add(yc);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean confirmServed(int maYC) {
        String sql = "UPDATE YeuCauGoiMon SET TrangThai = 4 WHERE MaYC = ? AND TrangThai = 1";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, maYC);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateOrderQuantity(int maYC, int newQty) {
        String sql = "UPDATE YeuCauGoiMon SET SoLuong = ? WHERE MaYC = ? AND TrangThai < 3";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, newQty);
            ps.setInt(2, maYC);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteOrderRequest(int maYC) {
        String sql = "DELETE FROM YeuCauGoiMon WHERE MaYC = ? AND TrangThai < 3";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, maYC);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean addSingleOrderForStaff(String maPhong, int maDV, int soLuong) {
        String sql = "INSERT INTO YeuCauGoiMon (MaPhong, MaDV, SoLuong, TrangThai) VALUES (?, ?, ?, 0)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            ps.setInt(2, maDV);
            ps.setInt(3, soLuong);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateNoteByRoom(String maPhong, String note) {
        String sql = "UPDATE YeuCauGoiMon SET GhiChu = ? WHERE MaPhong = ? AND TrangThai = 0";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, note);
            ps.setString(2, maPhong);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // ==========================================
    // ĐẶT PHÒNG & THANH TOÁN
    // ==========================================

    public KhachHang getCustomerByPhone(String sdt) {
        String sql = "SELECT * FROM KhachHang WHERE SDT = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, sdt);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return new KhachHang(
                    rs.getInt("MaKH"), rs.getString("TenKH"), rs.getString("SDT"));
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<Phong> getAvailableRooms() {
        List<Phong> list = new ArrayList<>();
        String sql = "SELECT p.MaPhong, p.TenPhong, p.TrangThai, lp.TenLoai, lp.GiaTheoGio "
                   + "FROM Phong p JOIN LoaiPhong lp ON p.MaLoai = lp.MaLoai "
                   + "WHERE p.TrangThai = 'Trống'";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                LoaiPhong lp = new LoaiPhong();
                lp.setTenLoai(rs.getString("TenLoai"));
                lp.setGiaTheoGio(rs.getDouble("GiaTheoGio"));
                Phong p = new Phong();
                p.setMaPhong(rs.getString("MaPhong"));
                p.setTenPhong(rs.getString("TenPhong"));
                p.setTrangThai(rs.getString("TrangThai"));
                p.setLoaiPhong(lp);
                list.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public String insertBooking(int maKH, String maPhong, String gioDat) {
        String sql = "INSERT INTO PhieuDatPhong (MaKH, MaPhong, GioDat, TrangThai) VALUES (?, ?, ?, 1)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, maKH);
            ps.setString(2, maPhong);
            ps.setString(3, gioDat);
            return ps.executeUpdate() > 0 ? "success" : "error";
        } catch (SQLException e) { e.printStackTrace(); return "error"; }
    }

    public List<PhieuDatPhong> getWaitingBookingsByDate(String date) {
        List<PhieuDatPhong> list = new ArrayList<>();
        String sql = "SELECT pdp.*, kh.TenKH, kh.SDT FROM PhieuDatPhong pdp "
                   + "JOIN KhachHang kh ON pdp.MaKH = kh.MaKH "
                   + "WHERE pdp.TrangThai = 1 AND DATE(pdp.GioDat) = ? "
                   + "ORDER BY pdp.GioDat ASC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, date);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PhieuDatPhong p = new PhieuDatPhong();
                    p.setMaPhieu(rs.getInt("MaPhieu"));
                    p.setTenKH(rs.getString("TenKH"));
                    p.setSdt(rs.getString("SDT"));
                    p.setMaPhong(rs.getString("MaPhong"));
                    // 🛡️ Đồng bộ Model mới
                    p.setGioDat(rs.getTimestamp("GioDat"));
                    p.setTrangThai(rs.getInt("TrangThai"));
                    list.add(p);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public boolean checkInBooking(int maPhieu, String maPhong) {
        String sql1 = "UPDATE PhieuDatPhong SET TrangThai = 2 WHERE MaPhieu = ?";
        String sql2 = "UPDATE Phong SET TrangThai = 'Đang hát' WHERE MaPhong = ?";
        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps1 = con.prepareStatement(sql1);
                 PreparedStatement ps2 = con.prepareStatement(sql2)) {
                ps1.setInt(1, maPhieu);
                ps2.setString(1, maPhong);
                if (ps1.executeUpdate() > 0 && ps2.executeUpdate() > 0) {
                    con.commit();
                    return true;
                } else {
                    con.rollback();
                }
            } catch (SQLException e) {
                con.rollback();
                e.printStackTrace();
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return false;
    }

    public boolean cancelBooking(int maPhieu, int maNV) {
        String sql = "UPDATE PhieuDatPhong SET TrangThai = 0, MaNV = ? WHERE MaPhieu = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, maNV);
            ps.setInt(2, maPhieu);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean insertCustomer(String tenKH, String sdt) {
        String sql = "INSERT INTO KhachHang (TenKH, SDT) VALUES (?, ?)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, tenKH);
            ps.setString(2, sdt);
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

    public List<PhieuDatPhong> getAllActiveBookings() {
        List<PhieuDatPhong> list = new ArrayList<>();
        String sql = "SELECT pdp.*, p.TenPhong, kh.TenKH, kh.SDT "
                   + "FROM PhieuDatPhong pdp JOIN Phong p ON pdp.MaPhong = p.MaPhong "
                   + "JOIN KhachHang kh ON pdp.MaKH = kh.MaKH "
                   + "WHERE pdp.TrangThai = 2 ORDER BY pdp.GioDat ASC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PhieuDatPhong p = new PhieuDatPhong();
                p.setMaPhieu(rs.getInt("MaPhieu"));
                p.setMaPhong(rs.getString("MaPhong"));
                p.setTenPhong(rs.getString("TenPhong"));
                p.setTenKH(rs.getString("TenKH"));
                p.setSdt(rs.getString("SDT"));
                // 🛡️ Đồng bộ Model mới
                p.setGioDat(rs.getTimestamp("GioDat"));
                list.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public PhieuDatPhong getActiveBooking(String maPhong) {
        String sql = "SELECT pdp.*, p.TenPhong, lp.GiaTheoGio, kh.TenKH, kh.SDT "
                   + "FROM PhieuDatPhong pdp JOIN Phong p ON pdp.MaPhong = p.MaPhong "
                   + "JOIN LoaiPhong lp ON p.MaLoai = lp.MaLoai "
                   + "JOIN KhachHang kh ON pdp.MaKH = kh.MaKH "
                   + "WHERE pdp.MaPhong = ? AND pdp.TrangThai = 2";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, maPhong);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PhieuDatPhong p = new PhieuDatPhong();
                    p.setMaPhieu(rs.getInt("MaPhieu"));
                    // 🛡️ Đồng bộ Model mới
                    p.setGioDat(rs.getTimestamp("GioDat"));
                    p.setGiaTheoGio(rs.getDouble("GiaTheoGio"));
                    p.setTenPhong(rs.getString("TenPhong"));
                    p.setMaPhong(rs.getString("MaPhong"));
                    p.setTenKH(rs.getString("TenKH"));
                    p.setSdt(rs.getString("SDT"));
                    return p;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public boolean confirmPayment(int maPhieu, String maPhong, String gioTra, int maNV, double tongTien) {
        if (gioTra != null && gioTra.contains(".")) gioTra = gioTra.substring(0, gioTra.indexOf("."));
        String formattedGioTra = (gioTra != null) ? gioTra.replace("T", " ") : "";
        double finalAmount = Math.max(0, tongTien);

        String sqlHD   = "INSERT INTO HoaDon (MaPhong, MaNV, MaKH, GioBatDau, GioKetThuc, TongTien, TrangThai) "
                       + "SELECT MaPhong, ?, MaKH, GioDat, ?, ?, 1 FROM PhieuDatPhong WHERE MaPhieu = ?";
        String sqlCTHD = "INSERT INTO ChiTietHoaDon (MaHD, MaDV, SoLuong, GiaTaiThoiDiem) "
                       + "SELECT ?, yc.MaDV, SUM(yc.SoLuong), (SELECT Gia FROM DichVu WHERE MaDV = yc.MaDV) "
                       + "FROM YeuCauGoiMon yc JOIN PhieuDatPhong pdp ON yc.MaPhong = pdp.MaPhong "
                       + "WHERE pdp.MaPhieu = ? AND yc.MaPhong = ? AND yc.TrangThai = 4 "
                       + "AND yc.ThoiGian >= pdp.GioDat GROUP BY yc.MaDV";
        String sqlPhieu = "UPDATE PhieuDatPhong SET TrangThai = 3, GioTra = ?, MaNV = ? WHERE MaPhieu = ?";
        String sqlPhong = "UPDATE Phong SET TrangThai = 'Chờ dọn' WHERE MaPhong = ?";
        String sqlMon   = "UPDATE YeuCauGoiMon yc JOIN PhieuDatPhong pdp ON yc.MaPhong = pdp.MaPhong "
                       + "SET yc.TrangThai = 3 "
                       + "WHERE pdp.MaPhieu = ? AND yc.MaPhong = ? AND yc.TrangThai IN (0,1,2,4) "
                       + "AND yc.ThoiGian >= pdp.GioDat";

        try (Connection con = DBContext.getConnection()) {
            con.setAutoCommit(false);
            try {
                int maHD = 0;
                try (PreparedStatement ps = con.prepareStatement(sqlHD, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, maNV);
                    ps.setString(2, formattedGioTra);
                    ps.setDouble(3, finalAmount);
                    ps.setInt(4, maPhieu);
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) maHD = rs.getInt(1);
                    }
                }
                if (maHD > 0) {
                    try (PreparedStatement ps = con.prepareStatement(sqlCTHD)) {
                        ps.setInt(1, maHD);
                        ps.setInt(2, maPhieu);
                        ps.setString(3, maPhong);
                        ps.executeUpdate();
                    }
                }
                try (PreparedStatement ps = con.prepareStatement(sqlPhieu)) {
                    ps.setString(1, formattedGioTra);
                    ps.setInt(2, maNV);
                    ps.setInt(3, maPhieu);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(sqlPhong)) {
                    ps.setString(1, maPhong);
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = con.prepareStatement(sqlMon)) {
                    ps.setInt(1, maPhieu);
                    ps.setString(2, maPhong);
                    ps.executeUpdate();
                }
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
    // LỊCH SỬ & THỐNG KÊ
    // ==========================================

    public double getRevenueByDate(String date) {
        double total = 0;
        String sql = "SELECT "
                   + "(SELECT COALESCE(SUM(TIMESTAMPDIFF(MINUTE, pdp.GioDat, pdp.GioTra) / 60.0 * lp.GiaTheoGio), 0) "
                   + " FROM PhieuDatPhong pdp JOIN Phong p ON pdp.MaPhong = p.MaPhong "
                   + " JOIN LoaiPhong lp ON p.MaLoai = lp.MaLoai "
                   + " WHERE pdp.TrangThai = 3 AND DATE(pdp.GioTra) = ?) AS TienGio, "
                   + "(SELECT COALESCE(SUM(yc.SoLuong * dv.Gia), 0) "
                   + " FROM YeuCauGoiMon yc JOIN DichVu dv ON yc.MaDV = dv.MaDV "
                   + " WHERE yc.TrangThai = 3 AND DATE(yc.ThoiGian) = ?) AS TienDV";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, date);
            ps.setString(2, date);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) total = rs.getDouble("TienGio") + rs.getDouble("TienDV");
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return total;
    }

    public List<PhieuDatPhong> getPaidBookings() {
        List<PhieuDatPhong> list = new ArrayList<>();
        String sql = "SELECT pdp.*, p.TenPhong, kh.TenKH, kh.SDT, nv.TenNV AS NguoiXuLy "
                   + "FROM PhieuDatPhong pdp LEFT JOIN Phong p ON pdp.MaPhong = p.MaPhong "
                   + "LEFT JOIN KhachHang kh ON pdp.MaKH = kh.MaKH "
                   + "LEFT JOIN NhanVien nv ON pdp.MaNV = nv.MaNV "
                   + "WHERE pdp.TrangThai IN (3, 0, 4) ORDER BY pdp.GioDat DESC";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                PhieuDatPhong p = new PhieuDatPhong();
                p.setMaPhieu(rs.getInt("MaPhieu"));
                p.setMaPhong(rs.getString("MaPhong"));
                p.setTenPhong(rs.getString("TenPhong"));
                // 🛡️ Đồng bộ Model mới
                p.setGioDat(rs.getTimestamp("GioDat"));
                p.setGioTra(rs.getTimestamp("GioTra"));
                p.setTenKH(rs.getString("TenKH"));
                p.setSdt(rs.getString("SDT"));
                p.setTrangThai(rs.getInt("TrangThai"));
                p.setNguoiXuLy(rs.getString("NguoiXuLy"));
                list.add(p);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public PhieuDatPhong getPaidBookingById(int maPhieu) {
        String sql = "SELECT pdp.*, p.TenPhong, lp.GiaTheoGio, kh.TenKH, kh.SDT, nv.TenNV AS NguoiXuLy "
                   + "FROM PhieuDatPhong pdp LEFT JOIN Phong p ON pdp.MaPhong = p.MaPhong "
                   + "LEFT JOIN LoaiPhong lp ON p.MaLoai = lp.MaLoai "
                   + "LEFT JOIN KhachHang kh ON pdp.MaKH = kh.MaKH "
                   + "LEFT JOIN NhanVien nv ON pdp.MaNV = nv.MaNV "
                   + "WHERE pdp.MaPhieu = ? AND pdp.TrangThai IN (3, 0, 4)";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, maPhieu);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    PhieuDatPhong p = new PhieuDatPhong();
                    p.setMaPhieu(rs.getInt("MaPhieu"));
                    p.setMaPhong(rs.getString("MaPhong"));
                    p.setTenPhong(rs.getString("TenPhong"));
                    // 🛡️ Đồng bộ Model mới
                    p.setGioDat(rs.getTimestamp("GioDat"));
                    p.setGioTra(rs.getTimestamp("GioTra"));
                    p.setGiaTheoGio(rs.getDouble("GiaTheoGio"));
                    p.setTenKH(rs.getString("TenKH"));
                    p.setSdt(rs.getString("SDT"));
                    p.setTrangThai(rs.getInt("TrangThai"));
                    p.setNguoiXuLy(rs.getString("NguoiXuLy"));
                    return p;
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return null;
    }

    public List<YeuCauGoiMon> getItemsByBookingId(int maPhieu, String maPhong, String gioDat, String gioTra) {
        List<YeuCauGoiMon> list = new ArrayList<>();
        String sql = "SELECT dv.TenDV, ct.GiaTaiThoiDiem AS Gia, ct.SoLuong "
                   + "FROM ChiTietHoaDon ct JOIN HoaDon hd ON ct.MaHD = hd.MaHD "
                   + "JOIN DichVu dv ON ct.MaDV = dv.MaDV "
                   + "WHERE hd.MaPhong = ? AND hd.GioBatDau = ?";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (gioDat != null && gioDat.contains(".")) gioDat = gioDat.substring(0, gioDat.indexOf("."));
            ps.setString(1, maPhong);
            ps.setString(2, gioDat != null ? gioDat.replace("T", " ") : "");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    YeuCauGoiMon yc = new YeuCauGoiMon();
                    yc.setTenDV(rs.getString("TenDV"));
                    yc.setGia(rs.getDouble("Gia"));
                    yc.setSoLuong(rs.getInt("SoLuong"));
                    list.add(yc);
                }
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return list;
    }

    public void autoCancelExpiredBookings() {
        String sql = "UPDATE PhieuDatPhong SET TrangThai = 4 "
                   + "WHERE TrangThai = 1 AND TIMESTAMPDIFF(MINUTE, GioDat, NOW()) > 30";
        try (Connection con = DBContext.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.executeUpdate();
        } catch (SQLException e) { e.printStackTrace(); }
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
}