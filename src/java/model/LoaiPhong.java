package model;

public class LoaiPhong {
    private int maLoai;
    private String tenLoai;
    private double giaTheoGio;
    private int soNguoiToiDa; 
    private String hinhAnh;

    public LoaiPhong() {
    }

    // 1. Constructor đầy đủ 5 tham số (Dùng để lấy dữ liệu từ DB lên - FIX LỖI DAO)
    public LoaiPhong(int maLoai, String tenLoai, double giaTheoGio, int soNguoiToiDa, String hinhAnh) {
        this.maLoai = maLoai;
        this.tenLoai = tenLoai;
        this.giaTheoGio = giaTheoGio;
        this.soNguoiToiDa = soNguoiToiDa;
        this.hinhAnh = hinhAnh;
    }

    // 2. Constructor dùng khi thêm mới (Thường không cần truyền maLoai vì DB tự tăng)
    public LoaiPhong(String tenLoai, double giaTheoGio, int soNguoiToiDa, String hinhAnh) {
        this.tenLoai = tenLoai;
        this.giaTheoGio = giaTheoGio;
        this.soNguoiToiDa = soNguoiToiDa;
        this.hinhAnh = hinhAnh;
    }

    // --- Getters and Setters ---
    public int getMaLoai() { return maLoai; }
    public void setMaLoai(int maLoai) { this.maLoai = maLoai; }

    public String getTenLoai() { return tenLoai; }
    public void setTenLoai(String tenLoai) { this.tenLoai = tenLoai; }

    public double getGiaTheoGio() { return giaTheoGio; }
    public void setGiaTheoGio(double giaTheoGio) { this.giaTheoGio = giaTheoGio; }

    public int getSoNguoiToiDa() { return soNguoiToiDa; }
    public void setSoNguoiToiDa(int soNguoiToiDa) { this.soNguoiToiDa = soNguoiToiDa; }

    public String getHinhAnh() { return hinhAnh; }
    public void setHinhAnh(String hinhAnh) { this.hinhAnh = hinhAnh; }
}