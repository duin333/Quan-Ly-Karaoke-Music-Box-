package model;

public class DichVu {
    private int maDV;
    private String tenDV;
    private double gia;
    private int soLuongTon;
    private int maLoaiDV;
    private String hinhAnh;
    private String tenLoaiDV; // Để hiển thị tên loại (đồ uống, đồ ăn...)
    private int trangThaiHienThi; // ✅ Mới bổ sung: 1 là Hiện, 0 là Ẩn

    public DichVu() {}

    // Constructor đầy đủ để lấy từ DB (có JOIN và Trạng thái hiển thị)
    public DichVu(int maDV, String tenDV, double gia, int soLuongTon, int maLoaiDV, String hinhAnh, String tenLoaiDV, int trangThaiHienThi) {
        this.maDV = maDV;
        this.tenDV = tenDV;
        this.gia = gia;
        this.soLuongTon = soLuongTon;
        this.maLoaiDV = maLoaiDV;
        this.hinhAnh = hinhAnh;
        this.tenLoaiDV = tenLoaiDV;
        this.trangThaiHienThi = trangThaiHienThi;
    }

    // --- Getters và Setters ---
    public int getMaDV() { return maDV; }
    public void setMaDV(int maDV) { this.maDV = maDV; }

    public String getTenDV() { return tenDV; }
    public void setTenDV(String tenDV) { this.tenDV = tenDV; }

    public double getGia() { return gia; }
    public void setGia(double gia) { this.gia = gia; }

    public int getSoLuongTon() { return soLuongTon; }
    public void setSoLuongTon(int soLuongTon) { this.soLuongTon = soLuongTon; }

    public int getMaLoaiDV() { return maLoaiDV; }
    public void setMaLoaiDV(int maLoaiDV) { this.maLoaiDV = maLoaiDV; }

    public String getHinhAnh() { return hinhAnh; }
    public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }

    public String getTenLoaiDV() { return tenLoaiDV; }
    public void setTenLoaiDV(String tenLoaiDV) { this.tenLoaiDV = tenLoaiDV; }

    // ✅ Getter & Setter cho trạng thái ẩn/hiện
    public int getTrangThaiHienThi() { return trangThaiHienThi; }
    public void setTrangThaiHienThi(int trangThaiHienThi) { this.trangThaiHienThi = trangThaiHienThi; }
}