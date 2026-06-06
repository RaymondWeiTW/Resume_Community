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
<title>報修彙整 - 儷府國宅</title>
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

    // 【智慧防呆前端驗證】：點擊修改狀態時，強制一定要輸入審查備註
    function updateFixStatus() {
        let remark = prompt("請輸入變更此報修案件的審查備註說明（必填）：");
        if (remark === null) {
            return; // 點選取消
        }
        if (remark.trim() === "") {
            alert("❌ 錯誤：依照系統稽核規範，物業修改狀態時『必須輸入備註內容』！"); //
            return;
        }
        alert("✅ 變更成功！審查備註已記錄為：" + remark);
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
            <h2>🛠️ (報修彙整) 社區報修歷史紀錄與狀態審查</h2>
            <p style="color:#666; font-size:14px;">💡 提示：點擊下方表格內各別案件的「狀態按鈕」，可進行修繕進度狀態變更（內含備註空白防呆攔截）。</p>
            
            <table border="1" cellpadding="10" style="width:100%; border-collapse:collapse; margin-top:15px; text-align: left;">
                <tr style="background:#eee;">
                    <th>報修時間</th>
                    <th>報修內容詳情</th>
                    <th>目前處理狀態 (點擊修改)</th>
                </tr>
                <tr>
                    <td>2026-06-04 10:11</td>
                    <td>B棟電梯燈泡閃爍不亮，請盡速派工換新</td>
                    <td>
                        <button type="button" onclick="updateFixStatus();" style="color:orange; font-weight:bold; background:none; border:1px solid orange; cursor:pointer; padding:4px 10px; border-radius:4px;">⏳ 待處理 (點擊變更)</button>
                    </td>
                </tr>
            </table>
        </div>
    </div>

</body>
</html>
