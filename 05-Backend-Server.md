---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_71544f9088d611f18108525400287e28
    ReservedCode1: DTSbuS3QzyhdhwGnxYevrDLW6B/HdQR4FyOR1bL+y0tnkWRyNyswQm71t8BgIEQ51+qD6XGguHFBxXummL6Nq+Gy6cqyD9iPMFRlheN3mHBVP78BcEiFY/cKo36O+S9GzeQEGwvLvzcxTxC61w+az6NiKP3c8aXNmii2vm+rlguuaofRij4qv9bDSmM=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_71544f9088d611f18108525400287e28
    ReservedCode2: DTSbuS3QzyhdhwGnxYevrDLW6B/HdQR4FyOR1bL+y0tnkWRyNyswQm71t8BgIEQ51+qD6XGguHFBxXummL6Nq+Gy6cqyD9iPMFRlheN3mHBVP78BcEiFY/cKo36O+S9GzeQEGwvLvzcxTxC61w+az6NiKP3c8aXNmii2vm+rlguuaofRij4qv9bDSmM=
---


# 多人在线卡牌对战游戏 - 联机系统开发提示词

> 本提示词用于 Claude Code，聚焦于多人在线对战的网络层、同步策略、房间服务和基础设施。
> 技术栈：Node.js + TypeScript + Socket.IO + Redis + PostgreSQL + Docker

---

## 一、联机架构总览

### 1.1 服务拓扑

```
                    ┌─────────────┐
                    │   Nginx     │ (TLS终止 / 负载均衡)
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼─────┐ ┌───▼────┐ ┌─────▼─────┐
        │  Gateway  │ │Gateway │ │  Gateway  │  (WebSocket 接入层)
        │  Node #1  │ │Node #2 │ │  Node #3  │
        └─────┬─────┘ └───┬────┘ └─────┬─────┘
              │            │            │
              └────────────┼────────────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼─────┐ ┌───▼────┐ ┌─────▼─────┐
        │   Game    │ │  Game  │ │   Game    │  (游戏逻辑层)
        │  Server 1 │ │Server 2│ │  Server 3 │
        └─────┬─────┘ └───┬────┘ └─────┬─────┘
              │            │            │
              └────────────┼────────────┘
                           │
              ┌────────────▼────────────┐
              │      Redis Cluster      │  (房间状态 / 会话 / Pub/Sub)
              └─────────────────────────┘
                           │
              ┌────────────▼────────────┐
              │      PostgreSQL         │  (持久化: 用户/卡牌/战绩)
              └─────────────────────────┘
```

### 1.2 分层职责

| 层 | 进程 | 职责 | 扩缩容 |
|----|------|------|--------|
| 接入层 | Gateway | WebSocket连接管理、认证、限流、消息路由 | 水平扩展，Nginx ip_hash 粘性路由 |
| 逻辑层 | Game Server | 游戏状态机、战斗结算、效果触发、房间管理 | 按房间分片，Redis 做路由表 |
| 数据层 | Redis + PG | 实时状态缓存、持久化存储、消息发布订阅 | 主从 + 哨兵 / Cluster |

### 1.3 项目目录结构

```
server/
├── src/
│   ├── gateway/                    # 接入层
│   │   ├── GatewayServer.ts        # WebSocket 网关主进程
│   │   ├── ConnectionManager.ts    # 连接生命周期管理
│   │   ├── MessageRouter.ts        # 消息路由与转发
│   │   ├── AuthGuard.ts            # 连接认证
│   │   └── RateLimiter.ts          # 令牌桶限流
│   │
│   ├── game/                       # 游戏逻辑层
│   │   ├── GameServer.ts           # 游戏服务器主进程
│   │   ├── RoomManager.ts          # 房间管理（创建/销毁/分配）
│   │   ├── Room.ts                 # 房间实体
│   │   ├── GameEngine.ts           # 游戏状态机
│   │   ├── TurnManager.ts          # 回合管理
│   │   ├── ManaSystem.ts           # 法力水晶
│   │   ├── CombatResolver.ts       # 战斗结算
│   │   ├── WinCondition.ts         # 胜负判定
│   │   ├── cards/                  # 卡牌系统
│   │   │   ├── CardRegistry.ts     # 卡牌注册表
│   │   │   ├── MinionCard.ts
│   │   │   ├── SpellCard.ts
│   │   │   └── EquipmentCard.ts
│   │   ├── effects/                # 效果系统
│   │   │   ├── EffectBase.ts
│   │   │   ├── EffectRegistry.ts
│   │   │   └── effects/            # 具体效果实现
│   │   ├── identity/               # 身份系统
│   │   │   ├── IdentityManager.ts
│   │   │   └── identities/
│   │   └── triggers/               # 事件触发器
│   │       └── TriggerManager.ts
│   │
│   ├── sync/                       # 同步策略
│   │   ├── StateSyncEngine.ts      # 状态同步核心
│   │   ├── DeltaCompressor.ts      # 增量压缩
│   │   ├── SnapshotManager.ts      # 快照管理
│   │   └── Reconciliation.ts       # 状态对账
│   │
│   ├── matchmaking/                # 匹配系统
│   │   ├── Matchmaker.ts           # 匹配核心
│   │   ├── MatchPool.ts            # 匹配池
│   │   ├── EloCalculator.ts        # ELO 计算
│   │   └── QueueManager.ts         # 队列管理
│   │
│   ├── reconnect/                  # 断线重连
│   │   ├── ReconnectManager.ts     # 重连管理器
│   │   ├── EventReplayer.ts        # 事件回放器
│   │   └── TimeoutWatcher.ts       # 超时监控
│   │
│   ├── network/                    # 网络协议
│   │   ├── Protocol.ts             # 消息协议定义
│   │   ├── Serializer.ts           # 序列化/反序列化
│   │   ├── BinaryProtocol.ts       # 二进制协议（可选优化）
│   │   └── handlers/               # 消息处理器
│   │       ├── authHandler.ts
│   │       ├── matchHandler.ts
│   │       ├── roomHandler.ts
│   │       └── gameHandler.ts
│   │
│   ├── latency/                    # 延迟优化
│   │   ├── LatencyMonitor.ts       # 延迟监控
│   │   ├── Interpolation.ts        # 插值平滑
│   │   └── Prediction.ts           # 客户端预测（可选）
│   │
│   ├── security/                   # 安全
│   │   ├── AntiCheat.ts            # 反作弊
│   │   ├── InputValidator.ts       # 操作合法性校验
│   │   └── TrafficAnalyzer.ts      # 流量异常检测
│   │
│   ├── db/                         # 数据层
│   │   ├── PostgresClient.ts
│   │   ├── RedisClient.ts
│   │   ├── RedisPubSub.ts
│   │   └── repositories/
│   │
│   └── utils/
│       ├── Logger.ts
│       ├── EventBus.ts
│       ├── ObjectPool.ts
│       └── ErrorCodes.ts
│
├── tests/
│   ├── unit/
│   ├── integration/
│   ├── stress/                     # 压力测试
│   └── network-sim/                # 网络模拟测试
│
├── docker/
│   ├── Dockerfile.gateway
│   ├── Dockerfile.game
│   ├── docker-compose.yml
│   └── nginx.conf
│
├── package.json
├── tsconfig.json
└── .env.example
```

