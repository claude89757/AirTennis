//
//  MainView.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import SwiftUI

/// 主界面
struct MainView: View {
    @State private var showTraining = false
    @State private var showHistory = false
    @State private var showSensorAlert = false
    @State private var sensorStatus = ""

    // 视图模型（用于传感器检查）
    @StateObject private var viewModel = TrainingViewModel()

    // 震动反馈管理器
    private let haptic = HapticManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // 应用标题
                VStack(spacing: 10) {
                    Image(systemName: "tennisball.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)

                    Text("AirTennis")
                        .font(.system(size: 48, weight: .bold, design: .rounded))

                    Text("网球体感训练")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)

                Spacer()

                // 功能按钮
                VStack(spacing: 20) {
                    // 开始训练
                    Button {
                        haptic.buttonTap()
                        showTraining = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "figure.tennis")
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("开始训练")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("记录你的每次挥拍")
                                    .font(.caption)
                                    .opacity(0.9)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .opacity(0.8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.85)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.3), radius: 8, y: 4)
                    }

                    // 训练档案
                    Button {
                        haptic.buttonTap()
                        showHistory = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text("训练档案")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text("查看进步轨迹")
                                    .font(.caption)
                                    .opacity(0.7)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .opacity(0.5)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.ultraThinMaterial)

                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.3),
                                                Color.purple.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                        )
                        .shadow(color: .blue.opacity(0.15), radius: 8, y: 4)
                    }
                    .foregroundStyle(.primary)

                    // 传感器调试
                    Button {
                        haptic.buttonTap()
                        sensorStatus = viewModel.checkSensorAvailability()
                        showSensorAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "gyroscope")
                            Text("传感器调试")
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()

                // 版本信息
                Text("MVP v1.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 20)
            }
            .fullScreenCover(isPresented: $showTraining) {
                TrainingView()
            }
            .sheet(isPresented: $showHistory) {
                HistoryView()
            }
            .alert("传感器状态", isPresented: $showSensorAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(sensorStatus)
            }
        }
    }
}

#Preview {
    MainView()
}
