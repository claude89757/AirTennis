#!/bin/bash

# 验证MP3文件是否在正确位置
echo "检查MP3文件位置..."

MP3_FILES=(
    "AirTennis/Resources/Sounds/tennis-ball-hit-151257.mp3"
    "AirTennis/Resources/Sounds/tennis-ball-hit-386155.mp3"
)

all_found=true
for file in "${MP3_FILES[@]}"; do
    if [ -f "$file" ]; then
        size=$(ls -lh "$file" | awk '{print $5}')
        echo "✅ 找到: $file (大小: $size)"
    else
        echo "❌ 未找到: $file"
        all_found=false
    fi
done

if [ "$all_found" = true ]; then
    echo ""
    echo "✅ 所有MP3文件都在正确位置！"
    echo "📝 注意: 由于项目使用 PBXFileSystemSynchronizedRootGroup，"
    echo "   Xcode 会自动同步这些文件。请在 Xcode 中打开项目以确保同步。"
else
    echo ""
    echo "❌ 部分文件缺失，请检查文件路径。"
    exit 1
fi