---

## 二、核心同步策略

### 2.1 为什么选择状态同步（而非帧同步）

| 维度 | 帧同步 (Lockstep) | 状态同步 (State Sync) | 卡牌游戏适用性 |
|------|------------------|----------------------|---------------|
| 操作频率 | 每帧都要同步输入 | 仅同步离散操作 | ✅ 卡牌操作频率低 |
| 确定性要求 | 极高（浮点数都不能用） | 低（服务端计算） | ✅ 效果复杂不适合 |
| 延迟敏感性 | 极高（一人卡全卡） | 低（异步操作） | ✅ 回合制容忍延迟 |
| 断线重连 | 从头回放 | 加载最新快照+增量 | ✅ 重连体验好 |
| 反作弊 | 客户端可看到全部信息 | 服务端只下发可见信息 | ✅ 身份局必须隐藏 |
| 带宽 | 低（仅输入） | 中（状态快照） | ✅ 卡牌状态量不大 |

**结论：使用服务端权威状态同步 (Server-Authoritative State Sync)**

### 2.2 状态同步架构

```
客户端A                          服务端                          客户端B
  │                                │                                │
  │ ── playCard {cardId, target} ──►                               │
  │                                │                                │
  │                          [验证合法性]                            │
  │                          [执行效果链]                            │
  │                          [计算新状态]                            │
  │                                │                                │
  │ ◄─── ack {seq, success} ───── │                                │
  │                                │                                │
  │ ◄─── stateDelta {...} ─────── │ ── stateDelta {...} ────────► │
  │                                │                                │
  │ [应用增量 → 渲染]              │                           [应用增量 → 渲染]
```

### 2.3 全量快照 vs 增量同步

```typescript
// SnapshotManager.ts - 双模式切换
interface SyncStrategy {
  /**
   * 全量快照：每 N 个增量后发一次，用于：
   *   - 新玩家加入 / 重连
   *   - 状态对账失败时修正
   *   - 每隔 30 秒定期同步（兜底纠错）
   */
  fullSnapshot(context: GameContext): GameSnapshot;

  /**
   * 增量同步：每次操作后仅下发变化部分，包括：
   *   - 场上随从属性变化（攻击/血量/buff）
   *   - 手牌变化（抽牌/弃牌/使用）
   *   - 法力水晶变化
   *   - 英雄血量变化
   *   - 触发效果动画指令（仅表现层）
   */
  delta(prevState: GameStateHash, operation: GameOperation): StateDelta;
}
```

**同步节奏**：
- 操作响应：操作立即返回 ack + 完整增量同步
- 定期快照：每 30 秒全网广播一次全量快照
- 对账机制：客户端每秒上报状态哈希，不匹配时服务端下发快照修正

### 2.4 增量压缩 (DeltaCompressor)

```typescript
// 仅传输变化字段
interface StateDelta {
  seq: number;                    // 序列号（严格递增，用于去重和排序）
  changes: EntityChange[];        // 变化的实体列表
  animations: AnimationCommand[]; // 表现层动画指令
  timestamp: number;              // 服务端时间戳
}

interface EntityChange {
  entityId: string;               // 实体ID（随从/英雄/卡牌）
  entityType: EntityType;
  changedFields: {                // 仅变化字段，不传全量
    field: string;
    oldValue: any;                // 可选，用于客户端差值动画
    newValue: any;
  }[];
}
```

---

## 三、消息协议设计

### 3.1 消息格式标准

