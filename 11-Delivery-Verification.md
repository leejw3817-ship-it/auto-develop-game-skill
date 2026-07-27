---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_7328b4b9896311f1b66e525400e6dd8f
    ReservedCode1: 4knhG1WPgm0aBtuYtwx0dTxABbTcbW2/InuFJQ3LG4+pQC7MVbWgtIucRuEqRNbpig7nPIB28L8F0hZ/qYmByEdvMMchDefFIMAXqPP1Y79UA6+bkMiVNUxGIBo70TRiK7Bjmlir/csZs4h2p4gFIyivCQ7SBAmG/vOfjR0vksvZYdHbd8dfb3h0OyI=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_7328b4b9896311f1b66e525400e6dd8f
    ReservedCode2: 4knhG1WPgm0aBtuYtwx0dTxABbTcbW2/InuFJQ3LG4+pQC7MVbWgtIucRuEqRNbpig7nPIB28L8F0hZ/qYmByEdvMMchDefFIMAXqPP1Y79UA6+bkMiVNUxGIBo70TRiK7Bjmlir/csZs4h2p4gFIyivCQ7SBAmG/vOfjR0vksvZYdHbd8dfb3h0OyI=
---

# 校园杀 v0.2 - 自动化测试框架与 CI/CD 提示词

## 项目背景

校园杀已具备双端构建能力（WebGL + Android），核心玩法开发中。本提示词负责搭建自动化测试体系与 CI/CD 流水线，确保每次提交后自动验证构建质量。

项目根路径：`C:\CampusKillUnity`

## 核心约束

1. **全覆盖**：单元测试 + 集成测试 + 端到端测试 + 性能测试 + 构建验证。
2. **零外部付费工具**：测试框架使用 Unity Test Framework（内置）+ NUnit，CI 使用 GitHub Actions 免费额度或本地批处理。
3. **可独立运行**：所有测试通过命令行触发，不依赖 Unity Editor GUI。
4. **失败即阻断**：任一关键测试失败，构建流程自动中止并输出报告。

## 子系统一：Unity Test Framework 单元测试

### 文件路径
- `Assets/_Project/Tests/EditMode/` - 编辑器模式测试
- `Assets/_Project/Tests/PlayMode/` - 运行模式测试
- `Assets/_Project/Tests/TestData/` - 测试数据（JSON 配置）

### 测试用例清单

**EditMode 测试（不依赖场景）：**
1. `CardDataTests.cs`：验证 CardData ScriptableObject 创建、字段读写、序列化/反序列化完整性。
2. `DeckTests.cs`：验证牌堆四区流转逻辑——初始化 30 张 → 抽牌 5 张 → 手牌 5 张 + 牌堆 25 张，再弃牌 3 张 → 弃牌堆 3 张。
3. `EffectResolverTests.cs`：验证 6 种技能效果的计算正确性（伤害、护盾、回血、抽牌、弃牌、翻倍）。
4. `AIDecisionTests.cs`：输入 100 组随机手牌 + 战场状态，验证 AI 输出为合法操作（费用不超过能量、目标不超出范围）。
5. `TurnLogicTests.cs`：验证完整回合流程状态转换——RoundStart → Draw → Main → Battle → End → 下一轮。
6. `EnergySystemTests.cs`：验证能量回复/消耗/上限边界条件（不能为负、不能超上限）。

**PlayMode 测试（依赖场景）：**
1. `BattleSceneLoadTest.cs`：验证 Battle 场景 3 秒内加载完成，所有 GameObject 非 null。
2. `CardPlayTest.cs`：模拟从手牌拖拽到目标 → 验证效果结算 → HP/护盾变化正确。
3. `TurnCycleTest.cs`：模拟 10 个完整回合 → 验证无内存泄漏（GC Alloc 线性增长）。
4. `BuildValidationTest.cs`：调用 `BuildScript.BuildWebGL` → 验证产物存在 → 文件大小 ≥ 10MB。

### 命令行运行
```bash
# EditMode 测试
Unity.exe -runTests -batchmode -projectPath C:\CampusKillUnity -testPlatform EditMode -testResults editmode-results.xml

# PlayMode 测试
Unity.exe -runTests -batchmode -projectPath C:\CampusKillUnity -testPlatform PlayMode -testResults playmode-results.xml
```

---

## 子系统二：性能基准测试

### 文件路径
- `Assets/_Project/Tests/Performance/`
- `Assets/_Project/Scripts/Tools/PerformanceProfiler.cs`

### 基准指标

| 指标 | WebGL 目标 | Android 目标 |
|------|-----------|-------------|
| 场景加载时间 | < 3 秒 | < 2 秒 |
| 帧率（战斗） | ≥ 30 FPS | ≥ 30 FPS |
| 内存峰值 | < 512 MB | < 768 MB |
| GC Alloc/帧 | < 1 KB | < 1 KB |
| Draw Calls | < 100 | < 50 |
| APK 启动时间 | N/A | < 5 秒冷启动 |

