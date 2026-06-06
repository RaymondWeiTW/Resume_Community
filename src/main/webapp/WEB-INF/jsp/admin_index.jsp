<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="community.C_JWTUtils" %>
<%@ page import="com.auth0.jwt.interfaces.DecodedJWT" %>
<%
    // 【後端 JWT 驗證】
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
<title>ADMIN 首頁 - 儷府國宅</title>
<script>
    let timeLeft = 60; 
    let countdown;     
    let lastRefreshTime = 0; 

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
        .then(data => {
            if (data.success) {
                timeLeft = 60; 
                console.log("管理者操作中，已於背景自動重置 JWT 時效。");
            }
        }).catch(error => console.error('Silent refresh failed:', error));
    }

    function setupActivityListeners() {
        const events = ['mousemove', 'click', 'keydown', 'scroll'];
        events.forEach(ev => window.addEventListener(ev, silentRefreshJWT));
    }

    window.onload = function() { startTimer(); setupActivityListeners(); };
</script>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">

<link rel="stylesheet" href="https://cloudflare.com">

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
            <h2 style="color: #333; margin-top: 0;">(首頁) 系統操作 Log 表格</h2>
            <p style="color: #666; font-size: 14px;">💡 提示：本系統已啟用智慧防呆，只要您在網頁內移動滑鼠或操作鍵盤，安全憑證時效將在背景無感刷新。</p>
            
            <table border="1" cellpadding="10" style="width:100%; border-collapse:collapse; margin-top: 20px; border: 1px solid #dee2e6; text-align: left;">
                <tr style="background:#f2f2f2; color: #495057;">
                    <th style="width: 25%;">時間</th>
                    <th style="width: 55%;">內容</th>
                    <th style="width: 20%;">狀態</th>
                </tr>
                <tr>
                    <td>2026-06-04 13:00:22</td>
                    <td>系統管理員(admin01) 成功登入系統。</td>
                    <td><span style="background: #d4edda; color: #155724; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: bold;">SUCCESS</span></td>
                </tr>
                <tr>
                    <td>2026-06-04 13:15:45</td>
                    <td>背景安全校驗：無感重置 JWT 憑證時效成功。</td>
                    <td><span style="background: #d4edda; color: #155724; padding: 2px 8px; border-radius: 4px; font-size: 12px; font-weight: bold;">SUCCESS</span></td>
                </tr>
            </table>
        </div>
    </div>

</body>
</html>