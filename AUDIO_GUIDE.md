# AirTennis 音效资源指南

本指南介绍如何获取和添加音效文件到 AirTennis 项目。

## 需要的音效文件

应用需要以下 4 个音效文件：

| 文件名 | 用途 | 时长 | 描述 |
|--------|------|------|------|
| `swing.wav` | 挥拍音 | 0.2-0.4秒 | 快速挥动的"嗖"声 |
| `hit.wav` | 击球音 | 0.1-0.3秒 | 球拍击球的清脆声 |
| `success.wav` | 成功音 | 0.3-0.5秒 | 提示音（训练开始等） |
| `error.wav` | 错误音 | 0.2-0.4秒 | 警告提示音 |

## 方案一：下载免费音效（推荐）

### 1. Zapsplat（免费注册）

**网站**：https://www.zapsplat.com

**推荐音效**：

```
挥拍音 (swing.wav):
- 搜索: "tennis racket swing" 或 "whoosh fast"
- 推荐: "Tennis Racket Swipe 1"
- URL: https://www.zapsplat.com/music/tennis-racket-swipe-1/

击球音 (hit.wav):
- 搜索: "tennis ball hit" 或 "racket impact"
- 推荐: "Tennis Ball Hit Hard"
- URL: https://www.zapsplat.com/music/tennis-ball-hit-hard/

成功音 (success.wav):
- 搜索: "success notification"
- 推荐任意明亮的提示音

错误音 (error.wav):
- 搜索: "error beep"
- 推荐任意柔和的警告音
```

**下载步骤**：
1. 注册免费账号
2. 搜索音效
3. 下载 WAV 格式
4. 重命名文件为对应名称

---

### 2. Pixabay（无需注册）

**网站**：https://pixabay.com/sound-effects/

**搜索关键词**：
```
swing.wav: "swoosh", "whoosh"
hit.wav: "tennis", "impact"
success.wav: "bell", "ding"
error.wav: "buzz", "beep"
```

**优点**：
- 完全免费
- 无需注册
- CC0 授权（可商用）

---

### 3. FreeSound（免费注册）

**网站**：https://freesound.org

**搜索关键词**：
```
swing.wav: "racket swing", "tennis whoosh"
hit.wav: "tennis ball", "racket hit"
success.wav: "notification positive"
error.wav: "notification negative"
```

**注意**：
- 部分音效需要署名
- 查看许可证类型

---

## 方案二：使用 macOS 内置音效

macOS 系统自带一些音效，可以临时使用：

```bash
# 系统音效目录
/System/Library/Sounds/

# 可用的音效（需要转换格式）
Ping.aiff → success.wav
Basso.aiff → error.wav
```

**转换命令**（使用 ffmpeg）：
```bash
# 安装 ffmpeg
brew install ffmpeg

# 转换格式
ffmpeg -i Ping.aiff -ar 44100 -ac 1 success.wav
ffmpeg -i Basso.aiff -ar 44100 -ac 1 error.wav
```

---

## 方案三：生成简单音效（用于测试）

### 使用在线工具生成

**ToneGenerator**：https://onlinetonegenerator.com/

**配置**：
```
挥拍音:
- 频率: 200Hz → 800Hz (扫频)
- 时长: 0.3秒
- 波形: 白噪音

击球音:
- 频率: 1000Hz
- 时长: 0.1秒
- 波形: 正弦波

成功音:
- 频率: 800Hz
- 时长: 0.2秒
- 波形: 正弦波

错误音:
- 频率: 400Hz
- 时长: 0.3秒
- 波形: 方波
```

---

## 添加音效到 Xcode 项目

### 步骤 1：准备文件

1. 确保所有音效文件为 **WAV 格式**
2. 文件命名正确：
   - `swing.wav`
   - `hit.wav`
   - `success.wav`
   - `error.wav`

3. **推荐音频参数**：
   ```
   格式: WAV (PCM)
   采样率: 44.1kHz 或 48kHz
   位深度: 16-bit
   声道: 单声道 (Mono)
   ```

---

### 步骤 2：添加到 Xcode

#### 方法 A：拖拽添加（推荐）

1. 在 Finder 中选择 4 个音效文件
2. 拖拽到 Xcode 项目导航器的 `Resources/Sounds/` 文件夹
3. 在弹出对话框中确认：
   - ✅ **Copy items if needed**
   - ✅ **Create groups**
   - ✅ **Add to targets: AirTennis**
4. 点击 **Finish**

#### 方法 B：右键添加

1. 在 Xcode 中右键点击 `AirTennis/Resources/Sounds` 文件夹
2. 选择 **Add Files to "AirTennis"...**
3. 选择音效文件
4. 确认设置（同上）
5. 点击 **Add**