### 实现要求
1. `PerformanceProfiler.cs`：挂载到场景，每 60 帧输出一次 FPS/内存/GC/DrawCall 采样日志到 `Application.persistentDataPath/perf_log.csv`。
2. `PerformanceBenchmarkTest.cs`（PlayMode）：自动化运行战斗场景 300 帧 → 取后 180 帧平均值 → 断言是否达标。
3. 使用 `UnityEngine.Profiling.Profiler` API 而非 `Debug.Log` 以减少开销。

---

## 子系统三：CI/CD 流水线

### 文件路径
- `.github/workflows/ci.yml`（GitHub Actions）
- `ci-build.ps1`（本地 Windows 批处理备选）

### GitHub Actions 流水线

```yaml
name: CampusKill CI
on: [push, pull_request]
jobs:
  test:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run EditMode Tests
        run: |
          & "C:\Program Files\Unity\Hub\Editor\2022.3.62f3c1\Editor\Unity.exe" `
            -runTests -batchmode -projectPath . `
            -testPlatform EditMode -testResults editmode.xml
      - name: Run PlayMode Tests
        run: |
          & "C:\Program Files\Unity\Hub\Editor\2022.3.62f3c1\Editor\Unity.exe" `
            -runTests -batchmode -projectPath . `
            -testPlatform PlayMode -testResults playmode.xml
      - name: Build WebGL
        run: |
          & "C:\Program Files\Unity\Hub\Editor\2022.3.62f3c1\Editor\Unity.exe" `
            -quit -batchmode -projectPath . `
            -executeMethod BuildScript.BuildWebGL -logFile build-webgl.log
      - name: Build Android
        run: |
          & "C:\Program Files\Unity\Hub\Editor\2022.3.62f3c1\Editor\Unity.exe" `
            -quit -batchmode -projectPath . `
            -executeMethod BuildScript.BuildAndroid -logFile build-android.log
      - name: Upload Artifacts
        uses: actions/upload-artifact@v4
        with:
          name: builds
          path: Builds/
```

### 本地备选：ci-build.ps1

```powershell
# ci-build.ps1 - 本地一键构建 + 测试
param([switch]$SkipTests)
$unity = "C:\Program Files\Unity\Hub\Editor\2022.3.62f3c1\Editor\Unity.exe"
$project = "C:\CampusKillUnity"
$date = Get-Date -Format "yyyyMMdd-HHmmss"
$reportDir = "Builds\Reports\$date"
New-Item -ItemType Directory -Force -Path $reportDir | Out-Null

if (-not $SkipTests) {
    Write-Host "[1/4] EditMode Tests..."
    & $unity -runTests -batchmode -projectPath $project -testPlatform EditMode -testResults "$reportDir\editmode.xml"
    Write-Host "[2/4] PlayMode Tests..."
    & $unity -runTests -batchmode -projectPath $project -testPlatform PlayMode -testResults "$reportDir\playmode.xml"
}
Write-Host "[3/4] Building..."
& $unity -quit -batchmode -nographics -projectPath $project -executeMethod BuildScript.BuildAll -logFile "$reportDir\build.log"
Write-Host "[4/4] Report generated at $reportDir"
```

---

## 子系统四：质量门禁升级

### 文件路径
- `Assets/_Project/Editor/BuildGuard.cs`（新增，在 BuildScript 中调用）

### 门禁规则

在 `BuildScript.BuildAll` 流程中插入以下检查点（构建前执行）：
1. **代码规范**：扫描所有 `.cs` 文件，检测 `Debug.Log` 超过 50 处 → 警告（生产环境应使用条件编译）。
2. **资源检查**：扫描 `Assets/_Project/Textures/` 下所有纹理，分辨率低于 256×256 → 警告。
3. **空引用扫描**：使用 Roslyn 简易分析器，检测 `GetComponent<>()` 后无 null 检查 → 警告。
4. **APK 体积**：构建后检查 APK < 1GB → 阻断（ERROR）。
5. **场景完整性**：验证 Build Settings 中所有场景存在且非空。

### BuildGuard 代码框架
```csharp
public static class BuildGuard
{
    public static bool RunAllChecks()
    {
        bool pass = true;
        pass &= CheckCodeStyle();
        pass &= CheckTextureResolution();
        pass &= CheckNullReferencePatterns();
        pass &= CheckSceneReferences();
        return pass;
    }
    // ... 具体实现
}
```

---

## 交付验证

完成后生成 `C:\CampusKillUnity\Builds\ci-report.json`：
```json
{
  "timestamp": "",
  "editmode_tests": {"passed": 0, "failed": 0, "skipped": 0},
  "playmode_tests": {"passed": 0, "failed": 0, "skipped": 0},
  "performance": {"fps_avg": 0, "memory_mb": 0, "gc_alloc_kb": 0},
  "build_guard": {"checks": 0, "passed": 0, "warnings": 0, "errors": 0},
  "webgl_mb": 0,
  "apk_gb": 0,
  "ci_pipeline_executed": false
}
```

生成 `C:\CampusKillUnity\Builds\ci-verification-modal.html` 弹窗验证，逐项勾选测试/性能/构建门禁/CI 流水线通过情况。
*（内容由AI生成，仅供参考）*
