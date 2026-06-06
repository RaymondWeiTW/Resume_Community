<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="community.C_JWTUtils" %>
<%@ page import="com.auth0.jwt.interfaces.DecodedJWT" %>
<%
    String token = (String) session.getAttribute("userToken");
    DecodedJWT decoded = C_JWTUtils.fn_verifyToken(token);
    if (token == null || decoded == null) {
        session.removeAttribute("userToken");
        session.removeAttribute("currentUser");
        request.setAttribute("errorMsg", "憑證已過期或未登入，請重新登入！");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
<meta charset="UTF-8">
<title>ADMIN 修改資料 - 儷府國宅</title>
<script>
    let timeLeft = 60; let countdown; let lastRefreshTime = 0;
    function startTimer() {
        const timerElement = document.getElementById("timer");
        if (countdown) clearInterval(countdown);
        countdown = setInterval(function() {
            timeLeft--;
            if (timerElement) timerElement.innerText = timeLeft;
            if (timeLeft <= 0) {
                clearInterval(countdown);
                alert("您已久未操作，登入時效已過期，將返回登入畫面！");
                window.location.href = "${pageContext.request.contextPath}/index.jsp";
            }
        }, 1000);
    }
    function silentRefreshJWT() {
        let currentTime = Date.now();
        if (currentTime - lastRefreshTime < 10000) return;
        lastRefreshTime = currentTime;
        fetch('${pageContext.request.contextPath}/RefreshTokenServlet', { method: 'POST' })
        .then(response => response.json())
        .then(data => { if (data.success) { timeLeft = 60; } })
        .catch(error => console.error(error));
    }
    function setupActivityListeners() {
        ['mousemove', 'click', 'keydown', 'scroll'].forEach(ev => window.addEventListener(ev, silentRefreshJWT));
    }
    window.onload = function() { startTimer(); setupActivityListeners(); };
</script>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">
  <div style=
    "display: flex; align-items: center; gap: 15px; display: inline-flex; 
    background:#28a745; color: white; padding:15px; box-shadow: 0 2px 5px rgba(0,0,0,0.2);">
    <div class="icon-wrapper" id="notificationIcon">
            <!-- 圖標 -->
           <i class="fa-solid fa-user-secret"></i>

            <!-- 紅色提示點 -->
            <span class="badge"></span>
        </div>
    <strong style="font-size: 18px;">[儷府國宅] 後台</strong>
        <span style="margin-left: 20px;">
            <a href="${pageContext.request.contextPath}/view?page=visitor_index" style="color: white; font-weight: bold; text-decoration: none; margin-right: 12px;"><i class="fa-solid fa-house-chimney"></i></a> 
             <a href="${pageContext.request.contextPath}/index.jsp" style="color: white; text-decoration: none;"><i class="fa-solid fa-arrow-right-from-bracket"></i></a> 
        </span>
        <span style="float:right; background:#fff3cd; color: #856404; padding:4px 10px; border-radius: 4px; font-size: 14px;">
            ⏳ JWT 剩餘時間：<span id="timer" style="color:red; font-weight:bold;">60</span> 秒
        </span>
    </div>


    <div style="display: flex; min-height: calc(100vh - 60px);">
        <div style="width: 220px; background: #f8f9fa; padding: 20px; border-right: 1px solid #dee2e6;">
            <h3 style="color: #495057; font-size: 16px; border-bottom: 2px solid #dee2e6; padding-bottom: 8px;">左側功能選單</h3>
            <ul style="list-style: none; padding: 0; margin: 0; line-height: 2.5;">
                <li><a href="${pageContext.request.contextPath}/view?page=admin_index" style="color: #007bff; text-decoration: none;margin-right: 12px;"><i class="fa-solid fa-clock-rotate-left"></i>&nbsp; Log表格</a></li>
                <li><a href="${pageContext.request.contextPath}/view?page=admin_permission" style="color: #007bff; text-decoration: none;margin-right: 12px;"> <i class="fa-solid fa-people-robbery"></i>&nbsp;修改權限</a></li>
                <li><a href="${pageContext.request.contextPath}/view?page=admin_detail" style="color: #495057; text-decoration: none;margin-right: 12px; font-weight: bold;">️ <i class="fa-solid fa-id-card"></i>&nbsp;修改資料</a></li>
            </ul>
        </div>

        <div style="flex: 1; padding: 30px;">
            <h2 style="color: #333; margin-top: 0;">(修改資料) 填寫表單</h2>
            <hr style="border: 0; border-top: 1px solid #dee2e6; margin-bottom: 20px;">
            
            <form action="#" method="POST" onsubmit="alert('骨架測試成功：個人資料已儲存！'); return false;" style="background: #fff; padding: 20px; border: 1px solid #dee2e6; border-radius: 4px; max-width: 600px;">
                <fieldset style="border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius: 4px;">
                    <legend style="font-weight: bold; padding: 0 10px; color: #17a2b8;">[區塊一：使用者]</legend>
                    <label>當前操作帳號：</label>
                    <input type="text" name="username" value="admin01" readonly style="background: #e9ecef; padding: 6px; width: 60%; border: 1px solid #ced4da; border-radius: 4px;">
                </fieldset>
                
                <fieldset style="border: 1px solid #ccc; padding: 15px; margin-bottom: 20px; border-radius: 4px;">
                    <legend style="font-weight: bold; padding: 0 10px; color: #17a2b8;">[區塊二：個資內容]</legend>
                    <div style="margin-bottom: 12px;">
                        <label style="display:inline-block; width: 100px;">真實姓名：</label>
                        <input type="text" name="realName" value="Raymond Wei" style="padding: 6px; width: 60%; border: 1px solid #ced4da; border-radius: 4px;">
                    </div>
                    <div style="margin-bottom: 12px;">
                        <label style="display:inline-block; width: 100px;">聯絡電話：</label>
                        <input type="text" name="phone" value="0911-111111" style="padding: 6px; width: 60%; border: 1px solid #ced4da; border-radius: 4px;">
                    </div>
                    <div>
                        <label style="display:inline-block; width: 100px;">居住房號：</label>
                        <input type="text" name="roomNumber" value="中控管理機房" style="padding: 6px; width: 60%; border: 1px solid #ced4da; border-radius: 4px;">
                    </div>
                </fieldset>
                
                <div style="text-align: right; padding-top: 10px;">
                    <button type="button" onclick="window.location.href='${pageContext.request.contextPath}/view?page=admin_index'" style="padding: 8px 16px; background: #6c757d; color: white; border: none; border-radius: 4px; cursor: pointer; margin-right: 10px;">取消</button>
                    <button type="submit" style="padding: 8px 16px; background: #17a2b8; color: white; border: none; border-radius: 4px; cursor: pointer;">確定送出</button>
                </div>
            </form>
        </div>
    </div>

</body>
</html>