```typescript
// Protocol.ts - 统一消息信封
interface MessageEnvelope<T = any> {
  // 协议头
  header: {
    msgId: string;           // 消息唯一ID (UUID v7，可按时间排序)
    type: MessageType;       // 消息类型
    seq: number;             // 服务端分配的操作序列号，客户端请求时为0
    timestamp: number;       // 发送时间戳 (ms)
    sessionId: string;       // 会话ID
  };
  // 负载
  payload: T;
}

enum MessageType {
  // 握手
  HELLO = 'hello',
  HELLO_ACK = 'hello_ack',
  
  // 心跳
  PING = 'ping',
  PONG = 'pong',
  
  // 操作请求
  REQUEST = 'request',
  
  // 操作确认
  ACK = 'ack',
  
  // 状态同步
  STATE_DELTA = 'state_delta',
  STATE_SNAPSHOT = 'state_snapshot',
  
  // 事件通知
  EVENT = 'event',
  
  // 错误
  ERROR = 'error',
}
```

### 3.2 心跳与连接保活

```typescript
// 双层心跳机制
interface HeartbeatConfig {
  // 客户端 → 服务端 PING
  clientPingInterval: 5000,     // 每5秒发送 PING
  clientPingTimeout: 15000,     // 15秒未收到 PONG 视为断开
  
  // 服务端 → 客户端 PING
  serverPingInterval: 10000,    // 每10秒发送 PING
  serverPingTimeout: 30000,     // 30秒未收到 PONG 断开连接
}

// 心跳实现要点：
// 1. 使用 WebSocket 原生 ping/pong 帧（低开销，不经过应用层）
// 2. 应用层 PING/PONG 作为兜底（部分代理会吞原生帧）
// 3. 服务端记录 lastHeartbeat，超时主动断开并触发重连流程
```

### 3.3 操作确认与序列号

```typescript
// 核心机制：服务端序列号保证全序
class SequenceManager {
  private nextSeq: number = 0;
  private clientLastAck: Map<string, number> = new Map();
  
  // 为操作分配全局递增序列号
  assign(operation: GameOperation): number {
    const seq = ++this.nextSeq;
    operation.seq = seq;
    return seq;
  }
  
  // 客户端上报已确认序列号，用于去重
  ack(clientId: string, seq: number): void {
    this.clientLastAck.set(clientId, seq);
  }
  
  // 判断操作是否已被某客户端确认（防止重放）
  isConfirmed(clientId: string, seq: number): boolean {
    const lastAck = this.clientLastAck.get(clientId);
    return lastAck !== undefined && seq <= lastAck;
  }
}
```

### 3.4 操作请求/响应示例

```typescript
// 客户端 → 服务端：出牌请求
{
  header: {
    msgId: "018f4a2c...",
    type: "request",
    seq: 0,
    timestamp: 1722000000000,
    sessionId: "sess_abc123"
  },
  payload: {
    action: "playCard",
    cardInstanceId: "card_45",     // 手牌实例ID（非卡牌模板ID）
    target: {
      type: "minion",
      entityId: "minion_enemy_3"   // 目标随从
    },
    position: 2                     // 放置位置（场上第几个槽位）
  }
}

// 服务端 → 客户端：操作确认 + 状态同步
{
  header: {
    msgId: "018f4a2d...",
    type: "ack",
    seq: 152,
    timestamp: 1722000000050,
    sessionId: "sess_abc123"
  },
  payload: {
    requestMsgId: "018f4a2c...",
    success: true,
    // 如果失败：
    // success: false, errorCode: 3002, errorMessage: "法力值不足"
  }
}

// 紧接着发送 STATE_DELTA（广播给所有玩家）
{
  header: {
    msgId: "018f4a2e...",
    type: "state_delta",
    seq: 153,
    timestamp: 1722000000060,
    sessionId: "server"
  },
  payload: {
    changes: [
      {
        entityId: "card_45",
        entityType: "card",
        changedFields: [
          { field: "location", newValue: "board", oldValue: "hand" },
          { field: "boardPosition", newValue: 2 }
        ]
      },
      {
        entityId: "player_A",
        entityType: "hero",
        changedFields: [
          { field: "mana.current", newValue: 2, oldValue: 7 }
        ]
      }
    ],
    animations: [
      { type: "playCard", cardId: "card_45", playerId: "player_A", position: 2 },
      { type: "manaSpend", playerId: "player_A", amount: 5 }
    ]
  }
}
```

---

## 四、房间系统

### 4.1 房间生命周期

```
              创建
               │
               ▼
          ┌─────────┐    玩家加入    ┌─────────┐   满员+全部准备   ┌──────────┐
          │ CREATED │ ────────────► │ WAITING │ ───────────────► │ STARTING │
          └─────────┘               └─────────┘                  └────┬─────┘
               ▲                         │                           │
               │                    玩家离开                          │
               │                    （变空房间）                       ▼
               │                         │                    ┌──────────┐
               │                         ▼                    │ IN_GAME  │
          ┌─────────┐               ┌─────────┐               └────┬─────┘
          │ CLOSED  │ ◄──────────── │  EMPTY  │                    │
          └─────────┘   超时未复用   └─────────┘              对局结束
                                                                │
                                                    ┌───────────▼───────────┐
                                                    │       FINISHED        │
                                                    └───────────┬───────────┘
                                                                │
                                                        5分钟后自动关闭
                                                                │
                                                                ▼
                                                          ┌─────────┐
                                                          │ CLOSED  │
                                                          └─────────┘
```

### 4.2 房间在 Redis 中的数据模型

