/* 第一步
 * 設定 DB 連線方式
 *
 * 需下載 MySQL JDBC Driver 的 jar 檔，
 * 並放置於 WEB-INF/lib 目錄下，
 */

package community;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class C_DBUtils {

    // 資料庫連線字串 (JDBC URL)
    // 指定：
    // 1. 資料庫主機位置
    // 2. 連接埠 Port
    // 3. 資料庫名稱 
    // 4. SSL 加密連線
    // 5. 時區設定為 Asia/Taipei
	private static final String URL =
			"jdbc:mysql://mysql-2026v1-raymondtw2026.h.aivencloud.com:11597/Community?ssl-mode=REQUIRED&serverTimezone=Asia/Taipei";
    // 資料庫登入帳號
    private static final String USER = "avnadmin";
    // 資料庫登入密碼
    private static final String PASSWORD = "AVNS_WU5UXnYohpIqiF4zTOv";

    // MySQL JDBC Driver 類別名稱
    // Class.forName() 會利用此名稱載入驅動程式
    private static final String DRIVER_CLASS = "com.mysql.cj.jdbc.Driver";

    // 靜態初始化區塊
    // 類別第一次被載入時執行一次
    static {
        try {
            // 載入 MySQL JDBC Driver
            // 若 Driver 存在，JDBC 即可註冊驅動程式
            Class.forName(DRIVER_CLASS);

        } catch (ClassNotFoundException e) {

            // 找不到 Driver 時顯示錯誤訊息
            System.out.println("找不到 MySQL JDBC 驅動程式！");

            // 輸出詳細錯誤資訊
            e.printStackTrace();
        }
    }

    /**
     * 取得資料庫連線
     * 回傳：Connection 物件
     * 失敗時將例外拋給呼叫端處理
     */
    public static Connection fn_getConnection() throws SQLException {

        // 使用 JDBC 建立資料庫連線
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static void fn_close(AutoCloseable... resources) {

        // 逐一巡訪傳入的資源
        for (AutoCloseable res : resources) {
            // 避免 NullPointerException
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
