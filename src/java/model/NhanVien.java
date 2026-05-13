package model;

public class NhanVien {
    private int maNV;
    private String tenNV;
    private String username;
    private String password;
    private int maCV;
    private int trangThai; // 🛡️ Bổ sung thêm: 1 là đang làm, 0 là nghỉ việc

    public NhanVien() {
    }

    // Constructor đầy đủ tham số
    public NhanVien(int maNV, String tenNV, String username, String password, int maCV, int trangThai) {
        this.maNV = maNV;
        this.tenNV = tenNV;
        this.username = username;
        this.password = password;
        this.maCV = maCV;
        this.trangThai = trangThai;
    }

    // Getter và Setter
    public int getMaNV() {
        return maNV;
    }

    public void setMaNV(int maNV) {
        this.maNV = maNV;
    }

    public String getTenNV() {
        return tenNV;
    }

    public void setTenNV(String tenNV) {
        this.tenNV = tenNV;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getMaCV() {
        return maCV;
    }

    public void setMaCV(int maCV) {
        this.maCV = maCV;
    }

    public int getTrangThai() {
        return trangThai;
    }

    public void setTrangThai(int trangThai) {
        this.trangThai = trangThai;
    }
    
    // 💡 Mẹo nhỏ: Con có thể thêm hàm này để kiểm tra quyền Admin cho nhanh
    public boolean isAdmin() {
        return this.maCV == 1;
    }
}