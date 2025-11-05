//
//  SpeedCalculator.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import CoreMotion

/// 速度计算服务
class SpeedCalculator {

    /// 默认手臂长度（米）
    static let defaultArmLength: Double = 0.65

    /// 用户手臂长度（可通过设置调整）
    var armLength: Double = defaultArmLength

    /// 计算挥拍速度（基于角速度）
    /// - Parameters:
    ///   - rotationRate: 陀螺仪旋转速率
    ///   - armLength: 手臂长度（米）
    /// - Returns: 线速度（米/秒）
    func calculateSwingSpeed(rotationRate: CMRotationRate, armLength: Double? = nil) -> Double {
        let length = armLength ?? self.armLength

        // 计算角速度的模（rad/s）
        let angularVelocity = sqrt(
            pow(rotationRate.x, 2) +
            pow(rotationRate.y, 2) +
            pow(rotationRate.z, 2)
        )

        // v = ω × r（线速度 = 角速度 × 半径）
        return angularVelocity * length
    }

    /// 计算加速度峰值
    /// - Parameter acceleration: 用户加速度（去除重力）
    /// - Returns: 加速度大小（G）
    func calculateAccelerationMagnitude(acceleration: CMAcceleration) -> Double {
        return sqrt(
            pow(acceleration.x, 2) +
            pow(acceleration.y, 2) +
            pow(acceleration.z, 2)
        )
    }

    /// 估算击球速度
    /// - Parameters:
    ///   - swingSpeed: 挥拍速度（m/s）
    ///   - swingType: 挥拍类型
    /// - Returns: 估算球速（km/h）
    func estimateBallSpeed(swingSpeed: Double, swingType: SwingType) -> Double {
        // 碰撞效率系数
        let coefficient: Double
        switch swingType {
        case .forehand, .backhand:
            coefficient = 0.80  // 底线击球系数（提升约23.1%）
        case .unknown:
            coefficient = 0.75  // 保守估计（保持合理比例）
        }

        // 转换为 km/h 并应用系数
        let ballSpeedMs = swingSpeed * coefficient
        let ballSpeedKmh = ballSpeedMs * 3.6

        return ballSpeedKmh
    }

    /// 从身高估算手臂长度
    /// - Parameter height: 身高（厘米）
    /// - Returns: 估算手臂长度（米）
    static func estimateArmLength(fromHeight height: Double) -> Double {
        // 根据人体学比例，手臂长度约为身高的 38-40%
        return (height * 0.39) / 100.0
    }
}
