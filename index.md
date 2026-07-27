# ============================================================
# 校园杀 · Unity 模块验证与补充安装脚本
# 功能：检查 Unity 2022.3.62f3c1 的 Android/iOS/WebGL 模块是否齐全
# ============================================================

Write-Host "=== 校园杀 Unity 模块验证 ===" -ForegroundColor Cyan
Write-Host ""

$unityHub = "${env:ProgramFiles}\Unity Hub\Unity Hub.exe"
$unityEditor = "C:\Program Files\Unity\Hub\Editor\2022.3.62f3c1\Editor\Unity.exe"
$unityVersion = "2022.3.62f3c1"

# 检查 Unity Hub
if (Test-Path $unityHub) {
    Write-Host "[OK] Unity Hub 已安装" -ForegroundColor Green
} else {
    Write-Host "[警告] Unity Hub 未找到，将尝试直接使用 Unity Editor" -ForegroundColor Yellow
}

# 检查 Unity Editor
if (Test-Path $unityEditor) {
    Write-Host "[OK] Unity Editor $unityVersion 已安装" -ForegroundColor Green
} else {
    Write-Host "[错误] Unity Editor $unityVersion 未找到！" -ForegroundColor Red
    Write-Host "  预期路径: $unityEditor" -ForegroundColor Yellow
    exit 1
}

# 检查核心模块目录
$moduleDir = "C:\Program Files\Unity\Hub\Editor\$unityVersion\Editor\Data\PlaybackEngines"
$requiredModules = @{
    "AndroidPlayer" = "Android Build Support"
    "iOSSupport"    = "iOS Build Support"
    "WebGLSupport"  = "WebGL Build Support"
}

Write-Host ">>> 检查构建模块..." -ForegroundColor Yellow
$missing = @()
foreach ($mod in $requiredModules.Keys) {
    $path = Join-Path $moduleDir $mod
    if (Test-Path $path) {
        Write-Host "[OK] $($requiredModules[$mod])" -ForegroundColor Green
    } else {
        Write-Host "[缺失] $($requiredModules[$mod])" -ForegroundColor Red
        $missing += $mod
    }
}

# Android 子模块检查
$androidModuleDir = Join-Path $moduleDir "AndroidPlayer"
if (Test-Path $androidModuleDir) {
    $androidSubModules = @{
        "SDK"   = "Android SDK"
        "NDK"   = "Android NDK"  
        "OpenJDK" = "Android OpenJDK"
    }
    foreach ($sub in $androidSubModules.Keys) {
        $found = Get-ChildItem $androidModuleDir -Directory -Recurse -Depth 2 |
                 Where-Object { $_.Name -like "*$sub*" -or $_.Name -like "*$($sub.ToLower())*" }
        if ($found) {
            Write-Host "  [OK] $($androidSubModules[$sub])" -ForegroundColor Green
        } else {
            Write-Host "  [缺失] $($androidSubModules[$sub])" -ForegroundColor Red
            $missing += "android-$sub"
        }
    }
}

# 尝试自动安装缺失模块
if ($missing.Count -gt 0 -and (Test-Path $unityHub)) {
    Write-Host ""
    Write-Host ">>> 尝试通过 Unity Hub 安装缺失模块..." -ForegroundColor Yellow
    
    $moduleList = @()
    if ($missing -contains "AndroidPlayer") { $moduleList += "android" }
    if ($missing -contains "iOSSupport")   { $moduleList += "ios" }
    if ($missing -contains "WebGLSupport") { $moduleList += "webgl" }
    if ($missing -contains "android-SDK")   { $moduleList += "android-sdk-ndk-tools" }
    if ($missing -contains "android-NDK")   { $moduleList += "android-sdk-ndk-tools" }
    if ($missing -contains "android-OpenJDK") { $moduleList += "android-open-jdk" }
    
    $moduleList = $moduleList | Select-Object -Unique
    $moduleArgs = ($moduleList | ForEach-Object { "-m $_" }) -join " "
    
    $installCmd = "& `"$unityHub`" -- --headless install-modules --version $unityVersion $moduleArgs --childModules"
    Write-Host "  执行: $installCmd" -ForegroundColor DarkGray
    
    $result = Invoke-Expression $installCmd 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] 模块安装命令已执行" -ForegroundColor Green
    } else {
        Write-Host "[失败] 自动安装失败，请打开 Unity Hub 手动安装" -ForegroundColor Red
        Write-Host "  Unity Hub → 安装 → $unityVersion → 添加模块" -ForegroundColor Yellow
    }
} elseif ($missing.Count -eq 0) {
    Write-Host ""
    Write-Host "[全部通过] 所有构建模块已就绪" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[注意] Unity Hub 未找到，无法自动安装缺失模块" -ForegroundColor Yellow
    Write-Host "  请手动打开 Unity Hub → 安装 → $unityVersion → 添加模块" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Unity 模块验证完成 ===" -ForegroundColor Cyan
