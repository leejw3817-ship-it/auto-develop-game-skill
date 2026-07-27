---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_08d8c3b5896711f1a68c525400826444
    ReservedCode1: Fxo6LKQckOlHy736unKr+qSflaM+tK15vL0Zmpo4A6RGe+oEzoJdyrsQaX/FVo+y37fGBMXxd51ucI6p6HT2495K+XtKIuStaNWrYhqE7ec0iRqFhfYtUNhgK2qEQ/tV0e403oDxZOhrA61YDswCnYXMWM+KeLwhRlkaWwv4oZpWgAZpPs5zYmu8PdQ=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_08d8c3b5896711f1a68c525400826444
    ReservedCode2: Fxo6LKQckOlHy736unKr+qSflaM+tK15vL0Zmpo4A6RGe+oEzoJdyrsQaX/FVo+y37fGBMXxd51ucI6p6HT2495K+XtKIuStaNWrYhqE7ec0iRqFhfYtUNhgK2qEQ/tV0e403oDxZOhrA61YDswCnYXMWM+KeLwhRlkaWwv4oZpWgAZpPs5zYmu8PdQ=
---

# 校园杀 · 技术栈全景 Master 提示词

> 适用对象：Claude Code / Cursor / Copilot  
> 版本：v2.0  
> 目标：梳理校园杀全部可用引擎与维护系统，交付可落地的子系统提示词索引。

---

## 一、任务目标

你正在接手的是一个多端卡牌对战游戏「校园杀」。当前项目目录 `C:\Users\31184\Desktop\校园杀v0.1` 内已有三套可运行的实现、一套UI编辑器工程、一套文档技能转换工具。

你的任务是：
1. 理解并梳理所有可用的引擎、框架与维护系统
2. 为后续开发提供清晰的技术栈决策依据

---

## 二、现有项目结构

```
校园杀v0.1/
├── CampusKillUnity/          # Unity 2022.3.62f3c1 工程（C#）
│   ├── Assets/_Project/       # 游戏代码与资源
│   ├── Assets/_Project/Editor/BuildScript.cs  # 双端构建脚本
│   ├── Builds/WebGL/          # WebGL 构建产物 (17MB)
│   └── Builds/Android/CampusKill.apk # Android APK (22MB)
├── FairyGUI-Project/          # FairyGUI UI编辑器工程
│   └── assets/{MainMenu,HeroSelect,BattleHUD,ResultPanel,CardTooltip,ResponsivePanel}/
├── book-to-skill-1.2.0/      # 文档→技能转换工具（Python）
│   └── game/                  # ★ 内置完整Web游戏（Vite+TS+Capacitor）
│       ├── index.html         # Web入口
│       ├── package.json       # npm依赖
│       ├── android/           # Capacitor Android构建
│       └── 校园杀-v1.0.1.apk  # 已产出APK
├── campus_kill.py            # Python 3 原生控制台版（1129行·全功能）
├── 校园杀 规则和人物.docx      # 完整游戏设计文档
├── 新角色.docx                # 新增角色设计
└── verification-final.html   # 验证弹窗门禁模板
```

---

## 三、全部可用引擎一览

### 3.1 游戏引擎层（3套·都可用）

| # | 引擎 | 语言 | 跨平台能力 | 当前产物 | 说明 |
|---|------|------|-----------|---------|------|
| 1 | **Unity 2022.3.62f3c1** | C# | WebGL / Android / iOS / PC | WebGL 17MB、APK 22MB | 主力引擎；双引擎架构（Canvas 2D + FairyGUI） |
| 2 | **Python 3 原生** | Python | 仅控制台 | campus_kill.py (1129行) | 零依赖控制台版；完整规则实现；适合快速原型与AI验证 |
| 3 | **Web(H5) + Capacitor** | TypeScript | Web / Android / iOS (PWA) | APK (book-to-skill/game内) | Vite构建；Capacitor打包原生APK；可直接在模拟器/手机运行 |

### 3.2 UI 引擎层（3套）

