---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_bb5e24f7891a11f1a68c525400826444
    ReservedCode1: h4HdY0dJzxr5R4FRw5t0AdW5mikFcwZQe42x2hGX8gVIw+xfLxVpKHYyZjEJKPEa1iYJxkH/PNDTozCFVZ3BPzh8N08qbCkRPFkikf8IQ0KozoIBw85yIwmMvtL7AeXyf2YaGx9qj50QdzqUzTQtzhmR/AUQpktMBdD58/4rh2o54bpiENKCMOtBx3Q=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_bb5e24f7891a11f1a68c525400826444
    ReservedCode2: h4HdY0dJzxr5R4FRw5t0AdW5mikFcwZQe42x2hGX8gVIw+xfLxVpKHYyZjEJKPEa1iYJxkH/PNDTozCFVZ3BPzh8N08qbCkRPFkikf8IQ0KozoIBw85yIwmMvtL7AeXyf2YaGx9qj50QdzqUzTQtzhmR/AUQpktMBdD58/4rh2o54bpiENKCMOtBx3Q=
---

# 02-Scene-StateMachine 提示词

## 任务目标

实现校园杀的完整场景状态机，管理从启动到游戏结束的所有场景流转、过渡动画、数据传递和状态持久化。

## 输出要求

### 1. 场景枚举与状态定义

在 `Assets\_Project\Scripts\Core\SceneState.cs` 定义：

```
public enum SceneState
{
    Bootstrap,      // 启动初始化
    MainMenu,       // 主菜单
    HeroSelect,     // 英雄选择（单人或房主）
    WaitingRoom,    // 等待房间（联机）
    BattleStart,    // 战斗开场动画
    BattleRound,    // 战斗回合进行中
    BattleResult,   // 战斗结算
    Replay,         // 回放
}
```

### 2. 状态机核心 SceneStateMachine.cs

- 使用有限状态机（FSM）模式
- 每个状态定义 Enter / Update / Exit 三个生命周期
- 状态切换支持过渡动画（淡入淡出 + 遮罩）
- 状态间数据传递通过 SceneContext 对象
- 支持条件守卫（Guard）——如未选英雄不能进战斗

### 3. 场景上下文 SceneContext.cs

```
public class SceneContext
{
    public List<string> SelectedHeroIds;  // 已选英雄
    public string RoomId;                 // 联机房间号
    public int PlayerCount;               // 玩家数量
    public GameMode Mode;                 // 单机/联机
    public Dictionary<string, object> CustomData;
}
```

### 4. 场景过渡管理器 TransitionManager.cs

- 屏幕遮罩淡入淡出（2秒过渡）
- 加载进度条显示
- 场景异步加载（Addressables 或场景名加载）
- 加载完成回调通知状态机

### 5. 场景入口脚本

每个场景创建对应的入口 MonoBehaviour，在 Awake 中向状态机注册：

| 文件 | 对应状态 |
|------|----------|
| `BootstrapEntry.cs` | Bootstrap |
| `MainMenuEntry.cs` | MainMenu |
| `HeroSelectEntry.cs` | HeroSelect |
| `WaitingRoomEntry.cs` | WaitingRoom |
| `BattleSceneEntry.cs` | BattleStart / BattleRound |
| `ResultSceneEntry.cs` | BattleResult |

### 6. 状态转换表

| 当前状态 | 可转换到 | 触发条件 |
|----------|----------|----------|
| Bootstrap | MainMenu | 资源加载完成 |
| MainMenu | HeroSelect | 点击"开始游戏" |
| MainMenu | WaitingRoom | 加入房间 |
| HeroSelect | WaitingRoom | 房主确认英雄 |
| HeroSelect | BattleStart | 单机模式确认 |
| WaitingRoom | BattleStart | 所有玩家就绪 |
| BattleStart | BattleRound | 开场动画结束 |
| BattleRound | BattleResult | 胜负判定 |
| BattleResult | MainMenu | 点击"返回" |

## 禁止行为

- 不要使用 Unity 的 SceneManager.LoadScene 直接加载（必须走状态机）
- 不要在过渡期间接受用户输入
- 不要跨状态直接访问其他状态的 UI 组件

## 验收标准

- 从主菜单 → 选英雄 → 战斗 → 结算 → 返回 完整链路无报错
- 过渡动画平滑无闪烁
- 按返回键能回到上一个合法状态
*（内容由AI生成，仅供参考）*
