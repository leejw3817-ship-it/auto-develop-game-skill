# auto-develop-game-skill

> Claude Code 手游全自动基础架构搭建技能 —— 一句话让 AI 帮你从零搭建可上线卡牌手游。

## 这是什么

一套给 Claude Code 用的 Skill 文件包。包含了从卡牌分类数据、游戏引擎提示词、UI 引擎提示词、自动化脚本、CI/CD 流水线到运维监控栈的完整技术方案。Claude 读完之后就能自动完成以下工作：

- 搭建 Unity / Python / H5 三套游戏引擎
- 生成 FairyGUI / UGUI / HTML+CSS 三套 UI
- 一键安装 Python / Node / Docker 全栈依赖
- 配置 GitHub Actions 自动构建与测试
- 部署 ELK + Grafana 运维监控栈

## 目录结构

```
├── skill/                    # Claude Code Skill 定义（核心入口）
│   └── SKILL.md
├── prompts/                  # AI 提示词库（32 份，按子系统分类）
│   ├── 01-engine/            # 引擎集成（FairyGUI、Unity 双引擎、渲染）
│   ├── 02-ui/                # UI 引擎（FairyGUI 自动操作、设计系统）
│   ├── 03-gameplay/          # 核心玩法（卡牌逻辑、联机、后端）
│   ├── 04-build/             # 构建打包（Android/iOS/WebGL）
│   ├── 05-ops/               # 运维部署（后端服务、Docker、监控）
│   ├── 06-quality/           # 质量门禁（测试、CI/CD、修复诊断）
│   └── 07-master/            # 整合主控（技术栈全景、集成方案）
├── config/                   # 手游配置体系
│   ├── card-library/         # 卡牌分类库（6 个 JSON，零依赖）
│   │   ├── card-types.json   #   30 张卡牌类型定义
│   │   ├── heroes.json       #   23 角色 + 5 阵营
│   │   ├── skills-taxonomy.json  #   37 技能完整描述
│   │   ├── camps.json        #   阵营元数据
│   │   ├── game-rules.json   #   对局规则（身份/阶段/牌堆）
│   │   └── card-data-schema.json #   JSON Schema 校验
│   ├── design-tokens/        # 三引擎统一设计变量
│   └── build-profiles/       # 开发/预发布/生产三套构建配置
├── scripts/                  # 自动化脚本（10 个）
│   ├── install/              # 环境安装（Python/Node/Docker/Unity 验证）
│   ├── automation/           # 浏览器测试、FairyGUI 发布、设计校验
│   └── build/                # 构建脚本
├── codebase/                 # 核心代码
│   └── BuildScript.cs        # Unity BuildPipeline 自动化构建
├── verification/             # 验证门禁 HTML
└── docs/                     # 项目文档
```

## 快速开始

### 1. 给 Claude Code 用

把 `skill/SKILL.md` 的内容复制给 Claude Code，然后说：

```
帮我搭建手游基础架构，目标平台 Android + WebGL
```

Claude 会自动执行全部流程。

### 2. 手动安装依赖

```bat
scripts\install\install-all.bat
```

### 3. 只看卡牌数据

```bash
cat config/card-library/card-types.json   # 30 张卡牌
cat config/card-library/heroes.json       # 23 个角色
cat config/card-library/skills-taxonomy.json  # 37 个技能
```

## 技术全景

| 层级 | 技术选型 | 产出 |
|------|---------|------|
| 游戏引擎 | Unity 2022.3 / Python 3 / H5+Capacitor | APK 22MB / 1129行控制台 / Web |
| UI 引擎 | FairyGUI / UGUI Canvas 2D / HTML+CSS | 6包51组件 |
| 渲染 | Built-in RP / Canvas 2D / WebGL | 三套渲染管线 |
| 音频 | Unity Audio / Web Audio | 双引擎音频 |
| 网络 | Photon / Mirror / WebSocket | 实时联机 |
| 后端 | Python FastAPI + PostgreSQL + Redis | REST API |
| CI/CD | GitHub Actions | 自动构建 + 测试 |
| 容器化 | Docker + Docker Compose | 一键部署 |
| 监控 | ELK + Grafana + Loki + Prometheus | 全栈可观测 |
| 测试 | Pytest + Vitest + Unity Test Framework | 三层测试 |

## 构建目标

| 平台 | 格式 | 要求 |
|------|------|------|
| Android | APK | ≥ 1GB（含资源包） |
| WebGL | Gzip HTML | ≤ 20MB |
| Windows | EXE | ≥ 500MB |

## 数据驱动

所有游戏数据由 `config/card-library/` 下的 6 个 JSON 文件驱动，三套引擎统一消费：

```
卡牌分类库 (JSON)
    ├──→ Unity     → CardData.cs       (Resources.Load)
    ├──→ Python    → card_loader.py    (json.load)
    └──→ Web       → card-data.ts      (import / fetch)
```

修改 JSON 即同步生效到全部引擎。

## 运维架构

```
Git Push → GitHub Actions
    ├── Pytest（Python 测试）
    ├── Vitest（Node 测试）
    ├── Unity Build（Android + WebGL）
    └── Docker Build & Push
            ↓
      Docker Compose 部署
            ↓
  ┌── ELK（日志分析）
  ├── Grafana（可视化面板）
  ├── Loki（日志聚合）
  └── Prometheus（指标采集）
```

## 贡献

欢迎提 Issue 和 PR。提交前请确保通过验证门禁。

## 许可
