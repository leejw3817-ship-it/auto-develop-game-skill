---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_bc87c5e2891a11f1a68c525400826444
    ReservedCode1: xRvU+WQIqnARbaCbwG70pxwOBo6GWQGKGdycK4kSBRW7Rjs7t5Pk5HIYXlMiX03k8P8kwvUSz8pS/9BFEhGJy56BWELtcW/fFb/gp03slBVtg4q/vmt4S+KrH9Fc4IyNu9/CxY4eDob/AB3L/JFk/+5inf7CR5u3lhjYH9SfQDmT69aELdcQHi03Y4c=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_bc87c5e2891a11f1a68c525400826444
    ReservedCode2: xRvU+WQIqnARbaCbwG70pxwOBo6GWQGKGdycK4kSBRW7Rjs7t5Pk5HIYXlMiX03k8P8kwvUSz8pS/9BFEhGJy56BWELtcW/fFb/gp03slBVtg4q/vmt4S+KrH9Fc4IyNu9/CxY4eDob/AB3L/JFk/+5inf7CR5u3lhjYH9SfQDmT69aELdcQHi03Y4c=
---

# 03-Card-Game-Core 提示词

## 任务目标

实现校园杀卡牌对战游戏的核心逻辑层，包含卡牌数据结构、牌堆管理、回合制战斗系统、技能/效果结算引擎。逻辑层完全与 UI 解耦，通过事件驱动的方式通知 UI 层。

## 输出要求

### 1. 数据模型层

#### CardData.cs — 卡牌数据定义
```
public class CardData
{
    public string Id;              // 唯一ID 如 "card_001"
    public string Name;            // 名称 如 "学霸的凝视"
    public CardType Type;          // 攻击/防御/技能/道具
    public int Cost;               // 消耗（行动点/法力）
    public int Attack;             // 攻击力
    public int Defense;            // 防御力
    public int Health;             // 生命值（作为单位时）
    public string Description;     // 效果描述文本
    public List<EffectData> Effects; // 触发效果列表
    public string FairyGUIPkg;     // FairyGUI 包名
    public string FairyGUIComp;    // FairyGUI 组件名
}

public enum CardType { Attack, Defense, Skill, Item }
```

#### HeroData.cs — 英雄数据
```
public class HeroData
{
    public string Id;
    public string Name;            // "班主任"、"学委"、"体育委员"
    public int MaxHealth;
    public int MaxMana;
    public string HeroAbilityId;   // 英雄专属技能ID
    public string FairyGUIComp;    // HeroSelect 中组件名
}
```

#### EffectData.cs — 效果数据
```
public class EffectData
{
    public EffectType Type;        // 伤害/治疗/抽牌/弃牌/buff/debuff/召唤
    public int Value;
    public int Duration;           // 持续回合数（0=即时）
    public TargetType Target;      // 自身/敌方/全体/随机
}
```

### 2. 游戏状态管理 GameManager.cs

```
public class GameManager : MonoBehaviour
{
    public GameState State { get; private set; }
    
    public void StartGame(List<HeroData> p1Heroes, List<HeroData> p2Heroes);
    public void StartTurn();
    public void EndTurn();
    public void PlayCard(string cardId, string targetHeroId);
    public void UseHeroAbility(string heroId);
    public void ResolveBattle();
}
```

### 3. 回合制系统

#### TurnManager.cs
- 回合计数（Round 1/2/3...）
- 回合阶段：抽牌阶段 → 行动阶段 → 结束阶段
- 行动点系统（每回合恢复 N 点，出牌消耗行动点）
- 回合超时自动跳过（联机模式 60 秒，单机无限制）

### 4. 牌堆系统 CardDeckManager.cs

- 牌库（Deck）：30 张卡牌
- 手牌（Hand）：最多 10 张，每回合抽到 5 张
- 弃牌堆（Discard）：使用后进入
- 消耗堆（Exhaust）：永久移除
- 抽牌逻辑：牌库空时洗入弃牌堆

### 5. 效果结算引擎 EffectResolver.cs

按优先级结算效果链：即时伤害 → 治疗 → buff → debuff → 召唤 → 抽牌

```
public class EffectResolver
{
    public Queue<EffectData> PendingEffects;
    public void EnqueueEffect(EffectData effect, string sourceId, string targetId);
    public IEnumerator ResolveAll();
}
```

### 6. 数据配置

创建 `Assets\_Project\Resources\Data\cards.json` — 至少包含 30 张校园主题卡牌：
- "考试突袭"（攻击）
- "逃课被抓"（debuff）
- "学生会庇护"（防御）
- "作弊被抓"（扣血）
- "奖学金"（回血）
- "转学警告"（高伤害）
- ...更多

创建 `Assets\_Project\Resources\Data\heroes.json` — 至少 6 名英雄。

### 7. JSON 配置加载器

```csharp
public class DataLoader
{
    public static List<CardData> LoadCards();
    public static List<HeroData> LoadHeroes();
}
```

## 禁止行为

- 逻辑层不要引用任何 FairyGUI 或 UnityEngine.UI 命名空间
- 不要在 MonoBehavior.Update 中执行游戏逻辑（走事件驱动）
- 不要硬编码数值 — 全部从 JSON 配置读取

## 验收标准

- 能加载 30 张卡牌和 6 名英雄的 JSON 数据
- GameManager 能完整走通一局：初始化 → 抽牌 → 出牌 → 结算 → 判定胜负
- 一个英雄血量归零时判定另一方胜利
- 所有效果结算无遗漏
*（内容由AI生成，仅供参考）*
