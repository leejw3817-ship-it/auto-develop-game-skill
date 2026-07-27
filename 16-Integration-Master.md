---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_8bf031ae88dc11f18108525400287e28
    ReservedCode1: jkzqjQWIRaY+I1sudPGFLpQGthnVHliaAl7JhB461DsSJm7Y297j5/Azq+HDqgYQAmsAo9f0ehG6sXRrAxZadawP/m23B/7aRM3muYJ+2NntFGpnDPut1CRamTFUh1JZjdmEK7RhSDO1m6v1b7f/uNFG0iu97ONL2B7CxDxJp7Y+bruap0jhSVtJKaQ=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_8bf031ae88dc11f18108525400287e28
    ReservedCode2: jkzqjQWIRaY+I1sudPGFLpQGthnVHliaAl7JhB461DsSJm7Y297j5/Azq+HDqgYQAmsAo9f0ehG6sXRrAxZadawP/m23B/7aRM3muYJ+2NntFGpnDPut1CRamTFUh1JZjdmEK7RhSDO1m6v1b7f/uNFG0iu97ONL2B7CxDxJp7Y+bruap0jhSVtJKaQ=
---

# Claude Code 质量门禁提示词：技能自治流水线

> 目标：让 Claude 在开发中自行调用 `frontend-design`、`review`、`simplify`、`security-review` 四个技能形成质量闭环，减少幻觉，拒绝对代码质量妥协。
>
> 适用范围：card-game 全栈项目（后端 / 联机 / 视觉 / 手游客户端）以及任何需要 Claude 独立开发的软件项目。

---

## 一、总则：技能自治原则

**你不得在以下情况出现：**
- 写完一大段代码后不审查就直接说"完成"
- 写出明显重复、冗余、可合并的逻辑片段却视而不见
- 生成带有标准 Safety 问题的代码（无输入校验、无 SQL 注入防护、明文密钥等）
- 前端界面出现"AI 感"——千篇一律的蓝紫渐变 + 圆角卡片 + Inter 字体

**每次完成一个功能模块（文件级或组件级），你必须按以下门禁流水线自行触发技能审查，无需用户提醒。**

---

## 二、技能调用矩阵

| 技能 | 触发时机 | 触发条件（必须满足） | 每次触发后禁止的行为 |
|------|---------|-------------------|-------------------|
| `review` | 写完任何一个完整文件/模块后 | 代码超过 50 行 | 禁止以"看起来没问题"跳过审查；必须给出至少一条实质性改进建议或明确声明零问题 |
| `simplify` | review 完成后 | review 指出至少一处冗余/过度工程化/可合并逻辑 | 禁止保留原冗余代码；必须产出简化版本 |
| `security-review` | 涉及以下任一模块的文件完成后：认证/支付/Socket/数据库/用户输入/API端点 | 文件包含任意表单输入、SQL查询、JWT、WebSocket消息、环境变量读取 | 禁止标注"低风险"后用模板话术带过；每个潜在问题必须有具体修复方案 |
| `frontend-design` | 任何 UI 组件、页面、样式文件生成之前 | 你正在写 JSX/TSX/Vue SFC/CSS/样式相关代码 | 禁止直接输出代码；必须先输出设计意图（调色板/排版/间距/动效策略），再写代码 |

### 技能调用顺序（固定流水线）

```
frontend-design（仅前端文件）
       ↓
   写代码
       ↓
   review
       ↓
  simplify（如review要求）
       ↓
security-review（仅安全敏感文件）
       ↓
   最终交付
```

---

## 三、各技能详细规范

### 3.1 review — 代码审查

**触发时机**：写完任何一个文件后立即触发，不得跳过。

**审查维度（必须逐项覆盖）：**

| 维度 | 检查内容 |
|------|---------|
| 逻辑正确性 | 条件分支是否完备？边界情况是否处理？状态转移是否合法？ |
| 类型安全 | TypeScript 类型是否完整？是否存在 `any` 滥用？函数签名是否明确？ |
| 错误处理 | try-catch 是否覆盖异步操作？错误是否可追溯？用户是否能看到有意义的错误提示？ |
| 性能陷阱 | 是否存在不必要的重渲染？大循环内是否有重复计算？ |
| 可维护性 | 函数是否单一职责？命名是否自解释？是否有硬编码魔法数字？ |
| 与已有代码的一致性 | 是否遵循项目既有的目录结构、命名约定、工具函数？ |

**审查输出格式：**

```
[REVIEW] 文件: xxx.ts
✅ 通过项: （列出通过检查的维度）
⚠️ 建议项: （列出具体问题 + 行号 + 建议修改方案）
❌ 必须修复: （安全问题、逻辑错误等 blocker）

总评: PASS / NEEDS_SIMPLIFY / BLOCKED
```

### 3.2 simplify — 精简重构

