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
<title>ADMIN 後台</title>
<script>
    let timeLeft = 60; // 憑證時效 60 秒
    let countdown;     // 倒數計時器
    let lastRefreshTime = 0; // 節流計時，防滑鼠頻繁觸發

    // 【1. 啟動倒數計時器】
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

    // 【2. 後端無感續期函數 (AJAX)】
    function silentRefreshJWT() {
        let currentTime = Date.now();
        // 10 秒之內，只允許默默刷新一次，避免對伺服器造成瘋狂轟炸
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
                timeLeft = 60; // 默默回歸 60 秒
                console.log("偵測到管理者操作中，已於背景自動重置 JWT 安全時效。");
            }
        })
        .catch(error => console.error('Silent refresh failed:', error));
    }

    // 【3. 智慧監聽：行為觸發】
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
    <h1>歡迎進入 ADMIN 後台系統</h1>
    
    <div style="background-color: #fff3cd; padding: 15px; border: 1px solid #ffeeba; display: inline-block; border-radius: 5px;">
        ⏳ JWT 安全憑證剩餘有效時間：<span id="timer" style="color:red; font-weight:bold; font-size:20px;">60</span> 秒
    </div>
    
    <p>💡 系統已啟動智慧防呆：只要您持續操作滑鼠或鍵盤，時效將在背景無感延長，無需手動點擊任何按鈕。</p>
</body>
</html>