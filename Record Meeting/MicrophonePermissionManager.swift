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
        guard let tempURL = getTempRecordingURL() else {
            print("❌ Could not create temp recording URL")
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
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
            
            // Stop immediately
            recorder.stop()
            
            // Give system time to process
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Clean up temp file
                try? FileManager.default.removeItem(at: tempURL)
                completion(canRecord)
            }
        } catch {
            print("❌ Microphone permission check failed: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempURL)
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
    
    /// Check microphone access by attempting to create a recorder
    private func checkMicrophoneAccess() -> Bool {
        guard let tempURL = getTempRecordingURL() else {
            print("❌ Could not create temp recording URL")
            return false
        }
        
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
            print("✅ Microphone check passed - can record: \(canRecord)")
            return canRecord
        } catch {
            print("❌ Microphone check error: \(error.localizedDescription)")
            try? FileManager.default.removeItem(at: tempURL)
            return false
        }
    }
    
    /// Get a temporary recording URL in the Documents/Meetings folder (within sandbox)
    private func getTempRecordingURL() -> URL? {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let meetingsFolder = documentsURL.appendingPathComponent("Meetings")
            
            // Create Meetings folder if it doesn't exist
            try FileManager.default.createDirectory(at: meetingsFolder, withIntermediateDirectories: true)
            
            let tempFileName = "mic_check_\(UUID().uuidString).m4a"
            return meetingsFolder.appendingPathComponent(tempFileName)
        } catch {
            print("❌ Failed to create temp recording URL: \(error.localizedDescription)")
            return nil
        }
    }
}
