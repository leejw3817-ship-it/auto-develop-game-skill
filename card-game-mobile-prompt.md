---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_3343460488d511f18108525400287e28
    ReservedCode1: qxaI6UGv0HLH3h4pQzvgEyxmPs3dkLOySUQ8gJ51qDgtaYfnhuvOepJbMA8X2Bn0gIDGj7CFXcqB5wFzWFSu+is24eFgnEK8dUgzjrtJ02OZf1LEIMNV6bf5vTPD25OmO5TNYTn77XOlKko9GIuoJ1G8wJcVtJ+NSSjbOG5lleqg6Mq1/U5/yACD0S0=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_3343460488d511f18108525400287e28
    ReservedCode2: qxaI6UGv0HLH3h4pQzvgEyxmPs3dkLOySUQ8gJ51qDgtaYfnhuvOepJbMA8X2Bn0gIDGj7CFXcqB5wFzWFSu+is24eFgnEK8dUgzjrtJ02OZf1LEIMNV6bf5vTPD25OmO5TNYTn77XOlKko9GIuoJ1G8wJcVtJ+NSSjbOG5lleqg6Mq1/U5/yACD0S0=
---


# 多人在线卡牌对战游戏 - 后端开发完整提示词

> 本提示词用于 Claude Code，请严格按照以下规范和架构生成完整后端代码。
> 技术栈：Node.js + TypeScript + Express + Socket.IO + PostgreSQL + Redis

---

## 一、项目总览与架构原则

### 1.1 游戏定位
- 回合制多人在线卡牌对战，融合炉石传说式法力水晶机制与三国杀式身份技能系统
- 支持两种对战模式：**1v1 标准对战** 与 **4人身份局（主公/忠臣/反贼/内奸）**

### 1.2 架构原则
| 原则 | 说明 |
|------|------|
| 状态机驱动 | 所有游戏流程由有限状态机管理，禁止 if-else 面条式逻辑 |
| 事件溯源 | 所有对战操作记录为不可变事件日志，支持复盘和断线重连 |
| 服务端权威 | 所有游戏逻辑在服务端计算并校验，客户端仅做表现层渲染 |
| 单一职责 | 卡牌效果、身份技能、回合阶段各自独立模块，通过事件总线解耦 |
| 水平扩展 | 房间服务无状态（Redis 存储），支持多进程部署 |

### 1.3 项目目录结构
```
server/
├── src/
│   ├── index.ts                    # 入口
│   ├── config/                     # 配置
│   │   └── index.ts
│   ├── core/                       # 核心游戏引擎
│   │   ├── GameEngine.ts           # 游戏主引擎（状态机调度）
│   │   ├── GameState.ts            # 全局游戏状态管理
│   │   ├── TurnManager.ts          # 回合管理器
│   │   ├── ManaSystem.ts           # 法力水晶系统
│   │   ├── CombatResolver.ts       # 战斗结算器
│   │   └── WinCondition.ts         # 胜负判定
│   ├── models/                     # 数据模型
│   │   ├── Card.ts                 # 卡牌基类
│   │   ├── MinionCard.ts           # 随从卡牌
│   │   ├── SpellCard.ts            # 法术卡牌
│   │   ├── EquipmentCard.ts        # 装备卡牌
│   │   ├── Player.ts               # 玩家模型
│   │   ├── Board.ts                # 战场模型
│   │   └── Deck.ts                 # 牌库模型
│   ├── identity/                   # 身份系统
│   │   ├── IdentityManager.ts      # 身份管理器
│   │   ├── IdentityBase.ts         # 身份基类
│   │   ├── Lord.ts                 # 主公
│   │   ├── Loyalist.ts             # 忠臣
│   │   ├── Rebel.ts                # 反贼
│   │   └── Spy.ts                  # 内奸
│   ├── effects/                    # 卡牌效果系统
│   │   ├── EffectBase.ts           # 效果基类
│   │   ├── EffectRegistry.ts       # 效果注册表
│   │   ├── DamageEffect.ts         # 伤害效果
│   │   ├── HealEffect.ts           # 治疗效果
│   │   ├── BuffEffect.ts           # 增益效果
│   │   ├── SummonEffect.ts         # 召唤效果
│   │   ├── DrawEffect.ts           # 抽牌效果
│   │   └── TriggerEffect.ts        # 触发式效果
│   ├── triggers/                   # 事件触发器
│   │   ├── TriggerManager.ts       # 触发器管理器
│   │   ├── TurnStartTrigger.ts     # 回合开始
│   │   ├── TurnEndTrigger.ts       # 回合结束
│   │   ├── DeathTrigger.ts         # 死亡触发
│   │   ├── DamageTrigger.ts        # 受伤触发
│   │   └── PlayCardTrigger.ts      # 出牌触发
│   ├── room/                       # 房间与匹配
│   │   ├── RoomManager.ts          # 房间管理器
│   │   ├── Room.ts                 # 房间实体
│   │   ├── Matchmaker.ts           # 匹配器
│   │   └── LobbyManager.ts         # 大厅管理
│   ├── network/                    # 网络层
│   │   ├── SocketServer.ts         # Socket.IO 服务
│   │   ├── Router.ts               # HTTP 路由
│   │   ├── middleware/             # 中间件
│   │   │   ├── auth.ts             # 认证中间件
│   │   │   └── rateLimit.ts        # 限流中间件
│   │   └── handlers/               # 消息处理器
│   │       ├── authHandler.ts      # 登录/注册
│   │       ├── lobbyHandler.ts     # 大厅操作
│   │       ├── roomHandler.ts      # 房间操作
│   │       ├── gameHandler.ts      # 游戏内操作
│   │       └── chatHandler.ts      # 聊天
│   ├── db/                         # 数据库层
│   │   ├── connection.ts           # DB连接管理
│   │   ├── repositories/           # 数据仓库
│   │   │   ├── UserRepository.ts
│   │   │   ├── CardRepository.ts
│   │   │   ├── DeckRepository.ts
│   │   │   ├── MatchRepository.ts
│   │   │   └── LeaderboardRepository.ts
│   │   └── migrations/             # 数据库迁移
│   ├── cache/                      # 缓存层
│   │   └── RedisClient.ts
│   └── utils/                      # 工具函数
│       ├── EventBus.ts             # 事件总线
│       ├── Logger.ts               # 日志
│       ├── Validator.ts            # 输入校验
│       └── ErrorCodes.ts           # 错误码定义
├── tests/                          # 测试
│   ├── unit/
│   ├── integration/
│   └── e2e/
├── package.json
├── tsconfig.json
├── jest.config.js
└── .env.example
```

