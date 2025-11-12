//
//  SwingData.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import SwiftData

/// 挥拍数据模型
@Model
final class SwingData {
    /// 唯一标识
    var id: UUID

    /// 时间戳
    var timestamp: Date

    /// 挥拍类型
    var swingType: SwingType

    /// 挥拍速度 (m/s)
    var swingSpeed: Double

    /// 估算球速 (km/h)
    var estimatedBallSpeed: Double

    /// 加速度峰值 (G)
    var peakAcceleration: Double

    /// 训练会话ID
    var sessionId: UUID?

    init(
        timestamp: Date = Date(),
        swingType: SwingType,
        swingSpeed: Double,
        estimatedBallSpeed: Double,
        peakAcceleration: Double,
        sessionId: UUID? = nil
    ) {
        self.id = UUID()
        self.timestamp = timestamp
        self.swingType = swingType
        self.swingSpeed = swingSpeed
        self.estimatedBallSpeed = estimatedBallSpeed
        self.peakAcceleration = peakAcceleration
        self.sessionId = sessionId
    }

    /// 速度等级（用于UI颜色显示）
    var speedLevel: SpeedLevel {
        if swingSpeed >= 22 { return .excellent }
        if swingSpeed >= 18 { return .good }
        if swingSpeed >= 12 { return .medium }
        return .low
    }
}

/// 速度等级
enum SpeedLevel: String {
    case excellent = "优秀"
    case good = "良好"
    case medium = "中等"
    case low = "偏慢"

    var colorName: String {
        switch self {
        case .excellent: return "green"
        case .good: return "blue"
        case .medium: return "yellow"
        case .low: return "gray"
        }
    }
}

/// 训练会话统计
struct SessionStats {
    var totalSwings: Int = 0
    var forehandCount: Int = 0
    var backhandCount: Int = 0
    var averageSpeed: Double = 0.0
    var maxSpeed: Double = 0.0
    var averageBallSpeed: Double = 0.0
    var averagePeakAcceleration: Double = 0.0
}
