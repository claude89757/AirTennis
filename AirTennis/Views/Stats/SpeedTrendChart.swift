//
//  SpeedTrendChart.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI
import Charts

struct SpeedTrendChart: View {
    let swings: [SwingData]
    let targetSpeed: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("速度趋势")
                    .font(.headline)
                Spacer()
                if let trend = calculateTrend() {
                    HStack(spacing: 4) {
                        Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                        Text(String(format: "%+.1f%%", trend))
                            .font(.caption)
                    }
                    .foregroundStyle(trend > 0 ? .green : .red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.secondary.opacity(0.1)))
                }
            }

            // Chart
            Chart {
                // Forehand Line
                ForEach(swings.filter { $0.swingType == .forehand }) { swing in
                    LineMark(
                        x: .value("时间", swing.timestamp),
                        y: .value("速度", swing.swingSpeed)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("时间", swing.timestamp),
                        y: .value("速度", swing.swingSpeed)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("时间", swing.timestamp),
                        y: .value("速度", swing.swingSpeed)
                    )
                    .foregroundStyle(.blue)
                    .symbolSize(50)
                }

                // Backhand Line
                ForEach(swings.filter { $0.swingType == .backhand }) { swing in
                    LineMark(
                        x: .value("时间", swing.timestamp),
                        y: .value("速度", swing.swingSpeed)
                    )
                    .foregroundStyle(.red)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("时间", swing.timestamp),
                        y: .value("速度", swing.swingSpeed)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.3), .red.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("时间", swing.timestamp),
                        y: .value("速度", swing.swingSpeed)
                    )
                    .foregroundStyle(.red)
                    .symbolSize(50)
                }

                // Target Speed Line
                if let targetSpeed = targetSpeed, !swings.isEmpty {
                    let firstDate = swings.map(\.timestamp).min() ?? Date()
                    let lastDate = swings.map(\.timestamp).max() ?? Date()

                    RuleMark(y: .value("目标", targetSpeed))
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("目标: \(String(format: "%.1f", targetSpeed)) m/s")
                                .font(.caption)
                                .foregroundStyle(.green)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(.green.opacity(0.1)))
                        }
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let speed = value.as(Double.self) {
                            Text("\(Int(speed))")
                        }
                    }
                }
            }
            .chartYAxisLabel("速度 (m/s)", alignment: .center)

            // Legend
            HStack(spacing: 20) {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 10, height: 10)
                    Text("正手")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                HStack(spacing: 6) {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                    Text("反手")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if targetSpeed != nil {
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(.green)
                            .frame(width: 15, height: 2)
                        Text("目标")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }

    private func calculateTrend() -> Double? {
        guard swings.count >= 2 else { return nil }

        let halfCount = swings.count / 2
        let firstHalf = Array(swings.prefix(halfCount))
        let secondHalf = Array(swings.suffix(halfCount))

        let firstAvg = firstHalf.map(\.swingSpeed).reduce(0, +) / Double(firstHalf.count)
        let secondAvg = secondHalf.map(\.swingSpeed).reduce(0, +) / Double(secondHalf.count)

        guard firstAvg > 0 else { return nil }
        return ((secondAvg - firstAvg) / firstAvg) * 100
    }
}

// MARK: - Swing Detail View

struct SwingDetailView: View {
    let swing: SwingData

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Swing Type
                VStack(spacing: 8) {
                    Image(systemName: swing.swingType.icon)
                        .font(.system(size: 50))
                        .foregroundStyle(swing.swingType.color)
                    Text(swing.swingType.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top)

                // Metrics
                VStack(spacing: 16) {
                    MetricRow(
                        label: "挥拍速度",
                        value: String(format: "%.2f m/s", swing.swingSpeed),
                        color: .blue,
                        icon: "speedometer"
                    )

                    MetricRow(
                        label: "预估球速",
                        value: String(format: "%.1f km/h", swing.estimatedBallSpeed),
                        color: .cyan,
                        icon: "figure.tennis"
                    )

                    MetricRow(
                        label: "峰值加速度",
                        value: String(format: "%.2f G", swing.peakAcceleration),
                        color: .orange,
                        icon: "waveform.path.ecg"
                    )

                    Divider()

                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text(swing.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                    .font(.caption)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.secondary.opacity(0.1))
                )

                Spacer()
            }
            .padding()
            .navigationTitle("挥拍详情")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MetricRow: View {
    let label: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)

            Text(label)
                .font(.callout)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    SpeedTrendChart(
        swings: [
            SwingData(swingType: .forehand, swingSpeed: 12.5, estimatedBallSpeed: 85, peakAcceleration: 3.2),
            SwingData(swingType: .forehand, swingSpeed: 13.0, estimatedBallSpeed: 88, peakAcceleration: 3.5),
            SwingData(swingType: .backhand, swingSpeed: 11.8, estimatedBallSpeed: 80, peakAcceleration: 3.0),
            SwingData(swingType: .forehand, swingSpeed: 14.2, estimatedBallSpeed: 95, peakAcceleration: 3.8)
        ],
        targetSpeed: 15.0
    )
    .padding()
}