---

## 二、核心游戏引擎

### 2.1 状态机设计（重中之重）

游戏全程由状态机驱动，禁止散落的条件判断。状态定义如下：

```
LOBBY → MATCHING → READY → IDENTITY_ASSIGN → MULLIGAN → TURN_START → MAIN_PHASE
→ COMBAT_PHASE → TURN_END → [循环至 TURN_START] → GAME_OVER → SETTLEMENT → ROOM_CLOSED
```

> **关键修复**：GAME_OVER 不是终点。对局结束后必须经过 SETTLEMENT（结算）→ ROOM_CLOSED（房间关闭），否则游戏流程卡死无法退出。没有 SETTLEMENT 就没有 ELO 更新、战绩写入、胜者播报，玩家永远困在对局里。

#### 状态转移表

| 当前状态 | 触发事件 | 下一状态 | 条件 | 说明 |
|----------|----------|----------|------|------|
| LOBBY | JOIN_ROOM | MATCHING | 房间人数满足 | |
| MATCHING | ALL_READY | READY | 所有人准备 | |
| READY | IDENTITY_ASSIGNED | MULLIGAN | 身份分配完成（4人局） | 1v1 模式跳过 IDENTITY_ASSIGN，直接 READY→MULLIGAN |
| MULLIGAN | MULLIGAN_DONE | TURN_START | 所有玩家换牌确认 | 需等待全部玩家确认后才转移 |
| TURN_START | AUTO_TRANSITION | MAIN_PHASE | 自动过场（0.5s延迟） | 触发回合开始效果、水晶+1、抽牌 |
| MAIN_PHASE | END_TURN | COMBAT_PHASE | 当前玩家主动结束 | |
| COMBAT_PHASE | COMBAT_DONE | TURN_END | 所有攻击结算完成 | |
| TURN_END | NEXT_PLAYER | TURN_START | 切换至下一位存活玩家 | 4人局跳过已死亡玩家 |
| TURN_END | WIN_CHECK_TRUE | GAME_OVER | 满足任意一方胜利条件 | 立即广播 GAME_OVER 事件 |
| GAME_OVER | SETTLEMENT_TIMEOUT | SETTLEMENT | 3秒展示延迟后自动进入 | 给客户端展示胜负动画的时间 |
| SETTLEMENT | SETTLEMENT_DONE | ROOM_CLOSED | ELO更新+战绩写入完成 | 广播个人结算数据 |
| ROOM_CLOSED | CLEANUP_DONE | LOBBY | 房间资源回收完成 | 玩家回到大厅 |
| ANY | PLAYER_DISCONNECT | WAITING_RECONNECT | 玩家断线 | |
| WAITING_RECONNECT | RECONNECT_OK | (断线前状态) | 60s内重连成功 | 回放 eventLog 重建状态 |
| WAITING_RECONNECT | RECONNECT_TIMEOUT | GAME_OVER | 60s超时 | 1v1对手直接获胜；4人局按身份规则判负 |

#### 实现要求
```typescript
// GameEngine.ts 核心接口
interface IGameState {
  name: GameStateEnum;
  onEnter(context: GameContext): void;
  onExit(context: GameContext): void;
  handleEvent(event: GameEvent, context: GameContext): GameStateEnum;
}

interface GameContext {
  room: Room;
  players: Player[];
  board: Board;
  turn: TurnInfo;
  eventLog: GameEvent[];
  mana: ManaState;
}
```

- 每个状态实现为一个独立类，继承 `IGameState`
- 状态转移通过 `GameEngine.transition(state, event)` 统一管理
- 所有转移记录到 `eventLog`，支持时间旅行调试

### 2.2 回合系统

#### 回合阶段拆分

```
TURN_START（回合开始）
  ├── 触发「回合开始」效果
  ├── 法力水晶 +1（上限10）+ 回满
  ├── 抽牌1张
  └── 自动进入 MAIN_PHASE

MAIN_PHASE（主要阶段）
  ├── 可操作：出随从/用法术/装装备/使用技能
  ├── 随从召唤后进入「召唤失调」状态（本回合不可攻击，除非冲锋）
  └── 玩家主动结束 → COMBAT_PHASE

COMBAT_PHASE（战斗阶段）
  ├── 选择攻击者 → 选择目标
  ├── 攻击结算：攻击力互减，生命归零则死亡
  ├── 触发「受伤」「死亡」相关效果
  └── 攻击完成 → TURN_END

TURN_END（结束阶段）
  ├── 触发「回合结束」效果
  ├── 弃牌至手牌上限（默认10张）
  ├── 检查胜负条件
  └── 切换到下一位玩家
```

#### TurnManager 关键接口
```typescript
interface ITurnManager {
  currentPhase: TurnPhase;
  currentPlayerId: string;
  turnNumber: number;
  priorityOrder: string[];        // 行动顺序
  
  advancePhase(): void;           // 推进到下一阶段
  endTurn(playerId: string): void; // 主动结束回合
  getAvailableActions(playerId: string): ActionType[];
}
```

### 2.3 法力水晶系统（ManaSystem）

```
规则：
- 起始水晶数：先手 1，后手 1（后手第2回合获得幸运币，可额外+1临时水晶）
- 每回合获得 1 颗永久水晶，上限 10
- 每回合开始时，当前水晶数 = 永久水晶数（回满）
- 过载（Overload）：下回合永久水晶 -N（参考炉石萨满机制）
```

```typescript
interface ManaState {
  permanent: number;   // 永久水晶（每回合+1，上限10）
  current: number;     // 当前可用水晶
  overloaded: number;  // 下回合锁定水晶数
  temporary: number;   // 临时额外水晶（如幸运币）
}
```

