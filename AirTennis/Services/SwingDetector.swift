//
//  SwingDetector.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import CoreMotion
import Combine

/// 挥拍检测状态
enum SwingState {
    case idle           // 待机
    case detecting      // 检测中
    case swinging       // 挥拍中
    case peak           // 速度峰值
    case classifying    // 分类中
    case completed      // 完成
}

/// 挥拍检测器（规则引擎）
class SwingDetector: ObservableObject {

    // MARK: - Properties

    /// 速度计算器
    private let speedCalculator = SpeedCalculator()

    /// 当前状态
    @Published var currentState: SwingState = .idle

    /// 最新检测结果
    @Published var latestSwing: SwingData?

    /// 检测到挥拍的回调
    var onSwingDetected: ((SwingData) -> Void)?

    // MARK: - Detection Parameters (规则引擎阈值)

    /// 加速度阈值（G）- 用于触发检测
    private let accelerationThreshold: Double = 2.5

    /// 旋转速率阈值（rad/s）- 用于判断挥拍方向（备用）
    private let rotationThreshold: Double = 2.62  // 约150°/s

    /// Z轴加速度阈值 - 用于判断正反手（基于手机朝向）
    private let zAccelerationThreshold: Double = 1.0

    /// 最小挥拍持续时间（秒）
    private let minSwingDuration: TimeInterval = 0.3

    /// 最大挥拍持续时间（秒）
    private let maxSwingDuration: TimeInterval = 1.0

    /// 姿态角度范围（pitch，弧度）
    private let minPitchAngle: Double = -0.52  // 约-30°
    private let maxPitchAngle: Double = 0.52   // 约30°

    // MARK: - State Variables

    /// 挥拍开始时间
    private var swingStartTime: Date?

    /// 挥拍过程中的最大速度
    private var maxSpeed: Double = 0.0

    /// 挥拍过程中的最大加速度
    private var maxAcceleration: Double = 0.0

    /// 挥拍过程中的旋转方向累积（备用）
    private var rotationAccumulator: Double = 0.0

    /// 挥拍过程中的Z轴加速度累积（用于判断正反手）
    private var accelerationZAccumulator: Double = 0.0

    /// 上一帧的速度（用于判断加速/减速阶段）
    private var previousSpeed: Double = 0.0

    /// 用于防抖的计时器
    private var cooldownTimer: Timer?

    /// 冷却时间（秒）- 防止重复检测（增加到1.5秒，避免引拍回程被误判）
    private let cooldownDuration: TimeInterval = 1.5

    // MARK: - Public Methods

    /// 处理传感器数据
    func processMotion(_ motion: CMDeviceMotion) {
        switch currentState {
        case .idle:
            checkForSwingStart(motion)

        case .detecting, .swinging:
            updateSwingData(motion)
            checkForSwingPeak(motion)

        case .peak:
            classifySwing(motion)

        case .classifying, .completed:
            // 等待冷却
            break
        }
    }

    /// 重置检测器
    func reset() {
        currentState = .idle
        swingStartTime = nil
        maxSpeed = 0.0
        maxAcceleration = 0.0
        rotationAccumulator = 0.0
        accelerationZAccumulator = 0.0
        previousSpeed = 0.0
        cooldownTimer?.invalidate()
        cooldownTimer = nil
    }

    // MARK: - Private Methods

    /// 检查挥拍开始
    private func checkForSwingStart(_ motion: CMDeviceMotion) {
        let acceleration = motion.userAcceleration
        let magnitude = speedCalculator.calculateAccelerationMagnitude(acceleration: acceleration)

        // 检查是否超过阈值
        if magnitude > accelerationThreshold {
            // 检查姿态角度是否合理
            let pitch = motion.attitude.pitch
            if pitch >= minPitchAngle && pitch <= maxPitchAngle {
                startSwingDetection()
            }
        }
    }

