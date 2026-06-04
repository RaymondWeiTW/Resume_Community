package community;

import com.auth0.jwt.JWT;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.interfaces.DecodedJWT;
import com.auth0.jwt.interfaces.JWTVerifier;
import java.util.Date;

public class C_JWTUtils {

    // JWT 簽章金鑰 (Secret Key)
    // 用於產生與驗證 Token 的簽章
    // 後續因該放在其他地方
    private static final String SECRET_KEY = "Community_Secret_Key_RaymondWei_2026";

    // Token 有效期限
    // 60 * 1000 = 60,000 毫秒 = 1 分鐘
    private static final long EXPIRE_TIME = 60 * 1000;

    /**
     * 生成 JWT Token (1分鐘有效)
     *
     * @param username 使用者帳號
     * @param role 使用者角色
     * @return JWT Token 字串
     */
    public static String fn_createToken(String username, String role) {

        // 計算 Token 過期時間
        // 目前時間 + 有效期限
        Date expireDate = new Date(System.currentTimeMillis() + EXPIRE_TIME);

        // 建立 JWT Token
        return JWT.create()

                // 加入自訂 Claim：username
                // Claim 可以理解為 Token 內儲存的資料欄位
                .withClaim("username", username)

                // 加入自訂 Claim：role
                /* 💡 補充註解: 
                 * 在工業管理系統中，role 欄位非常關鍵（如 OP-操作員、EQ-設備工程師、Admin-管理者）。
                 * 將 role 放入 Claim 中，可供後端進行角色權限控管（RBAC），
                 * 避免低權限人員誤觸或非法呼叫機台控制 API。
                 */
                .withClaim("role", role)

                // 設定 Token 過期時間
                .withExpiresAt(expireDate)

                // 使用 HMAC256 演算法進行簽章
                // 產生最終 JWT 字串
                .sign(Algorithm.HMAC256(SECRET_KEY));
    }

    /**
     * 驗證 JWT Token 是否有效
     *
     * @param token 前端傳來的 JWT Token
     *
     * @return
     * 驗證成功：
     *     回傳 DecodedJWT 物件
     *
     * 驗證失敗：
     *     回傳 null
     */
    public static DecodedJWT fn_verifyToken(String token) {

        try {

            // 建立與簽發 Token 相同的加密演算法
            Algorithm algorithm = Algorithm.HMAC256(SECRET_KEY);

            // 建立 JWT 驗證器
            JWTVerifier verifier = JWT.require(algorithm).build();

            // 驗證 Token
            //
            // 驗證內容包含：
            // 1. Token 格式是否正確
            // 2. 簽章是否正確
            // 3. 是否被竄改
            // 4. 是否已過期
            //
            // 驗證成功後回傳解碼完成的 JWT 物件
            return verifier.verify(token);

        } catch (Exception e) {
            /* 💡 補充註解: 
             * 當 Token 遭遇過期（TokenExpiredException）或簽章被竄改（SignatureVerificationException）時，
             * verifier.verify() 會拋出例外，在此處捕捉並直接回傳 null，
             * 供上層 Filter 或 Interceptor 進行攔截，直接拒絕非法存取。
             */
        	return null;
        }
    }
}
