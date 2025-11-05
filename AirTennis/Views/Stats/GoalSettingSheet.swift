//
//  GoalSettingSheet.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct GoalSettingSheet: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: StatsViewModel

    @State private var dailySwingTarget: Double
    @State private var targetAverageSpeed: Double
    @State private var weeklyTrainingDaysTarget: Double

    init(viewModel: StatsViewModel) {
        self.viewModel = viewModel
        let settings = viewModel.getGoalSettings()
        _dailySwingTarget = State(initialValue: Double(settings?.dailySwingTarget ?? 30))
        _targetAverageSpeed = State(initialValue: settings?.targetAverageSpeed ?? 15.0)
        _weeklyTrainingDaysTarget = State(initialValue: Double(settings?.weeklyTrainingDaysTarget ?? 5))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("每日目标挥拍次数")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(dailySwingTarget)) 次")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                        Slider(value: $dailySwingTarget, in: 10...100, step: 5)
                            .tint(.blue)
                    }
                } header: {
                    Label("训练量目标", systemImage: "figure.tennis")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("目标平均速度")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.1f m/s", targetAverageSpeed))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)
                        }
                        Slider(value: $targetAverageSpeed, in: 5...25, step: 0.5)
                            .tint(.green)
                    }
                } header: {
                    Label("速度目标", systemImage: "speedometer")
                } footer: {
                    Text("建议：初学者 8-12 m/s，进阶 12-18 m/s，专业 18+ m/s")
                        .font(.caption)
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("每周训练天数")
                                .font(.headline)
                            Spacer()
                            Text("\(Int(weeklyTrainingDaysTarget)) 天")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.orange)
                        }
                        Slider(value: $weeklyTrainingDaysTarget, in: 1...7, step: 1)
                            .tint(.orange)
                    }
                } header: {
                    Label("训练频率", systemImage: "calendar")
                } footer: {
                    Text("保持规律训练有助于提升技术水平")
                        .font(.caption)
                }
            }
            .navigationTitle("目标设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveGoals()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func saveGoals() {
        let settings = GoalSettings(
            dailySwingTarget: Int(dailySwingTarget),
            targetAverageSpeed: targetAverageSpeed,
            weeklyTrainingDaysTarget: Int(weeklyTrainingDaysTarget)
        )
        viewModel.saveGoalSettings(settings)
    }
}
