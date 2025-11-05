//
//  HapticManager.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import UIKit

/// 震动反馈管理器
class HapticManager {

    // MARK: - Properties

    /// 震动反馈生成器
    private var impactGenerator: UIImpactFeedbackGenerator?
    private var notificationGenerator: UINotificationFeedbackGenerator?
    private var selectionGenerator: UISelectionFeedbackGenerator?

    /// 是否启用震动
    var isEnabled: Bool = true

    // MARK: - Initialization

    init() {
        setupGenerators()
    }

    // MARK: - Setup

    /// 设置震动生成器
    private func setupGenerators() {
        impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        notificationGenerator = UINotificationFeedbackGenerator()
        selectionGenerator = UISelectionFeedbackGenerator()

        // 预准备，减少延迟
        impactGenerator?.prepare()
        notificationGenerator?.prepare()
        selectionGenerator?.prepare()

        print("📳 Haptic generators initialized")
    }

    // MARK: - Swing Feedback

    /// 挥拍开始震动（轻微）
    func swingStart() {
        guard isEnabled else { return }

        selectionGenerator?.selectionChanged()
        selectionGenerator?.prepare()
    }

    /// 挥拍峰值震动（根据速度调整强度）
    /// - Parameter speed: 挥拍速度 (m/s)
    func swingPeak(speed: Double) {
        guard isEnabled else { return }

        // 根据速度选择震动强度
        let style: UIImpactFeedbackGenerator.FeedbackStyle
        if speed >= 25 {
            style = .heavy      // 高速
        } else if speed >= 20 {
            style = .medium     // 中速
        } else {
            style = .light      // 低速
        }

        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    /// 击球震动（强烈）
    func hit() {
        guard isEnabled else { return }

        impactGenerator?.impactOccurred(intensity: 1.0)
        impactGenerator?.prepare()
    }

    /// 击球震动（自定义强度）
    /// - Parameter intensity: 强度 (0.0 - 1.0)
    func hit(intensity: CGFloat) {
        guard isEnabled else { return }

        impactGenerator?.impactOccurred(intensity: intensity)
        impactGenerator?.prepare()
    }

    // MARK: - Action Feedback

    /// 正手识别震动
    func forehandDetected() {
        guard isEnabled else { return }

        // 双击震动模式
        impactGenerator?.impactOccurred(intensity: 0.7)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impactGenerator?.impactOccurred(intensity: 0.7)
            self.impactGenerator?.prepare()
        }
    }

    /// 反手识别震动
    func backhandDetected() {
        guard isEnabled else { return }

        // 三击震动模式（与正手区分）
        impactGenerator?.impactOccurred(intensity: 0.7)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.impactGenerator?.impactOccurred(intensity: 0.7)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.impactGenerator?.impactOccurred(intensity: 0.7)
                self.impactGenerator?.prepare()
            }
        }
    }

    // MARK: - Notification Feedback

    /// 成功反馈
    func success() {
        guard isEnabled else { return }

        notificationGenerator?.notificationOccurred(.success)
        notificationGenerator?.prepare()
    }

    /// 警告反馈
    func warning() {
        guard isEnabled else { return }

        notificationGenerator?.notificationOccurred(.warning)
        notificationGenerator?.prepare()
    }

    /// 错误反馈
    func error() {
        guard isEnabled else { return }

        notificationGenerator?.notificationOccurred(.error)
        notificationGenerator?.prepare()
    }

    // MARK: - UI Feedback

    /// 按钮点击反馈
    func buttonTap() {
        guard isEnabled else { return }

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// 选择反馈
    func selection() {
        guard isEnabled else { return }

        selectionGenerator?.selectionChanged()
        selectionGenerator?.prepare()
    }

    // MARK: - Custom Patterns

    /// 训练开始震动模式
    func trainingStart() {
        guard isEnabled else { return }

        // 上升震动模式
        let light = UIImpactFeedbackGenerator(style: .light)
        let medium = UIImpactFeedbackGenerator(style: .medium)
        let heavy = UIImpactFeedbackGenerator(style: .heavy)

        light.prepare()
        light.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            medium.prepare()
            medium.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            heavy.prepare()
            heavy.impactOccurred()
        }
    }

    /// 训练结束震动模式
    func trainingEnd() {
        guard isEnabled else { return }

        // 下降震动模式
        let heavy = UIImpactFeedbackGenerator(style: .heavy)
        let medium = UIImpactFeedbackGenerator(style: .medium)
        let light = UIImpactFeedbackGenerator(style: .light)

        heavy.prepare()
        heavy.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            medium.prepare()
            medium.impactOccurred()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            light.prepare()
            light.impactOccurred()
        }
    }

    /// 连击震动（用于连续击球）
    /// - Parameter count: 连击次数
    func combo(count: Int) {
        guard isEnabled, count > 1 else { return }

        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()

        for i in 0..<min(count, 5) {  // 最多5次
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.08) {
                generator.impactOccurred(intensity: 0.5)
            }
        }
    }
}