### 2.4 战斗结算器（CombatResolver）

```typescript
// 攻击结算流程
1. 前置检查：
   - 攻击者是否可攻击（无冻结/无召唤失调）
   - 目标是否合法（敌方随从/英雄）
   - 攻击次数是否耗尽（默认每随从1次/回合）

2. 效果触发链：
   - 「攻击前」触发效果
   - 造成伤害（随从攻击力 - 目标当前生命）
   - 「受伤时」触发效果
   - 「死亡时」触发效果（生命值 <= 0）
   - 「攻击后」触发效果

3. 结算顺序：
   - 同时触发的效果按「先己后敌」「先场上后手牌」顺序入栈
   - 使用栈模型（LIFO）结算触发链
```

---

## 三、卡牌系统

### 3.1 卡牌类型体系

```typescript
enum CardType {
  MINION = 'minion',       // 随从
  SPELL = 'spell',         // 法术
  EQUIPMENT = 'equipment', // 装备
}

interface Card {
  id: string;
  name: string;
  type: CardType;
  cost: number;            // 法力消耗
  rarity: Rarity;
  class: HeroClass | null; // 职业限定，null 为中立
  effects: CardEffect[];   // 卡牌效果列表
  description: string;
}

interface MinionCard extends Card {
  attack: number;          // 攻击力
  health: number;          // 生命值
  tribe: Tribe | null;     // 种族（机械/野兽/龙等）
  keywords: Keyword[];     // 关键词（冲锋/嘲讽/圣盾/亡语等）
}

interface SpellCard extends Card {
  spellType: SpellType;    // 伤害/治疗/增益/召唤/抽牌
}

interface EquipmentCard extends Card {
  durability: number;      // 耐久度
  attack: number;          // 提供攻击力
  onEquip: CardEffect[];   // 装备时效果
  onDestroy: CardEffect[]; // 耐久耗尽时效果
}
```

### 3.2 卡牌效果系统（Effect System）

效果系统采用**组合模式**：每个卡牌效果是独立的可组合单元。

```typescript
abstract class EffectBase {
  abstract type: EffectType;
  abstract resolve(source: Entity, targets: Entity[], context: GameContext): Promise<void>;
  abstract validate(source: Entity, targets: Entity[], context: GameContext): boolean;
}

// 效果类型注册表
enum EffectType {
  DAMAGE,           // 造成伤害
  HEAL,             // 恢复生命
  BUFF_ATTACK,      // 攻击力增益
  BUFF_HEALTH,      // 生命值增益
  SUMMON,           // 召唤随从
  DRAW,             // 抽牌
  DESTROY,          // 消灭
  SILENCE,          // 沉默（移除所有效果）
  FREEZE,           // 冻结
  TRANSFORM,        // 变形
  RETURN_HAND,      // 回手
  DISCARD,          // 弃牌
  STEAL,            // 控制权转移
  COPY,             // 复制
}
```

**关键词（Keyword）**使用装饰器模式附加到随从：
- 冲锋（Charge）：出场即可攻击
- 嘲讽（Taunt）：敌方必须优先攻击
- 圣盾（Divine Shield）：免疫一次伤害
- 亡语（Deathrattle）：死亡时触发效果
- 战吼（Battlecry）：出场时触发效果
- 风怒（Windfury）：每回合可攻击两次
- 潜行（Stealth）：不能被指定为目标，直到造成伤害

### 3.3 效果触发链

```
事件 → TriggerManager → 匹配触发器 → 效果入栈 → 逐一出栈执行 → 可能产生新事件（递归）
```

实现要点：
- 使用显式栈管理触发链，防止无限循环（最大递归深度 30）
- 所有效果执行记录到 `eventLog`
- 支持 `await` 异步效果（如需要玩家选择目标）

---

## 四、身份系统

### 4.1 身份定义

```
4人身份局：
┌──────────┬──────┬──────────┬──────────────────┐
│   身份   │ 人数 │  血量加成 │   胜利条件        │
├──────────┼──────┼──────────┼──────────────────┤
│  主公    │   1  │  +5     │ 消灭所有反贼和内奸 │
│  忠臣    │   1  │  无     │ 保护主公，消灭反贼  │
│  反贼    │   2  │  无     │ 消灭主公           │
│  内奸    │   1  │  无     │ 先灭反贼忠臣后单挑主公│
└──────────┴──────┴──────────┴──────────────────┘
```

### 4.2 身份技能

每个身份拥有独特技能，通过接口注入：

```typescript
interface IdentitySkill {
  name: string;
  description: string;
  type: SkillType;             // PASSIVE（被动）/ ACTIVE（主动）
  cooldown: number;            // 冷却回合数，0 为无冷却
  trigger?: TriggerType;       // 被动技能的触发时机
  execute(context: GameContext, player: Player): Promise<void>;
}

// 主公 - 被动：登场时额外抽2张牌；主动（冷却3回合）：本回合召唤的随从获得+1/+1
// 忠臣 - 被动：主公受伤时可选择替主公承受伤害；主动（冷却4回合）：恢复主公3点生命
// 反贼 - 被动：对主公造成伤害时额外+1；主动（冷却3回合）：指定一名反贼队友，本回合共享目标信息
// 内奸 - 被动：身份始终隐藏，击败角色时抽1张牌；主动（冷却5回合）：本回合视为其他任意身份
```

### 4.3 身份管理流程

```
房间满4人 → IdentityManager.assign() → 
  * 随机分配身份（主公身份公开，其余隐藏）
  * 主公血量上限 +5
  * 注入身份技能到Player实例
  * 广播身份分配结果（仅公开信息）
```

---

## 五、房间与匹配系统

### 5.1 房间生命周期

```
CREATED → WAITING → FULL → STARTING → IN_GAME → FINISHED → CLOSED
```

```typescript
interface Room {
  id: string;
  mode: GameMode;              // MODE_1V1 | MODE_4P_IDENTITY
  players: Map<string, PlayerSlot>;
  maxPlayers: number;
  status: RoomStatus;
  settings: RoomSettings;      // 回合时间限制、观战开关等
  gameEngine: GameEngine | null;
}
```