```
# 房间元数据
room:{roomId} → Hash {
  id: "room_abc123"
  mode: "1v1" | "4p"
  status: "waiting" | "in_game" | "finished"
  gameServerId: "gs_3"          # 分配到的 Game Server 实例ID
  createdBy: "user_xxx"
  createdAt: 1722000000000
  maxPlayers: 2 | 4
}

# 房间玩家槽位
room:{roomId}:slots → Hash {
  slot_0: "user_xxx"            # 主公/先手
  slot_1: "user_yyy"
  slot_2: "user_zzz"
  slot_3: ""
}

# 房间玩家状态
room:{roomId}:player:{userId} → Hash {
  ready: true | false
  connected: true | false
  deckId: "deck_123"
  joinedAt: 1722000000000
}

# 游戏运行时状态（仅在 IN_GAME 期间存在）
game:{roomId}:state → String(JSON)    # 完整游戏状态快照
game:{roomId}:eventLog → List         # 事件日志（用于重连回放）
game:{roomId}:turnInfo → Hash         # 当前回合信息
game:{roomId}:player:{userId}:hand → String(JSON)  # 玩家手牌（仅本人可见）
```

### 4.3 房间分配策略

```typescript
// RoomManager.ts - 将房间分配到具体的 Game Server 实例
class RoomManager {
  /**
   * 分配策略：一致性哈希 + 最少房间数
   * 1. 计算 roomId 的哈希 → 映射到 Game Server
   * 2. 若目标 Server 负载过高（> 阈值），选择负载最低的
   * 3. 写入 Redis room:{roomId} → gameServerId 映射
   */
  async assignRoom(roomId: string): Promise<GameServerNode>;

  /**
   * 路由：Gateway 收到游戏消息时，根据 roomId 查找对应的 Game Server
   */
  async routeMessage(roomId: string, message: MessageEnvelope): Promise<void>;

  /**
   * Game Server 心跳上报
   */
  async reportHeartbeat(serverId: string, stats: ServerStats): Promise<void>;

  /**
   * 故障转移：检测到 Game Server 失联 → 将其房间迁移到健康节点
   */
  async failover(failedServerId: string): Promise<void>;
}
```

---

## 五、匹配系统

### 5.1 匹配算法

```typescript
// Matchmaker.ts
interface MatchConfig {
  mode: GameMode;
  
  // ELO 匹配范围
  initialEloRange: number;      // 初始范围 ±200
  maxEloRange: number;          // 最大范围 ±600
  eloExpansionInterval: number; // 每30秒扩大一次范围
  eloExpansionStep: number;     // 每次扩大 100
  
  // 超时
  matchTimeout: number;         // 最长匹配时间 120s
  matchTimeoutAction: 'expand' | 'bot' | 'fail';  // 超时后放宽/AI补位/失败
}

// 匹配流程
class Matchmaker {
  async startMatchmaking(user: User, config: MatchConfig): Promise<void> {
    // 1. 加入匹配池（Redis Sorted Set，score = ELO）
    // 2. 启动匹配定时器（每5秒尝试匹配一次）
    // 3. 尝试匹配逻辑：
    //    a. 从池中取出 ELO ± range 内的候选玩家
    //    b. 检查是否满足人数（1v1=2人，4p=4人）
    //    c. 满足 → 创建房间，分配身份，通知所有玩家
    //    d. 不满足 → 扩大 range，继续等待
    // 4. 超时处理
  }
}
```

### 5.2 匹配池 Redis 数据结构

```
# 1v1匹配池：Sorted Set（score=ELO，用于范围查询）
match:pool:1v1 → ZSET {
  "user_xxx": 1250,    # member=userId, score=ELO
  "user_yyy": 1320,
  ...
}

# 4p匹配池：Sorted Set
match:pool:4p → ZSET {
  "user_aaa": 1100,
  "user_bbb": 1150,
  ...
}

# 匹配状态
match:status:{userId} → Hash {
  status: "matching" | "matched" | "cancelled"
  mode: "1v1" | "4p"
  joinedAt: 1722000000000
  eloRange: 200
}

# 使用 Lua 脚本原子化匹配操作（避免并发问题）
```

### 5.3 匹配 Lua 脚本（Redis 原子操作）

```lua
-- match_1v1.lua
-- KEYS[1] = match:pool:1v1
-- ARGV[1] = userId
-- ARGV[2] = userElo
-- ARGV[3] = eloRange
-- ARGV[4] = maxPlayers (2)

-- 1. 将自己加入池中
redis.call('ZADD', KEYS[1], ARGV[2], ARGV[1])

-- 2. 查找 ELO 范围内的其他玩家
local candidates = redis.call('ZRANGEBYSCORE', KEYS[1], 
  tonumber(ARGV[2]) - tonumber(ARGV[3]), 
  tonumber(ARGV[2]) + tonumber(ARGV[3]))

-- 3. 排除自己，取前 N 个
local matched = {}
for i, uid in ipairs(candidates) do
  if uid ~= ARGV[1] and #matched < tonumber(ARGV[4]) - 1 then
    table.insert(matched, uid)
  end
end

-- 4. 凑够人数 → 从池中移除 → 返回匹配列表
if #matched == tonumber(ARGV[4]) - 1 then
  for _, uid in ipairs(matched) do
    redis.call('ZREM', KEYS[1], uid)
  end
  redis.call('ZREM', KEYS[1], ARGV[1])
  table.insert(matched, ARGV[1])
  return matched
end

-- 5. 不够 → 返回空
return {}
```

---

## 六、断线重连

