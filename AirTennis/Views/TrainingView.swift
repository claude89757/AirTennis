//
//  TrainingView.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import SwiftUI
import SwiftData

/// 训练界面
struct TrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel = TrainingViewModel()

    // 长按停止按钮状态
    @State private var longPressProgress: CGFloat = 0
    @State private var isLongPressing = false
    @State private var longPressTimer: Timer?

    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                colors: [Color.black, Color.blue.opacity(0.3), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 顶部工具栏
                HStack {
                    Button {
                        if viewModel.isTraining {
                            viewModel.stopTraining()
                        }
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }

                    Spacer()

                    // 状态指示器
                    HStack(spacing: 8) {
                        Circle()
                            .fill(viewModel.isTraining ? Color.green : Color.gray)
                            .frame(width: 12, height: 12)

                        Text(viewModel.isTraining ? "训练中" : "已暂停")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(20)

                    Spacer()

                    // 占位，保持居中
                    Color.clear
                        .frame(width: 60)
                }
                .padding(.horizontal)
                .padding(.top, -20)

                // 主显示区域
                VStack(spacing: 20) {
                    // 当前挥拍数据显示
                    if let swing = viewModel.currentSwing {
                        SwingDataCard(swing: swing)
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        PlaceholderCard(state: viewModel.detectorState)
                    }

                    Spacer()

                    // 会话统计
                    SessionStatsView(stats: viewModel.sessionStats)
                        .padding(.horizontal, 20)

                    // 控制按钮
                    HStack(spacing: 20) {
                        if !viewModel.isTraining {
                            Button {
                                viewModel.startTraining()
                            } label: {
                                Label("开始", systemImage: "play.fill")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 20)
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                        } else {
                            // 长按停止按钮
                            LongPressStopButton(
                                progress: $longPressProgress,
                                isLongPressing: $isLongPressing
                            ) {
                                viewModel.stopTraining()
                            }
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
        .animation(.spring(response: 0.3), value: viewModel.currentSwing)
        .animation(.easeInOut, value: viewModel.isTraining)
    }
}

// MARK: - 挥拍数据卡片

struct SwingDataCard: View {
    let swing: SwingData

    var body: some View {
        VStack(spacing: 38) {
            // 动作类型
            HStack {
                Image(systemName: swing.swingType.iconName)
                    .font(.title)
                Text(swing.swingType.rawValue)
                    .font(.system(size: 44, weight: .bold))
            }
            .foregroundColor(colorForType(swing.swingType))

            Divider()
                .background(Color.white.opacity(0.3))

            // 速度数据
            VStack(spacing: 28) {
                DataRow(
                    title: "挥拍速度",
                    value: String(format: "%.1f", swing.swingSpeed),
                    unit: "m/s",
                    color: colorForSpeed(swing.speedLevel)
                )

                DataRow(
                    title: "估算球速",
                    value: String(format: "%.0f", swing.estimatedBallSpeed),
                    unit: "km/h",
                    color: .cyan
                )

                DataRow(
                    title: "加速度峰值",
                    value: String(format: "%.2f", swing.peakAcceleration),
                    unit: "G",
                    color: .orange
                )
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 50)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.15))
                .shadow(color: .black.opacity(0.3), radius: 20)
        )
        .padding(.horizontal, 30)
    }

    private func colorForType(_ type: SwingType) -> Color {
        switch type {
        case .forehand: return .blue
        case .backhand: return .green
        case .unknown: return .gray
        }
    }

    private func colorForSpeed(_ level: SpeedLevel) -> Color {
        switch level {
        case .excellent: return .green
        case .good: return .blue
        case .medium: return .yellow
        case .low: return .gray
        }
    }
}

// MARK: - 数据行

struct DataRow: View {
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(color)

                Text(unit)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - 占位卡片

struct PlaceholderCard: View {
    let state: SwingState

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.5))

            Text(message)
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(height: 450)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.1))
        )
        .padding(.horizontal, 30)
    }

    private var iconName: String {
        switch state {
        case .idle: return "hand.raised.fill"
        case .detecting, .swinging: return "waveform"
        case .peak, .classifying: return "sparkles"
        case .completed: return "checkmark.circle.fill"
        }
    }

    private var message: String {
        switch state {
        case .idle: return "准备就绪\n请挥拍"
        case .detecting: return "检测中..."
        case .swinging: return "挥拍中..."
        case .peak: return "分析中..."
        case .classifying: return "识别中..."
        case .completed: return "完成！"
        }
    }
}

// MARK: - 长按停止按钮

struct LongPressStopButton: View {
    @Binding var progress: CGFloat
    @Binding var isLongPressing: Bool
    let onComplete: () -> Void

    @State private var timer: Timer?
    private let longPressDuration: Double = 1.5 // 1.5秒
    private let updateInterval: Double = 0.016 // 约60fps

    var body: some View {
        ZStack {
            // 按钮背景
            Label("长按停止", systemImage: "stop.fill")
                .font(.title2)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(16)

            // 进度环
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 60, height: 60)
                .rotationEffect(.degrees(-90))
                .opacity(isLongPressing ? 1 : 0)
                .animation(.easeInOut(duration: 0.2), value: isLongPressing)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isLongPressing {
                        startLongPress()
                    }
                }
                .onEnded { _ in
                    cancelLongPress()
                }
        )
    }

    private func startLongPress() {
        isLongPressing = true
        progress = 0

        // 轻震动反馈
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()

        // 启动定时器
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            progress += CGFloat(updateInterval / longPressDuration)

            if progress >= 1.0 {
                completeLongPress()
            }
        }
    }

    private func completeLongPress() {
        timer?.invalidate()
        timer = nil
        isLongPressing = false
        progress = 0

        // 强震动反馈
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()

        // 触发回调
        onComplete()
    }

    private func cancelLongPress() {
        timer?.invalidate()
        timer = nil

        withAnimation(.easeOut(duration: 0.2)) {
            isLongPressing = false
            progress = 0
        }
    }
}

// MARK: - 会话统计视图

struct SessionStatsView: View {
    let stats: SessionStats

    var body: some View {
        HStack(spacing: 15) {
            StatItem(title: "总计", value: "\(stats.totalSwings)")
            StatItem(title: "正手", value: "\(stats.forehandCount)")
            StatItem(title: "反手", value: "\(stats.backhandCount)")
            StatItem(
                title: "平均",
                value: stats.averageSpeed > 0 ? String(format: "%.1f", stats.averageSpeed) : "--"
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct StatItem: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}


#Preview {
    TrainingView()
        .modelContainer(for: SwingData.self, inMemory: true)
}