### 5.2 匹配器（Matchmaker）

```typescript
// 快速匹配算法
1. 玩家进入匹配队列
2. 按 ELO 分段（±200）匹配同模式玩家
3. 等待超时（30s）后放宽 ELO 限制
4. 匹配成功 → 创建房间 → 通知双方
5. 4人局需等到满4人
```

### 5.3 断线重连

```typescript
// 重连流程
1. 检测到 disconnect 事件 → 状态设为 DISCONNECTED
2. 启动重连倒计时（60s）
3. 玩家重新连接 → 回放 eventLog 重建完整状态
4. 超时未重连 → 自动判负，机器人托管（可选）
```

---

## 六、通信协议

### 6.1 Socket.IO 事件定义

#### 客户端 → 服务端

```typescript
enum ClientEvent {
  // 认证
  AUTH_LOGIN = 'auth:login',
  AUTH_REGISTER = 'auth:register',
  
  // 大厅
  LOBBY_JOIN = 'lobby:join',
  LOBBY_LEAVE = 'lobby:leave',
  LOBBY_CHAT = 'lobby:chat',
  
  // 匹配
  MATCH_START = 'match:start',       // 开始匹配
  MATCH_CANCEL = 'match:cancel',     // 取消匹配
  
  // 房间
  ROOM_CREATE = 'room:create',
  ROOM_JOIN = 'room:join',
  ROOM_LEAVE = 'room:leave',
  ROOM_READY = 'room:ready',
  ROOM_KICK = 'room:kick',
  
  // 游戏内
  GAME_MULLIGAN = 'game:mulligan',           // 换牌确认
  GAME_PLAY_CARD = 'game:playCard',          // 出牌
  GAME_ATTACK = 'game:attack',               // 攻击
  GAME_USE_SKILL = 'game:useSkill',          // 使用技能
  GAME_END_TURN = 'game:endTurn',            // 结束回合
  GAME_SURRENDER = 'game:surrender',         // 投降
  GAME_EMOTE = 'game:emote',                 // 表情
}
```

#### 服务端 → 客户端

```typescript
enum ServerEvent {
  // 通用
  ERROR = 'error',
  
  // 认证
  AUTH_SUCCESS = 'auth:success',
  
  // 匹配
  MATCH_FOUND = 'match:found',
  MATCH_QUEUE_STATUS = 'match:queueStatus',
  
  // 房间
  ROOM_UPDATE = 'room:update',          // 房间状态变更
  ROOM_PLAYER_JOIN = 'room:playerJoin',
  ROOM_PLAYER_LEAVE = 'room:playerLeave',
  
  // 游戏状态同步
  GAME_STATE = 'game:state',            // 全量状态同步
  GAME_START = 'game:start',
  GAME_IDENTITY = 'game:identity',      // 身份分配（仅本人）
  GAME_TURN_START = 'game:turnStart',
  GAME_TURN_END = 'game:turnEnd',
  GAME_CARD_PLAYED = 'game:cardPlayed',
  GAME_ATTACK_RESULT = 'game:attackResult',
  GAME_EFFECT_TRIGGERED = 'game:effectTriggered',
  GAME_OVER = 'game:over',
  
  // 重连
  GAME_RECONNECT_STATE = 'game:reconnectState',  // 完整状态回放
}
```

### 6.2 HTTP API

```typescript
// RESTful 接口（用于非实时操作）
GET    /api/cards              # 获取所有卡牌
GET    /api/cards/:id          # 获取单张卡牌
GET    /api/decks              # 我的牌组列表
POST   /api/decks              # 创建牌组
PUT    /api/decks/:id          # 编辑牌组
DELETE /api/decks/:id          # 删除牌组
GET    /api/matches/history    # 对战历史
GET    /api/matches/:id        # 对战详情（含回放）
GET    /api/leaderboard        # 天梯排行
GET    /api/users/:id/stats    # 玩家统计
```

---

## 七、数据库设计

### 7.1 PostgreSQL 核心表

```sql
-- 用户表
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(32) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    elo_1v1 INT DEFAULT 1000,
    elo_4p INT DEFAULT 1000,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 卡牌表
CREATE TABLE cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(64) NOT NULL,
    type VARCHAR(16) NOT NULL,          -- minion/spell/equipment
    cost INT NOT NULL,
    rarity VARCHAR(16) NOT NULL,        -- common/rare/epic/legendary
    class VARCHAR(32),                   -- 职业，null为中立
    attack INT,
    health INT,
    durability INT,
    effects JSONB NOT NULL DEFAULT '[]',
    keywords JSONB DEFAULT '[]',
    description TEXT,
    version INT DEFAULT 1
);

-- 牌组表
CREATE TABLE decks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    name VARCHAR(64) NOT NULL,
    class VARCHAR(32) NOT NULL,
    cards JSONB NOT NULL,               -- [{card_id, count}]
    is_active BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 对战记录表
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mode VARCHAR(8) NOT NULL,           -- 1v1 / 4p
    status VARCHAR(16) NOT NULL,
    players JSONB NOT NULL,             -- [{user_id, identity, final_hp, winner}]
    event_log JSONB,                    -- 完整事件日志（用于回放）
    duration_seconds INT,
    started_at TIMESTAMP,
    finished_at TIMESTAMP
);

-- 天梯排行物化视图（定时刷新）
CREATE MATERIALIZED VIEW leaderboard_1v1 AS
    SELECT id, username, elo_1v1,
           RANK() OVER (ORDER BY elo_1v1 DESC) as rank
    FROM users WHERE elo_1v1 > 0;
```

### 7.2 Redis 数据结构

| Key | 类型 | 说明 |
|-----|------|------|
| `room:{roomId}` | Hash | 房间实时状态 |
| `match:queue:1v1` | Sorted Set | 1v1匹配队列（score=elo） |
| `match:queue:4p` | List | 4人局匹配队列 |
| `game:{gameId}:state` | String(JSON) | 游戏实时状态快照 |
| `game:{gameId}:eventLog` | List | 事件日志（用于重连回放） |
| `session:{userId}` | String(JSON) | 用户会话信息 |
| `lock:room:{roomId}` | String | 房间操作分布式锁 |
| `rate:{userId}:{action}` | String | 限流计数器 |

