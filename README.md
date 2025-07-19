# LKSMS 自动短信发送应用

一个基于 Flutter 开发的企业级自动短信发送应用，支持定时轮询服务器获取短信任务并自动发送，具备完善的权限管理、错误处理和监控功能。

## ✨ 功能特点

- 🔄 **智能轮询机制**: 定时轮询服务器获取待发送短信任务，支持并发控制
- 📱 **自动短信发送**: 基于原生 Android SMS API，支持权限检查和异常处理
- 🚀 **前台服务**: 保证应用在后台持续运行，防止系统杀进程
- 📊 **实时监控**: 任务状态实时显示，支持统计分析和历史记录
- 🛡️ **完善的错误处理**: 详细的日志记录和用户友好的错误提示
- ⚙️ **灵活配置**: 支持轮询间隔、发送间隔、任务数量等参数配置
- 🔐 **安全认证**: HTTP Basic 认证，支持自定义服务器配置

## 🛠️ 技术栈

### 核心框架
- **Flutter**: 3.24.x (最新稳定版)
- **Dart**: 3.4.1+
- **GetX**: 4.6.6 (状态管理、路由管理、依赖注入)

### 主要依赖
- **dio**: 5.3.2 (HTTP 网络请求)
- **get_storage**: 2.1.1 (本地数据持久化)
- **flutter_foreground_task**: 6.5.0 (前台服务)
- **permission_handler**: 11.0.1 (权限管理)
- **connectivity_plus**: 5.0.1 (网络连接检测)
- **logger**: 2.6.0 (日志记录框架)

### 开发工具
- **json_annotation**: 4.8.1 (JSON 序列化)
- **build_runner**: 2.4.7 (代码生成)
- **flutter_launcher_icons**: 0.13.1 (应用图标)

## 📁 项目结构

```
lib/
├── main.dart                          # 应用入口
├── app/
│   ├── bindings/                      # GetX 依赖注入绑定
│   │   └── initial_binding.dart
│   ├── controllers/                   # 全局控制器
│   │   └── app_controller.dart        # 应用全局控制器
│   ├── data/                          # 数据层
│   │   ├── models/                    # 数据模型
│   │   │   ├── api_response.dart      # API 响应模型
│   │   │   ├── app_settings.dart      # 应用设置模型
│   │   │   ├── pending_task.dart      # 待发送任务模型
│   │   │   ├── report_request.dart    # 结果汇报模型
│   │   │   ├── sent_task.dart         # 已发送任务模型
│   │   │   └── task_statistics.dart   # 统计数据模型
│   │   ├── providers/                 # 数据提供者
│   │   │   ├── api_provider.dart      # API 提供者
│   │   │   ├── sms_provider.dart      # 短信提供者
│   │   │   └── storage_provider.dart  # 存储提供者
│   │   └── repositories/              # 数据仓库
│   │       ├── settings_repository.dart # 设置仓库
│   │       └── sms_repository.dart    # 短信仓库
│   ├── modules/                       # 功能模块
│   │   ├── layout/                    # 布局模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── home/                      # 主页模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   ├── views/
│   │   │   └── widgets/
│   │   ├── tasks/                     # 任务模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── settings/                  # 设置模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   ├── statistics/                # 统计模块
│   │   │   ├── bindings/
│   │   │   ├── controllers/
│   │   │   └── views/
│   │   └── sms_test/                  # 短信测试模块
│   ├── routes/                        # 路由配置
│   │   ├── app_pages.dart
│   │   └── app_routes.dart
│   ├── services/                      # 服务层
│   │   ├── api_client.dart            # API 客户端
│   │   ├── foreground_service.dart    # 前台服务
│   │   ├── isolate_communication_service.dart # Isolate 通信服务
│   │   ├── notification_service.dart  # 通知服务
│   │   └── sms_task_handler.dart      # 短信任务处理器
│   └── utils/                         # 工具类
│       ├── constants.dart             # 常量定义
│       └── logger.dart                # 日志工具
```

## 🏗️ 核心架构

### 1. 主线程轮询架构
- **前台任务 Isolate**: 定时触发轮询信号
- **主线程处理**: 所有业务逻辑在主线程执行
- **并发控制**: 防止重复轮询，确保任务顺序执行
- **异常隔离**: 单个任务失败不影响整体服务

### 2. 模块化布局设计
- **LayoutView**: 统一管理底部导航栏
- **独立页面**: 每个功能页面独立管理 AppBar 和功能按钮
- **状态保持**: 使用 IndexedStack 保持页面状态
- **职责分离**: 清晰的功能边界和数据流

