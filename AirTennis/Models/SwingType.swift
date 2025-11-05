//
//  SwingType.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import SwiftUI

/// 挥拍动作类型
enum SwingType: String, Codable, CaseIterable {
    case forehand = "正手"
    case backhand = "反手"
    case unknown = "未识别"

    /// 图标名称
    var iconName: String {
        switch self {
        case .forehand: return "arrow.right.circle.fill"
        case .backhand: return "arrow.left.circle.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }

    /// 图标名称（简化版）
    var icon: String {
        switch self {
        case .forehand: return "hand.point.up.left.fill"
        case .backhand: return "hand.point.up.fill"
        case .unknown: return "questionmark.circle"
        }
    }

    /// 显示名称
    var displayName: String {
        return self.rawValue
    }

    /// 颜色标识
    var colorName: String {
        switch self {
        case .forehand: return "blue"
        case .backhand: return "green"
        case .unknown: return "gray"
        }
    }

    /// SwiftUI Color
    var color: Color {
        switch self {
        case .forehand: return .blue
        case .backhand: return .red
        case .unknown: return .gray
        }
    }
}
