package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class PhieuDatPhong {
    private int maPhieu;
    private int maKH;
    private String maPhong;
    private Timestamp gioDat;
    private Timestamp gioTra;
    private int trangThai;
    private String tenKH;
    private String sdt;
    private String tenPhong;
    private double giaTheoGio;
    private String nguoiXuLy;
    private int maNV;

    public PhieuDatPhong() {
    }

    // --- GETTERS ĐÃ ĐỊNH DẠNG dd/MM/yyyy HH:mm ---
    public String getGioDat() {
        if (gioDat == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(gioDat);
    }

    public String getGioTra() {
        if (gioTra == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(gioTra);
    }

    // Hàm lấy dữ liệu gốc để tính toán
    public Timestamp getGioDatRaw() { return gioDat; }
    public Timestamp getGioTraRaw() { return gioTra; }

    // --- SETTERS VÀ CÁC GETTER KHÁC ---
    public void setGioDat(Timestamp gioDat) { this.gioDat = gioDat; }
    public void setGioTra(Timestamp gioTra) { this.gioTra = gioTra; }
    public int getMaPhieu() { return maPhieu; }
    public void setMaPhieu(int maPhieu) { this.maPhieu = maPhieu; }
    public int getMaKH() { return maKH; }
    public void setMaKH(int maKH) { this.maKH = maKH; }
    public String getMaPhong() { return maPhong; }
    public void setMaPhong(String maPhong) { this.maPhong = maPhong; }
    public int getTrangThai() { return trangThai; }
    public void setTrangThai(int trangThai) { this.trangThai = trangThai; }
    public String getTenKH() { return tenKH; }
    public void setTenKH(String tenKH) { this.tenKH = tenKH; }
    public String getSdt() { return sdt; }
    public void setSdt(String sdt) { this.sdt = sdt; }
    public String getTenPhong() { return tenPhong; }
    public void setTenPhong(String tenPhong) { this.tenPhong = tenPhong; }
    public double getGiaTheoGio() { return giaTheoGio; }
    public void setGiaTheoGio(double giaTheoGio) { this.giaTheoGio = giaTheoGio; }
    public String getNguoiXuLy() { return nguoiXuLy; }
    public void setNguoiXuLy(String nguoiXuLy) { this.nguoiXuLy = nguoiXuLy; }
    public int getMaNV() { return maNV; }
    public void setMaNV(int maNV) { this.maNV = maNV; }
}