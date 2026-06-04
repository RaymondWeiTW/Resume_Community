/*第三步
 * 編寫原生 SQL 語句來執行 CRUD（增刪查改）
 * 
 * 
 * */

package community;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import community.C_User;
import community.C_DBUtils;

public class C_UserDao {

    /**
     * 根據帳號與密碼查詢使用者 (登入驗證)
     */
    public C_User fn_loginCheck(String username, String password) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        C_User user = null;

        // 使用手動索引的 username 加快查詢
        String sql = "SELECT * FROM t_user WHERE username = ? AND password = ?";

        try {
            conn = C_DBUtils.fn_getConnection();
            
            /* 💡 補充註解: 
             * 採用 PreparedStatement 進行 SQL 預編譯。
             * 透過「占位符 (?)」傳參，能徹底阻絕「SQL 注入攻擊 (SQL Injection)」，
             * 這是工業與科技大廠系統開發中，最核心且不可妥協的資安防禦規範。
             */
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                user = new C_User();
                user.fn_setUserId(rs.getLong("user_id"));
                user.fn_setUsername(rs.getString("username"));
                user.fn_setPassword(rs.getString("password"));
                user.fn_setRealName(rs.getString("real_name"));
                user.fn_setRoomNumber(rs.getString("room_number"));
                user.fn_setPhone(rs.getString("phone"));
                user.fn_setRole(rs.getString("role")); // 這欄位是跳轉的關鍵！
                user.fn_setCreateTime(rs.getTimestamp("create_time"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // 釋放資源
            /* 💡 補充註解: 
             * 嚴格執行資源釋放。
             * 於 finally 區塊中呼叫 C_DBUtils.fn_close()，確保無論執行成功或拋出例外，
             * 皆會依照 ResultSet -> PreparedStatement -> Connection 的順序安全關閉，
             * 避免佔用資料庫連線數，維護智慧製造系統 24 小時不間斷運作的穩定性。
             */
            C_DBUtils.fn_close(rs, pstmt, conn);
        }
        return user;
    }
}
