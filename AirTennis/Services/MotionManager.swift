//
//  MotionManager.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import CoreMotion
import Combine

/// 传感器数据管理服务
class MotionManager: ObservableObject {

    // MARK: - Properties

    /// Core Motion 管理器
    private let motionManager = CMMotionManager()

    /// 操作队列（传感器数据处理）
    private let motionQueue = OperationQueue()

    /// 采样率（Hz）
    let sampleRate: Double = 100.0

    /// 发布的运动数据
    @Published var currentMotion: CMDeviceMotion?

    /// 是否正在追踪
    @Published var isTracking: Bool = false

    /// 数据回调
    var onMotionUpdate: ((CMDeviceMotion) -> Void)?

    // MARK: - Initialization

    init() {
        motionQueue.maxConcurrentOperationCount = 1
        motionQueue.qualityOfService = .userInteractive
    }

    // MARK: - Public Methods

    /// 开始追踪传感器数据
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Device Motion not available")
            return
        }

        guard !isTracking else {
            print("⚠️ Already tracking")
            return
        }

        // 配置采样率
        motionManager.deviceMotionUpdateInterval = 1.0 / sampleRate

        // 开始更新
        motionManager.startDeviceMotionUpdates(
            using: .xArbitraryZVertical,
            to: motionQueue
        ) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("❌ Motion update error: \(error)")
                }
                return
            }

            // 更新到主线程
            DispatchQueue.main.async {
                self.currentMotion = motion
                self.onMotionUpdate?(motion)
            }
        }

        isTracking = true
        print("✅ Motion tracking started at \(sampleRate)Hz")
    }

    /// 停止追踪
    func stopTracking() {
        guard isTracking else { return }

        motionManager.stopDeviceMotionUpdates()
        isTracking = false
        currentMotion = nil

        print("🛑 Motion tracking stopped")
    }

    /// 检查传感器可用性
    func checkAvailability() -> (accelerometer: Bool, gyroscope: Bool, deviceMotion: Bool) {
        return (
            accelerometer: motionManager.isAccelerometerAvailable,
            gyroscope: motionManager.isGyroAvailable,
            deviceMotion: motionManager.isDeviceMotionAvailable
        )
    }

    deinit {
        stopTracking()
    }
}

// MARK: - Helper Extensions

extension CMDeviceMotion {
    /// 格式化输出（用于调试）
    var formattedDescription: String {
        let acc = userAcceleration
        let rot = rotationRate
        let att = attitude

        return """
        📱 Device Motion:
        Acceleration: x=\(String(format: "%.2f", acc.x)), y=\(String(format: "%.2f", acc.y)), z=\(String(format: "%.2f", acc.z))
        Rotation: x=\(String(format: "%.2f", rot.x)), y=\(String(format: "%.2f", rot.y)), z=\(String(format: "%.2f", rot.z))
        Attitude: pitch=\(String(format: "%.2f", att.pitch)), roll=\(String(format: "%.2f", att.roll)), yaw=\(String(format: "%.2f", att.yaw))
        """
    }
}
