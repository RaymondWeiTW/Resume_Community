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
<title>公告編寫 - 儷府國宅</title>
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

    function checkBroadcastForm() {
        const content = document.getElementById("broadcastText").value.trim();
        if(content === "") {
            alert("❌ 錯誤：公告內容不能為空白！");
            return false;
        }
        alert("✅ 新公告發布成功！住戶端首頁同步更新。");
        return true;
    }
</script>
</head>
<body style="font-family: Arial, sans-serif; margin: 0; padding: 0;">
<!-- 上方主導覽列 -->
    <div style=
    "display: flex; align-items: center; gap: 15px; display: inline-flex; 
    background:#28a745; color: white; padding:15px; box-shadow: 0 2px 5px rgba(0,0,0,0.2);">
    <div class="icon-wrapper" id="notificationIcon">
            <!-- 圖標 -->
            <i class="fa-solid fa-user-ninja"></i>

            <!-- 紅色提示點 -->
            <span class="badge"></span>
        </div>
    <strong style="font-size: 18px;">[儷府國宅] 管理者</strong>
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
            <h3>物業功能選單</h3>
            <ul style="list-style: none; padding: 0; margin: 0; line-height: 2.5;">
               <li><a href="${pageContext.request.contextPath}/view?page=superiver_index" style="color: #007bff; text-decoration: none;margin-right: 12px;"><i class="fa-solid fa-calendar"></i>&nbsp;排班行事曆</a></li>
                <li><a href="${pageContext.request.contextPath}/view?page=superiver_broadcast" style="color: #495057; text-decoration: none;margin-right: 12px; font-weight: bold;"><i class="fa-solid fa-microphone-lines"></i>&nbsp;公告編寫</a></li>
                <li><a href="${pageContext.request.contextPath}/view?page=superiver_package" style="color: #007bff; text-decoration: none;margin-right: 12px;"> <i class="fa-solid fa-envelopes-bulk"></i>&nbsp;包裹收發</a></li>
                <li><a href="${pageContext.request.contextPath}/view?page=superiver_fix" style="color: #007bff; text-decoration: none;margin-right: 12px;"><i class="fa-solid fa-screwdriver-wrench"></i>&nbsp;報修彙整</a></li>
            </ul>
        </div>

        <div style="flex: 1; padding: 30px;">
            <h2>📢 (公告編寫) 填寫新發布公告內容</h2>
            
            <form action="#" method="POST" onsubmit="return checkBroadcastForm();" style="margin-bottom: 30px;">
                <textarea id="broadcastText" rows="5" style="width: 100%; max-width: 650px; padding: 10px; border:1px solid #ccc; border-radius:4px; resize: none;" placeholder="請在此輸入準備公告給全體社區住戶看到的文字訊息..."></textarea><br><br>
                <button type="submit" style="padding: 8px 22px; background:#28a745; color:white; border:none; border-radius:4px; cursor:pointer; font-weight:bold;">發布公告資訊</button>
            </form>

            <h3>📋 歷史公告訊息紀錄</h3>
            <table border="1" cellpadding="8" style="width:100%; border-collapse:collapse; text-align: left;">
                <tr style="background:#eee;"><th>發布時間</th><th>公告具體內容</th><th>發布狀態</th></tr>
                <tr><td>2026-06-04</td><td>本週五上午9點進行A、B棟水塔清洗作業，請住戶儲水備用。</td><td><span style="color:green; font-weight:bold;">✔️ 已發布</span></td></tr>
            </table>
        </div>
    </div>

</body>
</html>