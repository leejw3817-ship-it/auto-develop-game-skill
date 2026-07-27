---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_bd63ecf0891a11f1a68c525400826444
    ReservedCode1: O0Cuhe5cxcP0ZGQUsyUUhn2L+OheC1a3MXesokbgZJdQASqzF0Ug8HJa8itv04kmp3KlGVseoLh5G3LXQr9P5t1cIxbJd/6lGJ5pzZSMTdEWVzomoe3+v2ySo/8JPi5jOkuamyatqt5Tg6+Vg9TUormbZuSR3q6E8s334E254vHXjJN7N9ERJLUuQCU=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_bd63ecf0891a11f1a68c525400826444
    ReservedCode2: O0Cuhe5cxcP0ZGQUsyUUhn2L+OheC1a3MXesokbgZJdQASqzF0Ug8HJa8itv04kmp3KlGVseoLh5G3LXQr9P5t1cIxbJd/6lGJ5pzZSMTdEWVzomoe3+v2ySo/8JPi5jOkuamyatqt5Tg6+Vg9TUormbZuSR3q6E8s334E254vHXjJN7N9ERJLUuQCU=
---

# 04-Networking-Multiplayer 提示词

## 任务目标

实现校园杀的联机对战功能。使用 WebSocket 协议，支持房间创建/加入、实时对战同步、掉线重连、观战模式。服务器端使用 Node.js，客户端使用 Unity C#。

## 输出要求

### 1. 通信协议定义

在 `protocol.md` 中定义完整的 WebSocket 消息协议：

```json
// 客户端→服务器
{"type":"create_room","roomName":"xxx","maxPlayers":2}
{"type":"join_room","roomId":"xxx"}
{"type":"ready","heroIds":["h1","h2","h3"]}
{"type":"play_card","cardId":"xxx","targetId":"xxx"}
{"type":"end_turn"}
{"type":"chat","message":"xxx"}

// 服务器→客户端
{"type":"room_created","roomId":"xxx"}
{"type":"player_joined","playerId":"xxx","playerName":"xxx"}
{"type":"game_start","turnOrder":["p1","p2"]}
{"type":"card_played","playerId":"xxx","cardId":"xxx","targetId":"xxx"}
{"type":"turn_change","currentPlayer":"xxx","round":3}
{"type":"game_over","winnerId":"xxx","stats":{...}}
{"type":"error","code":404,"message":"xxx"}
```

### 2. Node.js 服务器

目录结构：
```
Server/
├── package.json
├── server.js          # 入口，WebSocket 服务器
├── roomManager.js     # 房间管理（创建/加入/离开/销毁）
├── gameSession.js     # 对局状态同步、回合管理
├── auth.js            # 简易 Token 认证
└── config.js          # 端口、超时等配置
```

特性：
- 使用 `ws` 库（轻量 WebSocket，零外部依赖）
- 内存存储房间状态（无需数据库）
- 心跳检测（15 秒间隔，30 秒超时断连）
- 掉线重连（180 秒内重连恢复状态）
- 支持不少于 100 个并发房间

### 3. Unity 客户端 NetworkManager.cs

```
public class NetworkManager : MonoBehaviour
{
    public void Connect(string serverUrl, string token);
    public void CreateRoom(string roomName, int maxPlayers);
    public void JoinRoom(string roomId);
    public void SendGameAction(string actionType, JObject data);
    
    // 事件回调
    public UnityEvent<JObject> OnMessageReceived;
    public UnityEvent<string> OnDisconnected;
    public UnityEvent OnReconnected;
}
```

### 4. 网络同步策略

- **权威服务器模式**：服务器为游戏逻辑的唯一权威，客户端只发送操作指令
- **增量同步**：只传输变化的数据（如某张牌被使用），不同步全量状态
- **操作确认**：客户端发出操作后需等待服务器 ACK 才能继续（防止作弊）
- **延迟补偿**：200ms 内延迟不弹出警告，200-500ms 显示网络图标，>500ms 提示重连

### 5. 观战模式 SpectatorManager.cs

- 允许第三方玩家加入房间但不参与游戏
- 实时接收完整对局状态
- 可切换视角（第一人称/上帝视角）

### 6. 局域网发现（可选，加分项）

使用 UDP 广播实现局域网房间发现：
- 服务器每 3 秒广播房间信息
- 客户端监听广播并展示可用房间列表

## 启动命令

```bash
cd Server
npm install
node server.js --port 3000
```

## 禁止行为

- 不要使用第三方联机服务（如 Photon / Mirror），必须自建 WebSocket
- 不要在客户端做游戏胜负判定（由服务器裁决）
- 不要明文传输任何用户标识（至少用 Base64 + 时间戳 token）

## 验收标准

- 两台设备通过 IP 能加入同一房间
- 双方出牌操作能实时看到对方操作
- 一方断网 30 秒内重连能恢复对局
- 完整打一局无同步错误
*（内容由AI生成，仅供参考）*
