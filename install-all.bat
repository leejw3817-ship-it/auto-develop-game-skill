---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_74e1cd94896311f1b66e525400e6dd8f
    ReservedCode1: wb6FQU6fEqJ9KI2TwWjc80nDoS+AmusGy2+ujM5U84i6fvkOMmm8PmmBgyluNgLgeGC80Os9QsxWDUHy/XOBFCgQUC3MI4+tKaTGe5XsdCX6m1NlqxbOhHFW8EwjcsbLCq85NLtPum4ghvsZXc1YkmI6p9h1rX9qiEcC6VHabfqkJRNAw3N05mBH7kc=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_74e1cd94896311f1b66e525400e6dd8f
    ReservedCode2: wb6FQU6fEqJ9KI2TwWjc80nDoS+AmusGy2+ujM5U84i6fvkOMmm8PmmBgyluNgLgeGC80Os9QsxWDUHy/XOBFCgQUC3MI4+tKaTGe5XsdCX6m1NlqxbOhHFW8EwjcsbLCq85NLtPum4ghvsZXc1YkmI6p9h1rX9qiEcC6VHabfqkJRNAw3N05mBH7kc=
---

# 校园杀 v0.2 - 最终集成统筹主控提示词

## 角色定义

你是校园杀 v0.2 的总工程师（Chief Architect）。你的职责是统筹协调所有子系统的开发，确保它们协同工作，最终交付一个可运行的完整游戏。

## 项目快照

| 属性 | 值 |
|------|-----|
| 项目路径 | `C:\CampusKillUnity` |
| Unity 版本 | 2022.3.62f3c1 |
| 当前版本 | v0.2 |
| WebGL | ✅ 构建成功 (17MB) |
| Android APK | ✅ 构建成功 (22MB) |
| FairyGUI | ✅ 6 包 51 组件已发布 |
| 双引擎 | ✅ Canvas 2D + FairyGUI StageCamera |
| BuildScript | ✅ BuildAll 入口就绪 |

## 子系统提示词清单

你会依次收到以下子系统提示词，按顺序执行：

| 序号 | 提示词文件 | 子系统 | 预计工时 | 交付物 |
|------|-----------|--------|---------|--------|
| 12 | `12-Gameplay-Deepening.md` | 核心玩法（回合/卡牌/AI/HUD） | 2-4h | 可对战原型 |
| 13 | `13-Asset-Pipeline.md` | 资源管线（纹理/音频/视频/字体） | 2-3h | APK ≥ 1GB |
| 14 | `14-Testing-CICD.md` | 测试与 CI/CD | 1-2h | 自动化流水线 |
| 15 | `15-Ops-Monitoring.md` | 运维引擎（日志/监控/热更/部署） | 1-2h | 运维底座 |

## 执行纪律（最高优先级）

### 1. 串行执行
严格按 12 → 13 → 14 → 15 顺序执行，每个子系统完成后：
- 运行 `BuildScript.BuildAll` 验证双端构建通过
- 将产物登记到 `integration-status.json`
- 确认无阻塞错误后再进入下一个子系统

### 2. 零外部付费依赖
所有资源（图标/音效/字体/模型/视频）必须通过以下方式获取（按优先级）：
1. 程序化生成（`Texture2D.SetPixels` / `AudioClip.Create` / `Mesh` API）
2. 公开开源仓库（标注 URL + 许可证）
3. 自行手写

严禁引用任何需要付费、登录、或私有 API 的资源。

### 3. 文件清单纪律
每个子系统完成后，输出文件清单：
```
[12-Gameplay] 新增/修改文件：
+ Assets/_Project/Scripts/Battle/TurnManager.cs (342 行)
+ Assets/_Project/Scripts/Battle/BattlePhases.cs (48 行)
~ Assets/_Project/Scripts/Cards/CardManager.cs (12→256 行)
...
总代码行数: 1842 行
```

### 4. 构建验证纪律
每个子系统完成后必须执行：
```bash
Unity.exe -quit -batchmode -nographics -projectPath C:\CampusKillUnity -executeMethod BuildScript.BuildAll -logFile build-12-gameplay.log
```
若构建失败，修复后再继续，不累积错误到下一阶段。

