---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_e64ac392896811f1a68c525400826444
    ReservedCode1: /dalwk828fZsu9Rx+AgHZaP1wtQ+whOuOhqdn5ihPNG0qU26lgVLG+cTToKnFcIututXPYP5kF2GuXeqx4j5qQgsTSP8z8JAt60Rjj1SK0RDa3V6hslC9kTHo8Cym+ZYNKUSSqo0xqCSkETHE6eq90kiNz/5hm+67yfpiLYTEPVAPiADl5tzgys2tIs=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_e64ac392896811f1a68c525400826444
    ReservedCode2: /dalwk828fZsu9Rx+AgHZaP1wtQ+whOuOhqdn5ihPNG0qU26lgVLG+cTToKnFcIututXPYP5kF2GuXeqx4j5qQgsTSP8z8JAt60Rjj1SK0RDa3V6hslC9kTHo8Cym+ZYNKUSSqo0xqCSkETHE6eq90kiNz/5hm+67yfpiLYTEPVAPiADl5tzgys2tIs=
---



# 校园杀 · 卡牌分类库搭建

> 适用对象：Claude Code / Cursor  
> 交付目标：搭建校园杀全量卡牌、角色、技能的跨引擎数据分类库  
> 约束：零外部依赖，纯 JSON 数据层，三套引擎统一消费

---

## 一、任务目标

为「校园杀」构建一个**独立于引擎**的卡牌分类数据库。这个库是一组结构化 JSON 文件 + 一个类型校验脚本，供 Unity C#、Python 3 控制台、Web(H5)+Capacitor 三套引擎直接引用。

---

## 二、分类维度（Class 元模型）

你需要实现的分类体系包含以下维度，每个维度一个 JSON 文件：

### 2.1 卡牌类型枚举（card-types.json）

```
卡牌大类：基础牌 / 锦囊牌 / 装备牌
细分标签：攻击 / 防御 / 回复 / 控制 / 增益 / 减益 / 判定 / 距离 / 特殊
触发时机：出牌阶段 / 响应阶段 / 濒死阶段 / 弃牌阶段 / 判定阶段 / 全局被动
目标范围：单体 / 全体 / 自身 / 指定多人
```

### 2.2 完整卡牌库（cards.json）

包含全部 30 张卡牌的完整元数据，每张至少要有：

```json
{
  "id": "card_sha",
  "name": "杀",
  "type": "basic",
  "subtype": "attack",
  "tags": ["攻击", "基础"],
  "timing": "出牌阶段",
  "target_scope": "单体",
  "description": "对1名角色造成1点伤害，每回合限1次",
  "damage": 1,
  "distance_required": true,
  "per_turn_limit": 1,
  "can_be_responded": true,
  "respond_card": "闪",
  "effects": [
    { "type": "damage", "value": 1 }
  ]
}
```

**必须覆盖的卡牌完整列表**（根据规则文档）：

| 类别 | 卡牌名 | 数量 |
|------|--------|------|
| 基础牌 | 杀、闪、桃、萝卜 | 4 |
| 锦囊牌 | 战争践踏、写作业、汤、决斗、唾沫横飞、恩赐、烤糖、午时已到、考试、假条、甩锅、处分、意外之喜、开户、没收、小偷小摸、瞌睡、福同享难同当 | 18 |
| 装备牌 | 手串、钰鞋、粉笔盒、命运之矛、岁月刀、鼻涕纸、尺子、臭水炸弹 | 8 |

### 2.3 角色库（heroes.json）

全部 22 名角色 + 2 名主公，每名角色至少：

```json
{
  "id": "hero_liubang",
  "name": "刘帮",
  "camp": "学",
  "hp": 4,
  "is_lord": false,
  "skills": [
    {
      "id": "skill_pi",
      "name": "屁",
      "type": "active",
      "timing": "出牌阶段",
      "trigger": "使用萝卜后",
      "description": "回合内使用萝卜，指定1人掉1血",
      "effects": [
        { "type": "target_damage", "condition": "used_carrot", "value": 1 }
      ]
    }
  ]
}
```

