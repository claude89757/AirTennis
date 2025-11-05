//
//  WeeklyCalendar.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct WeeklyCalendar: View {
    let weekDays: [WeekDay]
    let targetDays: Int
    @State private var selectedDay: WeekDay?

    var trainedDaysCount: Int {
        weekDays.filter(\.hasTrained).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("本周训练")
                    .font(.headline)
                Spacer()
                Text("\(trainedDaysCount)/\(targetDays) 天")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundStyle(trainedDaysCount >= targetDays ? .green : .orange)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule()
                            .fill(trainedDaysCount >= targetDays ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
                    )
            }

            // Calendar Grid
            HStack(spacing: 12) {
                ForEach(weekDays) { day in
                    VStack(spacing: 8) {
                        Text(day.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ZStack {
                            Circle()
                                .fill(day.hasTrained ? Color.green : Color.secondary.opacity(0.2))
                                .frame(width: 40, height: 40)

                            if day.hasTrained {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Text("-")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .overlay(
                            Circle()
                                .stroke(isToday(day.date) ? Color.blue : Color.clear, lineWidth: 2)
                        )

                        if day.hasTrained {
                            Text("\(day.swingCount)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else {
                            Text(" ")
                                .font(.caption2)
                        }
                    }
                    .onTapGesture {
                        if day.hasTrained {
                            selectedDay = day
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Progress Text
            HStack {
                Image(systemName: trainedDaysCount >= targetDays ? "trophy.fill" : "flame.fill")
                    .foregroundStyle(trainedDaysCount >= targetDays ? .yellow : .orange)
                Text(progressText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
        .sheet(item: $selectedDay) { day in
            DayDetailView(day: day)
                .presentationDetents([.medium])
        }
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private var progressText: String {
        if trainedDaysCount >= targetDays {
            return "太棒了！本周目标已达成"
        } else {
            let remaining = targetDays - trainedDaysCount
            return "还需训练 \(remaining) 天达成本周目标"
        }
    }
}

// MARK: - Day Detail View

struct DayDetailView: View {
    let day: WeekDay

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                    Text("星期\(day.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(day.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.top)

                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "figure.tennis")
                            .font(.title3)
                            .foregroundStyle(.blue)
                            .frame(width: 30)
                        Text("挥拍次数")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(day.swingCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.1))
                )

                Spacer()
            }
            .padding()
            .navigationTitle("训练记录")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WeeklyCalendar(
        weekDays: [
            WeekDay(name: "日", date: Date(), hasTrained: true, swingCount: 25),
            WeekDay(name: "一", date: Date(), hasTrained: true, swingCount: 30),
            WeekDay(name: "二", date: Date(), hasTrained: true, swingCount: 28),
            WeekDay(name: "三", date: Date(), hasTrained: false, swingCount: 0),
            WeekDay(name: "四", date: Date(), hasTrained: true, swingCount: 32),
            WeekDay(name: "五", date: Date(), hasTrained: false, swingCount: 0),
            WeekDay(name: "六", date: Date(), hasTrained: false, swingCount: 0)
        ],
        targetDays: 5
    )
    .padding()
}