---

## 八、1v1 vs 4人局差异处理 — 多人对局完整机制

> 4人局不是「4个人轮流1v1」，而是有身份阵营、信息不对称、连锁交互的多人博弈。以下逐层展开。

### 8.1 模式差异总表

| 维度 | 1v1 标准对战 | 4人身份局 |
|------|-------------|-----------|
| 玩家数 | 2 | 4 |
| 身份系统 | 无 | 主公 / 忠臣 / 反贼×2 / 内奸（身份隐藏，主公公开） |
| 初始血量 | 30 | 主公 35（+5上限），其余 30 |
| 回合顺序 | A→B→A→B | 主公→忠臣→反贼1→反贼2→内奸，死亡玩家跳过 |
| 胜负判定 | 对手英雄血量归零 | 阵营判定（见表 8.2） |
| 手牌上限 | 10 | 10 |
| 场上随从上限 | 7 | 5 |
| 投降 | 直接判负 | 仅主公可投降（忠臣/反贼/内奸投降视为逃跑，扣分加倍） |
| 回合超时 | 60s | 45s（保护多人对局节奏） |
| 信息可见性 | 完全对称 | 不对称（见 8.3） |
| 断线判负 | 对手直接获胜 | 按身份规则：主公断线→反贼阵营胜；其他→扣除ELO，AI托管 |

### 8.2 4人局完整回合流转（多人对局核心）

4人局回合不是简单的 A→B→C→D 轮转，而是带**死亡跳过 + 阵营博弈 + 回合间中断**的复杂流转：

```
┌──────────────────────────────────────────────────────────────────┐
│                    4人局完整回合流转示意                          │
├──────────────────────────────────────────────────────────────────┤
│                                                                  │
│  主公回合                                                        │
│    ├── TURN_START：+1水晶回满、抽牌、回合开始效果                  │
│    ├── MAIN_PHASE：出牌/技能/装备，可攻击任意目标                   │
│    ├── COMBAT_PHASE：攻击结算                                      │
│    └── TURN_END：判断胜负 → 如无胜负，TurnManager.nextPlayer()      │
│                                                                  │
│  忠臣回合（主公存活则继续，主公死亡 → 反贼立即获胜）                 │
│    └── 同上流程，跳过已死亡玩家（反贼1/反贼2/内奸任一存活则继续）     │
│                                                                  │
│  反贼1 回合                                                       │
│    └── 同上                                                        │
│                                                                  │
│  反贼2 回合（反贼1死亡则跳过）                                      │
│    └── 同上                                                        │
│                                                                  │
│  内奸回合（忠臣+反贼全部死亡 → 进入主公vs内奸1v1阶段）              │
│    └── 同上                                                        │
│                                                                  │
│  → 循环回 主公回合（跳过已死亡玩家）                                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

#### TurnManager 多人回合核心逻辑

```typescript
class TurnManager {
  private turnOrder: string[];        // 固定顺序 ['zhuGong','zhongChen','fanZei1','fanZei2','neiJian']
  private currentIndex: number = 0;
  private alivePlayers: Set<string>;  // 动态追踪存活玩家

  /**
   * 切换到下一位存活玩家。跳过已死亡的玩家，直到找到存活者。
   * 如果只剩一个阵营的玩家存活 → 返回 null，由 WinCondition 接管。
   */
  nextPlayer(): string | null {
    const maxIterations = this.turnOrder.length;
    for (let i = 0; i < maxIterations; i++) {
      this.currentIndex = (this.currentIndex + 1) % this.turnOrder.length;
      const playerId = this.turnOrder[this.currentIndex];
      if (this.alivePlayers.has(playerId)) {
        return playerId;
      }
    }
    return null; // 无可下一位玩家 → 触发 WIN_CHECK_TRUE
  }

  /**
   * 标记玩家死亡，从存活集合中移除。
   * 死亡瞬间立即检查胜负条件（如主公死亡 → 反贼阵营胜）。
   */
  markDead(playerId: string): WinResult | null {
    this.alivePlayers.delete(playerId);
    return this.winCondition.check(); // 立即触发胜负判定
  }

  /**
   * 检查是否只剩一个阵营存活（内奸特殊处理）。
   */
  getSurvivingFactions(): Faction[] {
    const factions = new Set<Faction>();
    for (const pid of this.alivePlayers) {
      factions.add(this.playerFactions.get(pid)!);
    }
    return [...factions];
  }
}
```

### 8.3 信息不对称机制（4人局核心特征）

4人局的核心张力来自「不知道谁是队友」。服务端必须严格控制信息分发：

| 信息类型 | 可见范围 | 实现方式 |
|---------|---------|---------|
| 自己的身份 | 仅本人 | `GAME_IDENTITY` 事件仅发给本人 socket |
| 主公身份 | 全公开 | 游戏开始时广播 |
| 其他玩家身份 | 隐藏 | 死亡时揭示：`GAME_IDENTITY_REVEALED` 事件广播已死亡玩家的真实身份 |
| 手牌内容 | 仅本人 | 全量状态同步时按 playerId 过滤手牌 |
| 场上随从 | 全公开 | board 状态全量广播 |
| 装备区 | 全公开 | 装备卡进入公开区域 |
| 英雄血量 | 全公开 | 实时同步 |
| 法力水晶 | 全公开 | 实时同步 |
| 出牌动画 | 全公开 | 对手打出牌时广播卡牌名称与费用（不广播手牌位置） |

```typescript
// 服务端为每个玩家生成差异化状态快照
class StateFilter {
  /**
   * 对同一游戏状态，为不同玩家生成不同的 ViewModel。
   * 核心原则：只发送该玩家有权看到的信息。
   */
  static filterForPlayer(fullState: GameState, playerId: string): PlayerViewModel {
    return {
      // 公开信息：全量发送
      board: fullState.board,
      heroes: fullState.heroes, // 血量公开
      turnInfo: fullState.turn,
      
      // 私有信息：仅本玩家
      hand: fullState.hands[playerId],           // 只发自己的手牌
      identity: fullState.identities[playerId],   // 只发自己的身份
      deckCount: fullState.decks[playerId].length, // 只发自己牌库剩余数
      
      // 隐藏信息：只发公开的
      revealedIdentities: this.getRevealedIdentities(fullState), // 已死亡玩家的身份
    };
  }
}
```

### 8.4 身份揭示时机与广播

```typescript
// 身份揭示只在以下时机发生：
// 1. 玩家死亡 → 广播其真实身份给所有人
// 2. 游戏结束 → 揭示所有未公开身份（结算界面展示）