**必须覆盖的 22 名角色**：刘帮、亲宝、曾子、科比二十四、四海王、胖斗士、老人儿、犬、砖哥、画师、双六将（学11人）｜沙蛾、恋旧海、黄河黄、柳叶(主公)、世界霸主（宇5人）｜梅希、柠檬、丞相、副主任、校长(主公)（师5人）

**主公标识**：柳叶、校长 初始血量+1，主公技单独标注

### 2.4 阵营元数据（camps.json）

```json
{
  "camps": [
    { "id": "xue", "name": "学", "color": "#4A90D9", "description": "学生阵营" },
    { "id": "yu",  "name": "宇", "color": "#9B59B6", "description": "宇宙阵营" },
    { "id": "shi", "name": "师", "color": "#E74C3C", "description": "教师阵营" }
  ]
}
```

### 2.5 技能分类库（skills-taxonomy.json）

按触发机制对所有技能做二次分类：

```
主动技 / 被动技 / 触发技
  ├── 伤害类（造成伤害、伤害加成、伤害减免、伤害转移）
  ├── 控制类（跳过回合、禁用技能、强制行动）
  ├── 资源类（摸牌、弃牌、偷牌、换牌、看牌）
  ├── 回复类（回血、濒死急救、血量上限变更）
  ├── 判定类（猜拳判定、硬币判定、条件判定）
  ├── 距离类（攻击距离增加、穿透效果）
  └── 状态类（属性附着、阵营变更、免疫效果）
```

### 2.6 游戏规则元数据（game-rules.json）

包含回合流程、判定方式、濒死规则、距离计算等核心规则的 JSON 化描述。

---

## 三、全引擎对接矩阵

分类库建成后，校园杀全部引擎按以下方式消费同一份 JSON（列全，不可遗漏）：

### 3.1 游戏引擎层

