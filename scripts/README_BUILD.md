# Android 签名和打包说明

## 📋 概述

本文档说明如何为 LKSMS Android 应用生成签名密钥和进行生产打包。

## 🔑 签名密钥生成

### Windows 用户

```bash
# 生成签名密钥（推荐使用修复版本）
scripts\generate_keystore_simple.bat

# 或者使用原版本（如果遇到中文编码问题请使用上面的版本）
scripts\generate_keystore.bat

# 按提示输入以下信息：
# - 密钥库密码（请牢记）
# - 密钥密码（请牢记）
# - 姓名
# - 组织单位
# - 组织
# - 城市
# - 省份
# - 国家代码（如：CN）
```

### Linux/macOS 用户

```bash
# 添加执行权限
chmod +x scripts/generate_keystore.sh

# 生成签名密钥
./scripts/generate_keystore.sh
```

### 生成后的文件

- `android/app/lksms-release-key.jks` - 签名密钥库文件
- `android/key.properties` - 签名配置文件（需要手动填写密码）

## ⚙️ 配置签名

编辑 `android/key.properties` 文件，填写正确的密码：

```properties
# Android 签名配置文件
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=lksms-key
storeFile=lksms-release-key.jks
```

## 📦 生产打包

### 完整构建（推荐）

**Windows:**
```bash
scripts\build_release.ps1 1.0.0
```

**Linux/macOS:**
```bash
chmod +x scripts/build_release.sh
./scripts/build_release.sh 1.0.0
```

### 快速构建（测试用）

```bash
# Windows
scripts\quick_build.bat

# Linux/macOS
chmod +x scripts/quick_build.sh
./scripts/quick_build.sh
```

## 📁 构建产物

构建完成后，在 `build/release/` 目录下会生成：

- `lksms-v1.0.0-release.apk` - APK 文件（用于直接安装）
- `lksms-v1.0.0-release.aab` - App Bundle 文件（用于 Google Play）
- `mapping-v1.0.0.txt` - 代码混淆映射文件（用于崩溃分析）
- `build-info-v1.0.0.txt` - 构建信息文件

## 🔒 安全注意事项

### 密钥安全

1. **妥善保管密钥库文件和密码**
   - 密钥库文件：`android/app/lksms-release-key.jks`
   - 配置文件：`android/key.properties`

2. **备份密钥库**
   - 将密钥库文件备份到安全位置
   - 记录密钥库密码和密钥密码

3. **不要提交到版本控制**
   - 密钥库文件不要提交到 Git
   - 配置文件不要提交到 Git
   - 参考 `scripts/gitignore_signing.txt` 更新 `.gitignore`

### 版本控制

将以下内容添加到 `.gitignore`：

```gitignore
# Android 签名文件
android/key.properties
android/app/*.jks
android/app/*.keystore
*.jks
*.keystore

# 构建产物
build/release/
*.apk
*.aab
```

## 🚀 发布流程

### Google Play 发布

1. 使用 `lksms-v1.0.0-release.aab` 文件
2. 上传到 Google Play Console
3. 保存 `mapping-v1.0.0.txt` 文件用于崩溃分析

### 直接分发

1. 使用 `lksms-v1.0.0-release.apk` 文件
2. 确保用户设备允许安装未知来源应用

## 🛠️ 构建配置

### 混淆配置

- 启用代码混淆和资源压缩
- 自定义混淆规则：`android/app/proguard-rules.pro`
- 保留 Flutter 和原生功能相关类

### 构建类型

- **Release**: 生产版本，启用混淆和签名
- **Debug**: 调试版本，使用调试签名

### 版本管理

- 版本号通过命令行参数指定
- 自动更新 `versionCode` 和 `versionName`
- 构建信息自动记录

## 🔍 故障排除

### 常见问题

1. **密钥库文件不存在**
   ```
   错误: 未找到密钥库文件
   解决: 运行 generate_keystore 脚本生成密钥
   ```

2. **签名配置错误**
   ```
   错误: 签名失败
   解决: 检查 key.properties 文件中的密码是否正确
   ```

3. **Flutter 环境问题**
   ```
   错误: 未找到 Flutter 环境
   解决: 确保 Flutter 已安装并配置环境变量
   ```

### 验证构建

```bash
# 检查 APK 签名
keytool -printcert -jarfile build/release/lksms-v1.0.0-release.apk

# 检查 APK 信息
aapt dump badging build/release/lksms-v1.0.0-release.apk
```

## 📞 技术支持

如果遇到构建问题：

1. 检查 Flutter 和 Android SDK 版本
2. 确认签名配置正确
3. 查看构建日志中的错误信息
4. 参考 Flutter 官方文档

## 📝 更新日志

- v1.0.0: 初始版本，支持基本的签名和打包功能
- 支持 APK 和 AAB 双格式构建
- 集成代码混淆和资源压缩
- 自动化构建流程和版本管理
