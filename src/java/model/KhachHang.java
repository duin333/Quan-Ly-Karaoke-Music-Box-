package model;

public class KhachHang {
    private int maKH;
    private String tenKH;
    private String sdt;

    public KhachHang() {}

    public KhachHang(int maKH, String tenKH, String sdt) {
        this.maKH = maKH;
        this.tenKH = tenKH;
        this.sdt = sdt;
    }

    // Getters and Setters
    public int getMaKH() { return maKH; }
    public void setMaKH(int maKH) { this.maKH = maKH; }
    public String getTenKH() { return tenKH; }
    public void setTenKH(String tenKH) { this.tenKH = tenKH; }
    public String getSdt() { return sdt; }
    public void setSdt(String sdt) { this.sdt = sdt; }
}