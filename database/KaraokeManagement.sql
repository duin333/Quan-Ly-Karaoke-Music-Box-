CREATE DATABASE KaraokeManagement;
USE KaraokeManagement;
select * from Phong;

-- 1. Bảng Chức vụ
CREATE TABLE ChucVu (
    MaCV INT PRIMARY KEY AUTO_INCREMENT,
    TenCV VARCHAR(50) NOT NULL -- Admin, Nhân viên
);

-- 2. Bảng Nhân viên (Gộp tài khoản vào đây)
CREATE TABLE NhanVien (
    MaNV INT PRIMARY KEY AUTO_INCREMENT,
    TenNV VARCHAR(100) NOT NULL,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(255) NOT NULL, -- Lưu mật khẩu đã mã hóa
    MaCV INT,
    TrangThai INT DEFAULT 1, -- 1: Đang làm, 0: Đã nghỉ/Khóa
    FOREIGN KEY (MaCV) REFERENCES ChucVu(MaCV)
);

-- 3. Bảng Loại phòng
CREATE TABLE LoaiPhong (
    MaLoai INT PRIMARY KEY AUTO_INCREMENT,
    TenLoai VARCHAR(50),
    GiaTheoGio DOUBLE,
    SoNguoiToiDa INT,
    HinhAnh VARCHAR(255)
);

-- 4. Bảng Phòng
CREATE TABLE Phong (
    MaPhong VARCHAR(10) PRIMARY KEY,
    TenPhong VARCHAR(50),
    MaLoai INT,
    TrangThai VARCHAR(20) DEFAULT 'Trống', -- Trống, Đang hát, Chờ dọn
    FOREIGN KEY (MaLoai) REFERENCES LoaiPhong(MaLoai)
);

-- 5. Bảng Khách hàng
CREATE TABLE KhachHang (
    MaKH INT PRIMARY KEY AUTO_INCREMENT,
    TenKH VARCHAR(100),
    SDT VARCHAR(15) UNIQUE
);

-- 6. Bảng Phiếu đặt phòng (Dành cho khách đặt trước)
CREATE TABLE PhieuDatPhong (
    MaPhieu INT PRIMARY KEY AUTO_INCREMENT,
    MaKH INT,
    MaPhong VARCHAR(10),
    GioDat DATETIME,
    TrangThai INT DEFAULT 1, -- 1: Chờ, 2: Đã nhận, 0: Hủy
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH),
    FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong)
);

-- 7. Bảng Loại dịch vụ & Dịch vụ
CREATE TABLE LoaiDichVu (
    MaLoaiDV INT PRIMARY KEY AUTO_INCREMENT,
    TenLoaiDV VARCHAR(50)
);

CREATE TABLE DichVu (
    MaDV INT PRIMARY KEY AUTO_INCREMENT,
    TenDV VARCHAR(100),
    Gia DOUBLE,
    SoLuongTon INT,
    MaLoaiDV INT,
    FOREIGN KEY (MaLoaiDV) REFERENCES LoaiDichVu(MaLoaiDV)
);

-- 8. Bảng Hóa đơn
CREATE TABLE HoaDon (
    MaHD INT PRIMARY KEY AUTO_INCREMENT,
    MaPhong VARCHAR(10),
    MaNV INT,
    MaKH INT,
    GioBatDau DATETIME,
    GioKetThuc DATETIME,
    ChietKhau DOUBLE DEFAULT 0,
    TongTien DOUBLE,
    TrangThai INT DEFAULT 0, -- 0: Chưa thanh toán, 1: Đã thanh toán
    FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV),
    FOREIGN KEY (MaKH) REFERENCES KhachHang(MaKH)
);

-- 9. Bảng Chi tiết hóa đơn
CREATE TABLE ChiTietHoaDon (
    MaHD INT,
    MaDV INT,
    SoLuong INT,
    GiaTaiThoiDiem DOUBLE,
    PRIMARY KEY (MaHD, MaDV),
    FOREIGN KEY (MaHD) REFERENCES HoaDon(MaHD),
    FOREIGN KEY (MaDV) REFERENCES DichVu(MaDV)
);

