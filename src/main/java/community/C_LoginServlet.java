package community;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import community.C_UserDao;
import community.C_User;

// 這個註解代表網頁輸入 /LoginServlet 時會由這個類別處理
@WebServlet("/LoginServlet")
public class C_LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private C_UserDao userDao = new C_UserDao();

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 設定編碼，防止中文亂碼
        request.setCharacterEncoding("UTF-8");
        
        // 2. 接收從 index.jsp 傳過來的欄位資料 (對應 input 的 name)
        String usernameStr = request.getParameter("username");
        String passwordStr = request.getParameter("password");
        
        // 3. 呼叫 DAO 去 Aiven MySQL 驗證
        C_User loginUser = userDao.fn_loginCheck(usernameStr, passwordStr);
       
        /* ===新增JWT前===
        if (loginUser != null) {
            // 登入成功！把使用者資訊存入 Session 中（讓後續頁面知道是誰登入）
            request.getSession().setAttribute("currentUser", loginUser);
            
            // 4. 根據角色判定轉跳路徑 (核心功能)
            String role = loginUser.fn_getRole();
            String targetJsp = "/WEB-INF/jsp/visitor.jsp"; // 預設去住戶頁
            
            switch (role) {
                case "ADMIN":
                    targetJsp = "/WEB-INF/jsp/admin.jsp";
                    break;
                case "SUPERIVER":
                    targetJsp = "/WEB-INF/jsp/superiver.jsp";
                    break;
                case "VISITOR":
                    targetJsp = "/WEB-INF/jsp/visitor.jsp";
                    break;
            }
            
            // 執行內部轉跳 (Forward)
            request.getRequestDispatcher(targetJsp).forward(request, response);
          */  
        
        if (loginUser != null) {
            // 1. 生成 1 分鐘的 JWT Token
            String token = C_JWTUtils.fn_createToken(loginUser.fn_getUsername(), loginUser.fn_getRole());
            
            // 2. 將 Token 存入 Session 或 Request 中，讓後面的頁面能拿到 
            request.getSession().setAttribute("userToken", token);
            request.getSession().setAttribute("currentUser", loginUser);
            
            // 3. 根據角色判定轉跳路徑
            /* 💡 補充註解: 
             * 這裡實現了控制器的分流核心。
             * 透過多角色（ADMIN / SUPERIVER / VISITOR）的分支判定，
             * 完美對應到工業系統中常見的：廠長/工程師/一般作業員的分級操作介面控管。
             */
            String role = loginUser.fn_getRole();
            
            // 【核心修正點】：改走控制器路由，且重導向後必須馬上 return 切斷執行緒，避免與下方舊程式碼衝突
            switch (role) {
                case "ADMIN": 
                    response.sendRedirect(request.getContextPath() + "/view?page=admin_index"); 
                    return;
                case "SUPERIVER": 
                    response.sendRedirect(request.getContextPath() + "/view?page=superiver_index"); 
                    return;
                case "VISITOR": 
                    response.sendRedirect(request.getContextPath() + "/view?page=visitor_index"); 
                    return;
                default:
                    response.sendRedirect(request.getContextPath() + "/index.jsp");
                    return;
            }
            
            /* 💡 補充註解: 
             * 採用 RequestDispatcher.forward() 進行伺服器端內部轉向。
             * 網址列不會改變，且能安全地將置於 WEB-INF 目錄下的 JSP 頁面隱藏起來，
             * 防止外部使用者繞過 Servlet 直接透過網址列對敏感頁面進行非法存取。
             * * ( 📝 備忘：現架構已改為走 C_ViewControllerServlet 進行視圖分流，
             * 故此處的 forward 已被上方 switch 的 return 完美避開，保留此處僅供歷史註解研讀。 )
             */
            // request.getRequestDispatcher(targetJsp).forward(request, response);
            
        } else {
            // 登入失敗：帶回錯誤訊息並彈回登入頁
            request.setAttribute("errorMsg", "帳號或密碼錯誤，請重新輸入！");
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 如果有人直接用網址列 GET 訪問，一律導回登入頁
        /* 💡 補充註解: 
         * 顯式限制請求方法。
         * 拒絕經由網址列直接進行 GET 請求，只允許經由表單遞交的 POST 請求，
         * 是提升 Web 應用程式基礎資安防禦（防止敏感資料暴露於 URL）的標準實務做法。
         */
        response.sendRedirect(request.getContextPath() + "/index.jsp");
    }
}