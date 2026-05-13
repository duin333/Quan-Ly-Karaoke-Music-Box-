package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class HoaDon {
    private int maHD;
    private String maPhong;
    private String tenNV;
    private Timestamp gioKetThuc;
    private double tongTien;

    public HoaDon() {}

    public HoaDon(int maHD, String maPhong, String tenNV, Timestamp gioKetThuc, double tongTien) {
        this.maHD = maHD;
        this.maPhong = maPhong;
        this.tenNV = tenNV;
        this.gioKetThuc = gioKetThuc;
        this.tongTien = tongTien;
    }

    // --- GETTER ĐỊNH DẠNG ---
    public String getGioKetThuc() {
        if (gioKetThuc == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(gioKetThuc);
    }

    public Timestamp getGioKetThucRaw() { return gioKetThuc; }

    public int getMaHD() { return maHD; }
    public void setMaHD(int maHD) { this.maHD = maHD; }
    public String getMaPhong() { return maPhong; }
    public void setMaPhong(String maPhong) { this.maPhong = maPhong; }
    public String getTenNV() { return tenNV; }
    public void setTenNV(String tenNV) { this.tenNV = tenNV; }
    public void setGioKetThuc(Timestamp gioKetThuc) { this.gioKetThuc = gioKetThuc; }
    public double getTongTien() { return tongTien; }
    public void setTongTien(double tongTien) { this.tongTien = tongTien; }
}