| 引擎 | 消费文件 | 接入方式 |
|------|---------|---------|
| Unity 2022 (C#) | cards.json / heroes.json / camps.json / game-rules.json | `Resources.Load<TextAsset>` 或 `JsonUtility.FromJson` 反序列化到 ScriptableObject 缓存 |
| Python 3 控制台 | 全部 6 个 JSON | `json.load(open(...))` 直接读取，注入 `CardRegistry` / `HeroRegistry` 单例 |
| Web(H5)+Capacitor (TS) | 全部 6 个 JSON | Vite `import` 或 fetch 加载，存入 `Map<string, CardDef>` 字典 |

### 3.2 UI 引擎层（展示消费）

| 引擎 | 消费文件 | 接入方式 |
|------|---------|---------|
| FairyGUI | cards.json / heroes.json | 运行时读取 card.name/description/tags 填充 UI 组件文本；卡牌图根据 subtype+tags 映射预设图标 |
| Unity UGUI Canvas 2D | cards.json / card-types.json | 程序化纹理生成时按 subtype 选择模板（攻击=红框、防御=蓝框、回复=绿框） |
| HTML5 + CSS | 全部 JSON | 直接渲染到 DOM，tags 映射 CSS class（`.card-attack` / `.card-defense` 等） |

### 3.3 渲染 / 音频 / 数据引擎（间接消费）

| 引擎 | 消费文件 | 接入方式 |
|------|---------|---------|
| Canvas 2D API | card-types.json | 按 subtype 选取程序化纹理生成策略（边框图案、底色渐变） |
| WebGL | game-rules.json | 读取判定方式（猜拳/硬币），决定 WebGL 端判定动画播放逻辑 |
| Unity Audio | cards.json (tags) | 按 tags 触发对应 SFX（attack→打击音效、heal→回复音效、trick→锦囊音效） |
| Web Audio API | cards.json (tags) | 同上，Web 端用 AudioContext 合成 |
| ScriptableObject | 全部 JSON | 作为 Editor 导入管线，自动生成 .asset 配置 |
| FairyGUI .fui.bytes | heroes.json (camps) | 按阵营颜色渲染角色头像边框/阵营徽章 |

### 3.4 运维引擎（数据校验消费）

| 子系统 | 消费文件 | 接入方式 |
|------|---------|---------|
| CampusKillOps Logging | game-rules.json | 校验规则版本号，版本不匹配时打 WARNING 日志 |
| CampusKillOps HotUpdate | cards.json / heroes.json | 作为 AssetBundle 版本清单中的 data 层增量更新单元 |
| deploy.ps1 | card-library/ 全目录 | 部署时随资源包一起上传到 CDN/MinIO |

### 3.5 测试框架（校验消费）

| 框架 | 消费文件 | 接入方式 |
|------|---------|---------|
| Unity Test Framework | 全部 JSON | EditMode 测试读取并校验 JSON 完整性 |
| pytest | 全部 JSON | `test_card_library.py` 遍历 cards.json 验证每张卡效果字段齐全 |
| Vitest | 全部 JSON | Web 端导入后做 `toMatchSchema` 校验 |

---

## 四、交付要求

### 3.1 文件清单

在项目目录 `C:\Users\31184\Desktop\校园杀v0.1\card-library\` 下产出：

```
card-library/
├── card-types.json          # 卡牌类型枚举 + 标签体系
├── cards.json               # 全量 30 张卡牌元数据
├── heroes.json              # 全量 22 名角色 + 技能
├── camps.json               # 3 阵营元数据
├── skills-taxonomy.json     # 技能二次分类体系
├── game-rules.json          # 核心规则 JSON 化
├── schema-validator.py      # 零依赖 JSON Schema 校验脚本
├── README.md                # 分类库使用说明
└── verification.html        # 交付验证弹窗
```

### 3.2 硬性约束

1. **零依赖**：所有 JSON 文件纯文本可读；schema-validator.py 只用 Python 3 stdlib，不允许 pip install
2. **引擎无关**：JSON key 用英文 snake_case，中文存 value（description/name 字段），方便三种引擎直接 parse
3. **可校验**：schema-validator.py 运行时自动检查：所有 ID 唯一、所有引用（技能↔角色、响应卡牌↔卡牌）有效、数值合法（血量≥1、伤害≥0）、必填字段齐全
4. **完整覆盖**：不得遗漏任何一张卡牌、任何一名角色、任何一项技能
5. **规则文档对齐**：所有效果描述必须与 `校园杀 规则和人物.docx` 原文一致

### 3.3 验证流程

完成后必须生成 `verification.html`，包含以下逐项勾选：

### 数据完整性
- [ ] card-types.json 已生成，类型+标签体系完整
- [ ] cards.json 已生成，30 张卡牌无遗漏，effect 与规则文档一致
- [ ] heroes.json 已生成，22 人 + 2 主公，全部技能录入
- [ ] camps.json 已生成，3 阵营元数据
- [ ] skills-taxonomy.json 已生成，全部技能按触发机制二次分类
- [ ] game-rules.json 已生成，核心规则覆盖完整
- [ ] schema-validator.py 零依赖，运行通过，无 ID 冲突、无无效引用

### 游戏引擎消费（3 套）
- [ ] Unity C# 端可用 `Resources.Load<TextAsset>` 加载分类 JSON
- [ ] Python 3 端可用 `json.load` 直接读取
- [ ] Web(H5)+Capacitor TS 端可通过 `import` 或 fetch 加载

### UI 引擎消费（3 套）
- [ ] FairyGUI 可按 tags 映射卡牌图标/边框/阵营色
- [ ] Unity UGUI Canvas 2D 可按 subtype 选择纹理模板
- [ ] HTML+CSS 可按 tags 绑定 CSS class

### 渲染 / 音频 / 数据 / 运维 / 测试（全面覆盖）
- [ ] Canvas 2D API 按 subtype 选纹理策略
- [ ] Unity Audio / Web Audio API 按 tags 触发对应音效
- [ ] ScriptableObject 管线可自动导入生成 .asset
- [ ] FairyGUI .fui.bytes 可读取阵营色渲染头像框
- [ ] CampusKillOps 各子系统可校验/消费对应 JSON
- [ ] UTF / pytest / Vitest 均可遍历验证数据完整性
- [ ] README.md 包含全引擎引入示例

### 基础要求
- [ ] 所有 JSON 格式合法，可用任意 JSON 解析器直接打开

> 以上全部勾选通过后方可交付。
*（内容由AI生成，仅供参考）*
*（内容由AI生成，仅供参考）*
