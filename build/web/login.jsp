<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - NICE KARAOKE</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body, html { height: 100%; margin: 0; font-family: 'Roboto', sans-serif; overflow: hidden; }
        .bg-image {
            background-image: url('${pageContext.request.contextPath}/assets/img/bg-login.jpg');
            height: 100%; background-position: center; background-repeat: no-repeat; background-size: cover;
            position: relative;
        }
        .overlay {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: linear-gradient(135deg, rgba(0,0,0,0.8) 0%, rgba(0,0,0,0.4) 100%);
            display: flex; align-items: center; justify-content: center;
        }
        .login-card {
            border: none; border-radius: 25px; background-color: rgba(255, 255, 255, 0.98);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.6); width: 100%; max-width: 420px; padding: 2.5rem;
        }
        .login-title { font-weight: 900; color: #ff8c00; letter-spacing: 1px; text-transform: uppercase; }
        .btn-login {
            background: linear-gradient(45deg, #ff8c00, #ff4500); border: none; border-radius: 12px;
            color: white; font-weight: 700; padding: 14px; transition: 0.3s;
        }
        .btn-login:hover { transform: scale(1.02); box-shadow: 0 8px 20px rgba(255, 140, 0, 0.4); color: white; }
        .form-control:focus { border-color: #ff8c00; box-shadow: 0 0 0 0.2rem rgba(255, 140, 0, 0.25); }
    </style>
</head>
<body>

    <div class="bg-image">
        <div class="overlay">
            <div class="login-card">
                <div class="text-center mb-4">
                    <div class="mb-2"><i class="fas fa-microphone-lines fa-3x text-warning"></i></div>
                    <h2 class="login-title">NICE KARAOKE</h2>
                    <p class="text-muted small">Hệ thống Quản lý Nhân viên</p>
                </div>

                <c:if test="${not empty mess}">
                    <div class="alert alert-danger py-2 text-center shadow-sm" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i><small>${mess}</small>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="post">
                    <div class="mb-3">
                        <label for="user" class="form-label fw-bold small text-secondary">Tài khoản</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="fas fa-user text-muted"></i></span>
                            <input type="text" class="form-control border-start-0" id="user" name="user" required autofocus>
                        </div>
                    </div>
                    
                    <div class="mb-4">
                        <label for="pass" class="form-label fw-bold small text-secondary">Mật khẩu</label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="fas fa-lock text-muted"></i></span>
                            <input type="password" class="form-control border-start-0" id="pass" name="pass" required>
                        </div>
                    </div>

                    <div class="d-grid gap-2">
                        <button type="submit" class="btn btn-login shadow-sm">ĐĂNG NHẬP NGAY</button>
                    </div>
                </form>

                <div class="mt-4 text-center border-top pt-3">
                    <a href="${pageContext.request.contextPath}/guest/home" class="text-decoration-none text-muted small fw-bold">
                        <i class="fas fa-arrow-right me-1"></i> Chế độ dành cho Khách hàng
                    </a>
                </div>
            </div>
        </div>
    </div>

</body>
</html>