package community;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/view")
public class C_ViewControllerServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 獲取前端傳來的 page 參數
        String page = request.getParameter("page");
        
        if (page == null || page.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/index.jsp");
            return;
        }

        // 根據參數，安全地將請求轉發（forward）到 WEB-INF/jsp/ 相對應的檔案
        String targetJsp = "/WEB-INF/jsp/" + page + ".jsp";
        
        // 轉跳前同樣可保留原有的 JWT 安全校驗（也可以等之後統一做成 Filter）
        request.getRequestDispatcher(targetJsp).forward(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
}