//
//  TrainingViewModel.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

/// 训练视图模型
@MainActor
class TrainingViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 是否正在训练
    @Published var isTraining: Bool = false

    /// 当前挥拍数据
    @Published var currentSwing: SwingData?

    /// 本次会话的挥拍记录
    @Published var sessionSwings: [SwingData] = []

    /// 会话统计
    @Published var sessionStats: SessionStats = SessionStats()

    /// 检测器状态
    @Published var detectorState: SwingState = .idle

    // MARK: - Services

    /// 传感器管理器
    private let motionManager = MotionManager()

    /// 挥拍检测器
    private let swingDetector = SwingDetector()

    /// 音频反馈管理器
    private let audioManager = AudioFeedbackManager()

    /// 震动反馈管理器
    private let hapticManager = HapticManager()

    /// 当前会话ID
    private var currentSessionId: UUID?

    /// 数据上下文（用于持久化）
    private var modelContext: ModelContext?

    /// Combine订阅
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setupAudio()
        setupBindings()
    }

    /// 设置音频系统
    private func setupAudio() {
        // 预加载所有音效
        audioManager.preloadAllSounds()
    }

    /// 设置数据绑定
    private func setupBindings() {
        // 监听检测器状态
        swingDetector.$currentState
            .sink { [weak self] state in
                self?.detectorState = state
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)

        // 监听检测器结果
        swingDetector.$latestSwing
            .compactMap { $0 }
            .sink { [weak self] swing in
                self?.handleSwingDetected(swing)
            }
            .store(in: &cancellables)
    }

    /// 处理状态变化（触发反馈）
    private func handleStateChange(_ state: SwingState) {
        switch state {
        case .idle:
            break

        case .detecting:
            // 检测开始 - 轻微震动
            hapticManager.swingStart()

        case .swinging:
            // 挥拍中 - 播放挥拍音
            break  // 在 peak 时才播放

        case .peak:
            // 速度峰值 - 不在这里触发，在 handleSwingDetected 中处理
            break

        case .classifying:
            break

        case .completed:
            break
        }
    }

    // MARK: - Public Methods

    /// 设置数据上下文
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    /// 开始训练
    func startTraining() {
        guard !isTraining else { return }

        // 创建新会话
        currentSessionId = UUID()
        sessionSwings.removeAll()
        sessionStats = SessionStats()

        // 配置检测器回调
        swingDetector.onSwingDetected = { [weak self] swing in
            // 这里会触发 $latestSwing 的更新
        }

        // 配置传感器回调
        motionManager.onMotionUpdate = { [weak self] motion in
            self?.swingDetector.processMotion(motion)
        }

        // 开始传感器
        motionManager.startTracking()

        isTraining = true

        // 反馈：训练开始
        hapticManager.trainingStart()
        audioManager.playSuccessSound()

        print("🎾 Training started - Session: \(currentSessionId?.uuidString ?? "unknown")")
    }

    /// 停止训练
    func stopTraining() {
        guard isTraining else { return }

        // 停止传感器
        motionManager.stopTracking()

        // 重置检测器
        swingDetector.reset()

        isTraining = false

        // 反馈：训练结束
        hapticManager.trainingEnd()

        print("🛑 Training stopped - Total swings: \(sessionSwings.count)")

        // 保存会话数据
        saveSession()
    }

    /// 清除当前挥拍
    func clearCurrentSwing() {
        currentSwing = nil
    }

    // MARK: - Private Methods

    /// 处理检测到的挥拍
    private func handleSwingDetected(_ swing: SwingData) {
        // 设置会话ID
        var swing = swing
        swing.sessionId = currentSessionId

        // 更新当前显示
        currentSwing = swing

        // 添加到会话记录
        sessionSwings.append(swing)

        // 更新统计
        updateSessionStats()

        // 🎵 音频反馈
        triggerAudioFeedback(for: swing)

        // 📳 震动反馈
        triggerHapticFeedback(for: swing)

        // 可选：保存到数据库（实时保存）
        // saveSwing(swing)
    }

    /// 触发音频反馈
    private func triggerAudioFeedback(for swing: SwingData) {
        // 播放挥拍音（音量根据速度调整）
        audioManager.playSwingSound(swingSpeed: swing.swingSpeed)

        // 延迟播放击球音（模拟击球时刻）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            let intensity = Float(min(swing.swingSpeed / 30.0, 1.0))
            self.audioManager.playHitSound(intensity: intensity)
        }
    }

    /// 触发震动反馈
    private func triggerHapticFeedback(for swing: SwingData) {
        // 根据挥拍类型给予不同震动模式
        switch swing.swingType {
        case .forehand:
            hapticManager.forehandDetected()
        case .backhand:
            hapticManager.backhandDetected()
        case .unknown:
            // 未识别类型，给予通用反馈
            hapticManager.hit(intensity: 0.5)
        }

        // 根据速度强度震动
        hapticManager.swingPeak(speed: swing.swingSpeed)

        // 如果是连击，额外震动
        if sessionSwings.count > 1 {
            let recentSwings = sessionSwings.suffix(5)
            if recentSwings.allSatisfy({ $0.swingType != .unknown }) {
                hapticManager.combo(count: recentSwings.count)
            }
        }
    }

    /// 更新会话统计
    private func updateSessionStats() {
        let swings = sessionSwings

        sessionStats.totalSwings = swings.count
        sessionStats.forehandCount = swings.filter { $0.swingType == .forehand }.count
        sessionStats.backhandCount = swings.filter { $0.swingType == .backhand }.count

        if !swings.isEmpty {
            sessionStats.averageSpeed = swings.map(\.swingSpeed).reduce(0, +) / Double(swings.count)
            sessionStats.maxSpeed = swings.map(\.swingSpeed).max() ?? 0.0
            sessionStats.averageBallSpeed = swings.map(\.estimatedBallSpeed).reduce(0, +) / Double(swings.count)
            sessionStats.averagePeakAcceleration = swings.map(\.peakAcceleration).reduce(0, +) / Double(swings.count)
        }
    }

    /// 保存单个挥拍
    private func saveSwing(_ swing: SwingData) {
        guard let context = modelContext else { return }
        context.insert(swing)
        try? context.save()
    }

    /// 保存会话
    private func saveSession() {
        guard let context = modelContext else { return }

        // 批量保存所有挥拍
        for swing in sessionSwings {
            context.insert(swing)
        }

        do {
            try context.save()
            print("💾 Session saved: \(sessionSwings.count) swings")
        } catch {
            print("❌ Failed to save session: \(error)")
        }
    }

    /// 检查传感器可用性
    func checkSensorAvailability() -> String {
        let availability = motionManager.checkAvailability()
        return """
        传感器状态:
        - 加速度计: \(availability.accelerometer ? "✅" : "❌")
        - 陀螺仪: \(availability.gyroscope ? "✅" : "❌")
        - 设备运动: \(availability.deviceMotion ? "✅" : "❌")
        """
    }

    deinit {
        // 停止传感器和检测器（非异步操作）
        motionManager.stopTracking()
        swingDetector.reset()
    }
}
