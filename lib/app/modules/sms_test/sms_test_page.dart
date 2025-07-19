import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../providers/sms_provider.dart';

/// 短信测试页面
class SmsTestPage extends StatefulWidget {
  const SmsTestPage({Key? key}) : super(key: key);

  @override
  State<SmsTestPage> createState() => _SmsTestPageState();
}

class _SmsTestPageState extends State<SmsTestPage> {
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _smsController = Get.put(SmsController());

  bool _hasPermission = false;
  bool _isSending = false;
  List<Map<String, dynamic>> _simCards = [];
  int _selectedSimIndex = 0;

  @override
  void initState() {
    super.initState();
    // 初始化原生短信服务
    SmsProvider.initialize();
    _checkPermissionAndLoadSimCards();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// 检查权限并加载SIM卡信息
  Future<void> _checkPermissionAndLoadSimCards() async {
    final hasPermission = await SmsProvider.checkSmsPermission();
    final simCards = await SmsProvider.getSimCardInfo();

    setState(() {
      _hasPermission = hasPermission;
      _simCards = simCards;
    });
  }

  /// 请求权限
  Future<void> _requestPermission() async {
    final granted = await SmsProvider.requestSmsPermission();
    if (granted) {
      await _checkPermissionAndLoadSimCards();
    }
  }

  /// 发送短信
  Future<void> _sendSms() async {
    if (_phoneController.text.isEmpty || _messageController.text.isEmpty) {
      Get.snackbar('错误', '请填写手机号码和短信内容');
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final subscriptionId = _simCards.isNotEmpty && _selectedSimIndex < _simCards.length
          ? _simCards[_selectedSimIndex]['subscriptionId'] as int
          : -1;

      final result = await SmsProvider.sendSms(
        phoneNumber: _phoneController.text.trim(),
        message: _messageController.text.trim(),
        subscriptionId: subscriptionId,
      );

      if (result.success) {
        Get.snackbar('成功', result.message, backgroundColor: Colors.green);
      } else {
        Get.snackbar('失败', result.message, backgroundColor: Colors.red);
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  /// 批量发送测试
  Future<void> _sendBatchSms() async {
    final testContacts = [
      {'phoneNumber': '10086', 'message': '测试短信1'},
      {'phoneNumber': '10010', 'message': '测试短信2'},
    ];

    setState(() {
      _isSending = true;
    });

    try {
      final results = await SmsProvider.sendBatchSms(testContacts);
      final successCount = results.where((r) => r.success).length;
      
      Get.snackbar(
        '批量发送完成', 
        '成功: $successCount/${results.length}',
        backgroundColor: successCount == results.length ? Colors.green : Colors.orange,
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('短信测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 权限状态卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '权限状态',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _hasPermission ? Icons.check_circle : Icons.error,
                          color: _hasPermission ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(_hasPermission ? '已获得短信权限' : '未获得短信权限'),
                        const Spacer(),
                        if (!_hasPermission)
                          ElevatedButton(
                            onPressed: _requestPermission,
                            child: const Text('请求权限'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // SIM卡选择
            if (_simCards.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIM卡选择',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        value: _selectedSimIndex,
                        isExpanded: true,
                        items: _simCards.asMap().entries.map((entry) {
                          final index = entry.key;
                          final simCard = entry.value;
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(
                              '${simCard['displayName']} (${simCard['carrierName']})',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSimIndex = value ?? 0;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 短信发送表单
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '发送短信',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: '手机号码',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: '短信内容',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hasPermission && !_isSending ? _sendSms : null,
                            child: _isSending
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('发送短信'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _hasPermission && !_isSending ? _sendBatchSms : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                            ),
                            child: const Text('批量测试'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 发送历史
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '发送历史',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _smsController.clearHistory(),
                            child: const Text('清空'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Obx(() {
                          final history = _smsController.smsHistory;
                          if (history.isEmpty) {
                            return const Center(
                              child: Text('暂无发送记录'),
                            );
                          }
                          
                          return ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final result = history[index];
                              return ListTile(
                                leading: Icon(
                                  result.success ? Icons.check_circle : Icons.error,
                                  color: result.success ? Colors.green : Colors.red,
                                ),
                                title: Text(result.message),
                                subtitle: Text('状态: ${result.status?.name ?? "未知"}'),
                                trailing: Text(
                                  DateTime.now().toString().substring(11, 19),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
