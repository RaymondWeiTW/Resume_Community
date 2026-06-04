/*第二步
 * 建立對應表單名資料 get set
 * 
 * 
 * */

package community;

import java.sql.Timestamp;

public class C_User {
    private Long userId;          // 對應 BIGINT
    private String username;
    private String password;
    private String realName;
    private String roomNumber;
    private String phone;
    private String role;          // SUPERIVER / ADMIN / VISITOR
    private Timestamp createTime;

    // 建構子
    public C_User() {}

    // Getters and Setters
    /* 💡 補充註解: 
     * 遵循 封裝 (Encapsulation) 原則。
     * 將所有成員變數設為 private，並僅透過 public 的 getter/setter 方法進行存取。
     */
    public Long fn_getUserId() { return userId; }
    public void fn_setUserId(Long userId) { this.userId = userId; }

    public String fn_getUsername() { return username; }
    public void fn_setUsername(String username) { this.username = username; }

    public String fn_getPassword() { return password; }
    public void fn_setPassword(String password) { this.password = password; }

    public String fn_getRealName() { return realName; }
    public void fn_setRealName(String realName) { this.realName = realName; }

    public String fn_getRoomNumber() { return roomNumber; }
    public void fn_setRoomNumber(String roomNumber) { this.roomNumber = roomNumber; }

    public String fn_getPhone() { return phone; }
    public void fn_setPhone(String phone) { this.phone = phone; }

    public String fn_getRole() { return role; }
    public void fn_setRole(String role) { this.role = role; }

    public Timestamp fn_getCreateTime() { return createTime; }
    /* 💡 補充註解: 
     * 這裡選用了 java.sql.Timestamp 來映射資料庫的 DATETIME/TIMESTAMP 型態。
     * 在生產線系統中，這對於記錄精確到毫秒級的事件（如：機台警報觸發時間、
     * 生產進站時間 Log）至關重要，能完整保留高精度的時間軌跡。
     */
    public void fn_setCreateTime(Timestamp createTime) { this.createTime = createTime; }
}
