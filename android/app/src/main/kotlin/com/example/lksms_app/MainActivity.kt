package com.example.lksms

import android.Manifest
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.SmsManager
import android.telephony.SubscriptionInfo
import android.telephony.SubscriptionManager
import android.telephony.TelephonyManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.lksms/sms"
    private val SMS_PERMISSION_REQUEST_CODE = 1001
    private lateinit var methodChannel: MethodChannel
    private var permissionResult: MethodChannel.Result? = null
    private var smsResult: MethodChannel.Result? = null
    private var smsTimeout: Runnable? = null
    private val handler = Handler(Looper.getMainLooper())

    // 短信发送状态常量
    companion object {
        const val SMS_SENT_ACTION = "SMS_SENT"
        const val SMS_DELIVERED_ACTION = "SMS_DELIVERED"
    }

    // 短信状态广播接收器
    private val smsStatusReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                SMS_SENT_ACTION -> {
                    // 取消超时任务
                    smsTimeout?.let { handler.removeCallbacks(it) }
                    smsTimeout = null

                    when (resultCode) {
                        Activity.RESULT_OK -> {
                            sendSmsStatusToFlutter("sent", "短信发送成功", true)
                            smsResult?.success(hashMapOf(
                                "success" to true,
                                "message" to "短信发送成功",
                                "status" to "sent"
                            ))
                        }
                        SmsManager.RESULT_ERROR_GENERIC_FAILURE -> {
                            val errorMsg = "发送失败：通用错误"
                            sendSmsStatusToFlutter("failed", errorMsg, false)
                            smsResult?.success(hashMapOf(
                                "success" to false,
                                "message" to errorMsg,
                                "errorCode" to "GENERIC_FAILURE"
                            ))
                        }
                        SmsManager.RESULT_ERROR_NO_SERVICE -> {
                            val errorMsg = "发送失败：无服务"
                            sendSmsStatusToFlutter("failed", errorMsg, false)
                            smsResult?.success(hashMapOf(
                                "success" to false,
                                "message" to errorMsg,
                                "errorCode" to "NO_SERVICE"
                            ))
                        }
                        SmsManager.RESULT_ERROR_NULL_PDU -> {
                            val errorMsg = "发送失败：PDU为空"
                            sendSmsStatusToFlutter("failed", errorMsg, false)
                            smsResult?.success(hashMapOf(
                                "success" to false,
                                "message" to errorMsg,
                                "errorCode" to "NULL_PDU"
                            ))
                        }
                        SmsManager.RESULT_ERROR_RADIO_OFF -> {
                            val errorMsg = "发送失败：无线电关闭"
                            sendSmsStatusToFlutter("failed", errorMsg, false)
                            smsResult?.success(hashMapOf(
                                "success" to false,
                                "message" to errorMsg,
                                "errorCode" to "RADIO_OFF"
                            ))
                        }
                        else -> {
                            val errorMsg = "发送失败：用户拒绝或未知错误 (code: $resultCode)"
                            sendSmsStatusToFlutter("failed", errorMsg, false)
                            smsResult?.success(hashMapOf(
                                "success" to false,
                                "message" to errorMsg,
                                "errorCode" to "USER_DENIED_OR_UNKNOWN"
                            ))
                        }
                    }
                    smsResult = null
                }
                SMS_DELIVERED_ACTION -> {
                    when (resultCode) {
                        Activity.RESULT_OK -> {
                            sendSmsStatusToFlutter("delivered", "短信已送达", true)
                        }
                        else -> {
                            sendSmsStatusToFlutter("failed", "短信送达失败", false)
                        }
                    }
                }
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "checkSmsPermission" -> {
                    result.success(checkSmsPermission())
                }
                "requestSmsPermission" -> {
                    requestSmsPermission(result)
                }
                "sendSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    val subscriptionId = call.argument<Int>("subscriptionId") ?: -1

                    if (phoneNumber != null && message != null) {
                        sendSms(phoneNumber, message, subscriptionId, result)
                    } else {
                        result.error("INVALID_ARGUMENTS", "手机号码和短信内容不能为空", null)
                    }
                }
                "getSimCardInfo" -> {
                    result.success(getSimCardInfo())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // 注册短信状态广播接收器
        registerSmsStatusReceiver()
    }

    override fun onDestroy() {
        super.onDestroy()
        try {
            unregisterReceiver(smsStatusReceiver)
        } catch (e: Exception) {
            // 忽略取消注册时的异常
        }

        // 清理待处理的回调
        smsTimeout?.let { handler.removeCallbacks(it) }
        smsResult = null
        permissionResult = null
    }

    /**
     * 注册短信状态广播接收器
     */
    private fun registerSmsStatusReceiver() {
        val intentFilter = IntentFilter().apply {
            addAction(SMS_SENT_ACTION)
            addAction(SMS_DELIVERED_ACTION)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(smsStatusReceiver, intentFilter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(smsStatusReceiver, intentFilter)
        }
    }

    /**
     * 检查短信权限
     */
    private fun checkSmsPermission(): Boolean {
        return ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.SEND_SMS
        ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * 请求短信权限
     */
    private fun requestSmsPermission(result: MethodChannel.Result) {
        // 先检查是否已经有权限
        if (checkSmsPermission()) {
            result.success(true)
            return
        }

        // 保存结果回调，在权限请求完成后使用
        permissionResult = result

        ActivityCompat.requestPermissions(
            this,
            arrayOf(Manifest.permission.SEND_SMS),
            SMS_PERMISSION_REQUEST_CODE
        )
    }

    /**
     * 处理权限请求结果
     */
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            SMS_PERMISSION_REQUEST_CODE -> {
                val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED

                // 返回权限请求结果给 Flutter
                permissionResult?.success(granted)
                permissionResult = null

                // 同时通知 Flutter 权限结果（用于回调监听）
                methodChannel.invokeMethod("onPermissionResult", hashMapOf(
                    "permission" to "SEND_SMS",
                    "granted" to granted
                ))
            }
        }
    }

    /**
     * 发送短信
     */
    private fun sendSms(phoneNumber: String, message: String, subscriptionId: Int, result: MethodChannel.Result) {
        try {
            // 检查权限
            if (!checkSmsPermission()) {
                result.success(hashMapOf(
                    "success" to false,
                    "message" to "没有短信发送权限",
                    "errorCode" to "NO_PERMISSION"
                ))
                return
            }

            // 保存结果回调，在广播接收器中使用
            smsResult = result

            // 获取短信管理器
            val smsManager = if (subscriptionId != -1 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                SmsManager.getSmsManagerForSubscriptionId(subscriptionId)
            } else {
                SmsManager.getDefault()
            }

            // 创建发送和送达意图
            val sentIntent = PendingIntent.getBroadcast(
                this, 0, Intent(SMS_SENT_ACTION),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
            )

            val deliveredIntent = PendingIntent.getBroadcast(
                this, 0, Intent(SMS_DELIVERED_ACTION),
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
            )

            // 检查短信长度，如果超过160字符则分段发送
            if (message.length > 160) {
                val parts = smsManager.divideMessage(message)
                val sentIntents = ArrayList<PendingIntent>()
                val deliveredIntents = ArrayList<PendingIntent>()

                for (i in parts.indices) {
                    sentIntents.add(sentIntent)
                    deliveredIntents.add(deliveredIntent)
                }

                smsManager.sendMultipartTextMessage(
                    phoneNumber, null, parts, sentIntents, deliveredIntents
                )
            } else {
                smsManager.sendTextMessage(
                    phoneNumber, null, message, sentIntent, deliveredIntent
                )
            }

            // 设置超时处理（30秒后如果没有收到广播结果，则认为发送失败）
            smsTimeout = Runnable {
                smsResult?.success(hashMapOf(
                    "success" to false,
                    "message" to "发送超时：可能被用户拒绝或系统异常",
                    "errorCode" to "TIMEOUT"
                ))
                smsResult = null
            }
            handler.postDelayed(smsTimeout!!, 30000) // 30秒超时

        } catch (e: Exception) {
            result.success(hashMapOf(
                "success" to false,
                "message" to "发送失败：${e.message}",
                "errorCode" to "SEND_ERROR"
            ))
        }
    }

    /**
     * 获取SIM卡信息
     */
    private fun getSimCardInfo(): List<Map<String, Any>> {
        val simCards = mutableListOf<Map<String, Any>>()

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
                val subscriptionManager = getSystemService(Context.TELEPHONY_SUBSCRIPTION_SERVICE) as SubscriptionManager

                if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                    val subscriptionInfos = subscriptionManager.activeSubscriptionInfoList

                    subscriptionInfos?.forEach { subscriptionInfo ->
                        val simCard = hashMapOf(
                            "subscriptionId" to subscriptionInfo.subscriptionId,
                            "displayName" to (subscriptionInfo.displayName?.toString() ?: ""),
                            "carrierName" to (subscriptionInfo.carrierName?.toString() ?: ""),
                            "phoneNumber" to (subscriptionInfo.number ?: ""),
                            "simSlotIndex" to subscriptionInfo.simSlotIndex
                        )
                        simCards.add(simCard)
                    }
                }
            } else {
                // 对于较旧的Android版本，返回默认SIM卡信息
                val telephonyManager = getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
                val simCard = hashMapOf(
                    "subscriptionId" to -1,
                    "displayName" to "默认SIM卡",
                    "carrierName" to (telephonyManager.networkOperatorName ?: ""),
                    "phoneNumber" to "",
                    "simSlotIndex" to 0
                )
                simCards.add(simCard)
            }
        } catch (e: Exception) {
            // 如果获取失败，返回空列表
        }

        return simCards
    }

    /**
     * 向Flutter发送短信状态更新
     */
    private fun sendSmsStatusToFlutter(status: String, message: String, success: Boolean) {
        methodChannel.invokeMethod("onSmsStatusChanged", hashMapOf(
            "status" to status,
            "message" to message,
            "success" to success
        ))
    }
}