### 3. 静态服务架构
- **ApiClient**: 静态方法提供 API 调用
- **SettingsRepository**: 静态方法管理配置数据
- **SmsProvider**: 原生短信功能封装
- **NotificationService**: 用户通知管理

## 🚀 核心功能模块

### 1. 智能轮询机制
- 🔄 定时轮询 `/api/v1/sms/tasks/pending` 接口
- ⚙️ 可配置轮询间隔 (默认 30 秒)
- 🛡️ 并发控制，防止重复轮询
- 📊 自动过滤重复任务

### 2. 原生短信发送
- 📱 基于 Android 原生 SMS API
- 🔐 完善的权限检查和请求流程
- ⏱️ 可配置发送间隔 (默认 1 秒)
- 🎯 支持用户确认和拒绝处理
- 📝 详细的发送状态反馈

### 3. 结果汇报系统
- 📤 自动汇报发送结果到 `/api/v1/sms/report` 接口
- ✅ 支持成功、失败、重试状态汇报
- 🔄 网络异常时的重试机制
- 📋 完整的错误信息记录

### 4. 前台服务保障
- 🚀 基于 flutter_foreground_task 6.5.0 实现
- 🛡️ 防止系统杀进程，确保服务持续运行
- 🔔 持久通知显示服务状态
- 📱 支持悬浮窗权限管理

### 5. 数据持久化
- 💾 基于 GetStorage 实现本地存储
- ⚙️ 设置信息持久化
- 📊 任务状态本地缓存
- 🔄 支持数据导入导出

## 📱 页面功能

### 🏠 主页面 (HomeView)
- 📊 服务状态实时显示
- 🎛️ 启动/停止服务按钮
- ⚙️ 快速跳转设置页面
- 📱 权限状态检查
- 🔔 服务运行状态通知

### 📋 任务页面 (TasksView)
- 📝 任务列表实时显示 (待发送、发送中、已发送、失败)
- 🔍 任务状态过滤 (全部、待发送、已发送、失败)
- 🔎 关键词搜索功能
- 🗑️ 清除已完成任务
- 🔄 下拉刷新任务列表
- 📊 任务统计信息显示

### ⚙️ 设置页面 (SettingsView)
- 🌐 服务器地址配置
- 🔐 HTTP Basic 认证信息设置
- 📱 应用 ID 配置
- ⏱️ 轮询间隔设置 (秒)
- 📊 单次获取任务数量限制
- ⏰ 短信发送间隔设置 (毫秒)
- 💾 配置保存和验证

### 📊 统计页面 (StatisticsView)
- 📈 实时任务统计数据
- 📋 待处理新任务数量
- 🔄 待处理重试任务数量
- ⚡ 处理中任务数量
- ❌ 处理失败任务数量
- 🔄 手动刷新统计数据

## 💻 开发环境要求

- **Flutter SDK**: 3.24.x 或更高
- **Dart SDK**: 3.4.1 或更高
- **Android**: 6.0+ (minSdkVersion: 23)
- **Java**: JDK 11 或更高
- **Android Studio**: 最新版本 (推荐)

## 🚀 快速开始

### 1. 克隆项目
```bash
git clone https://github.com/yourusername/lksms-app.git
cd lksms-app
```

### 2. 安装依赖
```bash
flutter pub get
```

### 3. 代码生成
```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. 运行应用
```bash
# 调试模式
flutter run

# 发布模式
flutter run --release
```

## 📦 构建发布

### 快速构建 (测试用)
```bash
# Windows
scripts\quick_build.bat

# Linux/macOS
chmod +x scripts/quick_build.sh
./scripts/quick_build.sh
```

### 生产构建
```bash
# 1. 生成签名密钥
scripts\generate_keystore.bat  # Windows
./scripts/generate_keystore.sh # Linux/macOS

# 2. 配置签名信息
# 编辑 android/key.properties 文件