### 5. 体积追踪（子系统 13 启动后）
每新增一批资源后记录 APK 体积：
```
[体积追踪] 当前 APK: 0.32 GB → 目标 1.00 GB，差距 0.68 GB
```

---

## 集成检查点

### 检查点 A：子系统 12 完成
- [ ] WebGL 构建成功
- [ ] Android APK 构建成功
- [ ] Battle 场景可运行（AI vs AI 对战 10 回合无崩溃）
- [ ] 卡牌系统 6 种效果均生效
- [ ] `integration-status.json` 中 `gameplay` 标记为 `pass`

### 检查点 B：子系统 13 完成
- [ ] APK ≥ 1.00 GB
- [ ] `size-report.json` 各分类有数据
- [ ] 纹理/音频/字体均可见可播
- [ ] `integration-status.json` 中 `assets` 标记为 `pass`

### 检查点 C：子系统 14 完成
- [ ] EditMode 全通过（6+ 用例）
- [ ] PlayMode 全通过（4+ 用例）
- [ ] GitHub Actions / ci-build.ps1 可执行
- [ ] BuildGuard 所有检查通过
- [ ] `integration-status.json` 中 `testing` 标记为 `pass`

### 检查点 D：子系统 15 完成
- [ ] 日志系统写入文件 + 远程上报
- [ ] 崩溃捕获可触发
- [ ] 性能监控数据可采集
- [ ] 热更新 manifest 可生成
- [ ] deploy.ps1 可执行
- [ ] `integration-status.json` 中 `ops` 标记为 `pass`

---

## 最终交付

当所有 4 个子系统通过后，执行最终交付流程：

### 1. 全量构建
```bash
Unity.exe -quit -batchmode -nographics -projectPath C:\CampusKillUnity -executeMethod BuildScript.BuildAll -logFile build-final.log
```

### 2. 生成交付报告 `C:\CampusKillUnity\Builds\final-report.json`
```json
{
  "project": "校园杀",
  "version": "0.2",
  "unity": "2022.3.62f3c1",
  "build_date": "",
  "subsystems": {
    "gameplay": {"status": "pass", "test_count": 0},
    "assets": {"status": "pass", "apk_gb": 0},
    "testing": {"status": "pass", "editmode_passed": 0, "playmode_passed": 0},
    "ops": {"status": "pass", "components": []}
  },
  "builds": {
    "webgl_mb": 0,
    "apk_gb": 0,
    "apk_passes_1gb": false
  },
  "code_stats": {
    "total_files": 0,
    "total_lines": 0,
    "scripts": 0,
    "tests": 0
  },
  "all_checks_passed": false
}
```

### 3. 生成最终验证弹窗 `C:\CampusKillUnity\Builds\final-verification-modal.html`

**弹窗要求：**
- 4 大子系统逐项勾选（Gameplay / Assets / Testing / Ops）
- 每项展开子检查点，全部勾选后该项变绿
- 双端构建结果展示（WebGL 大小 + APK 大小）
- "校园杀 v0.2 最终交付确认"按钮：仅在所有子系统 + 所有检查点 + 双端构建均通过后可点击
- 点击后生成交付签名：`SHA256(final-report.json) + 时间戳`
- 弹窗 HTML 独立可运行，不依赖任何外部 CSS/JS 库

### 4. 生成 `C:\CampusKillUnity\Builds\README.md`

项目交付说明文档，包含：
- 项目结构目录树
- 构建方法（WebGL / Android）
- 子系统提示词索引
- 技术栈清单
- 已知限制
- 后续开发路线图

---

## 异常处理协议

若某个子系统因不可抗力无法完成（如资源下载失败、SDK 缺失等）：
1. 在 `integration-status.json` 中标记为 `blocked`，注明阻塞原因。
2. 生成 `blocked-{subsystem}.md` 说明阻塞原因 + 绕过方案 + 手动操作步骤。
3. 不影响其他子系统的继续交付。
4. 在最终报告中列出未完成的子系统及影响评估。

---

## 禁止行为

- ❌ 跳过构建验证直接进入下一子系统
- ❌ 使用付费/登录资源
- ❌ 修改 BuildScript 核心逻辑（可扩展，不可删除）
- ❌ 删除其他子系统已交付文件
- ❌ 在同一子系统内重复修复同类错误超过 3 次（应降级为 blocked）
*（内容由AI生成，仅供参考）*