-- 10. Bảng Nhật ký hệ thống (Cybersecurity)
CREATE TABLE SystemLogs (
    LogID INT PRIMARY KEY AUTO_INCREMENT,
    MaNV INT,
    HanhDong TEXT,
    ThoiGian DATETIME DEFAULT CURRENT_TIMESTAMP,
    IPAddress VARCHAR(45),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
-- 11. Bảng Yêu cầu gọi món
CREATE TABLE YeuCauGoiMon (
    MaYC INT PRIMARY KEY AUTO_INCREMENT,
    MaPhong VARCHAR(10),
    MaDV INT,
    SoLuong INT,
    ThoiGian DATETIME DEFAULT CURRENT_TIMESTAMP,
    TrangThai INT DEFAULT 0, -- 0: Chờ duyệt, 1: Đã duyệt, 2: Đã hủy
    FOREIGN KEY (MaPhong) REFERENCES Phong(MaPhong),
    FOREIGN KEY (MaDV) REFERENCES DichVu(MaDV)
);
ALTER TABLE YeuCauGoiMon ADD COLUMN GhiChu VARCHAR(255) DEFAULT '';

ALTER TABLE YeuCauGoiMon ADD COLUMN ThoiGianDuyet DATETIME;
SELECT * FROM DichVu;
select * from YeuCauGoiMon;

-- Tính năng đăng nhập
INSERT INTO ChucVu (TenCV) VALUES ('Admin');
INSERT INTO ChucVu (TenCV) VALUES ('Nhân viên');

-- Thêm tài khoản Admin (MaCV = 1)
INSERT INTO NhanVien (TenNV, Username, Password, MaCV, TrangThai) 
VALUES ('Nguyễn Thái Kỳ Duyên', 'admin', '123', 1, 1);

-- Thêm tài khoản Nhân viên (MaCV = 2)
INSERT INTO NhanVien (TenNV, Username, Password, MaCV, TrangThai) 
VALUES ('Nhân viên Lê Văn A', 'staff', '123', 2, 1);

-- Thêm một tài khoản bị khóa (để test trường hợp đăng nhập không thành công dù đúng pass)
INSERT INTO NhanVien (TenNV, Username, Password, MaCV, TrangThai) 
VALUES ('Nhân viên Nghỉ Việc', ' nghi_viec', '123', 2, 0);

SELECT nv.MaNV, nv.TenNV, nv.Username, cv.TenCV, nv.TrangThai
FROM NhanVien nv
JOIN ChucVu cv ON nv.MaCV = cv.MaCV;

-- 1. Thêm dữ liệu mẫu cho Loại Phòng
-- Lưu ý: Cột HinhAnh lưu đường dẫn tương đối tính từ thư mục Web Pages của bạn
INSERT INTO LoaiPhong (TenLoai, GiaTheoGio, SoNguoiToiDa, HinhAnh) VALUES 
('Phòng Thường', 50000, 10, 'assets/img/rooms/normal.jpg'),
('Phòng VIP', 150000, 15, 'assets/img/rooms/vip.jpg'),
('Phòng Super VIP', 300000, 30, 'assets/img/rooms/super_vip.jpg');

-- 2. Thêm dữ liệu mẫu cho các Phòng
-- Giả sử ID tự tăng của LoaiPhong là 1 (Thường), 2 (VIP), 3 (Super VIP)
INSERT INTO Phong (MaPhong, TenPhong, MaLoai, TrangThai) VALUES 
('P101', 'Phòng 101', 1, 'Trống'),
('P102', 'Phòng 102', 1, 'Đang hát'),
('P103', 'Phòng 103', 1, 'Chờ dọn'),
('P201', 'Phòng VIP 201', 2, 'Trống'),
('P202', 'Phòng VIP 202', 2, 'Đang hát'),
('P301', 'Phòng Super VIP 301', 3, 'Trống');

-- Thêm loại dịch vụ
INSERT INTO LoaiDichVu (TenLoaiDV) VALUES ('Đồ uống'), ('Thức ăn');

-- Thêm dịch vụ (Phải khớp với ID 1 và 2 mà code JS đang gọi)
INSERT INTO DichVu (MaDV, TenDV, Gia, SoLuongTon, MaLoaiDV) VALUES 
(1, 'Bia Tiger (Lon)', 25000, 100, 1),
(2, 'Đĩa Trái Cây (Lớn)', 150000, 50, 2);
INSERT INTO DichVu (MaDV, TenDV, Gia, SoLuongTon, MaLoaiDV) VALUES 
-- Nhóm 1: Đồ uống
(3, 'Bia Tiger Crystal', 28000, 100, 1),
(4, 'Bia Heineken Silver', 32000, 100, 1),
(5, 'Nước suối Aquafina', 15000, 200, 1),
(6, 'Coca-Cola', 20000, 150, 1),
(7, 'Bò húc (Redbull)', 25000, 120, 1),
(8, 'Nước cam ép', 35000, 50, 1),

-- Nhóm 2: Thức ăn (Bao gồm cả ăn nhẹ và món nhắm)
(9, 'Đĩa Trái Cây (Nhỏ)', 80000, 30, 2),
(10, 'Hạt hướng dương', 20000, 100, 2),
(11, 'Đậu phộng rang tỏi', 25000, 100, 2),
(12, 'Snack Oishi các loại', 15000, 100, 2),
(13, 'Mực khô nướng', 180000, 20, 2),
(14, 'Cánh gà chiên mắm', 120000, 25, 2),
(15, 'Mì xào hải sản', 95000, 15, 2),
(16, 'Khoai tây chiên', 45000, 40, 2),
(17, 'Sụn gà rang muối', 110000, 20, 2);

ALTER TABLE DichVu ADD COLUMN HinhAnh VARCHAR(255) DEFAULT 'assets/img/menu/default.jpg';
-- Nhóm Đồ uống
UPDATE DichVu SET HinhAnh = 'assets/img/menu/tiger-lon.jpg' WHERE MaDV = 1;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/tiger-crystal.jpg' WHERE MaDV = 3;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/heineken-silver.jpg' WHERE MaDV = 4;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/aquafina.jpg' WHERE MaDV = 5;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/coca-cola.jpg' WHERE MaDV = 6;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/redbull.jpg' WHERE MaDV = 7;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/nuoc-cam.jpg' WHERE MaDV = 8;

-- Nhóm Đồ ăn nhẹ & Trái cây
UPDATE DichVu SET HinhAnh = 'assets/img/menu/trai-cay-lon.jpg' WHERE MaDV = 2;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/trai-cay-nho.jpg' WHERE MaDV = 9;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/huong-duong.jpg' WHERE MaDV = 10;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/dau-phong.jpg' WHERE MaDV = 11;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/snack-oishi.jpg' WHERE MaDV = 12;

-- Nhóm Món nhắm & Món chính
UPDATE DichVu SET HinhAnh = 'assets/img/menu/muc-nuong.jpg' WHERE MaDV = 13;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/canh-ga.jpg' WHERE MaDV = 14;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/mi-xao.jpg' WHERE MaDV = 15;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/khoai-tay-chien.jpg' WHERE MaDV = 16;
UPDATE DichVu SET HinhAnh = 'assets/img/menu/sun-ga.jpg' WHERE MaDV = 17;

SELECT * FROM DichVu;

-- 1. Thêm khách hàng mẫu
INSERT INTO KhachHang (TenKH, SDT) VALUES ('Nguyễn Thái Kỳ Duyên', '0905123456');
select * from KhachHang;
-- 2. Thêm phiếu đặt cho ngày hôm nay (Sửa lại MaKH cho đúng với ID vừa tạo)
INSERT INTO PhieuDatPhong (MaKH, MaPhong, GioDat, TrangThai) 
VALUES (1, 'P101', '2026-04-20 19:00:00', 1);

INSERT INTO PhieuDatPhong (MaKH, MaPhong, GioDat, TrangThai) 
VALUES (1, 'P201', '2026-04-20 20:30:00', 1);

select * from PhieuDatPhong;

DELIMITER //

CREATE PROCEDURE sp_DuyetYeuCau(
    IN p_MaYC INT,
    OUT p_Result VARCHAR(50)
)
BEGIN
    DECLARE v_MaDV INT;
    DECLARE v_SoLuongYC INT;
    DECLARE v_TonKho INT;

    -- 1. Lấy thông tin món và số lượng từ yêu cầu
    SELECT MaDV, SoLuong INTO v_MaDV, v_SoLuongYC 
    FROM YeuCauGoiMon WHERE MaYC = p_MaYC;

    -- 2. Kiểm tra tồn kho thực tế
    SELECT SoLuongTon INTO v_TonKho FROM DichVu WHERE MaDV = v_MaDV;

    -- 3. Logic xử lý
    IF v_TonKho >= v_SoLuongYC THEN
        -- Đủ hàng: Trừ kho và Duyệt món
        UPDATE DichVu SET SoLuongTon = SoLuongTon - v_SoLuongYC WHERE MaDV = v_MaDV;
        UPDATE YeuCauGoiMon SET TrangThai = 1, ThoiGianDuyet = CURRENT_TIMESTAMP WHERE MaYC = p_MaYC;
        SET p_Result = 'success';
    ELSE
        -- Thiếu hàng: Trả về thông báo lỗi
        SET p_Result = 'out_of_stock';
    END IF;
END //DELIMITER ;

select * from DichVu;
select * from YeuCauGoiMon;
select * from LoaiPhong;
select * from PhieuDatPhong;
ALTER TABLE PhieuDatPhong ADD COLUMN GioTra DATETIME NULL;
SELECT SUM(TIMESTAMPDIFF(MINUTE, GioDat, GioTra) / 60.0 * 50000) 
FROM PhieuDatPhong 
WHERE TrangThai = 3;

ALTER TABLE Phong ADD COLUMN YeuCauHoTro INT DEFAULT 0;
ALTER TABLE Phong ADD COLUMN GhiChuHoTro NVARCHAR(255) DEFAULT '';
select * from NhanVien;
INSERT INTO NhanVien (TenNV, Username, Password, MaCV, TrangThai) 
VALUES ('Nhân viên Trần Văn B', 'B', '123', 2, 1);

-- 2. Tạo bảng Lịch sử hỗ trợ 
CREATE TABLE LichSuHoTro (
    MaLS INT AUTO_INCREMENT PRIMARY KEY,
    MaPhong VARCHAR(10),
    NoiDung NVARCHAR(255),
    ThoiGianGoi DATETIME DEFAULT CURRENT_TIMESTAMP,
    ThoiGianDuyetHoTro DATETIME, -- Lưu lúc nhân viên bấm "Tiếp nhận"
    ThoiGianXong DATETIME,       -- Lưu lúc nhân viên bấm "Hoàn thành"
    TrangThai INT -- Để đồng bộ với bảng Phong
);
ALTER TABLE LichSuHoTro ADD COLUMN MaNV VARCHAR(50);

-- 1. Bổ sung cột MaNV vào bảng PhieuDatPhong để lưu người thu tiền
ALTER TABLE PhieuDatPhong ADD MaNV INT;

-- 2. Thêm khóa ngoại để liên kết MaNV này với bảng NhanVien (Rất quan trọng)
ALTER TABLE PhieuDatPhong ADD CONSTRAINT FK_PhieuDatPhong_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV);