| # | 引擎 | 格式 | 覆盖范围 | 说明 |
|---|------|------|---------|------|
| 1 | **FairyGUI** | 编辑器 + Unity Runtime SDK | 6包51组件 | 独立UI编辑器；MainMenu/HeroSelect/BattleHUD/ResultPanel/CardTooltip/ResponsivePanel |
| 2 | **Unity UGUI Canvas 2D** | Unity内置 | 程序化卡牌纹理渲染 | 与FairyGUI通过 StageCamera depth=1 + MainCamera depth=0 共存 |
| 3 | **HTML5 + CSS** | 标准Web技术 | Web版全UI | book-to-skill/game 中的界面 |

### 3.3 渲染引擎层（3套）

| # | 引擎 | 用途 | 说明 |
|---|------|------|------|
| 1 | **Unity Built-in Render Pipeline** | 3D/2D混合渲染 | CampusKillUnity 默认管线 |
| 2 | **Canvas 2D API** | 程序化卡牌纹理生成 | 纯代码生成卡牌正面/背面/边框/图标，不依赖外部美术资源 |
| 3 | **WebGL** | 浏览器端硬件加速渲染 | Unity WebGL 导出 + Web原生渲染 |

### 3.4 音频引擎层（2套）

| # | 引擎 | 用途 | 说明 |
|---|------|------|------|
| 1 | **Unity Audio System** | 游戏内音效/背景音乐 | AudioSource + AudioClip |
| 2 | **Web Audio API** | Web端音频 | WebGL/Web版音效合成 |

### 3.5 物理引擎层（1套）

| # | 引擎 | 用途 | 说明 |
|---|------|------|------|
| 1 | **Unity Physics (Box2D/PhysX)** | 卡牌物理交互（可选） | 2D物理用于卡牌拖拽、碰撞检测 |

### 3.6 数据引擎层（3套）

| # | 引擎 | 格式 | 用途 |
|---|------|------|------|
| 1 | **Unity ScriptableObject** | .asset | 角色/卡牌/装备配置数据 |
| 2 | **JSON** | .json | 游戏存档、网络通信、版本清单 |
| 3 | **FairyGUI .fui.bytes** | 二进制 | UI组件序列化发布文件 |

### 3.7 网络与联机引擎（待扩展）

| # | 可选方案 | 适用端 | 说明 |
|---|---------|--------|------|
| 1 | **Unity Netcode for GameObjects (NGO)** | Unity全端 | 官方联机方案；P2P/Relay |
| 2 | **Mirror** | Unity全端 | 社区主流联机框架 |
| 3 | **Photon PUN/Fusion** | Unity全端 | 商业联机方案；有免费额度 |
| 4 | **WebSocket + 自建服务器** | Web/Python | 适用于Web版联机 |

---

## 四、全部可用维护系统一览

### 4.1 构建与打包系统

| # | 系统 | 覆盖端 | 工具链 | 当前状态 |
|---|------|--------|--------|---------|
| 1 | **Unity Build Pipeline** | WebGL / Android | BuildScript.cs | ✅ 双端构建通过 |
| 2 | **Vite** | Web(H5) | vite.config.js | ✅ book-to-skill/game |
| 3 | **Capacitor** | Web→Android APK | capacitor.config.ts | ✅ 已产出APK |
| 4 | **Gradle** | Android原生编译 | build.gradle | ✅ 双引擎均用 |

### 4.2 CI/CD（持续集成/持续交付）

| # | 系统 | 配置位置 | 说明 |
|---|------|---------|------|
| 1 | **GitHub Actions** | .github/workflows/ | 自动构建、测试、打包 |
| 2 | **Unity Cloud Build**（可选） | Unity Dashboard | Unity官方云端构建服务 |
| 3 | **BuildGuard 门禁** | 提示词内置 | 构建前自动校验：资源完整性/编译/测试 |

### 4.3 测试体系

| # | 框架 | 类型 | 说明 |
|---|------|------|------|
| 1 | **Unity Test Framework** | EditMode + PlayMode | C# 单元测试与集成测试 |
| 2 | **pytest**（可选） | Python端测试 | 针对 campus_kill.py 的规则逻辑测试 |
| 3 | **Vitest / Jest**（可选） | Web端测试 | 针对 TypeScript 游戏逻辑 |

### 4.4 运维引擎（CampusKillOps）

独立 .asmdef 程序集 `CampusKillOps`，包含以下子系统：

