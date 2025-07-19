# 新构建脚本说明

## 📋 脚本概览

经过重构，现在提供了更简洁、更可靠的构建脚本：

### Windows 脚本
- `build_release.ps1` - PowerShell 生产构建脚本（推荐）
- `quick_build.bat` - 批处理快速构建脚本

### Linux/macOS 脚本
- `build_release.sh` - Bash 生产构建脚本
- `quick_build.sh` - Bash 快速构建脚本

## 🚀 使用方法

### Windows 用户

#### 生产构建（推荐）
```powershell
# 使用 PowerShell（推荐）
.\scripts\build_release.ps1 1.0.0

# 或者不指定版本（默认 1.0.0）
.\scripts\build_release.ps1
```

#### 快速构建（测试用）
```cmd
# 使用批处理文件
scripts\quick_build.bat
```

### Linux/macOS 用户

#### 生产构建
```bash
# 设置执行权限（首次运行）
chmod +x scripts/build_release.sh

# 执行构建
./scripts/build_release.sh 1.0.0

# 或者不指定版本（默认 1.0.0）
./scripts/build_release.sh
```

#### 快速构建（测试用）
```bash
# 设置执行权限（首次运行）
chmod +x scripts/quick_build.sh

# 执行构建
./scripts/quick_build.sh
```

## 🔧 脚本特性

### PowerShell 脚本 (`build_release.ps1`)
- ✅ **彩色输出**: 使用不同颜色显示状态信息
- ✅ **版本参数**: 支持命令行指定版本号
- ✅ **文件检查**: 检查必要的配置文件
- ✅ **自动复制**: 自动复制 APK 到根目录和发布目录
- ✅ **构建信息**: 生成详细的构建信息文件
- ✅ **错误处理**: 友好的错误提示和状态显示

### Bash 脚本 (`build_release.sh`)
- ✅ **跨平台**: 支持 Linux 和 macOS
- ✅ **彩色输出**: 使用 ANSI 颜色代码
- ✅ **版本参数**: 支持命令行指定版本号
- ✅ **文件检查**: 检查必要的配置文件
- ✅ **自动复制**: 自动复制 APK 到根目录和发布目录
- ✅ **构建信息**: 生成详细的构建信息文件
- ✅ **GUI 集成**: 支持打开文件管理器（如果可用）

### 快速构建脚本
- ✅ **简化流程**: 只执行必要的构建步骤
- ✅ **快速测试**: 适合开发过程中的快速测试
- ✅ **自动复制**: 复制 APK 到根目录方便访问

## 📁 输出文件

### 生产构建输出
```
build/
├── release/
│   ├── lksms-v1.0.0-release.apk     # 带版本号的 APK
│   ├── lksms-v1.0.0-release.aab     # 带版本号的 AAB（如果构建）
│   └── build-info-v1.0.0.txt        # 构建信息文件
└── app/outputs/flutter-apk/
    └── app-release.apk               # 原始 APK 文件

lksms-release.apk                     # 根目录快速访问副本
```

### 快速构建输出
```
build/app/outputs/flutter-apk/
└── app-release.apk                   # 原始 APK 文件

lksms-debug.apk                       # 根目录快速访问副本
```

## 🎯 脚本优势

### 相比之前的批处理脚本
1. **更好的错误处理**: 不会因为错误级别检查而意外退出
2. **跨平台支持**: 提供 Windows、Linux、macOS 的原生脚本
3. **彩色输出**: 更直观的状态显示
4. **简化逻辑**: 去掉了复杂的条件判断，更稳定可靠

### PowerShell vs 批处理
- **PowerShell 优势**: 更现代的语法，更好的错误处理，更丰富的功能
- **批处理优势**: 兼容性更好，不需要特殊的执行策略设置

## 🔍 故障排除

### Windows PowerShell 执行策略问题
如果遇到执行策略错误：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Linux/macOS 权限问题
如果脚本无法执行：
```bash
chmod +x scripts/build_release.sh
chmod +x scripts/quick_build.sh
```

### 构建失败
1. 检查 Flutter 环境：`flutter doctor`
2. 检查签名配置：确保 `android/key.properties` 和密钥库文件存在
3. 清理项目：`flutter clean && flutter pub get`

## 📝 自定义配置

### 修改默认版本
编辑脚本文件，修改默认版本号：

**PowerShell:**
```powershell
[string]$Version = "1.0.0"  # 修改这里
```

**Bash:**
```bash
VERSION=${1:-"1.0.0"}  # 修改这里
```

### 启用清理和依赖获取
如果需要每次都执行完整的清理和依赖获取，可以取消脚本中相关行的注释。

## 🔗 相关文件

- `scripts/README_BUILD.md` - 完整的构建说明文档
- `android/key.properties` - Android 签名配置
- `android/app/lksms-release-key.jks` - 签名密钥库文件

## 📞 技术支持

如果遇到问题：
1. 检查 Flutter 环境：`flutter doctor`
2. 查看详细错误信息
3. 参考 `scripts/README_BUILD.md` 中的故障排除部分