### 6.1 重连状态机

```
                NORMAL
                   │
              disconnect
                   │
                   ▼
        ┌──────────────────┐
        │   DISCONNECTED   │
        │  (启动60s倒计时)  │
        └──────┬───────────┘
               │
       ┌───────┼───────┐
       │       │       │
   重连成功  超时    投降
       │       │       │
       ▼       ▼       ▼
   NORMAL   GAME    GAME
  (状态回放) OVER    OVER
```

### 6.2 重连数据回放

```typescript
// ReconnectManager.ts
class ReconnectManager {
  /**
   * 重连流程：
   * 1. 客户端用原有 sessionId 重连
   * 2. 服务端验证 sessionId 是否有效且关联到进行中的对局
   * 3. 服务端下发 RECONNECT_STATE 消息，包含：
   *    a. 当前游戏状态全量快照
   *    b. 断线后的事件日志增量（eventLog 从 lastAckSeq 开始）
   *    c. 当前回合信息和剩余操作时间
   * 4. 客户端先应用快照，再逐条回放事件，重建渲染状态
   * 5. 回放完成 → 客户端发送 RECONNECT_READY
   * 6. 服务端将该玩家标记为 CONNECTED，恢复操作权限
   */
  async handleReconnect(
    sessionId: string, 
    clientLastSeq: number
  ): Promise<ReconnectPayload> {
    // 1. 查找关联房间
    const roomId = await redis.get(`session:${sessionId}:room`);
    if (!roomId) throw new GameError(ErrorCode.RECONNECT_NO_ROOM);
    
    // 2. 获取当前状态快照
    const snapshot = await this.snapshotManager.getLatestSnapshot(roomId);
    
    // 3. 获取断线后的事件日志增量
    const events = await this.eventReplayer.getEventsAfter(
      roomId, 
      clientLastSeq
    );
    
    // 4. 返回重连数据
    return {
      snapshot,
      missedEvents: events,
      turnInfo: await this.getTurnInfo(roomId),
      remainingTime: this.getRemainingTurnTime(roomId),
    };
  }
  
  /**
   * 超时处理
   */
  async onReconnectTimeout(userId: string, roomId: string): Promise<void> {
    // 1. 标记玩家为 ABANDONED
    // 2. 若为1v1 → 对手直接获胜
    // 3. 若为4p身份局 → 该玩家由 AI 托管，或该玩家判负（按身份规则）
    // 4. 通知其他玩家
    // 5. 若该玩家是主公 → 反贼直接获胜
  }
}
```

### 6.3 事件日志存储策略

```typescript
// eventLog 使用 Redis List + PostgreSQL 持久化
interface EventLogEntry {
  seq: number;              // 全局序列号
  type: EventType;          // 操作/效果/状态变更
  timestamp: number;
  actorId: string;          // 操作者
  data: Record<string, any>; // 事件数据
}

// Redis 存储最近 500 条（热数据，重连用）
// key: game:{roomId}:eventLog → List (LPUSH 追加)
// 超过 500 条时 RTRIM 保留最新

// PostgreSQL 异步批量写入（冷数据，回放/复盘用）
// 每 100 条或每 10 秒批量 flush 一次
```

---

## 七、延迟优化

### 7.1 乐观更新与回滚

```typescript
// 客户端侧（提示词中描述实现思路，不要求 Claude Code 写前端代码）
/**
 * 乐观更新策略（适用于出牌、攻击等操作）：
 * 
 * 1. 玩家操作 → 客户端立即在本地应用效果（乐观假设服务端通过）
 * 2. 同时发送请求到服务端
 * 3. 服务端返回 ACK：
 *    - success=true + stateDelta → 客户端以 stateDelta 覆盖本地状态（修正差异）
 *    - success=false → 客户端回滚到操作前的状态快照
 * 
 * 4. 客户端保存操作前的快照栈（最多5层），用于快速回滚
 */
```

### 7.2 延迟监控与自适应

```typescript
// LatencyMonitor.ts
class LatencyMonitor {
  private metrics: Map<string, number[]> = new Map();
  
  // 每个客户端维护最近 20 次 RTT 样本
  recordRTT(clientId: string, rttMs: number): void;
  
  // 计算加权平均值（近期权重高）
  getAverageRTT(clientId: string): number;
  
  // 根据延迟自适应调整：
  //   - 延迟 < 100ms：正常模式
  //   - 延迟 100-300ms：增加动画时长缓冲
  //   - 延迟 > 300ms：提示玩家网络不佳；延长操作超时时间
  getLatencyTier(clientId: string): 'good' | 'moderate' | 'poor';
}
```

### 7.3 操作超时保护

```typescript
// 每回合操作时间限制
interface TurnTimeLimit {
  mode1v1: {
    mulligan: 45000,       // 换牌 45秒
    mainPhase: 75000,      // 主要阶段 75秒
    combatPhase: 45000,    // 战斗阶段 45秒
  };
  mode4p: {
    mulligan: 30000,       // 4人局更快
    mainPhase: 45000,
    combatPhase: 30000,
  };
}

// 超时处理：
// 1. 倒计时 10 秒时广播 TIME_WARNING
// 2. 超时 → 自动结束当前阶段
// 3. 连续超时 2次 → 警告，连续3次 → 由 AI 托管 / 判负
```

---

## 八、安全体系

### 8.1 连接安全

