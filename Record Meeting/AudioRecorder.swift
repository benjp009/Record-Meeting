import AVFoundation
import Foundation

/// Handles audio recording and file management
class AudioRecorder: NSObject, AVAudioRecorderDelegate {
    static let shared = AudioRecorder()
    
    private var audioRecorder: AVAudioRecorder?
    private var recordingURL: URL?
    
    var isRecording: Bool {
        audioRecorder?.isRecording ?? false
    }
    
    var recordingTime: TimeInterval {
        audioRecorder?.currentTime ?? 0
    }
    
    // MARK: - Recording Methods
    
    /// Start recording audio with a given filename
    func startRecording(filename: String) -> Bool {
        do {
            // Request microphone permission
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            // Create recording URL
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let meetingsFolder = documentsURL.appendingPathComponent("Meetings")
            
            // Create Meetings folder if it doesn't exist
            try FileManager.default.createDirectory(at: meetingsFolder, withIntermediateDirectories: true)
            
            recordingURL = meetingsFolder.appendingPathComponent(filename)
            
            guard let recordingURL = recordingURL else {
                Logger.log("Failed to create recording URL", level: .error)
                return false
            }
            
            // Configure audio settings
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: AppConfig.Recording.defaultSampleRate,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: AppConfig.Recording.defaultBitRate
            ]
            
            // Create and start recorder
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            Logger.log("Recording started: \(filename)", level: .info)
            return true
        } catch {
            Logger.log("Failed to start recording: \(error.localizedDescription)", level: .error)
            return false
        }
    }
    
    /// Stop recording and return the recording details
    func stopRecording() -> Recording? {
        guard audioRecorder?.isRecording == true else {
            Logger.log("No active recording to stop", level: .warning)
            return nil
        }
        
        audioRecorder?.stop()
        
        guard let recordingURL = recordingURL else {
            Logger.log("Recording URL not found", level: .error)
            return nil
        }
        
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: recordingURL.path)
        let fileSize = fileAttributes?[.size] as? Int ?? 0
        
        let recording = Recording(
            filename: recordingURL.lastPathComponent,
            url: recordingURL,
            duration: audioRecorder?.currentTime ?? 0,
            fileSize: fileSize,
            createdAt: Date()
        )
        
        Logger.log("Recording stopped: \(recording.filename) (\(formatFileSize(fileSize)))", level: .info)
        return recording
    }
    
    /// Pause recording
    func pauseRecording() {
        audioRecorder?.pause()
        Logger.log("Recording paused", level: .info)
    }
    
    /// Resume recording
    func resumeRecording() -> Bool {
        guard audioRecorder?.pause() != nil else {
            Logger.log("Failed to resume recording", level: .error)
            return false
        }
        audioRecorder?.record()
        Logger.log("Recording resumed", level: .info)
        return true
    }
    
    // MARK: - File Management
    
    /// Get all recordings from Documents/Meetings folder
    func getAllRecordings() -> [Recording] {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let meetingsFolder = documentsURL.appendingPathComponent("Meetings")
            
            guard FileManager.default.fileExists(atPath: meetingsFolder.path) else {
                return []
            }
            
            let fileURLs = try FileManager.default.contentsOfDirectory(at: meetingsFolder, includingPropertiesForKeys: nil)
            
            return fileURLs
                .filter { $0.pathExtension.lowercased() == "m4a" }
                .compactMap { url -> Recording? in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = attributes?[.size] as? Int ?? 0
                    let createdAt = attributes?[.creationDate] as? Date ?? Date()
                    
                    let asset = AVAsset(url: url)
                    let duration = CMTimeGetSeconds(asset.duration)
                    
                    return Recording(
                        filename: url.lastPathComponent,
                        url: url,
                        duration: duration,
                        fileSize: fileSize,
                        createdAt: createdAt
                    )
                }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            Logger.log("Failed to get recordings: \(error.localizedDescription)", level: .error)
            return []
        }
    }
    
    /// Delete a recording file
    func deleteRecording(url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            Logger.log("Recording deleted: \(url.lastPathComponent)", level: .info)
            return true
        } catch {
            Logger.log("Failed to delete recording: \(error.localizedDescription)", level: .error)
            return false
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useBytes]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    // MARK: - AVAudioRecorderDelegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            Logger.log("Recording failed to finish successfully", level: .error)
        }
    }
}

// MARK: - Recording Model

struct Recording: Identifiable {
    let id = UUID()
    let filename: String
    let url: URL
    let duration: TimeInterval
    let fileSize: Int
    let createdAt: Date
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useBytes]
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: Int64(fileSize))
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}
