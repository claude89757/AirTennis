//
//  StatsViewModel.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import Foundation
import SwiftData
import SwiftUI

enum DateRangeFilter: String, CaseIterable {
    case today = "今天"
    case week = "本周"
    case month = "本月"
    case all = "全部"

    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()

        switch self {
        case .today:
            return calendar.startOfDay(for: now)
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .all:
            return Date.distantPast
        }
    }
}

@Observable
final class StatsViewModel {
    var selectedRange: DateRangeFilter = .week
    var selectedSwingType: SwingType? = nil
    var showGoalSetting = false

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Goal Management

    func getGoalSettings() -> GoalSettings? {
        let descriptor = FetchDescriptor<GoalSettings>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try? modelContext.fetch(descriptor).first
    }

    func saveGoalSettings(_ settings: GoalSettings) {
        if let existing = getGoalSettings() {
            existing.dailySwingTarget = settings.dailySwingTarget
            existing.targetAverageSpeed = settings.targetAverageSpeed
            existing.weeklyTrainingDaysTarget = settings.weeklyTrainingDaysTarget
            existing.updatedAt = Date()
        } else {
            modelContext.insert(settings)
        }
        try? modelContext.save()
    }

    // MARK: - Data Fetching

    func fetchSwings(for range: DateRangeFilter? = nil, type: SwingType? = nil) -> [SwingData] {
        let range = range ?? selectedRange
        let type = type ?? selectedSwingType

        var predicate: Predicate<SwingData>?
        let startDate = range.startDate

        if let type = type {
            predicate = #Predicate<SwingData> { swing in
                swing.timestamp >= startDate && swing.swingType == type
            }
        } else {
            predicate = #Predicate<SwingData> { swing in
                swing.timestamp >= startDate
            }
        }

        let descriptor = FetchDescriptor<SwingData>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Today Stats

    func getTodayStats() -> TodayStats {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let todaySwings = fetchSwings(for: .today)
        let yesterdayPredicate = #Predicate<SwingData> { swing in
            swing.timestamp >= yesterday && swing.timestamp < today
        }
        let yesterdayDescriptor = FetchDescriptor<SwingData>(predicate: yesterdayPredicate)
        let yesterdaySwings = (try? modelContext.fetch(yesterdayDescriptor)) ?? []

        let todayCount = todaySwings.count
        let todayAvgSpeed = todaySwings.isEmpty ? 0 : todaySwings.map(\.swingSpeed).reduce(0, +) / Double(todayCount)
        let yesterdayAvgSpeed = yesterdaySwings.isEmpty ? 0 : yesterdaySwings.map(\.swingSpeed).reduce(0, +) / Double(yesterdaySwings.count)

        let forehandCount = todaySwings.filter { $0.swingType == .forehand }.count
        let backhandCount = todaySwings.filter { $0.swingType == .backhand }.count

        let goal = getGoalSettings()
        let targetCount = goal?.dailySwingTarget ?? 30
        let progress = min(Double(todayCount) / Double(targetCount), 1.0)

        return TodayStats(
            swingCount: todayCount,
            targetCount: targetCount,
            progress: progress,
            averageSpeed: todayAvgSpeed,
            speedChange: todayAvgSpeed - yesterdayAvgSpeed,
            forehandCount: forehandCount,
            backhandCount: backhandCount
        )
    }

    // MARK: - Weekly Training Days

    func getWeeklyTrainingDays() -> [WeekDay] {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let sunday = calendar.date(byAdding: .day, value: -(weekday - 1), to: today)!

        var weekDays: [WeekDay] = []

        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: sunday)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let predicate = #Predicate<SwingData> { swing in
                swing.timestamp >= dayStart && swing.timestamp < dayEnd
            }
            let descriptor = FetchDescriptor<SwingData>(predicate: predicate)
            let swings = (try? modelContext.fetch(descriptor)) ?? []

            let dayName = ["日", "一", "二", "三", "四", "五", "六"][i]
            weekDays.append(WeekDay(
                name: dayName,
                date: date,
                hasTrained: !swings.isEmpty,
                swingCount: swings.count
            ))
        }

        return weekDays
    }

    // MARK: - Swing Type Comparison

    func getSwingTypeComparison() -> SwingTypeStats {
        let swings = fetchSwings()

        let forehandSwings = swings.filter { $0.swingType == .forehand }
        let backhandSwings = swings.filter { $0.swingType == .backhand }

        let forehandAvgSpeed = forehandSwings.isEmpty ? 0 : forehandSwings.map(\.swingSpeed).reduce(0, +) / Double(forehandSwings.count)
        let backhandAvgSpeed = backhandSwings.isEmpty ? 0 : backhandSwings.map(\.swingSpeed).reduce(0, +) / Double(backhandSwings.count)

        return SwingTypeStats(
            forehandCount: forehandSwings.count,
            backhandCount: backhandSwings.count,
            forehandAvgSpeed: forehandAvgSpeed,
            backhandAvgSpeed: backhandAvgSpeed
        )
    }
}

// MARK: - Supporting Types

struct TodayStats {
    let swingCount: Int
    let targetCount: Int
    let progress: Double
    let averageSpeed: Double
    let speedChange: Double
    let forehandCount: Int
    let backhandCount: Int

    var remaining: Int {
        max(0, targetCount - swingCount)
    }

    var progressPercent: Int {
        Int(progress * 100)
    }

    var motivationText: String {
        if progress >= 1.0 {
            return "🎉 今日目标已达成！"
        } else if progress >= 0.8 {
            return "💪 继续加油，还差 \(remaining) 次达标！"
        } else if progress >= 0.5 {
            return "👍 已完成一半，加油！"
        } else if swingCount > 0 {
            return "📈 良好开始，继续保持！"
        } else {
            return "🎾 开始今天的训练吧！"
        }
    }
}

struct WeekDay: Identifiable {
    let id = UUID()
    let name: String
    let date: Date
    let hasTrained: Bool
    let swingCount: Int
}

struct SwingTypeStats {
    let forehandCount: Int
    let backhandCount: Int
    let forehandAvgSpeed: Double
    let backhandAvgSpeed: Double

    var totalCount: Int {
        forehandCount + backhandCount
    }

    var forehandPercentage: Double {
        totalCount > 0 ? Double(forehandCount) / Double(totalCount) : 0
    }

    var backhandPercentage: Double {
        totalCount > 0 ? Double(backhandCount) / Double(totalCount) : 0
    }
}
