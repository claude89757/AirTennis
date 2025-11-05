# AirTennis - 网球体感训练应用

一个基于 iPhone 传感器的网球挥拍动作识别和训练应用。

## 项目概述

AirTennis 使用 iPhone 的加速度计和陀螺仪来识别网球挥拍动作（正手/反手），计算挥拍速度和估算击球速度，并提供实时反馈。

### 核心功能

- ✅ **动作识别**：自动识别正手和反手挥拍
- ✅ **速度计算**：实时显示挥拍速度和估算球速
- ✅ **实时反馈**：即时的视觉和数据反馈
- ✅ **数据统计**：训练会话统计和历史记录
- ✅ **本地存储**：使用 SwiftData 持久化数据

### 技术特性

- **开发语言**：Swift 5.9+
- **UI 框架**：SwiftUI
- **传感器**：Core Motion (100Hz 采样率)
- **动作识别**：基于规则引擎的实时检测
- **数据持久化**：SwiftData
- **最低支持**：iOS 17.0

## 项目结构

```
AirTennis/
├── Models/                    # 数据模型
│   ├── SwingType.swift       # 挥拍类型枚举
│   └── SwingData.swift       # 挥拍数据模型
├── Views/                     # UI 视图
│   ├── MainView.swift        # 主界面
│   └── TrainingView.swift    # 训练界面
├── ViewModels/                # 视图模型
│   └── TrainingViewModel.swift
├── Services/                  # 核心服务
│   ├── MotionManager.swift   # 传感器管理
│   ├── SpeedCalculator.swift # 速度计算
│   └── SwingDetector.swift   # 挥拍检测（规则引擎）
└── Resources/                 # 资源文件
    └── Sounds/               # 音效文件（待添加）
```

## 快速开始

### 1. 环境要求

- **Xcode**: 15.0+
- **iOS**: 17.0+
- **设备**: 真实 iPhone（模拟器不支持运动传感器）
- **Apple Developer Account**: 用于真机测试

### 2. 配置项目

详细配置步骤请查看 [SETUP.md](./SETUP.md)

**关键步骤摘要**：

1. 打开 `AirTennis.xcodeproj`
2. 添加 Motion 权限说明到 Info.plist
3. 将新文件添加到 Xcode 项目
4. 连接 iPhone 并运行

### 3. 运行应用

```bash
# 1. 连接 iPhone 到 Mac
# 2. 在 Xcode 中选择你的设备
# 3. 按 Cmd+R 运行
```

## 使用指南

### 基本使用

1. **启动应用** → 点击"开始训练"
2. **开始训练** → 点击"开始"按钮
3. **挥拍动作** → 手持 iPhone，做出网球挥拍动作
4. **查看结果** → 实时显示动作类型和速度数据
5. **停止训练** → 点击"停止"查看本次统计

### 最佳实践

- 📱 **握持方式**：握住 iPhone，就像握网球拍一样
- 💪 **动作幅度**：做出完整的挥拍动作，不要只是晃动手腕
- 🎯 **检测范围**：保持手机屏幕面向前方，pitch 角度在 -30° 到 30° 之间
- ⏱️ **挥拍速度**：正常挥拍速度即可，系统会自动检测峰值

### 识别规则

#### 正手（Forehand）
- X轴加速度峰值 > 2.5G（向右挥动）
- Z轴旋转速率 > 150°/s（顺时针旋转）
- 持续时间：0.3-1.0秒

#### 反手（Backhand）
- X轴加速度峰值 < -2.5G（向左挥动）
- Z轴旋转速率 < -150°/s（逆时针旋转）
- 持续时间：0.3-1.0秒

## 技术实现

### 核心算法

#### 1. 速度计算

```swift
// 基于角速度计算线速度
v = ω × r

其中：
- v: 线速度（m/s）
- ω: 角速度（rad/s）= sqrt(gx² + gy² + gz²)
- r: 手臂长度（默认 0.65m）
```

#### 2. 球速估算

```swift
球速 = 挥拍速度 × 碰撞系数 × 3.6

碰撞系数：
- 正手/反手：0.65
- 未识别：0.60
```

#### 3. 状态机

```
IDLE → DETECTING → SWINGING → PEAK → CLASSIFYING → COMPLETED → IDLE
```

### 性能指标

- **采样率**：100Hz (每秒100个数据点)
- **延迟**：< 50ms (从检测到显示)
- **准确率**：目标 >85% (需实际测试调优)
- **电池续航**：> 2小时连续使用

## 调优指南

如果检测效果不理想，可以调整以下参数（在 `SwingDetector.swift` 中）：

```swift
// 加速度阈值（G）- 降低以提高灵敏度
private let accelerationThreshold: Double = 2.5

// 旋转速率阈值（rad/s）- 约150°/s
private let rotationThreshold: Double = 2.62

// 挥拍持续时间范围（秒）
private let minSwingDuration: TimeInterval = 0.3
private let maxSwingDuration: TimeInterval = 1.0

// 姿态角度范围（弧度）
private let minPitchAngle: Double = -0.52  // 约-30°
private let maxPitchAngle: Double = 0.52   // 约30°
```

### 调试技巧

1. **查看日志**：Xcode 控制台会输出详细的检测日志
2. **阈值调整**：逐步降低或提高阈值，观察效果
3. **数据可视化**：可以添加实时图表显示传感器数据
4. **测试样本**：多次挥拍，记录成功和失败的案例

## 已知限制

- ❌ 仅支持 iPhone（iPad 可能工作但未测试）
- ❌ 模拟器不支持（无运动传感器）
- ❌ 需要 iOS 17.0+
- ⚠️ 速度估算有误差（±10-15%）
- ⚠️ 不同手机握持方式影响准确度
- ⚠️ 左撇子用户需要调整阈值符号

## 后续规划

### Version 1.1 (Week 9-12)
- [ ] 增加发球和截击识别
- [ ] Apple Watch 支持
- [ ] 音效反馈系统
- [ ] 震动反馈（Haptic）
- [ ] 训练计划功能

### Version 1.2 (Week 13-16)
- [ ] Create ML 模型（提升准确率）
- [ ] 挥拍轨迹 3D 可视化
- [ ] 数据导出功能
- [ ] 动作评分和建议

### Version 2.0 (Future)
- [ ] 蓝牙/WiFi 互联对战
- [ ] 视频录制与分析
- [ ] 社交分享功能
- [ ] 云端数据同步

## 贡献指南

欢迎提交 Issue 和 Pull Request！

### 开发流程

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详见 [LICENSE](LICENSE) 文件

## 鸣谢

- Apple Core Motion Framework
- SwiftUI & SwiftData
- 网球技术参考资料
- 开源社区

---

**Made with ❤️ for Tennis Lovers**

如有问题，请提交 [Issue](https://github.com/yourusername/AirTennis/issues)
