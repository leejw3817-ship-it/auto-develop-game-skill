---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: 4c8a8bb6f995287693e182da72e4edfd_c246e0ad891a11f1a68c525400826444
    ReservedCode1: xQoZUqz1cKyga7y1fqxC7KKUUuTaycncUetEqlefgTSTwr9fyxzvdKwl+sdRD32NLagLN6boqvTDe6D1vZh7ZvZweaohKBT5N9OFapo0jkul+AuUWIsWi2oT4i+CABxyBKZJhGF4MGvH8RcUnGIm2fwY70Vf96t+r78yKz6q3N4AIjpcVH40bORIMcg=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: 4c8a8bb6f995287693e182da72e4edfd_c246e0ad891a11f1a68c525400826444
    ReservedCode2: xQoZUqz1cKyga7y1fqxC7KKUUuTaycncUetEqlefgTSTwr9fyxzvdKwl+sdRD32NLagLN6boqvTDe6D1vZh7ZvZweaohKBT5N9OFapo0jkul+AuUWIsWi2oT4i+CABxyBKZJhGF4MGvH8RcUnGIm2fwY70Vf96t+r78yKz6q3N4AIjpcVH40bORIMcg=
---

# 09-Quality-Gate 提示词

## 任务目标

建立校园杀项目的质量门禁体系。包括自动化测试、代码审查规则、性能基准、安全扫描、构建验证。每个子系统完成后必须通过对应质量检查点才能交付。

## 输出要求

### 1. 单元测试

使用 Unity Test Framework，为以下模块编写测试：

| 模块 | 测试文件 | 用例数（≥） |
|------|----------|------------|
| CardData 加载 | CardDataTests.cs | 5 |
| EffectResolver | EffectResolverTests.cs | 8 |
| TurnManager | TurnManagerTests.cs | 6 |
| SceneStateMachine | StateMachineTests.cs | 5 |
| NetworkManager | NetworkManagerTests.cs | 4 |
| DualEngineBridge | DualEngineTests.cs | 3 |

测试类型：
- 正常路径测试（Happy Path）
- 边界值测试（空手牌、满手牌、血量0）
- 异常测试（无效卡牌ID、网络断连）

### 2. 集成测试 IntegrationTests.cs

- 完整对局流程测试（初始化 → 抽牌 → 出牌 → 结算 → 胜负）
- 联机房间创建/加入/开始游戏
- 场景切换完整链路（MainMenu → HeroSelect → Battle → Result → MainMenu）

### 3. 性能基准 .benchmarks.json

```json
{
  "battle_scene": {
    "target_fps": 60,
    "min_fps": 30,
    "max_draw_calls": 50,
    "max_tris": 15000,
    "max_memory_mb": 300,
    "max_batch_count": 30,
    "max_setpass_calls": 20
  },
  "main_menu": {
    "target_fps": 60,
    "max_draw_calls": 20,
    "max_memory_mb": 150
  }
}
```

使用 Unity Profiler 验证，超标时标记为阻塞。

### 4. 代码审查规则 .editorconfig

```
[*.cs]
csharp_style_var_when_type_is_apparent = true
csharp_style_expression_bodied_methods = true
indent_style = space
indent_size = 4
dotnet_naming_rule.private_members_with_underscore.symbols = private_fields
dotnet_style_require_accessibility_modifiers = always
```

### 5. 安全检查 Checklist

- [ ] 无硬编码密码/Token
- [ ] SQLite 查询使用参数化（防注入）
- [ ] 网络传输使用 WebSocket Secure（wss://）加密
- [ ] 客户端不做胜负判定（防作弊）
- [ ] PlayerPrefs 不存储敏感数据
- [ ] Log 中不输出完整 Token

### 6. 构建验证 BuildValidator.cs

- 构建前自动检查：
  - 所有场景在 Build Settings 中
  - 无 Missing Script
  - 无 Missing Prefab
  - Asset Bundle 无重复资源
  - IL2CPP 编译无错误

### 7. 崩溃报告（Critical Errors Only）

使用 `Application.logMessageReceived` 捕获错误：
```csharp
void OnEnable() {
    Application.logMessageReceived += (condition, stackTrace, type) => {
        if (type == LogType.Exception || type == LogType.Error) {
            // 写入崩溃日志文件
        }
    };
}
```

## 禁止行为

- 不要让测试依赖特定运行顺序
- 不要在测试中访问网络（使用 Mock）
- 不要跳过任何一个质量门禁直接交付

## 验收标准

- `Run All Tests` 全部绿色通过
- Profiler 数据在基准范围内
- 安全检查 Checklist 全部勾选
- Clean Build 无错误无警告
*（内容由AI生成，仅供参考）*
