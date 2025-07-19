#!/bin/bash

# 设置脚本执行权限
# 使用方法: ./setup_permissions.sh

echo "设置脚本执行权限..."

# 设置所有 shell 脚本的执行权限
chmod +x scripts/*.sh

echo "权限设置完成！"
echo
echo "可用脚本："
echo "- ./scripts/generate_keystore.sh  # 生成签名密钥"
echo "- ./scripts/build_release.sh      # 生产打包"
echo "- ./scripts/quick_build.sh        # 快速构建"
