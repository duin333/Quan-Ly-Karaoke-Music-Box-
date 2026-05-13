package model;

public class ChucVu {
    private int maCV;
    private String tenCV;

    // 1. Constructor mặc định (Không tham số)
    public ChucVu() {
    }

    // 2. Constructor đầy đủ tham số (Dùng khi lấy dữ liệu từ DB lên)
    public ChucVu(int maCV, String tenCV) {
        this.maCV = maCV;
        this.tenCV = tenCV;
    }

    // 3. Constructor dùng khi thêm mới (Thường DB tự tăng MaCV nên chỉ cần TenCV)
    public ChucVu(String tenCV) {
        this.tenCV = tenCV;
    }

    // --- GETTER AND SETTER ---

    public int getMaCV() {
        return maCV;
    }

    public void setMaCV(int maCV) {
        this.maCV = maCV;
    }

    public String getTenCV() {
        return tenCV;
    }

    public void setTenCV(String tenCV) {
        this.tenCV = tenCV;
    }

    // 4. toString để hỗ trợ việc Debug/Kiểm tra nhanh dữ liệu
    @Override
    public String toString() {
        return "ChucVu{" + "maCV=" + maCV + ", tenCV=" + tenCV + '}';
    }
}