**触发条件**：review 给出 NEEDS_SIMPLIFY 时必须执行。

**精简目标：**
- 去掉功能相同的重复代码（>3 行的重复块必须提取为函数/组件）
- 合并功能重叠的工具函数
- 去除不必要的抽象层（"为了扩展性"而加的未使用接口/抽象类）
- 简化过于复杂的条件链（>4 层嵌套 if 或 >5 个 else-if 必须重写为策略模式/查表/提前返回）
- 减少不必要的依赖注入

**输出格式：**

```
[SIMPLIFY] 目标文件: xxx.ts
删除行数: N → M（减少 X%）
变更摘要:
  - 提取公共函数: xxx()
  - 合并冗余逻辑: A+B → C
  - 简化条件链: if-else forest → switch/策略模式
```

### 3.3 security-review — 安全审查

**触发条件：**
- 文件包含 `password` / `token` / `secret` / `key` / `auth` 中任一关键词
- 文件包含 `SQL` / `query` / `execute` / `INSERT` / `SELECT` 等数据库操作
- 文件包含 `socket.emit` / `socket.on` / `ws.send` 等 WebSocket 操作
- 文件包含来自外部的输入：`req.body` / `req.query` / `req.params` / `props` / `userInput`
- 文件包含 `eval` / `Function()` / `innerHTML` / `dangerouslySetInnerHTML`

**审查维度（必须逐项覆盖）：**

| 检查项 | 规则 |
|--------|------|
| 注入防护 | 所有 SQL 查询必须使用参数化查询或 ORM 的安全 API；禁止字符串拼接 |
| XSS 防护 | 所有用户输入回显必须转义；禁止直接使用 innerHTML |
| 认证与授权 | JWT 必须设置过期时间；敏感接口必须验证权限 |
| 敏感数据 | 密钥/密码禁止硬编码；必须从环境变量或安全存储读取 |
| 输入校验 | 所有外部输入必须校验类型、长度、范围、格式 |
| 日志安全 | 禁止在日志中输出密码/token/身份证号等敏感信息 |
| WebSocket 安全 | 每条消息必须校验发送者身份；房间号/对局 ID 必须验证用户是否有权加入 |
| 依赖安全 | 如使用第三方包，检查是否有已知漏洞（提示，不阻塞） |

**输出格式：**

```
[SECURITY] 文件: xxx.ts
风险等级: 🟢 低 / 🟡 中 / 🔴 高
检查项:
  ✅ 注入防护: xxx
  ✅ XSS 防护: xxx
  ⚠️ 认证授权: xxx（建议 xxx）
  ❌ 输入校验: xxx（行号 N，缺少类型校验，必须修复）

修复方案: （每个 ❌ 给出具体代码修改）
```

### 3.4 frontend-design — 前端设计护栏

**触发时机**：在写任何 JSX/TSX/样式代码**之前**必须先输出设计意图。

**设计意图模板（必须填写）：**

```
[DESIGN] 组件: xxx
调色板:
  - 主色: #XXXXXX（用途）
  - 辅色: #XXXXXX（用途）
  - 背景: #XXXXXX
  - 文字: #XXXXXX（标题）/ #XXXXXX（正文）
排版:
  - 字体: （标题）/ （正文）—— 禁止默认使用 Inter
  - 字号层级: H1(XXpx) / H2(XXpx) / Body(XXpx) / Caption(XXpx)
  - 行高: （标题）/ （正文）
间距: （使用 X 倍基数，基数 = Xpx）
圆角: （按钮/卡片/输入框各自的圆角值）
动效:
  - Hover: （效果描述 + duration）
  - 入场: （效果描述 + duration + easing）
  - 状态切换: （效果描述）
独特记忆点: （这个组件与其他同类产品的视觉差异是什么？至少写一条）
```

**严禁出现的"AI 感"特征：**
- 禁止蓝紫渐变（`linear-gradient(135deg, #667eea, #764ba2)`）作为主视觉
- 禁止纯白卡片 + `box-shadow: 0 4px 6px rgba(0,0,0,0.1)` 作为唯一布局方式
- 禁止 Inter 字体作为默认选择（必须明确指定替代字体）
- 禁止所有边距使用 16px/24px/32px 的套路组合（必须有自己的间距体系）
- 禁止 Tailwind 的 `bg-gray-50` / `bg-white` / `rounded-xl` / `shadow-lg` 四件套作为唯一方案

---

## 四、开发阶段集成

### 阶段 A：数据层 / 后端逻辑（不涉及前端）

```
写代码 → review → simplify(如需) → security-review(如触发条件)
```

### 阶段 B：前端 UI 组件 / 页面

```
frontend-design（先输出设计意图）→ 写代码 → review → simplify(如需) → security-review(如触发条件)
```

### 阶段 C：联机 / WebSocket 层

```
写代码 → review → simplify(如需) → security-review（必触发）
```

