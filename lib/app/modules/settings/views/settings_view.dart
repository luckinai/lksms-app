import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final SettingsController controller;

  // 文本控制器
  late final TextEditingController _serverUrlController;
  late final TextEditingController _appIdController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SettingsController>();

    // 初始化文本控制器
    _serverUrlController = TextEditingController(text: controller.tempServerUrl.value);
    _appIdController = TextEditingController(text: controller.tempAppId.value);
    _usernameController = TextEditingController(text: controller.tempUsername.value);
    _passwordController = TextEditingController(text: controller.tempPassword.value);

    // 监听控制器变化并更新响应式变量
    _serverUrlController.addListener(() {
      controller.tempServerUrl.value = _serverUrlController.text;
    });
    _appIdController.addListener(() {
      controller.tempAppId.value = _appIdController.text;
    });
    _usernameController.addListener(() {
      controller.tempUsername.value = _usernameController.text;
    });
    _passwordController.addListener(() {
      controller.tempPassword.value = _passwordController.text;
    });

    // 监听响应式变量变化并更新文本控制器
    ever(controller.tempServerUrl, (String value) {
      if (_serverUrlController.text != value) {
        _serverUrlController.text = value;
      }
    });
    ever(controller.tempAppId, (String value) {
      if (_appIdController.text != value) {
        _appIdController.text = value;
      }
    });
    ever(controller.tempUsername, (String value) {
      if (_usernameController.text != value) {
        _usernameController.text = value;
      }
    });
    ever(controller.tempPassword, (String value) {
      if (_passwordController.text != value) {
        _passwordController.text = value;
      }
    });
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _appIdController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: controller.showAbout,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServerSection(),
              const SizedBox(height: 24),
              _buildPollingSection(),
              // const SizedBox(height: 24),
              // _buildAboutSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildServerSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cloud, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  '服务器设置',
                  style: Get.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 服务器地址
            TextField(
              decoration: const InputDecoration(
                labelText: '服务器地址',
                hintText: '例如: https://api.example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
              controller: _serverUrlController,
            ),
            const SizedBox(height: 12),

            // 应用ID
            TextField(
              decoration: const InputDecoration(
                labelText: '应用ID',
                hintText: '输入应用ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.app_registration),
              ),
              controller: _appIdController,
            ),
            const SizedBox(height: 12),

            // 用户名
            TextField(
              decoration: const InputDecoration(
                labelText: '用户名',
                hintText: '输入用户名',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              controller: _usernameController,
            ),
            const SizedBox(height: 12),

            // 密码
            TextField(
              decoration: const InputDecoration(
                labelText: '密码',
                hintText: '输入密码',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPollingSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  '轮询设置',
                  style: Get.textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 轮询间隔
            Row(
              children: [
                const Icon(Icons.timer, size: 20),
                const SizedBox(width: 8),
                const Text('轮询间隔 (秒):'),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Slider(
                    value: controller.tempPollingInterval.value.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: controller.tempPollingInterval.value.toString(),
                    onChanged: (value) => controller.tempPollingInterval.value = value.round(),
                  )),
                ),
                SizedBox(
                  width: 40,
                  child: Obx(() => Text(
                    '${controller.tempPollingInterval.value}',
                    textAlign: TextAlign.center,
                  )),
                ),
              ],
            ),

            // 任务限制
            Row(
              children: [
                const Icon(Icons.list, size: 20),
                const SizedBox(width: 8),
                const Text('任务限制:'),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Slider(
                    value: controller.tempTaskLimit.value.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: controller.tempTaskLimit.value.toString(),
                    onChanged: (value) => controller.tempTaskLimit.value = value.round(),
                  )),
                ),
                SizedBox(
                  width: 40,
                  child: Obx(() => Text(
                    '${controller.tempTaskLimit.value}',
                    textAlign: TextAlign.center,
                  )),
                ),
              ],
            ),

            // 发送间隔
            Row(
              children: [
                const Icon(Icons.send, size: 20),
                const SizedBox(width: 8),
                const Text('发送间隔 (毫秒):'),
                const SizedBox(width: 8),
                Expanded(
                  child: Obx(() => Slider(
                    value: controller.tempSendInterval.value.toDouble(),
                    min: 100,
                    max: 5000,
                    divisions: 49,
                    label: controller.tempSendInterval.value.toString(),
                    onChanged: (value) => controller.tempSendInterval.value = value.round(),
                  )),
                ),
                SizedBox(
                  width: 60,
                  child: Obx(() => Text(
                    '${controller.tempSendInterval.value}',
                    textAlign: TextAlign.center,
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text('重置设置'),
          onPressed: controller.resetSettings,
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('保存设置'),
          onPressed: controller.saveSettings,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