```typescript
// 连接认证流程
// 1. HTTP 先登录获取 JWT Token（有效期 24h）
// 2. WebSocket 连接时在 query 参数中携带 token
// 3. Gateway 验证 token 有效性
// 4. 验证通过 → 创建 session，绑定 userId → socketId
// 5. 后续消息通过 sessionId 识别用户，不再需要每次传 token
```

### 8.2 操作安全（防作弊核心）

```typescript
class InputValidator {
  /**
   * 每一条操作请求，服务端必须校验以下全部项：
   */
  async validate(userId: string, action: GameAction): Promise<ValidationResult> {
    // 1. 身份校验：该 socket 是否绑定到该 userId
    // 2. 房间校验：该玩家是否在当前房间
    // 3. 回合校验：是否该玩家的回合
    // 4. 阶段校验：当前阶段是否允许该操作
    // 5. 资源校验：法力/攻击次数/技能冷却是否满足
    // 6. 卡牌校验：该卡牌是否在手牌中
    // 7. 目标校验：目标是否合法（嘲讽盾/潜行/友方敌方）
    // 8. 频率校验：操作间隔是否合理（防脚本）
    
    // 任何一项不通过 → 拒绝操作 + 记录日志 + 累计可疑分
  }
}
```

### 8.3 反作弊评分

```typescript
class AntiCheat {
  private suspiciousScores: Map<string, number> = new Map();
  
  // 可疑行为及其加分
  private rules = {
    INVALID_ACTION: 5,          // 非法操作
    RAPID_ACTION: 10,           // 过快操作（< 100ms 间隔）
    CONSISTENT_TIMING: 3,       // 操作间隔极度一致（脚本特征）
    STATE_MISMATCH: 15,         // 客户端状态哈希与服务端不一致
    UNREALISTIC_APM: 8,         // 异常高的 APM
    SUSPICIOUS_PATTERN: 20,     // 行为模式匹配已知外挂特征
  };
  
  // 累计 ≥ 30 分 → 临时封禁该对局
  // 累计 ≥ 100 分 → 永久封禁账号
}
```

### 8.4 信息隔离（身份局关键）

```typescript
// 4人身份局中，以下信息对特定玩家不可见：
class InformationFilter {
  filterStateForPlayer(fullState: GameState, playerId: string): GameState {
    return {
      ...fullState,
      players: fullState.players.map(p => {
        if (p.id === playerId) return p;  // 自己的完整信息
        
        // 对其他玩家：
        return {
          ...p,
          identity: p.identity === 'lord' ? 'lord' : 'hidden',  // 仅主公身份公开
          hand: [],                     // 不暴露手牌
          handCount: p.hand.length,     // 仅暴露手牌数量
          deckCount: p.deck.length,     // 仅暴露牌库数量
          // 身份技能使用记录不可见
        };
      })
    };
  }
}
```

---

## 九、水平扩展与高可用

### 9.1 Gateway 层扩展

```
Nginx 配置 ip_hash（按客户端 IP 粘性路由）：
- 同一客户端始终连接到同一 Gateway 实例
- Gateway 是无状态的（session 存 Redis）
- 缓存热点数据（卡牌定义、用户基础信息）在内存

扩容：增加 Gateway 实例 + 更新 Nginx upstream
缩容：从 upstream 摘除，等待现有连接自然关闭
```

### 9.2 Game Server 层扩展

```typescript
// 房间分片策略
class GameServerCluster {
  /**
   * 一致性哈希环：
   * - 每个 Game Server 在环上有多个虚拟节点（默认 100）
   * - roomId 哈希后映射到环上 → 确定归属 Server
   * - 新增 Server：仅影响相邻房间（约 1/N）
   * - 移除 Server：其房间迁移到顺时针下一个节点
   */
  
  /**
   * 故障检测：
   * - 每 3 秒心跳上报到 Redis
   * - 15 秒未收到心跳 → 标记为 SUSPECT
   * - 30 秒未收到心跳 → 标记为 DEAD，触发故障转移
   */
}
```

### 9.3 故障转移

```typescript
// FailoverManager.ts
class FailoverManager {
  async handleServerFailure(failedServerId: string): Promise<void> {
    // 1. 从 Redis 获取该 Server 上所有活跃房间
    const rooms = await redis.smembers(`server:${failedServerId}:rooms`);
    
    // 2. 对每个房间：
    for (const roomId of rooms) {
      // a. 选择目标健康节点（负载最低）
      const target = await this.selectTargetNode();
      
      // b. 迁移房间状态：
      //    - 从 Redis 读取房间完整状态（不依赖故障节点内存）
      //    - 在新节点重建 GameEngine 实例
      //    - 更新 room:{roomId} → gameServerId 映射
      
      // c. 通知 Gateway 路由更新
      await this.pubsub.publish('route:update', {
        roomId,
        oldServer: failedServerId,
        newServer: target.id,
      });
      
      // d. 通知房间内所有玩家（短暂卡顿后恢复）
      await this.notifyRoomPlayers(roomId, {
        type: 'SERVER_MIGRATION',
        reconnectHint: '服务器迁移中，请稍候...',
      });
    }
  }
}
```

### 9.4 优雅关闭

