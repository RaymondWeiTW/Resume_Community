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
<title>VISITOR 住戶首頁</title>
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
                console.log("偵測到住戶操作中，已於背景自動重置 JWT 安全時效。");
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
    <h1>歡迎進入 VISITOR 住戶首頁</h1>
    
    <div style="background-color: #fff3cd; padding: 15px; border: 1px solid #ffeeba; display: inline-block; border-radius: 5px;">
        ⏳ JWT 安全憑證剩餘有效時間：<span id="timer" style="color:red; font-weight:bold; font-size:20px;">60</span> 秒
    </div>
    
    <p>歡迎回家！本頁面設有智慧操作感應，若閒置超過 1 分鐘未有任何動作，將會自動登出以保護帳戶安全。</p>
</body>
</html>