package model;

public class LoaiDichVu {
    private int maLoaiDV;
    private String tenLoaiDV;

    // 1. Constructor không tham số (Bắt buộc phải có để các Framework sau này dùng)
    public LoaiDichVu() {
    }

    // 2. Constructor đầy đủ tham số
    public LoaiDichVu(int maLoaiDV, String tenLoaiDV) {
        this.maLoaiDV = maLoaiDV;
        this.tenLoaiDV = tenLoaiDV;
    }

    // --- GETTERS AND SETTERS ---

    public int getMaLoaiDV() {
        return maLoaiDV;
    }

    public void setMaLoaiDV(int maLoaiDV) {
        this.maLoaiDV = maLoaiDV;
    }

    public String getTenLoaiDV() {
        return tenLoaiDV;
    }

    public void setTenLoaiDV(String tenLoaiDV) {
        this.tenLoaiDV = tenLoaiDV;
    }

    // 3. Override toString (Hữu ích khi con cần Debug in dữ liệu ra Console)
    @Override
    public String toString() {
        return "LoaiDichVu{" + "maLoaiDV=" + maLoaiDV + ", tenLoaiDV=" + tenLoaiDV + '}';
    }
}