DESC PhieuDatPhong;


select * from DichVu;
select * from HoaDon;

select * from PhieuDatPhong;

UPDATE HoaDon SET TongTien = 53333.333 WHERE MaHD = 9;


INSERT INTO HoaDon (MaPhong, MaNV, MaKH, GioBatDau, GioKetThuc, ChietKhau, TongTien, TrangThai)
SELECT 
    pdp.MaPhong, 
    IFNULL(pdp.MaNV, 1) as MaNV, -- Nếu chưa có MaNV thì tạm để Admin (ID 1)
    pdp.MaKH, 
    pdp.GioDat, 
    pdp.GioTra, 
    0 as ChietKhau,
    -- Tính tiền giờ: (Số phút / 60) * Giá theo giờ của loại phòng đó
    (TIMESTAMPDIFF(MINUTE, pdp.GioDat, pdp.GioTra) / 60.0 * lp.GiaTheoGio) as TongTien,
    1 as TrangThai -- Đánh dấu là đã thanh toán
FROM PhieuDatPhong pdp
JOIN Phong p ON pdp.MaPhong = p.MaPhong
JOIN LoaiPhong lp ON p.MaLoai = lp.MaLoai
WHERE pdp.TrangThai = 3 -- Chỉ lấy các phiếu đã Hoàn thành
AND NOT EXISTS (
    -- Kiểm tra để không chèn trùng nếu hóa đơn đã tồn tại
    SELECT 1 FROM HoaDon h 
    WHERE h.MaPhong = pdp.MaPhong AND h.GioBatDau = pdp.GioDat
);


