import AVFoundation
import Foundation

/// Handles microphone permission checking and requesting for macOS
class MicrophonePermissionManager {
    static let shared = MicrophonePermissionManager()
    
    /// Check if the app has microphone permission
    func hasMicrophonePermission() -> Bool {
        // On macOS, we need to check if the app is in the microphone privacy settings
        // AVAudioRecorder will fail silently if permission is denied
        return checkMicrophoneAccess()
    }
    
    /// Request microphone permission (macOS shows system prompt)
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        // Create a temporary audio recorder to trigger the system permission prompt
        let tempURL = URL(fileURLWithPath: "/tmp/mic_test_\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        
        do {
            let recorder = try AVAudioRecorder(url: tempURL, settings: settings)
            // Try to record - this will trigger the permission prompt if needed
            let canRecord = recorder.record()
            
            // Stop and clean up
            recorder.stop()
            try FileManager.default.removeItem(at: tempURL)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                completion(canRecord)
            }
        } catch {
            print("❌ Microphone permission check failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    /// Check microphone access by attempting to create a recorder
    private func checkMicrophoneAccess() -> Bool {
        let tempURL = URL(fileURLWithPath: "/tmp/mic_check_\(UUID().uuidString).m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]
        
        do {
            let recorder = try AVAudioRecorder(url: tempURL, settings: settings)
            let canRecord = recorder.record()
            recorder.stop()
            try? FileManager.default.removeItem(at: tempURL)
            return canRecord
        } catch {
            print("❌ Microphone check error: \(error.localizedDescription)")
            return false
        }
    }
}