    /// 开始挥拍检测
    private func startSwingDetection() {
        currentState = .detecting
        swingStartTime = Date()
        maxSpeed = 0.0
        maxAcceleration = 0.0
        rotationAccumulator = 0.0
        accelerationZAccumulator = 0.0  // 重置Z轴加速度累加器
        previousSpeed = 0.0  // 重置上一帧速度

        print("🎾 Swing detection started")

        // 0.1秒后进入swinging状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self, self.currentState == .detecting else { return }
            self.currentState = .swinging
        }
    }

    /// 更新挥拍数据
    private func updateSwingData(_ motion: CMDeviceMotion) {
        // 计算当前速度
        let currentSpeed = speedCalculator.calculateSwingSpeed(rotationRate: motion.rotationRate)
        maxSpeed = max(maxSpeed, currentSpeed)

        // 记录最大加速度
        let acceleration = speedCalculator.calculateAccelerationMagnitude(acceleration: motion.userAcceleration)
        maxAcceleration = max(maxAcceleration, acceleration)

        // 只在加速阶段累积Z轴加速度（避免引拍回程的反向加速度干扰判断）
        // 当速度还在上升时，才累积Z轴加速度
        if currentSpeed >= previousSpeed * 0.95 {  // 允许5%的波动
            // 累积Z轴加速度（用于判断正反手：正手屏幕朝前+，反手背面朝前-）
            accelerationZAccumulator += motion.userAcceleration.z

            // 累积旋转方向（备用）
            rotationAccumulator += motion.rotationRate.z
        }

        // 更新上一帧速度
        previousSpeed = currentSpeed
    }

    /// 检查是否达到速度峰值
    private func checkForSwingPeak(_ motion: CMDeviceMotion) {
        guard let startTime = swingStartTime else { return }

        let duration = Date().timeIntervalSince(startTime)

        // 检查持续时间
        if duration < minSwingDuration {
            return  // 还未达到最小时长
        }

        // 计算当前速度
        let currentSpeed = speedCalculator.calculateSwingSpeed(rotationRate: motion.rotationRate)

        // 检测速度峰值（当前速度开始下降）
        if currentSpeed < maxSpeed * 0.7 {
            // 速度下降超过30%，认为已过峰值
            currentState = .peak
            print("⚡️ Peak detected: \(maxSpeed) m/s")

            // 立即分类
            classifySwing(motion)
        }

        // 超时检查
        if duration > maxSwingDuration {
            currentState = .peak
            classifySwing(motion)
        }
    }

    /// 分类挥拍类型
    private func classifySwing(_ motion: CMDeviceMotion) {
        guard currentState == .peak else { return }

        currentState = .classifying

        // 根据累积Z轴加速度判断正手/反手（基于手机朝向）
        // iOS坐标系：正Z从背面穿过屏幕指向前方
        let swingType: SwingType
        if accelerationZAccumulator > zAccelerationThreshold {
            swingType = .forehand  // 正Z：屏幕朝前加速 → 正手
        } else if accelerationZAccumulator < -zAccelerationThreshold {
            swingType = .backhand  // 负Z：背面朝前加速 → 反手
        } else {
            // Z轴加速度不明显，使用旋转方向作为备用判断
            if rotationAccumulator > rotationThreshold {
                swingType = .forehand
            } else if rotationAccumulator < -rotationThreshold {
                swingType = .backhand
            } else {
                swingType = .unknown
            }
        }

        // 估算球速
        let ballSpeed = speedCalculator.estimateBallSpeed(
            swingSpeed: maxSpeed,
            swingType: swingType
        )

        // 创建挥拍数据
        let swingData = SwingData(
            swingType: swingType,
            swingSpeed: maxSpeed,
            estimatedBallSpeed: ballSpeed,
            peakAcceleration: maxAcceleration
        )

        // 发布结果
        DispatchQueue.main.async {
            self.latestSwing = swingData
            self.onSwingDetected?(swingData)
            self.currentState = .completed

            print("""
            ✅ Swing detected:
               Type: \(swingType.rawValue)
               Speed: \(String(format: "%.1f", self.maxSpeed)) m/s
               Ball Speed: \(String(format: "%.1f", ballSpeed)) km/h
               Acceleration: \(String(format: "%.2f", self.maxAcceleration)) G
               📊 Z-Acc累积: \(String(format: "%.2f", self.accelerationZAccumulator)) (阈值: ±\(self.zAccelerationThreshold))
               📊 旋转累积: \(String(format: "%.2f", self.rotationAccumulator)) (阈值: ±\(self.rotationThreshold))
            """)

            // 启动冷却计时器
            self.startCooldown()
        }
    }

    /// 启动冷却计时器
    private func startCooldown() {
        cooldownTimer?.invalidate()
        cooldownTimer = Timer.scheduledTimer(withTimeInterval: cooldownDuration, repeats: false) { [weak self] _ in
            self?.reset()
            print("🔄 Detector ready")
        }
    }

    deinit {
        cooldownTimer?.invalidate()
    }
}