# 3. 构建发布版本
scripts\build_release.bat 1.0.0  # Windows
./scripts/build_release.sh 1.0.0 # Linux/macOS
```

## 🔐 权限要求

应用需要以下权限才能正常工作：

### Android 权限
- **SEND_SMS**: 发送短信权限 (核心功能)
- **FOREGROUND_SERVICE**: 前台服务权限
- **INTERNET**: 网络访问权限
- **ACCESS_NETWORK_STATE**: 网络状态检查
- **SYSTEM_ALERT_WINDOW**: 悬浮窗权限 (可选)
- **RECEIVE_BOOT_COMPLETED**: 开机自启动权限 (可选)

### 运行时权限
- 短信发送权限需要用户手动授权
- 悬浮窗权限需要用户在系统设置中开启

## 📋 API 接口

### 1. 获取待发送任务
```http
GET /api/v1/sms/tasks/pending?appId={appId}&limit={limit}
Authorization: Basic {base64(username:password)}

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "tasks": [
      {
        "taskId": "string",
        "phoneNumber": "string",
        "content": "string"
      }
    ]
  }
}
```

### 2. 汇报发送结果
```http
POST /api/v1/sms/report
Authorization: Basic {base64(username:password)}
Content-Type: application/json

{
  "taskId": "string",
  "appId": "string",
  "status": "success|failed",
  "errorMessage": "string",
  "shouldRetry": true|false
}
```

### 3. 获取统计信息
```http
GET /api/v1/admin/task-statistics
Authorization: Basic {base64(username:password)}

Response:
{
  "code": 200,
  "message": "success",
  "data": {
    "pendingNewTasks": 10,
    "pendingRetryTasks": 5,
    "processingTasks": 2,
    "failedTasks": 1
  }
}
```

## 📝 日志系统

应用集成了完善的日志系统，支持：
- 🔍 **多级别日志**: DEBUG、INFO、WARNING、ERROR
- 💾 **日志持久化**: 本地文件存储
- 🎯 **环境配置**: 开发和生产环境的不同日志级别
- 📊 **性能监控**: 关键操作的性能日志

### 日志查看方式
- **开发环境**: Android Studio Logcat
- **生产环境**: 应用内日志查看功能
- **文件日志**: 设备存储中的日志文件

## ⚙️ 配置说明

### 服务器配置
- **服务器地址**: 支持 HTTP/HTTPS，格式如 `https://api.example.com`
- **认证方式**: HTTP Basic 认证
- **应用 ID**: 用于标识不同的应用实例

### 轮询配置
- **轮询间隔**: 建议 30-60 秒，避免过于频繁
- **任务数量**: 单次获取的任务数量限制 (建议 1-10)
- **发送间隔**: 短信发送之间的间隔时间 (建议 1000ms)

## 🔧 故障排除

### 常见问题

#### 1. 短信发送失败
- ✅ 检查 SEND_SMS 权限是否已授权
- ✅ 确认手机号码格式正确
- ✅ 检查短信内容是否包含敏感词
- ✅ 验证 SIM 卡状态和余额

#### 2. 服务停止运行
- ✅ 检查前台服务权限
- ✅ 关闭电池优化 (设置 → 电池 → 应用优化)
- ✅ 检查悬浮窗权限
- ✅ 确认应用未被系统清理

#### 3. 网络连接失败
- ✅ 检查服务器地址格式
- ✅ 验证网络连接状态
- ✅ 确认认证信息正确
- ✅ 检查防火墙和代理设置

#### 4. 任务获取失败
- ✅ 验证 API 接口地址
- ✅ 检查 HTTP Basic 认证信息
- ✅ 确认应用 ID 配置正确
- ✅ 查看服务器日志

### 调试工具

#### 测试脚本
项目提供了多个测试脚本用于验证功能：
- `test_script/sms_permission_test.dart` - 短信权限测试
- `test_script/exception_handling_test.dart` - 异常处理测试
- `test_script/main_thread_polling_test.dart` - 轮询机制测试

#### 日志分析
```bash
# 查看应用日志
adb logcat | grep "LKSMS"

# 过滤错误日志
adb logcat | grep -E "(ERROR|FATAL)"
```

## 🤝 贡献指南

1. **Fork 项目** 到你的 GitHub 账户
2. **创建功能分支** (`git checkout -b feature/AmazingFeature`)
3. **提交更改** (`git commit -m 'Add some AmazingFeature'`)
4. **推送到分支** (`git push origin feature/AmazingFeature`)
5. **创建 Pull Request**

### 开发规范
- 遵循 Dart 代码规范
- 添加必要的注释和文档
- 编写单元测试
- 更新相关文档

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 技术支持

如果遇到问题或需要技术支持，请：
1. 查看 [故障排除](#-故障排除) 部分
2. 搜索已有的 [Issues](https://github.com/yourusername/lksms-app/issues)
3. 创建新的 Issue 并提供详细信息
4. 联系开发团队

## 📝 免责声明

本项目仅供个人学习交流研究，非商用，禁止商业用途和倒卖，不承担用户使用资源对自己或他人造成的任何影响和伤害。