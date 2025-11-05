//
//  TodayStatsCard.swift
//  AirTennis
//
//  Created by Claude on 2025-11-05.
//

import SwiftUI

struct TodayStatsCard: View {
    let stats: TodayStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("今日训练")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }

            // Progress Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(stats.swingCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.blue)
                    Text("/ \(stats.targetCount) 次")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(stats.progressPercent)%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * stats.progress, height: 12)
                    }
                }
                .frame(height: 12)
            }

            // Stats Grid
            HStack(spacing: 20) {
                // Average Speed
                VStack(alignment: .leading, spacing: 4) {
                    Text("平均速度")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", stats.averageSpeed))
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text("m/s")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if stats.speedChange != 0 {
                            Image(systemName: stats.speedChange > 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption)
                                .foregroundStyle(stats.speedChange > 0 ? .green : .red)
                        }
                    }
                }

                Divider()

                // Swing Type Ratio
                VStack(alignment: .leading, spacing: 4) {
                    Text("正手/反手")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.point.up.left.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            Text("\(stats.forehandCount)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        Text("/")
                            .foregroundStyle(.secondary)
                        HStack(spacing: 4) {
                            Image(systemName: "hand.point.up.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                            Text("\(stats.backhandCount)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }

            // Motivation Text
            Text(stats.motivationText)
                .font(.callout)
                .foregroundStyle(.secondary)
                .padding(.top, 4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
        )
    }
}

#Preview {
    TodayStatsCard(stats: TodayStats(
        swingCount: 23,
        targetCount: 30,
        progress: 0.76,
        averageSpeed: 13.2,
        speedChange: 1.5,
        forehandCount: 15,
        backhandCount: 8
    ))
    .padding()
}