```typescript
// GracefulShutdown.ts
class GracefulShutdown {
  async shutdown(signal: string): Promise<void> {
    logger.info(`收到 ${signal} 信号，开始优雅关闭...`);
    
    // 1. 停止接受新连接和新匹配
    this.healthCheck.setStatus('draining');
    
    // 2. 等待现有匹配队列清空（最多 30 秒）
    await this.drainMatchQueue(30000);
    
    // 3. 通知所有活跃房间：服务器即将维护
    for (const room of this.activeRooms) {
      await this.notifyRoomMaintenance(room.id, 120); // 2分钟缓冲
    }
    
    // 4. 保存所有房间状态到 Redis
    await this.flushAllRoomsToRedis();
    
    // 5. 从集群摘除自己
    await this.deregisterFromCluster();
    
    // 6. 等待房间自然结束或迁移（最多 5 分钟）
    await this.waitForRoomDrain(300000);
    
    // 7. 关闭 HTTP / WebSocket 服务器
    await this.closeServers();
    
    // 8. 断开 Redis / PostgreSQL
    await this.closeConnections();
    
    process.exit(0);
  }
}
```

---

## 十、监控与可观测性

### 10.1 关键指标

```typescript
// 需要暴露的 Prometheus 指标
interface Metrics {
  // 连接指标
  ws_connections_active: Gauge;     // 活跃连接数
  ws_connections_total: Counter;    // 累计连接数
  ws_disconnections_total: Counter; // 累计断开数
  
  // 房间指标
  rooms_active: Gauge;              // 活跃房间数
  rooms_created_total: Counter;     // 累计创建房间数
  rooms_finished_total: Counter;    // 累计完成对局数
  
  // 匹配指标
  match_queue_size: Gauge;          // 匹配队列长度
  match_duration_seconds: Histogram; // 匹配耗时分布
  match_success_total: Counter;     // 匹配成功次数
  match_timeout_total: Counter;     // 匹配超时次数
  
  // 游戏指标
  game_actions_total: Counter;      // 游戏操作总数
  game_turn_duration_seconds: Histogram; // 回合耗时分布
  game_disconnections_total: Counter;    // 对局中断线数
  game_reconnects_total: Counter;        // 重连成功数
  
  // 延迟指标
  rtt_milliseconds: Histogram;      // 客户端RTT分布
  
  // 错误指标
  errors_total: Counter;            // 错误总数（按错误码分类）
  
  // 系统指标
  event_loop_lag_seconds: Gauge;    // 事件循环延迟
  memory_heap_used_bytes: Gauge;    // 堆内存使用
  redis_operations_duration: Histogram;
  postgres_query_duration: Histogram;
}
```

### 10.2 日志规范

```typescript
// 结构化日志，禁止 console.log
interface LogEntry {
  level: 'debug' | 'info' | 'warn' | 'error';
  timestamp: string;           // ISO 8601
  service: 'gateway' | 'game' | 'matchmaker';
  instanceId: string;          // 进程实例ID
  traceId: string;             // 全链路追踪ID（从 Gateway 传入 Game Server）
  roomId?: string;
  userId?: string;
  action?: string;
  message: string;
  data?: Record<string, any>;  // 结构化上下文
  error?: {
    code: string;
    message: string;
    stack?: string;
  };
}

// 关键日志打点位置：
// - 每次状态转移：INFO，含 fromState → toState
// - 每次匹配成功/失败：INFO，含匹配耗时和ELO范围
// - 每次断线/重连：WARN，含断线时长
// - 每次作弊检测：WARN，含可疑分和触发规则
// - 每次错误：ERROR，含完整上下文
```

---

## 十一、测试体系

### 11.1 网络模拟测试

```typescript
// 使用 toxiproxy 或自定义代理模拟网络条件
class NetworkSimulator {
  // 模拟条件
  scenarios = {
    IDEAL:      { latency: 0,    jitter: 0,    packetLoss: 0 },
    GOOD:       { latency: 30,   jitter: 5,    packetLoss: 0 },
    AVERAGE:    { latency: 80,   jitter: 20,   packetLoss: 0.01 },
    POOR:       { latency: 200,  jitter: 80,   packetLoss: 0.05 },
    TERRIBLE:   { latency: 500,  jitter: 200,  packetLoss: 0.15 },
    DISCONNECT: { latency: 100,  jitter: 20,   packetLoss: 1.0 },  // 100%丢包
  };
  
  // 每个场景下运行完整对局，验证：
  // 1. 状态一致性（双方状态哈希终态一致）
  // 2. 无卡死/死锁
  // 3. 断线重连后状态正确恢复
}
```

### 11.2 压力测试

```typescript
// 使用 Artillery 或 k6 + Socket.IO 插件
// 测试场景：
// 1. 1000 并发连接建立
// 2. 500 个同时进行中的 1v1 对局
// 3. 200 个同时进行中的 4p 对局
// 4. 100 人同时匹配（观察匹配队列和耗时）
// 5. 50 个房间同时触发故障转移
```

### 11.3 混沌测试

```typescript
// 在测试环境随机注入故障：
// - 随机杀 Game Server 进程（验证故障转移）
// - 随机断开 Redis 连接（验证降级策略）
// - 随机注入网络延迟/丢包（验证重连和同步）
// - 随机发送非法操作（验证反作弊）
```

---

## 十二、部署配置

### 12.1 Docker Compose 开发环境