SET SQL_SAFE_UPDATES = 0;

-- 1. Xóa sạch chi tiết hóa đơn bị sai
DELETE FROM ChiTietHoaDon;

-- 2. Chốt lại trạng thái "Đã thanh toán" cho các món cũ (Tránh bị dính vào đơn mới sau này)
UPDATE YeuCauGoiMon yc
JOIN HoaDon h ON yc.MaPhong = h.MaPhong
SET yc.TrangThai = 3
WHERE yc.ThoiGian <= h.GioKetThuc;

-- 3. Đổ lại dữ liệu "Sạch" vào Chi tiết hóa đơn
INSERT INTO ChiTietHoaDon (MaHD, MaDV, SoLuong, GiaTaiThoiDiem)
SELECT 
    h.MaHD, yc.MaDV, SUM(yc.SoLuong), (SELECT Gia FROM DichVu WHERE MaDV = yc.MaDV)
FROM HoaDon h
JOIN YeuCauGoiMon yc ON h.MaPhong = yc.MaPhong
WHERE yc.ThoiGian BETWEEN h.GioBatDau AND h.GioKetThuc -- 🛡️ CHỈ LẤY MÓN TRONG CA HÁT ĐÓ
GROUP BY h.MaHD, yc.MaDV;

SET SQL_SAFE_UPDATES = 1;

