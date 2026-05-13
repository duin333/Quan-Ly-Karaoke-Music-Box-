package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    private static final String URL  = "jdbc:mysql://localhost:3306/KaraokeManagement?autoReconnect=true&useSSL=false";
    private static final String USER = "root";
    private static final String PASS = "123456";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Không tìm thấy MySQL Driver!", e);
        }
    }

    // Mỗi lần gọi là tạo connection MỚI, dùng xong TỰ ĐÓNG bằng try-with-resources
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }
}