package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class LichSuHoTro {
    private int maLS;
    private String maPhong;
    private String noiDung;
    private Timestamp thoiGianGoi;
    private Timestamp thoiGianDuyetHoTro;
    private Timestamp thoiGianXong;
    private String tenNhanVien;
    private int trangThai;

    public LichSuHoTro() {
    }

    public LichSuHoTro(int maLS, String maPhong, String noiDung, Timestamp thoiGianGoi, 
                       Timestamp thoiGianDuyetHoTro, Timestamp thoiGianXong, String tenNhanVien, int trangThai) {
        this.maLS = maLS;
        this.maPhong = maPhong;
        this.noiDung = noiDung;
        this.thoiGianGoi = thoiGianGoi;
        this.thoiGianDuyetHoTro = thoiGianDuyetHoTro;
        this.thoiGianXong = thoiGianXong;
        this.tenNhanVien = tenNhanVien;
        this.trangThai = trangThai;
    }

    // --- GETTERS ĐỊNH DẠNG ---
    public String getThoiGianGoi() {
        if (thoiGianGoi == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(thoiGianGoi);
    }

    public String getThoiGianDuyetHoTro() {
        if (thoiGianDuyetHoTro == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(thoiGianDuyetHoTro);
    }

    public String getThoiGianXong() {
        if (thoiGianXong == null) return "";
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(thoiGianXong);
    }

    // --- RAW GETTERS ---
    public Timestamp getThoiGianGoiRaw() { return thoiGianGoi; }
    public Timestamp getThoiGianDuyetHoTroRaw() { return thoiGianDuyetHoTro; }
    public Timestamp getThoiGianXongRaw() { return thoiGianXong; }

    // --- CÁC GETTER/SETTER CÒN LẠI ---
    public int getMaLS() { return maLS; }
    public void setMaLS(int maLS) { this.maLS = maLS; }
    public String getMaPhong() { return maPhong; }
    public void setMaPhong(String maPhong) { this.maPhong = maPhong; }
    public String getNoiDung() { return noiDung; }
    public void setNoiDung(String noiDung) { this.noiDung = noiDung; }
    public void setThoiGianGoi(Timestamp thoiGianGoi) { this.thoiGianGoi = thoiGianGoi; }
    public void setThoiGianDuyetHoTro(Timestamp thoiGianDuyetHoTro) { this.thoiGianDuyetHoTro = thoiGianDuyetHoTro; }
    public void setThoiGianXong(Timestamp thoiGianXong) { this.thoiGianXong = thoiGianXong; }
    public String getTenNhanVien() { return tenNhanVien; }
    public void setTenNhanVien(String tenNhanVien) { this.tenNhanVien = tenNhanVien; }
    public int getTrangThai() { return trangThai; }
    public void setTrangThai(int trangThai) { this.trangThai = trangThai; }
}