| # | 子系统 | 技术栈 | 职责 |
|---|--------|--------|------|
| 1 | **Logging 日志系统** | Unity ILogger / Serilog | 分级日志输出到文件/控制台/远程 |
| 2 | **Crash Reporting 崩溃收集** | Unity CrashReport / Sentry SDK | 崩溃堆栈自动上传与聚合分析 |
| 3 | **Monitoring 性能监控** | ELK Stack / Grafana + Loki | 帧率/内存/GC/网络延迟实时监控 |
| 4 | **HotUpdate 热更新** | AssetBundle + 版本清单 | 客户端资源增量更新，无需重装APK |
| 5 | **deploy.ps1 部署脚本** | PowerShell | 一键上传到 MinIO / OSS / CDN |

### 4.5 开发工具链

| # | 工具 | 用途 |
|---|------|------|
| 1 | **FairyGUI Editor** | 可视化UI编辑，导出 .fui.bytes |
| 2 | **book-to-skill-1.2.0** | 文档（PDF/EPUB/DOCX/Markdown）→ Claude Skill 结构化转换 |
| 3 | **Claude Code / Cursor** | AI辅助开发 |
| 4 | **VS Code / Rider** | 代码编辑与调试 |
| 5 | **verification-modal.html** | 交付验收弹窗门禁模板 |

---

## 五、技术栈关系拓扑

```
                    校园杀 技术栈全景

    ┌─────────── 游戏引擎层 ───────────┐
    │  Unity 2022   Python 3    H5+Cap │
    │  (主力·双端)  (原型·验证)  (Web·APK)│
    └───────────────┬──────────────────┘
                    │
    ┌───────────────┼──────────────────┐
    │           UI 引擎层              │
    │  FairyGUI ◄─► UGUI ◄─► HTML/CSS │
    │  (StageCamera depth 双引擎共存)  │
    └───────────────┼──────────────────┘
                    │
    ┌───────────────┼──────────────────┐
    │     渲染 · 音频 · 物理 · 数据     │
    │  Built-in RP / Canvas 2D / WebGL│
    │  Audio System / Web Audio API   │
    │  Physics 2D / ScriptableObject   │
    └───────────────┼──────────────────┘
                    │
    ┌───────────────┼──────────────────┐
    │          维护/运维层              │
    │  Build │ CI/CD │ Test │ Ops     │
    │  Unity+Vite+Gradle+Capacitor    │
    │  GitHub Actions │ BuildGuard    │
    │  UTF │ pytest │ CampusKillOps   │
    │  Logging Crash HotUpdate Deploy │
    └──────────────────────────────────┘
```

---

## 六、后续子系统提示词索引

以下提示词文件与本文件配套使用，可按需交给 Claude 逐个执行：

| 文件 | 覆盖范围 |
|------|---------|
| 17a-Unity-Engine-Core.md | Unity引擎核心：Canvas 2D纹理管线、FairyGUI双引擎桥接、脚本架构 |
| 17b-Web-Mobile-Engine.md | Web(H5)+Capacitor引擎：Vite构建、TS游戏逻辑、Capacitor APK打包 |
| 17c-Python-Console-Engine.md | Python 3控制台引擎：campus_kill.py 规则引擎重构与扩展 |
| 17d-Build-CI-Pipeline.md | 三端构建系统：Unity/Vite/Gradle/Capacitor 统一构建+GitHub Actions CI |
| 17e-CampusKillOps-Engine.md | 运维引擎独立构建：Logging/Crash/Monitoring/HotUpdate/Deploy 五子系统 |
| 17f-Test-QA-System.md | 测试体系：UTF(EditMode+PlayMode)、pytest、集成测试门禁 |

---

## 七、交付要求

本文件完成后必须调用 `verification-modal.html` 进行逐项验收：

- [ ] 三套游戏引擎均已识别并说明当前产物
- [ ] 三套UI引擎均已说明共存方式
- [ ] 渲染/音频/物理/数据引擎均已覆盖
- [ ] 四套构建打包系统均已列出
- [ ] CI/CD流程已说明
- [ ] 测试框架已覆盖
- [ ] 运维引擎五子系统已定义
- [ ] 开发工具链已枚举
- [ ] 后续提示词索引已生成

> 以上清单全部勾选通过后，方视为本提示词执行完毕。
*（内容由AI生成，仅供参考）*