---

### 步骤 3：验证文件

在 Xcode 项目导航器中确认：

```
AirTennis/
└── Resources/
    └── Sounds/
        ├── swing.wav
        ├── hit.wav
        ├── success.wav
        └── error.wav
```

**检查 Target Membership**：
1. 选择任意音效文件
2. 打开右侧 **File Inspector**
3. 确认 **Target Membership** 中 `AirTennis` 已勾选

---

## 测试音效

### 方法 1：在代码中测试

在 `TrainingViewModel` 的 `init` 方法中添加测试代码：

```swift
init() {
    setupAudio()
    setupBindings()

    // 测试音效（启动后 2 秒播放）
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        self.audioManager.playSwingSound(swingSpeed: 20)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.audioManager.playHitSound()
        }
    }
}
```

### 方法 2：查看控制台日志

运行应用后，在 Xcode 控制台查找：

```
✅ Preloaded sound: swing
✅ Preloaded sound: hit
✅ Preloaded sound: success
✅ Preloaded sound: error
🔊 Audio engine initialized successfully
```

如果看到：
```
⚠️ Sound file not found: swing.wav
⚠️ Created silent buffer for swing
```

说明文件未正确添加。

---

## 如果音效不工作

### 检查清单

- [ ] 文件格式是 WAV
- [ ] 文件名正确（区分大小写）
- [ ] 文件在 `Resources/Sounds/` 目录
- [ ] 文件添加到 AirTennis Target
- [ ] 音频权限已授予（自动处理）
- [ ] 设备音量未静音
- [ ] 查看 Xcode 控制台错误日志

### 常见问题

**Q: 音效没有声音？**
```
A:
1. 检查设备音量和静音开关
2. 确认文件格式正确
3. 查看 Xcode 控制台日志
4. 尝试在真机上测试（不是模拟器）
```

**Q: 音效延迟很高？**
```
A:
1. 确认使用 WAV 格式（不要用 MP3）
2. 降低采样率到 44.1kHz
3. 使用单声道
4. 减小文件时长
```

**Q: 编译错误 "File not found"？**
```
A:
1. 确认文件在 Xcode 项目导航器中可见
2. 检查 Target Membership
3. Clean Build Folder (Shift+Cmd+K)
4. 重新添加文件
```

---

## 临时解决方案：无音效运行

如果暂时没有音效文件，应用仍然可以正常运行：

- ✅ AudioFeedbackManager 会创建静音缓冲区
- ✅ 不会崩溃或报错
- ✅ 只是没有音效反馈
- ✅ 震动反馈仍然工作

控制台会显示：
```
⚠️ Sound file not found: swing.wav
⚠️ Created silent buffer for swing
```

---

## 音效制作建议（高级）

如果想要自定义音效，可以使用：

### macOS

**Audacity**（免费）
- 下载：https://www.audacityteam.org
- 功能：录音、编辑、生成音调

**GarageBand**（免费，预装）
- 可以录制和编辑音效
- 支持导出 WAV 格式

### iOS

**Ferrite Recording Studio**
- 录制和编辑音频
- 可以 AirDrop 到 Mac

---

## 推荐配置（最佳实践）

```
swing.wav:
- 来源: Zapsplat "Tennis Racket Swipe"
- 时长: 0.3秒
- 格式: WAV 44.1kHz Mono

hit.wav:
- 来源: Zapsplat "Tennis Ball Hit"
- 时长: 0.15秒
- 格式: WAV 44.1kHz Mono

success.wav:
- 来源: Pixabay "Notification Bell"
- 时长: 0.4秒
- 格式: WAV 44.1kHz Mono

error.wav:
- 来源: Pixabay "Error Buzz"
- 时长: 0.3秒
- 格式: WAV 44.1kHz Mono
```

---

## 许可证说明

使用第三方音效时，请注意：

- ✅ **CC0/Public Domain**: 完全免费，可商用
- ⚠️ **CC BY**: 需要署名
- ❌ **非商业**: 不能用于商业项目

对于 MVP 测试，建议使用 CC0 音效。

---

## 快速开始（5分钟）

```bash
# 1. 访问 Pixabay
open https://pixabay.com/sound-effects/

# 2. 搜索并下载 4 个音效
#    - whoosh (swing.wav)
#    - tennis (hit.wav)
#    - bell (success.wav)
#    - buzz (error.wav)

# 3. 重命名文件

# 4. 拖拽到 Xcode 的 Resources/Sounds/ 文件夹

# 5. 运行应用测试
```

---

**完成后，您的应用将拥有完整的音效反馈体验！** 🔊🎾

如有问题，请查看 [TESTING.md](./TESTING.md) 中的测试步骤。
