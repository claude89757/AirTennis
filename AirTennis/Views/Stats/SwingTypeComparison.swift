//
//  SwingTypeComparison.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI
import Charts

struct SwingTypeComparison: View {
    let stats: SwingTypeStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("正手 vs 反手")
                .font(.headline)

            if stats.totalCount == 0 {
                // Empty State
                VStack(spacing: 12) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("暂无数据")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 20) {
                    // Count Comparison
                    VStack(alignment: .leading, spacing: 12) {
                        Text("挥拍次数")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 12) {
                            // Forehand
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "hand.point.up.left.fill")
                                        .foregroundStyle(.blue)
                                    Text("正手")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text("\(stats.forehandCount)")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.blue)
                                        .frame(width: geometry.size.width * stats.forehandPercentage, height: 8)
                                }
                                .frame(height: 8)

                                Text(String(format: "%.0f%%", stats.forehandPercentage * 100))
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            // Backhand
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "hand.point.up.fill")
                                        .foregroundStyle(.red)
                                    Text("反手")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Text("\(stats.backhandCount)")
                                    .font(.title2)
                                    .fontWeight(.bold)

                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(.red)
                                        .frame(width: geometry.size.width * stats.backhandPercentage, height: 8)
                                }
                                .frame(height: 8)

                                Text(String(format: "%.0f%%", stats.backhandPercentage * 100))
                                    .font(.caption2)
                                    .foregroundStyle(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Divider()

                    // Speed Comparison Chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("平均速度")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Chart {
                            BarMark(
                                x: .value("类型", "正手"),
                                y: .value("速度", stats.forehandAvgSpeed)
                            )
                            .foregroundStyle(.blue)
                            .annotation(position: .top) {
                                Text(String(format: "%.1f", stats.forehandAvgSpeed))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }

                            BarMark(
                                x: .value("类型", "反手"),
                                y: .value("速度", stats.backhandAvgSpeed)
                            )
                            .foregroundStyle(.red)
                            .annotation(position: .top) {
                                Text(String(format: "%.1f", stats.backhandAvgSpeed))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(height: 120)
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
                        .chartYAxisLabel("m/s", alignment: .center)
                    }

                    // Insight
                    if stats.forehandCount > 0 && stats.backhandCount > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(.yellow)
                            Text(getInsight())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.yellow.opacity(0.1))
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

    private func getInsight() -> String {
        let countDiff = abs(stats.forehandCount - stats.backhandCount)
        let speedDiff = stats.forehandAvgSpeed - stats.backhandAvgSpeed

        if countDiff > stats.totalCount / 3 {
            let dominant = stats.forehandCount > stats.backhandCount ? "正手" : "反手"
            return "建议增加\(dominant == "正手" ? "反手" : "正手")练习，保持平衡发展"
        } else if abs(speedDiff) > 2.0 {
            let faster = speedDiff > 0 ? "正手" : "反手"
            let slower = speedDiff > 0 ? "反手" : "正手"
            return "\(faster)速度较快，可以重点提升\(slower)的力量和技术"
        } else {
            return "正反手发展均衡，继续保持！"
        }
    }
}

#Preview {
    SwingTypeComparison(stats: SwingTypeStats(
        forehandCount: 45,
        backhandCount: 32,
        forehandAvgSpeed: 13.5,
        backhandAvgSpeed: 11.8
    ))
    .padding()
}
