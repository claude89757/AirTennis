//
//  AudioFeedbackManager.swift
//  AirTennis
//
//  Created by Claude on 2025/11/5.
//

import Foundation
import AVFoundation

/// 音频反馈管理器
class AudioFeedbackManager {

    // MARK: - Properties

    /// 音频引擎
    private let audioEngine = AVAudioEngine()

    /// 播放器节点
    private let playerNode = AVAudioPlayerNode()

    /// 音频缓冲区缓存
    private var audioBuffers: [SoundType: AVAudioPCMBuffer] = [:]

    /// 是否已初始化
    private var isInitialized = false

    /// 标准音频格式（单声道，44.1kHz）
    private let standardFormat = AVAudioFormat(
        standardFormatWithSampleRate: 44100,
        channels: 2  // 立体声，与 mainMixerNode 兼容
    )!

    // MARK: - Sound Types

    enum SoundType {
        case swing      // 挥拍音（whoosh）
        case hit        // 击球音（impact）
        case success    // 成功音
        case error      // 错误音

        var fileName: String {
            switch self {
            case .swing: return "swing"
            case .hit: return "hit"
            case .success: return "success"
            case .error: return "error"
            }
        }
    }

    // MARK: - Initialization

    init() {
        setupAudioEngine()
    }

    // MARK: - Setup

    /// 设置音频引擎
    private func setupAudioEngine() {
        // 连接播放器节点到主混音器（使用标准格式）
        audioEngine.attach(playerNode)
        audioEngine.connect(
            playerNode,
            to: audioEngine.mainMixerNode,
            format: standardFormat
        )

        // 配置音频会话
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]  // 允许与其他音频混合
            )

            // 设置低延迟
            try audioSession.setPreferredIOBufferDuration(0.005)  // 5ms缓冲

            try audioSession.setActive(true)

            // 启动音频引擎
            try audioEngine.start()

            isInitialized = true
            print("🔊 Audio engine initialized successfully")

        } catch {
            print("❌ Failed to setup audio engine: \(error)")
            isInitialized = false
        }
    }

    // MARK: - Buffer Management

    /// 预加载音效
    /// - Parameters:
    ///   - soundType: 音效类型
    ///   - fileURL: 音频文件 URL
    func preloadSound(_ soundType: SoundType, from fileURL: URL) {
        do {
            let audioFile = try AVAudioFile(forReading: fileURL)

            // 创建与标准格式匹配的缓冲区
            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: standardFormat,
                frameCapacity: AVAudioFrameCount(audioFile.length)
            ) else {
                print("❌ Failed to create buffer for \(soundType)")
                return
            }

            // 如果文件格式与标准格式不同，需要转换
            if audioFile.processingFormat == standardFormat {
                // 格式相同，直接读取
                try audioFile.read(into: buffer)
            } else {
                // 格式不同，使用转换器
                let converter = AVAudioConverter(from: audioFile.processingFormat, to: standardFormat)!

                // 创建临时缓冲区读取原始数据
                guard let inputBuffer = AVAudioPCMBuffer(
                    pcmFormat: audioFile.processingFormat,
                    frameCapacity: AVAudioFrameCount(audioFile.length)
                ) else {
                    print("❌ Failed to create input buffer for \(soundType)")
                    return
                }

                try audioFile.read(into: inputBuffer)

                // 转换格式
                var error: NSError?
                let inputBlock: AVAudioConverterInputBlock = { inNumPackets, outStatus in
                    outStatus.pointee = .haveData
                    return inputBuffer
                }

                converter.convert(to: buffer, error: &error, withInputFrom: inputBlock)

                if let error = error {
                    print("⚠️ Conversion warning for \(soundType): \(error)")
                }
            }

            buffer.frameLength = buffer.frameCapacity
            audioBuffers[soundType] = buffer

            print("✅ Preloaded sound: \(soundType)")

        } catch {
            print("❌ Failed to load sound \(soundType): \(error)")
        }
    }

    /// 预加载所有音效（从 Bundle）
    func preloadAllSounds() {
        for soundType in [SoundType.swing, .hit, .success, .error] {
            if let url = Bundle.main.url(
                forResource: soundType.fileName,
                withExtension: "wav"
            ) {
                preloadSound(soundType, from: url)
            } else {
                print("⚠️ Sound file not found: \(soundType.fileName).wav")
                // 创建静音缓冲区作为占位符
                createSilentBuffer(for: soundType)
            }
        }
    }

    /// 创建静音缓冲区（当音效文件不存在时）
    private func createSilentBuffer(for soundType: SoundType) {
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: standardFormat,
            frameCapacity: 4410  // 0.1秒的静音
        ) else { return }

        buffer.frameLength = buffer.frameCapacity

        // 清零所有数据（确保静音）
        if let channelData = buffer.floatChannelData {
            for channel in 0..<Int(buffer.format.channelCount) {
                memset(channelData[channel], 0, Int(buffer.frameLength) * MemoryLayout<Float>.size)
            }
        }

        audioBuffers[soundType] = buffer

        print("⚠️ Created silent buffer for \(soundType)")
    }

    // MARK: - Playback

    /// 播放音效
    /// - Parameters:
    ///   - soundType: 音效类型
    ///   - volume: 音量 (0.0 - 1.0)
    func playSound(_ soundType: SoundType, volume: Float = 1.0) {
        guard isInitialized else {
            print("⚠️ Audio engine not initialized")
            return
        }

        guard let buffer = audioBuffers[soundType] else {
            print("⚠️ Buffer not found for \(soundType)")
            return
        }

        // 设置音量
        playerNode.volume = max(0.0, min(1.0, volume))

        // 调度播放
        playerNode.scheduleBuffer(
            buffer,
            at: nil,
            options: [],
            completionHandler: nil
        )

        // 确保播放器在运行
        if !playerNode.isPlaying {
            playerNode.play()
        }
    }

    /// 根据速度播放动态音效
    /// - Parameter swingSpeed: 挥拍速度 (m/s)
    func playSwingSound(swingSpeed: Double) {
        // 根据速度调整音量 (15-30 m/s 映射到 0.5-1.0)
        let normalizedSpeed = (swingSpeed - 15.0) / 15.0  // 15-30 m/s
        let volume = Float(0.5 + normalizedSpeed * 0.5)

        playSound(.swing, volume: volume)
    }

    /// 播放击球音效
    /// - Parameter intensity: 强度 (0.0 - 1.0)
    func playHitSound(intensity: Float = 1.0) {
        playSound(.hit, volume: intensity)
    }

    /// 播放成功音效
    func playSuccessSound() {
        playSound(.success, volume: 0.8)
    }

    /// 播放错误音效
    func playErrorSound() {
        playSound(.error, volume: 0.6)
    }

    // MARK: - Cleanup

    deinit {
        audioEngine.stop()
        print("🔊 Audio engine stopped")
    }
}
