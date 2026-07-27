---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_c444999f891a11f1a68c525400826444
    ReservedCode1: NMK/9wMmNcrYDDGQBN8gkpdqwedBzfDnHj9ItVPVrfOUlSyrMpGyZy9jqI2JcWw0eckFIFfjNWBRllCvAG8BciLjTIFJebiuL5Zc1yjDdSdpRyIOgH+jtVwvT3SgCloPMsFXb9kC+D6lqsc24dJFH4psxPFMRi7e2Nk5fH/+jrmTd8bvXtZcQomX+lU=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_c444999f891a11f1a68c525400826444
    ReservedCode2: NMK/9wMmNcrYDDGQBN8gkpdqwedBzfDnHj9ItVPVrfOUlSyrMpGyZy9jqI2JcWw0eckFIFfjNWBRllCvAG8BciLjTIFJebiuL5Zc1yjDdSdpRyIOgH+jtVwvT3SgCloPMsFXb9kC+D6lqsc24dJFH4psxPFMRi7e2Nk5fH/+jrmTd8bvXtZcQomX+lU=
---

# 11-Delivery-Verification 提示词

## 任务目标

生成交付验证系统。当所有子系统完成后，自动生成交互式验证弹窗，强制开发者逐项勾选所有检查点，全部通过后才算正式交付。这是整个项目的最终门禁。

## 输出要求

### 1. 验证清单（11 大项，N 个子项）

| 编号 | 子系统 | 检查项（示例） |
|------|--------|---------------|
| 01 | FairyGUI-Integration | 6个包正常加载、MainMenu显示、按钮可点击 |
| 02 | Scene-StateMachine | 完整链路可走通、过渡动画无闪烁、返回键合法 |
| 03 | Card-Game-Core | 30张牌加载成功、一局完整走通、效果结算无误 |
| 04 | Networking-Multiplayer | 房间创建/加入、出牌实时同步、断线重连 |
| 05 | Backend-Server | 注册/登录、排行榜返回、对局记录入库 |
| 06 | Visual-Rendering | 卡牌动画链路完整、粒子可见、音效触发 |
| 07 | Mobile-Build | APK安装成功、触控流畅、横屏适配 |
| 08 | Unity-DualEngine | 英雄模型可见、3D出牌动画、摄像机移动 |
| 09 | Quality-Gate | 所有测试通过、性能达标、安全检查全勾 |
| 10 | Ops-Deployment | 一键部署、Grafana可访问、PM2自动重启 |
| 11 | 整体集成 | 端到端流程无卡顿、无崩溃、无明显Bug |

### 2. verification.html

生成到项目根目录的单文件 HTML，要求：

**功能特性**：
- 11 个大类，每个大类下有子检查项（共约 50+ 项）
- 每项前面有复选框（checkbox），必须逐项手动勾选
- 进度条显示完成百分比
- 未全部完成时，底部「交付」按钮为灰色（disabled）
- 全部完成后，「交付」按钮变为绿色可点击
- 点击「交付」弹出确认对话框，确认后显示「校园杀 v0.1 交付完成」

**技术要求**：
- 纯静态 HTML，零外部依赖，单文件可离线打开
- CSS 使用现代简洁风格（暗色主题，绿色进度条）
- 使用 LocalStorage 保存勾选状态（刷新不丢失）
- 支持导出/导入勾选状态（JSON 下载/上传）
- 响应式布局，移动端可用

**HTML 结构参考**：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园杀 v0.1 — 交付验收</title>
    <style>
        :root {
            --bg: #1a1a2e;
            --card-bg: #16213e;
            --accent: #0f3460;
            --green: #00ff88;
            --red: #ff4757;
            --text: #e0e0e0;
            --text-secondary: #a0a0a0;
        }
        /* 完整 CSS 样式在此处 */
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>🏫 校园杀 v0.1 — 交付验收</h1>
            <div class="progress-bar">
                <div class="progress-fill" id="progressFill"></div>
            </div>
            <p id="progressText">0 / 50 已完成</p>
        </header>
        
        <div class="checklist" id="checklist">
            <!-- JS 动态生成 11 大类 50+ 子项 -->
        </div>
        
        <div class="actions">
            <button id="exportBtn">导出状态</button>
            <button id="importBtn">导入状态</button>
            <button id="deliverBtn" disabled>✅ 交付</button>
        </div>
        
        <div id="deliverModal" class="modal hidden">
            <div class="modal-content">
                <h2>确认交付</h2>
                <p>所有验证项已通过。确认交付校园杀 v0.1？</p>
                <button id="confirmDeliver">确认交付</button>
                <button id="cancelDeliver">取消</button>
            </div>
        </div>
    </div>
    <script>
        // 完整的验证逻辑、LocalStorage、进度计算、导出导入
    </script>
</body>
</html>
```

### 3. 验证项 JSON 数据模型

```javascript
const verificationItems = [
    {
        id: "01",
        title: "FairyGUI 集成绑定",
        items: [
            "FairyGUI SDK 正确安装在 Unity 项目中",
            "6 个 .bytes 包位于 Assets/_Project/FairyGUI/Packages/",
            "UIManager.Awake 中成功加载 MainMenu 包",
            "点击 '开始游戏' 按钮可切换到 HeroSelect",
            "所有按钮交互有日志输出",
            "无 NullReferenceException",
        ]
    },
    {
        id: "02",
        title: "场景状态机",
        items: [
            "Bootstrap → MainMenu → HeroSelect → Battle → Result → MainMenu 完整链路",
            "过渡动画平滑无闪烁",
            "返回键能回到上一个合法状态",
            "未选英雄时不能进入战斗（Guard 守卫生效）",
            "场景上下文数据正确传递",
        ]
    },
    // ... 其余 9 个大类
];
```

### 4. 自动生成脚本（可选）

创建 `generate_verification.py`，根据各子系统提示词自动生成 verification.html 中的检查项，减少手动同步工作量。

## 交付流程

```
开发者打开 verification.html
  → 逐项勾选检查项
  → 进度条实时更新
  → 全部勾选完成后「交付」按钮激活
  → 点击「交付」→ 确认 → 交付完成
```

## 禁止行为

- 不要跳过验证弹窗直接口头说"完成了"
- 不要在检查项中使用模糊描述（"基本可用"、"大概没问题"）
- 不要允许取消弹窗后直接解锁交付按钮

## 验收标准

- verification.html 在浏览器中正确渲染
- 11 大类 50+ 子项全部可勾选
- 进度条实时更新
- LocalStorage 保存刷新不丢失
- 导出/导入 JSON 正常
- 全部勾选后交付按钮可用，点击确认后显示「交付完成」
*（内容由AI生成，仅供参考）*