SET SQL_SAFE_UPDATES = 0;

UPDATE HoaDon h
SET TongTien = (
    -- 1. Tính lại tiền giờ thực tế
    COALESCE((
        SELECT (TIMESTAMPDIFF(MINUTE, h.GioBatDau, h.GioKetThuc) / 60.0 * lp.GiaTheoGio)
        FROM Phong p 
        JOIN LoaiPhong lp ON p.MaLoai = lp.MaLoai 
        WHERE p.MaPhong = h.MaPhong
    ), 0)
    +  
    -- 2. Cộng với tổng tiền dịch vụ ĐÃ LÀM SẠCH trong bảng ChiTietHoaDon
    COALESCE((
        SELECT SUM(SoLuong * GiaTaiThoiDiem) 
        FROM ChiTietHoaDon ct 
        WHERE ct.MaHD = h.MaHD
    ), 0)
)
-- Chỉ cập nhật những hóa đơn đã thanh toán
WHERE h.TrangThai = 1;

SET SQL_SAFE_UPDATES = 1;

-- Kiểm tra lại kết quả
SELECT MaHD, MaPhong, TongTien FROM HoaDon WHERE DATE(GioKetThuc) = '2026-05-11';


ALTER TABLE LichSuHoTro MODIFY COLUMN MaNV INT;
ALTER TABLE LichSuHoTro ADD CONSTRAINT FK_LichSuHoTro_NhanVien FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV);


-- Xóa cột thừa cho đỡ rối code
ALTER TABLE Phong DROP COLUMN YeuCauHoTro; 

-- Chốt SupportStatus: 0:Bình thường, 1:Khách đang gọi (Chuông reo), 2:Nhân viên đang đến
ALTER TABLE Phong MODIFY COLUMN SupportStatus INT DEFAULT 0;


-- Cập nhật lại chú thích cho dễ nhớ nhen Duyên
ALTER TABLE YeuCauGoiMon 
MODIFY COLUMN TrangThai INT DEFAULT 0 COMMENT '0:Chờ duyệt, 1:Bếp làm, 2:Đã giao, 3:Đã thanh toán, 4:Hủy';


ALTER TABLE DichVu ADD TrangThaiHienThi INT DEFAULT 1;

-- Thêm cột trạng thái hỗ trợ (0: Bình thường, 1: Đang đợi, 2: Đang đến)
ALTER TABLE Phong ADD COLUMN SupportStatus INT DEFAULT 0;
