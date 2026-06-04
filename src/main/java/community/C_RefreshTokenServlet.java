package community;

import com.auth0.jwt.interfaces.DecodedJWT;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/RefreshTokenServlet")
public class C_RefreshTokenServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. 檢查目前的 Token 是否還有效
        String currentToken = (String) request.getSession().getAttribute("userToken");
        DecodedJWT decoded = C_JWTUtils.fn_verifyToken(currentToken);
        C_User currentUser = (C_User) request.getSession().getAttribute("currentUser");

        response.setContentType("application/json;charset=UTF-8");

        // 2. 如果使用者根本沒登入，或是過期太久了，拒絕續期
        if (currentToken == null || decoded == null || currentUser == null) {
            /* 💡 補充註解: 
             * 遵循 RESTful 規範。當驗證失敗或過期時，回傳 HTTP 401 Unauthorized 狀態碼，
             * 配合標準的 JSON 錯誤格式，讓前端（或點對點的機台設備）能即時攔截並引導至登入畫面。
             */
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"success\": false, \"message\": \"憑證已失效，無法續期！\"}");
            return;
        }

        // 3. 驗證通過，後端重新生成一張全新 1 分鐘的 JWT Token
        /* 💡 補充註解: 
         * 這裡運用了「滾動式續期 (Rolling Session / Token Refresh)」概念。
         * 只要操作人員在權限有效期間內持續與系統互動，系統就會自動發行新權杖，
         * 在完全不打擾使用者的情況下，完成動態密鑰更換。
         */
        String newToken = C_JWTUtils.fn_createToken(currentUser.fn_getUsername(), currentUser.fn_getRole());
        
        // 4. 覆蓋舊的 Token
        request.getSession().setAttribute("userToken", newToken);

        // 5. 回傳成功 JSON 給前端
        response.getWriter().write("{\"success\": true, \"message\": \"續期成功！\"}");
    }
}
