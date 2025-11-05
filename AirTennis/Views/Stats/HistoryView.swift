//
//  HistoryView.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: StatsViewModel?
    @State private var selectedRange: DateRangeFilter = .week
    @State private var showGoalSetting = false

    var body: some View {
        NavigationStack {
            ScrollView {
                if let vm = viewModel {
                    VStack(spacing: 20) {
                        // Time Range Picker & Goal Setting
                        HStack {
                            Picker("时间范围", selection: $selectedRange) {
                                ForEach(DateRangeFilter.allCases, id: \.self) { range in
                                    Text(range.rawValue).tag(range)
                                }
                            }
                            .pickerStyle(.segmented)

                            Button {
                                showGoalSetting = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                    .padding(8)
                                    .background(Circle().fill(.blue.opacity(0.1)))
                            }
                        }
                        .padding(.horizontal)
                        .onChange(of: selectedRange) { _, newValue in
                            vm.selectedRange = newValue
                        }

                        // Today Stats Card
                        TodayStatsCard(stats: vm.getTodayStats())
                            .padding(.horizontal)

                        // Speed Trend Chart
                        let swings = vm.fetchSwings(for: selectedRange)
                        if !swings.isEmpty {
                            SpeedTrendChart(
                                swings: swings,
                                targetSpeed: vm.getGoalSettings()?.targetAverageSpeed
                            )
                            .padding(.horizontal)

                            // Weekly Calendar
                            WeeklyCalendar(
                                weekDays: vm.getWeeklyTrainingDays(),
                                targetDays: vm.getGoalSettings()?.weeklyTrainingDaysTarget ?? 5
                            )
                            .padding(.horizontal)

                            // Swing Type Comparison
                            SwingTypeComparison(
                                stats: vm.getSwingTypeComparison()
                            )
                            .padding(.horizontal)

                            // Recent Swings List
                            RecentSwingsList(swings: Array(swings.suffix(10)))
                                .padding(.horizontal)
                        } else {
                            EmptyStatsView()
                                .padding(.horizontal)
                                .padding(.vertical, 40)
                        }
                    }
                    .padding(.vertical)
                } else {
                    ProgressView()
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("数据统计")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showGoalSetting) {
                if let vm = viewModel {
                    GoalSettingSheet(viewModel: vm)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = StatsViewModel(modelContext: modelContext)
            }
        }
    }
}

// MARK: - Recent Swings List

struct RecentSwingsList: View {
    let swings: [SwingData]
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("近期记录")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "收起" : "展开")
                            .font(.caption)
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption)
                    }
                    .foregroundStyle(.blue)
                }
            }

            if isExpanded {
                VStack(spacing: 12) {
                    ForEach(swings.reversed()) { swing in
                        HStack {
                            Image(systemName: swing.swingType.icon)
                                .font(.title3)
                                .foregroundStyle(swing.swingType.color)
                                .frame(width: 30)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(swing.swingType.displayName)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                Text(swing.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 4) {
                                Text(String(format: "%.1f m/s", swing.swingSpeed))
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                Text(String(format: "%.0f km/h", swing.estimatedBallSpeed))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.secondary.opacity(0.05))
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
}

// MARK: - Empty State

struct EmptyStatsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("暂无训练数据")
                .font(.title3)
                .fontWeight(.semibold)

            Text("开始你的第一次训练，记录你的进步！")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [SwingData.self, GoalSettings.self], inMemory: true)
}
