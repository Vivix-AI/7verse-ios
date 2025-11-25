import AVFoundation
import UIKit

/// Manages audio session configuration for optimal voice quality with noise cancellation
class AudioSessionManager {
    static let shared = AudioSessionManager()
    
    private init() {}
    
    /// Configure audio session for high-quality voice input with noise cancellation
    /// This leverages iPhone's microphone array for beamforming and echo cancellation
    func configureForVoiceInput() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            // Use .playAndRecord mode to enable full duplex audio
            // This is required for real-time voice interactions
            try audioSession.setCategory(
                .playAndRecord,
                mode: .voiceChat,  // Optimized for voice, enables noise cancellation
                options: [
                    .defaultToSpeaker,     // Use speaker by default
                    .allowBluetooth,       // Support Bluetooth headsets
                    .allowBluetoothA2DP    // Support high-quality Bluetooth audio
                ]
            )
            
            // Activate the session
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            print("✅ [AudioSession] Configured with:")
            print("   - Mode: .voiceChat (auto noise cancellation)")
            print("   - Microphone array: Enabled")
            print("   - Echo cancellation: Enabled")
            print("   - Beamforming: Enabled (automatic)")
            
        } catch {
            print("❌ [AudioSession] Failed to configure: \(error)")
            fatalError("Cannot configure audio session for voice input: \(error)")
        }
    }
    
    /// Configure for high-quality recording (e.g., for music or podcast)
    func configureForHighQualityRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(
                .playAndRecord,
                mode: .measurement,  // Minimal processing, maximum quality
                options: [.defaultToSpeaker, .allowBluetooth]
            )
            
            // Request highest sample rate and I/O buffer duration
            try audioSession.setPreferredSampleRate(48000.0)
            try audioSession.setPreferredIOBufferDuration(0.005)  // 5ms latency
            
            try audioSession.setActive(true)
            
            print("✅ [AudioSession] High-quality recording mode")
            
        } catch {
            print("❌ [AudioSession] Failed to configure HQ mode: \(error)")
        }
    }
    
    /// Deactivate audio session when done
    func deactivate() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("✅ [AudioSession] Deactivated")
        } catch {
            print("⚠️ [AudioSession] Failed to deactivate: \(error)")
        }
    }
    
    /// Get current audio route information
    func logAudioRoute() {
        let audioSession = AVAudioSession.sharedInstance()
        
        print("🎙️ [AudioSession] Current route:")
        
        for input in audioSession.currentRoute.inputs {
            print("   Input: \(input.portName) - \(input.portType.rawValue)")
            print("   Channels: \(input.channels?.count ?? 0)")
        }
        
        for output in audioSession.currentRoute.outputs {
            print("   Output: \(output.portName) - \(output.portType.rawValue)")
        }
    }
}

