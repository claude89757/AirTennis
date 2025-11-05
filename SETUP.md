# AirTennis 配置指南

## 必要的配置步骤

### 1. 添加 Motion 权限说明

由于应用需要访问设备的运动传感器（加速度计、陀螺仪），需要在 Xcode 项目中添加权限说明：

#### 操作步骤：

1. 打开 `AirTennis.xcodeproj` 项目
2. 选择左侧导航栏中的 **AirTennis** 项目
3. 选择 **AirTennis** Target
4. 进入 **Info** 标签页
5. 在 **Custom iOS Target Properties** 中添加以下键值对：

| Key | Type | Value |
|-----|------|-------|
| **Privacy - Motion Usage Description** | String | 我们需要访问运动传感器来识别您的网球挥拍动作 |

或者使用原始键名：

```
NSMotionUsageDescription: 我们需要访问运动传感器来识别您的网球挥拍动作
```

### 2. 设置部署目标

确保项目的 **Deployment Target** 设置为 **iOS 17.0** 或更高版本：

1. 选择 **AirTennis** Target
2. 进入 **General** 标签页
3. 在 **Deployment Info** 中设置：
   - **Minimum Deployments**: iOS 17.0

### 3. 添加文件到 Xcode 项目

由于我们创建了新的文件和目录，需要将它们添加到 Xcode 项目中：

#### 方法一：通过 Xcode（推荐）

1. 在 Xcode 中，右键点击 **AirTennis** 文件夹
2. 选择 **Add Files to "AirTennis"...**
3. 选择新创建的目录（Models, Views, ViewModels, Services）
4. 确保勾选：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets: AirTennis**

#### 方法二：拖拽添加

1. 在 Finder 中打开项目目录
2. 将新创建的文件夹（Models, Views, ViewModels, Services）拖拽到 Xcode 的项目导航器中
3. 在弹出对话框中确认：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets: AirTennis**

### 4. 验证项目结构

确保 Xcode 项目导航器中的结构如下：

```
AirTennis/
├── AirTennisApp.swift
├── ContentView.swift
├── Models/
│   ├── SwingType.swift
│   └── SwingData.swift
├── Views/
│   ├── MainView.swift
│   └── TrainingView.swift
├── ViewModels/
│   └── TrainingViewModel.swift
├── Services/
│   ├── MotionManager.swift
│   ├── SpeedCalculator.swift
│   └── SwingDetector.swift
├── Resources/
│   └── Sounds/
└── Assets.xcassets
```

## 运行应用

### 在真机上运行（推荐）

**重要**：由于模拟器不支持运动传感器，必须在真实 iPhone 设备上测试！

1. 使用 USB 连接 iPhone 到 Mac
2. 在 Xcode 顶部选择您的 iPhone 设备
3. 点击 **Run** 按钮（或按 Cmd+R）
4. 首次运行时需要：
   - 信任开发者证书（在 iPhone 的 设置 → 通用 → VPN与设备管理）
   - 允许运动传感器访问权限

### 测试传感器功能

1. 启动应用
2. 点击 **开始训练**
3. 点击 **开始** 按钮
4. 手持 iPhone，模拟网球正手挥拍动作
5. 观察应用是否能检测到挥拍并显示数据

## 常见问题

### Q: 应用检测不到挥拍？

**A:** 检查以下几点：
1. 确认运行在真实设备上（不是模拟器）
2. 确认已授予运动权限
3. 挥拍动作要足够明显（加速度 > 2.5G）
4. 查看 Xcode 控制台日志

### Q: 权限提示没有弹出？

**A:** 尝试：
1. 删除应用重新安装
2. 检查 Info.plist 是否正确配置
3. 重启 iPhone

### Q: 编译错误？

**A:** 确保：
1. 所有新文件都已添加到 Xcode 项目
2. Target Membership 正确（文件右侧面板）
3. 清理项目：Product → Clean Build Folder (Shift+Cmd+K)

## 下一步

配置完成后，可以开始：

1. ✅ 测试基础功能
2. ✅ 调整检测参数（在 `SwingDetector.swift` 中）
3. ✅ 添加音效文件（下载并放入 `Resources/Sounds/` 目录）
4. ✅ 根据实际测试调优阈值

## 需要帮助？

如果遇到问题，请检查：
- Xcode 控制台日志
- 设备是否支持 Core Motion
- iOS 版本是否 >= 17.0
