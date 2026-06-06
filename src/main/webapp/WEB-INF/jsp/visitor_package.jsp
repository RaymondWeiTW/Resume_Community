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
<title>我的包裹 - 儷府國宅</title>
<script>
    // JWT 計時器與活動監聽
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

     <!-- 上方主導覽列 -->
    <div style=
    "display: flex; align-items: center; gap: 15px; display: inline-flex; 
    background:#28a745; color: white; padding:15px; box-shadow: 0 2px 5px rgba(0,0,0,0.2);">
    <div class="icon-wrapper" id="notificationIcon">
            <!-- 圖標 -->
            <i class="fa-solid fa-user"></i>
            <!-- 紅色提示點 -->
            <span class="badge"></span>
        </div>
    <strong style="font-size: 18px;">[儷府國宅] 住戶服務中心</strong>
        <span style="margin-left: 20px;">
            <a href="${pageContext.request.contextPath}/view?page=visitor_index" style="color: white; font-weight: bold; text-decoration: none; margin-right: 12px;"><i class="fa-solid fa-house-chimney"></i></a> 
             <a href="${pageContext.request.contextPath}/index.jsp" style="color: white; text-decoration: none;"><i class="fa-solid fa-arrow-right-from-bracket"></i></a> 
        </span>
        <span style="float:right; background:#fff3cd; color: #856404; padding:4px 10px; border-radius: 4px; font-size: 14px;">
            ⏳ JWT 剩餘時間：<span id="timer" style="color:red; font-weight:bold;">60</span> 秒
        </span>
    </div>

    <div style="display: flex; min-height: calc(100vh - 60px);">
        <!-- 左側功能選單 -->
        <div style="width: 220px; background: #f8f9fa; padding: 20px; border-right: 1px solid #dee2e6;">
            <h3 style="color: #495057; font-size: 16px; border-bottom: 2px solid #dee2e6; padding-bottom: 8px;">功能選單</h3>
            <ul style="list-style: none; padding: 0; margin: 0; line-height: 2.5;">
                                 <li><a href="${pageContext.request.contextPath}/view?page=visitor_index" style="color: #495057; text-decoration: none; font-weight: bold;"><i class="fa-solid fa-microphone-lines"></i>&nbsp;廣播</a></li>
                <li><a href="${pageContext.request.contextPath}/view?page=visitor_package" style="color: #007bff; text-decoration: none;"><i class="fa-solid fa-envelopes-bulk"></i>&nbsp;包裹</a></li>
                <li><a href="${pageContext.request.contextPath}/view?page=visitor_fix" style="color: #007bff; text-decoration: none;"><i class="fa-solid fa-screwdriver-wrench"></i>&nbsp;報修</a></li>
            </ul>
        </div>

        <!-- 右側主要內容顯示區 -->
        <div style="flex: 1; padding: 30px;">
            <h2>📦 (我的包裹) 個人專屬歷史包裹訊息</h2>
            <p style="color: #666; font-size: 14px;">💡 提示：若狀態顯示為「管理室未領取」，請攜帶印章或身分證件至一樓管理室辦理簽收。</p>

            <table border="1" cellpadding="10" style="width:100%; border-collapse:collapse; margin-top:20px; text-align: left;">
                <tr style="background:#eee;">
                    <th>到貨時間</th>
                    <th>快遞/物流類型</th>
                    <th>目前領取狀態</th>
                </tr>
                <tr>
                    <td>2026-06-03 16:45</td>
                    <td>蝦皮購物 - 門市包裹</td>
                    <td><span style="background:#fff3cd; color:#856404; padding:4px 8px; border-radius:4px; font-weight:bold; font-size:14px;">📦 管理室未領取</span></td>
                </tr>
                <tr>
                    <td>2026-05-28 10:12</td>
                    <td>黑貓宅急便 - 冷凍常溫商品</td>
                    <td><span style="background:#e2e3e5; color:#383d41; padding:4px 8px; border-radius:4px; font-size:14px;">✔️ 住戶已簽收領取</span></td>
                </tr>
            </table>
        </div>
    </div>

</body>
</html>