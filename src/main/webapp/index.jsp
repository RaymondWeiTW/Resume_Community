<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    // 當使用者被彈回登入首頁時，主動把舊的過期 Token 與使用者資訊清空，確保安全
    session.removeAttribute("userToken");
    session.removeAttribute("currentUser");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>社區管理系統 - 登入</title>
</head>
<body>
    <h2>社區管理系統 - 帳號登入</h2>
    
    <form action="${pageContext.request.contextPath}/LoginServlet" method="POST">
        <label>帳號：</label>
        <input type="text" name="username" required><br><br>
        
        <label>密碼：</label>
        <input type="password" name="password" required><br><br>
        
        <button type="submit">登入</button>
    </form>
    
    <%-- 顯示登入失敗的錯誤訊息 --%>
    <c:if test="${not empty errorMsg}">
        <p style="color:red;">${errorMsg}</p>
    </c:if>
</body>
</html>