class IdentityRevealManager {
  onPlayerDeath(playerId: string, room: Room): void {
    const identity = room.getIdentity(playerId);
    // 广播揭示事件给房间内所有玩家
    room.broadcast('game:identityRevealed', {
      playerId,
      identity,          // 主公/忠臣/反贼/内奸
      killedBy: this.getKillerId(playerId),
    });
    room.markIdentityRevealed(playerId);
  }

  onGameEnd(room: Room): RevealedState[] {
    // 结算时揭示所有未公开身份
    return room.getUnrevealedIdentities().map(p => ({
      playerId: p.id,
      identity: p.identity,
      wasWinner: this.isWinner(p, room.winResult),
    }));
  }
}
```

### 8.5 多态设计

```typescript
// 通过策略模式处理模式差异
interface IGameModeStrategy {
  validateAction(action: GameAction, context: GameContext): boolean;
  checkWinCondition(context: GameContext): WinResult | null;
  getTurnOrder(players: Player[]): string[];
  getMaxBoardSlots(): number;
  getInitialHealth(identity?: Identity): number;
  getTurnTimeout(): number; // 1v1: 60s, 4p: 45s
  onPlayerDeath(playerId: string, context: GameContext): void; // 4p 需揭示身份
}

class DuelModeStrategy implements IGameModeStrategy { /* 1v1实现 */ }
class IdentityModeStrategy implements IGameModeStrategy { /* 4人身份局实现 */ }
```

---

## 九、对局结束与结算流程（解决"卡住"问题的关键）

> 这是原版提示词最大的缺失。GAME_OVER 之后必须有一条完整的结算管道，否则：
> - 玩家看不到结算界面，困在对局中无法退出
> - ELO 分数不更新，天梯永远不变
> - 战绩不写入数据库，对战历史为空
> - 房间资源不释放，内存泄漏

### 9.1 完整结算管道

```
GAME_OVER 触发
     │
     ├── 1. 广播 GAME_OVER 事件（500ms内）
     │       ├── winnerCamp / winnerPlayerId
     │       ├── 各玩家身份揭示（4人局）
     │       └── 击杀统计（谁杀了谁）
     │
     ├── 2. 等待展示动画（3s SETTLEMENT_TIMEOUT）
     │       └── 客户端播放胜负动画期间，服务端并行计算结算数据
     │
     ├── 3. 进入 SETTLEMENT 状态 → 计算结算数据
     │       ├── ELO 变化量（K因子 × 预期胜率差）
     │       ├── 各玩家统计（造成伤害量、治疗量、随从击杀数、回合数）
     │       ├── MVP 判定（综合贡献值最高者）
     │       └── 奖励计算（金币/经验/卡包，如有）
     │
     ├── 4. 写入持久化存储
     │       ├── PostgreSQL matches 表（含完整 eventLog）
     │       ├── PostgreSQL users 表（更新 ELO）
     │       └── Redis 清理游戏状态缓存
     │
     ├── 5. 广播 SETTLEMENT_DATA 事件（每人一份个人结算）
     │       └── 包含 ELO 变化、统计、MVP、奖励
     │
     └── 6. 触发 SETTLEMENT_DONE → ROOM_CLOSED
             ├── 移除房间 Socket.IO 命名空间
             ├── 清理 Redis room key
             └── 广播 room:closed → 所有玩家返回大厅
```

### 9.2 ELO 结算算法

```typescript
class EloCalculator {
  private readonly K_FACTOR = 32; // 标准 K 因子

  /**
   * 4人局 ELO 不同于1v1——需要按阵营分别计算。
   *
   * 1v1：标准 ELO 公式
   *   ΔR = K × (实际得分 - 预期得分)
   *   胜者得分=1，败者得分=0
   *
   * 4人局：阵营集体结算
   *   胜方阵营每个玩家：ΔR = K × (1 - 预期阵营胜率)
   *   败方阵营每个玩家：ΔR = K × (0 - 预期阵营胜率)
   *   阵营预期胜率 = 1 / (胜方平均ELO + 败方平均ELO) 的逻辑函数
   */
  calculate1v1(winnerElo: number, loserElo: number): { winnerDelta: number; loserDelta: number } {
    const expectedWin = 1 / (1 + Math.pow(10, (loserElo - winnerElo) / 400));
    const winnerDelta = Math.round(this.K_FACTOR * (1 - expectedWin));
    const loserDelta = Math.round(this.K_FACTOR * (0 - expectedWin));
    return { winnerDelta, loserDelta };
  }

  calculate4P(
    winnerCamp: { playerId: string; elo: number }[],
    loserCamp: { playerId: string; elo: number }[]
  ): Map<string, number> {
    const winnerAvgElo = winnerCamp.reduce((s, p) => s + p.elo, 0) / winnerCamp.length;
    const loserAvgElo = loserCamp.reduce((s, p) => s + p.elo, 0) / loserCamp.length;
    const expectedWin = 1 / (1 + Math.pow(10, (loserAvgElo - winnerAvgElo) / 400));

    const deltas = new Map<string, number>();
    for (const p of winnerCamp) {
      deltas.set(p.playerId, Math.round(this.K_FACTOR * (1 - expectedWin)));
    }
    for (const p of loserCamp) {
      deltas.set(p.playerId, Math.round(this.K_FACTOR * (0 - expectedWin)));
    }
    return deltas;
  }
}
```

### 9.3 GameEngine 状态转移实现（GAME_OVER→SETTLEMENT 关键代码）

```typescript
// GameEngine.ts 中 GAME_OVER 状态的 onEnter 实现
class GameOverState implements IGameState {
  name = GameStateEnum.GAME_OVER;