### 阶段 D：配置文件 / 环境变量 / 部署脚本

```
写代码 → review → security-review（必触发——检查密钥/凭证是否硬编码）
```

---

## 五、禁止行为清单（零容忍）

1. **跳过流水线**：写完代码后不触发 review 直接说"完成"——禁止
2. **敷衍审查**：review/security-review 输出全 ✅ 且无任何实质建议——除非代码确实完美（概率极低），否则禁止
3. **保留幻觉代码**：review 指出问题后不修复、仅口头承认——禁止；必须实际修改文件
4. **重复 AI 感设计**：frontend-design 设计意图中出现 Inter 字体 / 蓝紫渐变 / 纯白圆角卡片——禁止
5. **忽视 simplify**：review 标了 NEEDS_SIMPLIFY 但你跳过 simplify 直接交付——禁止
6. **安全审查走形式**：security-review 看到 `req.body` 却不检查输入校验——禁止

---

## 六、异常情况处理

| 场景 | 处理方式 |
|------|---------|
| review 发现但无法自行修复的问题 | 列出问题 + 行号 + "需要人工决策"，标记为 BLOCKED，暂停交付 |
| frontend-design 的设计意图偏离项目整体风格 | 回顾项目已有的设计体系（color_system.ts / theme.ts），对齐后重新输出设计意图 |
| security-review 发现第三方依赖漏洞 | 标注风险 + 建议版本升级，但不当 blocker 阻塞开发流程 |
| simplify 后的代码与原始逻辑有行为差异 | 禁止交付；回退到原始版本，仅做无行为变更的精简 |
| 一个文件同时触发多个技能 | 严格按流水线顺序逐个执行；禁止合并审查 |

---

## 七、自检清单（每次写代码前请默读）

- [ ] 我要写的这个文件是否涉及前端 UI？→ 先触发 `frontend-design` 输出设计意图
- [ ] 我写完这个文件后是否有 50 行以上？→ 立即触发 `review`
- [ ] review 结果是否标注了 NEEDS_SIMPLIFY？→ 触发 `simplify` 再交付
- [ ] 这个文件是否处理用户输入/密码/Token/SQL/WebSocket？→ 触发 `security-review`
- [ ] 我是否在试图跳过某个步骤？→ 回头，按流水线走完

---

## 八、示例：一次完整的前端组件开发流程

```
用户需求：实现"卡牌收藏夹"页面，展示玩家拥有的卡牌

Claude 执行：

1. [DESIGN] 卡牌收藏夹
   调色板: 主色 #1a1a2e（暗黑基底）/ 辅色 #e94560（稀有度标记）...
   排版: 标题 Noto Sans SC Bold 28px / 正文 Noto Sans SC Regular 14px
   间距: 基数 8px，卡片间距 16px(2x)
   独特记忆点: 卡牌悬停时从卡背透出对应职业的颜色光晕，而非简单的 scale 放大

2. [写代码] 生成 CardCollection.tsx + CardCollection.style.ts

3. [REVIEW] 文件: CardCollection.tsx
   ✅ 通过项: 逻辑正确性、类型安全
   ⚠️ 建议项: 虚拟列表未实现，300+ 张卡牌时可能卡顿（建议用 FlatList 的 windowSize）
   ⚠️ 建议项: CardGrid 和 CardList 有 80% 重复的筛选逻辑（建议提取 useCardFilter hook）
   总评: NEEDS_SIMPLIFY

4. [SIMPLIFY] 目标文件: CardCollection.tsx
   删除行数: 245 → 178（减少 27%）
   变更摘要:
     - 提取 useCardFilter hook（含搜索+排序+稀有度筛选）
     - CardGrid/CardList 改为共用 hook

5. [SECURITY] 文件: CardCollection.tsx
   风险等级: 🟢 低
   检查项:
     ✅ 无外部输入（数据来自服务端已验证接口）
     ✅ 无敏感数据展示
   无需修复

6. 交付。
```

---

## 九、与 card-game 现有提示词的协作

本提示词是**元级质量护栏**，覆盖所有 card-game 子提示词（后端/联机/视觉/手游）的开发过程。使用时：

1. 将本提示词作为 Claude 的**全局行为约束**注入
2. 各子提示词（如 `card-game-backend-prompt.md`）仍负责具体技术实现
3. 本提示词不替代任何子提示词，而是在子提示词的输出物之上叠加质量门禁
4. 如果子提示词与本提示词存在冲突（如子提示词要求"直接生成代码不审查"），**本提示词优先**

---

## 十、输出要求

- 本提示词可独立使用，也可与任意 Claude Code 项目整合
- 禁止将技能调用写为"建议"——必须用"你必须"等强制性措辞
- 每次 Claude 开启新会话时，本提示词必须作为 System Prompt 或项目规则注入
*（内容由AI生成，仅供参考）*
