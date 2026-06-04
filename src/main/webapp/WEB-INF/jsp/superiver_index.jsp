<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="community.C_JWTUtils" %>
<%@ page import="com.auth0.jwt.interfaces.DecodedJWT" %>
<%
    // 【後端驗證】
    String token = (String) session.getAttribute("userToken");
    DecodedJWT decoded = C_JWTUtils.fn_verifyToken(token);

    if (token == null || decoded == null) {
        session.removeAttribute("userToken");
        session.removeAttribute("currentUser");
        request.setAttribute("errorMsg", "您的 JWT 憑證已過期（滿1分鐘）或未登入，請重新登入！");
        request.getRequestDispatcher("/index.jsp").forward(request, response);
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>SUPERIVER 物業經理面版</title>
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
        if (currentTime - lastRefreshTime < 10000) {
            return; 
        }
        lastRefreshTime = currentTime;

        fetch('${pageContext.request.contextPath}/RefreshTokenServlet', {
            method: 'POST'
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                timeLeft = 60; 
                console.log("偵測到物業經理操作中，已於背景自動重置 JWT 安全時效。");
            }
        })
        .catch(error => console.error('Silent refresh failed:', error));
    }

    function setupActivityListeners() {
        const events = ['mousemove', 'click', 'keydown', 'scroll'];
        events.forEach(function(eventType) {
            window.addEventListener(eventType, function() {
                silentRefreshJWT();
            });
        });
    }

    window.onload = function() {
        startTimer();
        setupActivityListeners();
    };
</script>
</head>
<body>
    <h1>歡迎進入 SUPERIVER 物業經理頁面</h1>
    
    <div style="background-color: #fff3cd; padding: 15px; border: 1px solid #ffeeba; display: inline-block; border-radius: 5px;">
        ⏳ JWT 安全憑證剩餘有效時間：<span id="timer" style="color:red; font-weight:bold; font-size:20px;">60</span> 秒
    </div>
    
    <p>您好，物業經理！只要您有在畫面上進行編輯、滑動或點擊，系統將確保您的登入狀態不中斷。</p>
</body>
</html>