  async onEnter(context: GameContext): Promise<void> {
    const winResult = context.winCondition.check(context);

    // 1. 广播 GAME_OVER 事件（立即）
    context.room.broadcast('game:over', {
      winnerCamp: winResult.winnerCamp,
      reason: winResult.reason,           // 'hero_death' | 'surrender' | 'disconnect_timeout'
      finalState: context.board.summary(),
      identities: context.getRevealedIdentities(), // 4人局揭示全部身份
    });

    // 2. 启动 3 秒定时器 → SETTLEMENT（不阻塞，异步并行预计算结算数据）
    context.settlementData = await this.preCalculateSettlement(context, winResult);

    setTimeout(() => {
      context.engine.transition(GameStateEnum.SETTLEMENT, GameEvent.SETTLEMENT_TIMEOUT);
    }, 3000);
  }

  private async preCalculateSettlement(context: GameContext, winResult: WinResult): Promise<SettlementData> {
    const eloCalc = new EloCalculator();
    const eloDeltas = context.mode === '1v1'
      ? eloCalc.calculate1v1(/* ... */)
      : eloCalc.calculate4P(/* ... */);

    return {
      eloDeltas,
      playerStats: this.calculatePlayerStats(context),
      mvp: this.determineMVP(context),
      duration: Date.now() - context.startTime,
    };
  }

  onExit(context: GameContext): void { /* 清理游戏内临时资源 */ }
}

class SettlementState implements IGameState {
  name = GameStateEnum.SETTLEMENT;

  async onEnter(context: GameContext): Promise<void> {
    const data = context.settlementData!;

    // 1. 写入数据库
    await MatchRepository.create({
      mode: context.mode,
      status: 'finished',
      players: context.players.map(p => ({
        userId: p.userId,
        identity: p.identity,
        finalHp: p.hero.currentHp,
        winner: data.winResult.isWinner(p.playerId),
        eloDelta: data.eloDeltas.get(p.playerId),
      })),
      eventLog: context.eventLog,
      duration: data.duration,
      mvpPlayerId: data.mvp.playerId,
      startedAt: context.startTime,
      finishedAt: new Date(),
    });

    // 2. 更新每个玩家的 ELO
    for (const [playerId, delta] of data.eloDeltas) {
      await UserRepository.updateElo(playerId, context.mode, delta);
    }

    // 3. 向每个玩家发送个人结算数据
    for (const player of context.players) {
      player.socket.emit('game:settlement', {
        eloChange: data.eloDeltas.get(player.id),
        stats: data.playerStats[player.id],
        mvp: data.mvp,
        isWinner: data.winResult.isWinner(player.id),
        reward: data.rewards[player.id],
      });
    }

    // 4. 结算完成 → 关闭房间
    context.engine.transition(GameStateEnum.ROOM_CLOSED, GameEvent.SETTLEMENT_DONE);
  }
}

class RoomClosedState implements IGameState {
  name = GameStateEnum.ROOM_CLOSED;

  async onEnter(context: GameContext): Promise<void> {
    // 广播关闭事件
    context.room.broadcast('room:closed', {
      roomId: context.room.id,
      message: '对局已结束，房间即将关闭',
    });

    // 清理 Socket.IO 命名空间
    context.socketServer.removeNamespace(`/room/${context.room.id}`);

    // 清理 Redis
    await Promise.all([
      context.redis.del(`room:${context.room.id}`),
      context.redis.del(`game:${context.gameId}:state`),
      context.redis.del(`game:${context.gameId}:eventLog`),
    ]);

    // 玩家回到大厅
    context.engine.transition(GameStateEnum.LOBBY, GameEvent.CLEANUP_DONE);
  }
}
```

### 9.4 结算事件协议

```typescript
// game:over（广播，所有人相同）
interface GameOverEvent {
  winnerCamp: 'loyalist' | 'rebel' | 'renegade' | 'playerA' | 'playerB';
  reason: 'hero_death' | 'surrender' | 'disconnect_timeout';
  finalState: BoardSummary;
  identities: RevealedIdentity[]; // 4人局全部身份
  duration: number;               // 对局时长（秒）
}

// game:settlement（单播，每人不同）
interface SettlementEvent {
  eloChange: number;              // ELO 变化值（可为负数）
  newElo: number;                 // 更新后的 ELO
  stats: PlayerMatchStats;
  mvp: { playerId: string; score: number; reason: string };
  isWinner: boolean;
  reward: { gold: number; exp: number };
}

interface PlayerMatchStats {
  damageDealt: number;            // 造成总伤害
  damageTaken: number;            // 承受总伤害
  healingDone: number;            // 治疗量
  minionsKilled: number;          // 击杀随从数
  minionsPlayed: number;          // 召唤随从数
  spellsCast: number;             // 施放法术数
  heroPowerUsed: number;          // 英雄技能使用次数
  cardsPlayed: number;            // 总出牌数
  turnsTaken: number;             // 回合数
}
```

### 9.5 异常流程容错

| 异常场景 | 处理策略 |
|---------|---------|
| 结算过程中某玩家断线 | 不阻塞结算管道，异步推送结算数据（客户端下次登录从 matches 表拉取） |
| 数据库写入失败 | 结算数据存入 Redis 队列 `settlement:retry:{gameId}`，后台 worker 重试（最多 3 次） |
| ELO 计算异常 | 兜底：胜者 +10 / 败者 -10 |
| 结算超时（30s） | 强制进入 ROOM_CLOSED，记录异常日志 |

---

## 十、安全性要求

### 10.1 防作弊机制
- **服务端权威校验**：所有操作必须通过服务端验证，不信任客户端任何数据
- **操作合法性校验**：每次出牌/攻击/使用技能前，校验法力、冷却、目标合法性
- **时序校验**：校验操作是否符合当前阶段和回合
- **频率限制**：同一用户每秒最多 10 次操作请求
- **异常检测**：同一IP频繁创建销毁房间 → 触发风控

### 10.2 认证与授权
- JWT Token 认证，过期时间 24h
- WebSocket 连接时验证 token
- 房间操作验证是否为房间成员
- 游戏操作验证是否为当前回合玩家

---

## 十一、错误处理规范

```typescript
// 统一错误码体系
enum ErrorCode {
  // 认证 1xxx
  AUTH_INVALID_TOKEN = 1001,
  AUTH_EXPIRED_TOKEN = 1002,
  AUTH_USERNAME_TAKEN = 1003,
  
