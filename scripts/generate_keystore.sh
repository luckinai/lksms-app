#!/bin/bash

# Android 应用签名密钥生成脚本
# 使用方法: ./generate_keystore.sh

echo "========================================"
echo "Android 应用签名密钥生成脚本"
echo "========================================"
echo

# 检查 Java 环境
if ! command -v java &> /dev/null; then
    echo "错误: 未找到 Java 环境，请确保已安装 JDK 并配置环境变量"
    exit 1
fi

# 设置密钥库文件路径
KEYSTORE_PATH="android/app/lksms-release-key.jks"
KEY_ALIAS="lksms-key"

echo "即将生成 Android 应用签名密钥..."
echo "密钥库文件: $KEYSTORE_PATH"
echo "密钥别名: $KEY_ALIAS"
echo

# 检查密钥库是否已存在
if [ -f "$KEYSTORE_PATH" ]; then
    echo "警告: 密钥库文件已存在！"
    read -p "是否覆盖现有密钥库？(y/N): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "操作已取消"
        exit 0
    fi
    echo "删除现有密钥库..."
    rm "$KEYSTORE_PATH"
fi

echo
echo "请按提示输入密钥信息..."
echo "注意: 请妥善保管密钥库密码和密钥密码，丢失后无法恢复！"
echo

# 创建目录（如果不存在）
mkdir -p "$(dirname "$KEYSTORE_PATH")"

# 生成密钥库
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storetype JKS

if [ $? -ne 0 ]; then
    echo
    echo "错误: 密钥生成失败！"
    exit 1
fi

echo
echo "========================================"
echo "密钥生成成功！"
echo "========================================"
echo "密钥库文件: $KEYSTORE_PATH"
echo "密钥别名: $KEY_ALIAS"
echo
echo "重要提醒:"
echo "1. 请妥善保管密钥库文件和密码"
echo "2. 密钥库文件不要提交到版本控制系统"
echo "3. 建议将密钥库文件备份到安全位置"
echo

# 创建 key.properties 模板
echo "正在创建 key.properties 配置文件..."
cat > android/key.properties << EOF
# Android 签名配置文件
# 请填写正确的密钥信息
storePassword=请输入密钥库密码
keyPassword=请输入密钥密码
keyAlias=$KEY_ALIAS
storeFile=lksms-release-key.jks
EOF

echo
echo "key.properties 配置文件已创建: android/key.properties"
echo "请编辑该文件，填写正确的密码信息"
echo
echo "下一步:"
echo "1. 编辑 android/key.properties 文件，填写密码"
echo "2. 运行 ./scripts/build_release.sh 进行生产打包"
echo
