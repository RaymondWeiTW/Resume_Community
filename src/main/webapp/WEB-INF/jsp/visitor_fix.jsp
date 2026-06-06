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
<title>社區報修 - 儷府國宅</title>
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

    // 【住戶端前端防呆驗證】：送出前檢查欄位是否空白
    function validateFixForm() {
        const title = document.forms["fixForm"]["title"].value.trim();
        const content = document.forms["fixForm"]["content"].value.trim();
        if (title === "" || content === "") {
            alert("❌ 錯誤：報修主旨與詳細內容皆不能為空！");
            return false;
        }
        alert("✅ 報修申請已成功送出！請靜候物業通知。");
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
            <h2>🛠️ (社區報修) 填寫新報修申請表單</h2>
            
            <form name="fixForm" action="#" method="POST" onsubmit="return validateFixForm();" style="background: #fff; padding: 20px; border: 1px solid #dee2e6; border-radius: 4px; max-width: 600px; margin-bottom: 30px;">
                <div style="margin-bottom: 15px;">
                    <label style="display:block; margin-bottom:5px; font-weight:bold;">報修主旨：</label>
                    <input type="text" name="title" placeholder="例如：廚房水管漏水" style="padding: 6px; width: 95%; border: 1px solid #ccc; border-radius:4px;">
                </div>
                <div style="margin-bottom: 15px;">
                    <label style="display:block; margin-bottom:5px; font-weight:bold;">詳細內容描述：</label>
                    <textarea name="content" rows="4" placeholder="請詳細說明損壞狀況以利安排修繕..." style="padding: 6px; width: 95%; border: 1px solid #ccc; border-radius:4px; resize: none;"></textarea>
                </div>
                <button type="submit" style="padding: 8px 20px; background: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; font-weight:bold;">送出報修申請</button>
            </form>

            <hr style="border: 0; border-top: 1px solid #dee2e6;">

            <h3>📋 我的歷史報修進度紀錄</h3>
            <table border="1" cellpadding="10" style="width:100%; border-collapse:collapse; margin-top:15px; text-align: left;">
                <tr style="background:#eee;">
                    <th>申請日期</th>
                    <th>報修項目</th>
                    <th>處理狀態</th>
                </tr>
                <tr>
                    <td>2026-06-01</td>
                    <td>客廳對講機沒有聲音</td>
                    <td><span style="background:#d4edda; color:#155724; padding:3px 8px; border-radius:4px; font-size:14px;">已派工修繕</span></td>
                </tr>
            </table>
        </div>
    </div>

</body>
</html>