  // 房间 2xxx
  ROOM_NOT_FOUND = 2001,
  ROOM_FULL = 2002,
  ROOM_NOT_OWNER = 2003,
  
  // 游戏 3xxx
  GAME_NOT_YOUR_TURN = 3001,
  GAME_INSUFFICIENT_MANA = 3002,
  GAME_INVALID_TARGET = 3003,
  GAME_CARD_NOT_IN_HAND = 3004,
  GAME_MINION_CANT_ATTACK = 3005,
  GAME_SKILL_ON_COOLDOWN = 3006,
  GAME_INVALID_PHASE = 3007,
  
  // 系统 9xxx
  SYSTEM_INTERNAL_ERROR = 9001,
  SYSTEM_RATE_LIMITED = 9002,
}

class GameError extends Error {
  constructor(
    public code: ErrorCode,
    public message: string,
    public httpStatus: number = 400
  ) {
    super(message);
  }
}
```

所有错误统一通过 `SocketServer.emitError(socket, error)` 发送，格式：
```json
{
  "code": 3002,
  "message": "法力值不足",
  "details": { "required": 5, "available": 3 }
}
```

---

## 十二、测试策略

### 12.1 测试金字塔

```
        / E2E: 完整对局流程（5%）
       /  Integration: 模块间交互测试（15%）
      /   Unit: 核心逻辑单元测试（80%）
```

### 12.2 必测核心逻辑（优先级最高）

| 测试对象 | 测试内容 |
|---------|---------|
| GameEngine 状态机 | 所有状态转移路径，包括异常路径 |
| CombatResolver | 攻击-受伤-死亡完整链，关键词交互 |
| EffectResolver | 所有效果类型的分支逻辑 |
| WinCondition | 1v1/4人局每种身份胜负判定 |
| TurnManager | 回合阶段推进、玩家切换 |
| ManaSystem | 水晶增长、消耗、过载、上限 |
| IdentityManager | 身份分配随机性、技能冷却 |
| CardValidator | 出牌合法性校验全场景 |
| SocketHandler | 断线重连状态回放一致性 |

### 11.3 模拟测试工具

```typescript
// 提供一套测试辅助工具
class GameSimulator {
  // 快速创建对局并推进到指定状态
  static async createGameAtPhase(
    mode: GameMode,
    phase: TurnPhase,
    setup?: Partial<GameSetup>
  ): Promise<GameContext>;
  
  // 回放事件日志验证状态一致性
  static async replayAndVerify(eventLog: GameEvent[]): Promise<boolean>;
  
  // 模拟N个AI玩家自动对局（压力测试）
  static async runAIGame(mode: GameMode): Promise<MatchResult>;
}
```

---

## 十三、可扩展性设计

### 13.1 卡牌热加载
- 卡牌数据存储在数据库，服务启动时加载到内存
- 提供 `POST /api/admin/cards/reload` 管理接口热更新卡牌池
- 卡牌版本号机制，新版本不影响进行中的对局

### 13.2 新效果扩展
- 只需实现 `EffectBase` 并在 `EffectRegistry` 注册
- 无需修改现有代码，符合开闭原则
- 效果可组合（一张卡可携带多个独立效果）

### 12.3 新身份扩展
- 实现 `IdentityBase` + 定义技能即可
- 身份配置存储在数据库，支持动态调整

### 13.4 性能优化预留
- 关键路径（战斗结算、效果触发链）使用对象池减少 GC
- Redis Pub/Sub 支持多进程房间服务水平扩展
- 事件日志异步批量写入 PostgreSQL

---

## 十四、开发顺序（Phase Plan）

| 阶段 | 内容 | 产出物 |
|------|------|--------|
| Phase 1 | 项目骨架、数据模型、DB迁移、卡牌系统 | 可运行的 Express + DB |
| Phase 2 | 游戏引擎核心（状态机、回合、法力、战斗） | 1v1 单人本地可模拟 |
| Phase 3 | Socket.IO 通信层、房间匹配、大厅 | 可创建房间、匹配对战 |
| Phase 4 | 1v1 完整对局流程 | 两人可在线对战 |
| Phase 5 | 身份系统、4人局 | 4人身份局可玩 |
| Phase 6 | 断线重连、观战、回放 | 完整体验闭环 |
| Phase 7 | 天梯、战绩、卡牌收集 | 长期留存系统 |

---

## 十五、输出要求

请按照以下顺序生成代码：

1. **类型定义**：先输出所有 `interfaces.ts` / `types.ts` / `enums.ts`
2. **核心引擎**：GameEngine → TurnManager → ManaSystem → CombatResolver → WinCondition
3. **卡牌系统**：Card 模型 → Effect 系统 → 20张示例卡牌（含随从/法术/装备，覆盖所有关键词）
4. **身份系统**：IdentityBase → 四个身份实现 → IdentityManager
5. **网络层**：SocketServer → 所有 Handler → HTTP Router
6. **数据层**：DB 迁移脚本 → Repository 实现 → Redis 客户端
7. **房间匹配**：Room → RoomManager → Matchmaker
8. **测试**：核心逻辑单元测试 → 集成测试 → 模拟对局脚本
9. **配置文件**：.env.example / docker-compose.yml / package.json / tsconfig.json

每个模块生成后附带一行注释说明该模块的职责。所有代码使用 TypeScript 严格模式。
*（内容由AI生成，仅供参考）*
*（内容由AI生成，仅供参考）*
