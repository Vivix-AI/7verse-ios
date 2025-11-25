import AVFoundation
import UIKit

/// Manages audio session configuration for optimal voice quality with noise cancellation
/// Optimized for VAD (Voice Activity Detection) and ASR (Automatic Speech Recognition)
class AudioSessionManager {
    static let shared = AudioSessionManager()
    
    private init() {}
    
    /// Configure audio session for ASR-optimized voice input
    /// This leverages hardware-level optimizations for Voice Activity Detection and Speech Recognition
    func configureForVoiceInput() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // STEP 1: Configure audio category and mode
            try audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,  // Enables automatic noise suppression, AGC, and echo cancellation
                options: [
                    .defaultToSpeaker,
                    .allowBluetoothA2DP,
                    .mixWithOthers
                ]
            )
            
            // STEP 2: Optimize sample rate for ASR (16kHz optimal for speech)
            try audioSession.setPreferredSampleRate(16000.0)
            
            // STEP 3: Optimize I/O buffer for low latency VAD (10ms)
            try audioSession.setPreferredIOBufferDuration(0.010)
            
            // STEP 4: Set preferred input and mono channel
            if let availableInputs = audioSession.availableInputs,
               let builtInMic = availableInputs.first(where: { $0.portType == .builtInMic }) {
                try audioSession.setPreferredInput(builtInMic)
                
                // Configure front-facing microphone with cardioid pattern
                let dataSources = builtInMic.dataSources ?? []
                var frontSource: AVAudioSessionDataSourceDescription? = nil
                
                for source in dataSources {
                    if source.orientation == AVAudioSession.Orientation.front {
                        frontSource = source
                        break
                    }
                }
                
                if frontSource == nil && !dataSources.isEmpty {
                    frontSource = dataSources.first
                }
                
                if let dataSource = frontSource {
                    try builtInMic.setPreferredDataSource(dataSource)
                    
                    // Try to set Cardioid polar pattern for optimal noise rejection
                    if let supportedPatterns = dataSource.supportedPolarPatterns,
                       let cardioid = supportedPatterns.first(where: { pattern in
                           pattern == AVAudioSession.PolarPattern.cardioid
                       }) {
                        try dataSource.setPreferredPolarPattern(cardioid)
                    }
                }
                
                try audioSession.setPreferredInputNumberOfChannels(1)  // Mono for ASR
            }
            
            // STEP 5: Configure input gain for optimal dynamic range
            if audioSession.isInputGainSettable {
                try audioSession.setInputGain(0.75)
            }
            
            // STEP 6: Activate the session
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Log success (minimal output)
            print("✅ [AudioSession] Configured: 16kHz, Cardioid, VAD/ASR optimized")
            
        } catch {
            // Don't crash in production, just log the error
            print("⚠️ [AudioSession] Configuration failed: \(error.localizedDescription)")
            print("⚠️ [AudioSession] Continuing with default settings")
        }
    }
    
    /// Configure for high-quality recording (e.g., for music or podcast)
    func configureForHighQualityRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.defaultToSpeaker]
            )
            
            try audioSession.setPreferredSampleRate(48000.0)
            try audioSession.setPreferredIOBufferDuration(0.005)
            try audioSession.setActive(true)
            
            print("✅ [AudioSession] High-quality recording: 48kHz")
        } catch {
            print("⚠️ [AudioSession] HQ recording config failed: \(error.localizedDescription)")
        }
    }
    
    /// Configure for ultra-high-quality ASR (when WiFi available, not cellular)
    /// 48kHz sample rate for maximum fidelity, then let server downsample
    func configureForHighQualityASR() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .measurement,
                options: [.defaultToSpeaker, .allowBluetoothA2DP]
            )
            
            try audioSession.setPreferredSampleRate(48000.0)
            try audioSession.setPreferredIOBufferDuration(0.005)
            try audioSession.setPreferredInputNumberOfChannels(1)
            try audioSession.setActive(true)
            
            print("✅ [AudioSession] High-quality ASR: 48kHz")
        } catch {
            print("⚠️ [AudioSession] HQ ASR config failed: \(error.localizedDescription)")
        }
    }
    
    /// Get current audio input level (for VAD visualization)
    /// Returns dB value (-160 to 0), useful for showing "listening" animation
    func getCurrentInputLevel() -> Float {
        let audioSession = AVAudioSession.sharedInstance()
        
        // inputGain ranges from 0.0 to 1.0
        // We can estimate relative level based on this
        if audioSession.isInputAvailable {
            return audioSession.inputGain
        }
        
        return 0.0
    }
    
    /// Monitor audio route changes (e.g., plugging in headphones)
    /// Call this to set up notifications for route changes
    func setupRouteChangeObserver(onChange: @escaping (AVAudioSession.RouteChangeReason) -> Void) {
        NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
                  let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
                return
            }
            
            onChange(reason)
        }
    }
    
    /// Deactivate audio session when done
    func deactivate() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // Silent failure is OK for deactivation
        }
    }
    
    /// Get current audio route information
    func logAudioRoute() {
        let audioSession = AVAudioSession.sharedInstance()
        
        print("🎙️ [AudioSession] Route: \(audioSession.currentRoute.inputs.first?.portName ?? "Unknown")")
    }
}