```yaml
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: cardgame
      POSTGRES_USER: cardgame
      POSTGRES_PASSWORD: dev_password
    ports: ["5432:5432"]
    volumes: [pg_data:/var/lib/postgresql/data]

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    ports: ["6379:6379"]
    volumes: [redis_data:/data]

  gateway:
    build:
      context: .
      dockerfile: docker/Dockerfile.gateway
    ports: ["3000:3000"]
    environment:
      NODE_ENV: development
      REDIS_URL: redis://redis:6379
      JWT_SECRET: dev_secret_change_in_production
    depends_on: [redis]

  game-server-1:
    build:
      context: .
      dockerfile: docker/Dockerfile.game
    environment:
      NODE_ENV: development
      REDIS_URL: redis://redis:6379
      DB_URL: postgresql://cardgame:dev_password@postgres:5432/cardgame
      INSTANCE_ID: gs_1
    depends_on: [redis, postgres]

  game-server-2:
    build:
      context: .
      dockerfile: docker/Dockerfile.game
    environment:
      NODE_ENV: development
      REDIS_URL: redis://redis:6379
      DB_URL: postgresql://cardgame:dev_password@postgres:5432/cardgame
      INSTANCE_ID: gs_2
    depends_on: [redis, postgres]

volumes:
  pg_data:
  redis_data:
```

### 12.2 环境变量

```bash
# .env.example
# ===== 服务 =====
NODE_ENV=development
SERVICE_TYPE=gateway               # gateway | game
INSTANCE_ID=gw_1

# ===== 端口 =====
PORT=3000
METRICS_PORT=9090

# ===== Redis =====
REDIS_URL=redis://localhost:6379
REDIS_CLUSTER_MODE=false
REDIS_PASSWORD=

# ===== PostgreSQL =====
DB_URL=postgresql://cardgame:dev_password@localhost:5432/cardgame
DB_POOL_MIN=2
DB_POOL_MAX=10

# ===== JWT =====
JWT_SECRET=change_this_in_production
JWT_EXPIRES_IN=24h

# ===== 游戏 =====
MATCH_TIMEOUT_SECONDS=120
RECONNECT_TIMEOUT_SECONDS=60
ROOM_CLEANUP_INTERVAL=300          # 清理空房间间隔(秒)
MAX_ROOMS_PER_SERVER=500

# ===== 限流 =====
RATE_LIMIT_PER_SECOND=10
RATE_LIMIT_BURST=20

# ===== 日志 =====
LOG_LEVEL=debug
LOG_FORMAT=json
```

---

## 十三、开发顺序

| 阶段 | 内容 | 验证方式 |
|------|------|---------|
| Phase 1 | Protocol 定义 + Redis/Postgres 连接 + 基础项目骨架 | 连接测试通过 |
| Phase 2 | Gateway（WebSocket 连接管理、认证、心跳、限流） | 多客户端连接/断开测试 |
| Phase 3 | Game Server 单实例 + 房间管理（创建/加入/离开） | 单人创建房间流程 |
| Phase 4 | 同步核心（StateSync + Snapshot + Delta + 序列号） | 单房间状态同步一致 |
| Phase 5 | 匹配系统（MatchPool + Matchmaker + Lua脚本） | 2人/4人匹配成功 |
| Phase 6 | 游戏状态机 + 战斗结算（在 Game Server 内） | 单机模拟完整对局 |
| Phase 7 | 消息路由（Gateway ↔ Game Server 通过 Redis Pub/Sub） | 跨进程消息收发 |
| Phase 8 | 断线重连（ReconnectManager + EventReplayer） | 模拟断线后恢复 |
| Phase 9 | 4人身份局信息隔离 + 身份技能 | 4人完整对局 |
| Phase 10 | 集群扩展（一致性哈希 + 故障转移 + 优雅关闭） | 双 Game Server 故障转移 |
| Phase 11 | 监控/日志/指标 | Prometheus 指标可查询 |
| Phase 12 | 压力测试 + 网络模拟测试 + 混沌测试 | 各场景通过 |

---

## 十四、输出要求

按以下顺序生成代码，每个文件包含完整实现：

1. **类型与协议**：`Protocol.ts`（所有消息类型、枚举、接口）→ `ErrorCodes.ts`
2. **基础设施**：`RedisClient.ts` → `RedisPubSub.ts` → `PostgresClient.ts` → `Logger.ts` → `EventBus.ts`
3. **Gateway 层**：`GatewayServer.ts` → `ConnectionManager.ts` → `AuthGuard.ts` → `RateLimiter.ts` → `MessageRouter.ts`
4. **Game Server 层**：`GameServer.ts` → `RoomManager.ts` → `Room.ts` → `GameEngine.ts` → `TurnManager.ts` → `ManaSystem.ts` → `CombatResolver.ts` → `WinCondition.ts`
5. **同步层**：`StateSyncEngine.ts` → `DeltaCompressor.ts` → `SnapshotManager.ts` → `Reconciliation.ts`
6. **匹配层**：`Matchmaker.ts` → `MatchPool.ts` → `EloCalculator.ts` + Lua 脚本
7. **重连层**：`ReconnectManager.ts` → `EventReplayer.ts` → `TimeoutWatcher.ts`
8. **安全层**：`AntiCheat.ts` → `InputValidator.ts` → `InformationFilter.ts`
9. **扩展与运维**：`GameServerCluster.ts` → `FailoverManager.ts` → `GracefulShutdown.ts` → `LatencyMonitor.ts`
10. **配置与部署**：`docker-compose.yml` → `Dockerfile.gateway` → `Dockerfile.game` → `nginx.conf` → `.env.example`
11. **测试**：单元测试 → 集成测试 → 网络模拟测试 → 压力测试脚本

每个模块文件头部注明职责、上下游依赖关系。所有代码 TypeScript 严格模式，使用 async/await 处理异步，错误统一抛出 GameError。
*（内容由AI生成，仅供参考）*
