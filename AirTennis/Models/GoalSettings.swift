//
//  GoalSettings.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import Foundation
import SwiftData

@Model
final class GoalSettings {
    var dailySwingTarget: Int
    var targetAverageSpeed: Double
    var weeklyTrainingDaysTarget: Int
    var createdAt: Date
    var updatedAt: Date

    init(
        dailySwingTarget: Int = 30,
        targetAverageSpeed: Double = 15.0,
        weeklyTrainingDaysTarget: Int = 5
    ) {
        self.dailySwingTarget = dailySwingTarget
        self.targetAverageSpeed = targetAverageSpeed
        self.weeklyTrainingDaysTarget = weeklyTrainingDaysTarget
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
