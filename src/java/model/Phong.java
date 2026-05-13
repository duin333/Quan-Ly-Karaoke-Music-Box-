package model;

public class Phong {
    private String maPhong;
    private String tenPhong;
    private int maLoai;
    private String trangThai; // Trống, Đang hát, Chờ dọn
    private int supportStatus; // 0: Bình thường, 1: Đang đợi, 2: Đang đến
    private String ghiChuHoTro; // Nội dung khách yêu cầu
    private LoaiPhong loaiPhong; 
    private String tenLoai;

    public Phong() {
    }

    public Phong(String maPhong, String tenPhong, int maLoai, String trangThai, int supportStatus, String ghiChuHoTro) {
        this.maPhong = maPhong;
        this.tenPhong = tenPhong;
        this.maLoai = maLoai;
        this.trangThai = trangThai;
        this.supportStatus = supportStatus;
        this.ghiChuHoTro = ghiChuHoTro;
    }
    
    public Phong(String maPhong, String tenPhong, int maLoai, String trangThai) {
        this.maPhong = maPhong;
        this.tenPhong = tenPhong;
        this.maLoai = maLoai;
        this.trangThai = trangThai;
        this.supportStatus = 0; // Mặc định không có yêu cầu
    }

    public String getMaPhong() { return maPhong; }
    public void setMaPhong(String maPhong) { this.maPhong = maPhong; }

    public String getTenPhong() { return tenPhong; }
    public void setTenPhong(String tenPhong) { this.tenPhong = tenPhong; }

    public int getMaLoai() { return maLoai; }
    public void setMaLoai(int maLoai) { this.maLoai = maLoai; }

    public String getTrangThai() { return trangThai; }
    public void setTrangThai(String trangThai) { this.trangThai = trangThai; }

    public int getSupportStatus() { return supportStatus; }
    public void setSupportStatus(int supportStatus) { this.supportStatus = supportStatus; }

    public String getGhiChuHoTro() { return ghiChuHoTro; }
    public void setGhiChuHoTro(String ghiChuHoTro) { this.ghiChuHoTro = ghiChuHoTro; }

    public LoaiPhong getLoaiPhong() { return loaiPhong; }
    public void setLoaiPhong(LoaiPhong loaiPhong) { this.loaiPhong = loaiPhong; }

    public String getTenLoai() { return tenLoai; }
    public void setTenLoai(String tenLoai) { this.tenLoai = tenLoai; }
    
    @Override
    public String toString() {
        return "Phong{" + "maPhong=" + maPhong + ", tenPhong=" + tenPhong + ", trangThai=" + trangThai + ", supportStatus=" + supportStatus + '}';
    }
}