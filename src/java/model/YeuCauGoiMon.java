package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class YeuCauGoiMon {
    private int maYC;
    private String maPhong;
    private int maDV;
    private int soLuong;
    private Timestamp thoiGian;
    private int trangThai;
    private String tenDV;
    private double gia;
    private String ghiChu;
    
    public YeuCauGoiMon() {}

    public YeuCauGoiMon(String maPhong, int maDV, int soLuong) {
        this.maPhong = maPhong;
        this.maDV = maDV;
        this.soLuong = soLuong;
    }

    // --- GETTER ĐỊNH DẠNG ---
    public String getThoiGian() {
        if (thoiGian == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(thoiGian);
    }

    public Timestamp getThoiGianRaw() { return thoiGian; }

    // --- CÁC GETTER/SETTER CÒN LẠI ---
    public int getMaYC() { return maYC; }
    public void setMaYC(int maYC) { this.maYC = maYC; }
    public String getMaPhong() { return maPhong; }
    public void setMaPhong(String maPhong) { this.maPhong = maPhong; }
    public int getMaDV() { return maDV; }
    public void setMaDV(int maDV) { this.maDV = maDV; }
    public int getSoLuong() { return soLuong; }
    public void setSoLuong(int soLuong) { this.soLuong = soLuong; }
    public void setThoiGian(Timestamp thoiGian) { this.thoiGian = thoiGian; }
    public int getTrangThai() { return trangThai; }
    public void setTrangThai(int trangThai) { this.trangThai = trangThai; }
    public String getTenDV() { return tenDV; }
    public void setTenDV(String tenDV) { this.tenDV = tenDV; }
    public double getGia() { return gia; }
    public void setGia(double gia) { this.gia = gia; }
    public String getGhiChu() { return ghiChu; }
    public void setGhiChu(String ghiChu) { this.ghiChu = ghiChu; }
}