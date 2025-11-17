import AVFoundation
import Foundation

/// Handles audio recording and file management for macOS
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
            // Create recording URL
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let meetingsFolder = documentsURL.appendingPathComponent("Meetings")
            
            // Create Meetings folder if it doesn't exist
            try FileManager.default.createDirectory(at: meetingsFolder, withIntermediateDirectories: true)
            
            recordingURL = meetingsFolder.appendingPathComponent(filename)
            
            guard let recordingURL = recordingURL else {
                print("❌ Failed to create recording URL")
                return false
            }
            
            // Configure audio settings for macOS
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ]
            
            // Create and start recorder
            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            print("✅ Recording started: \(filename)")
            return true
        } catch {
            print("❌ Failed to start recording: \(error.localizedDescription)")
            return false
        }
    }
    
    /// Stop recording and return the recording details
    func stopRecording() -> Recording? {
        guard audioRecorder?.isRecording == true else {
            print("⚠️ No active recording to stop")
            return nil
        }
        
        audioRecorder?.stop()
        
        guard let recordingURL = recordingURL else {
            print("❌ Recording URL not found")
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
        
        print("✅ Recording stopped: \(recording.filename) (\(formatFileSize(fileSize)))")
        return recording
    }
    
    /// Pause recording
    func pauseRecording() {
        audioRecorder?.pause()
        print("⏸️ Recording paused")
    }
    
    /// Resume recording
    func resumeRecording() -> Bool {
        guard audioRecorder?.pause() != nil else {
            print("❌ Failed to resume recording")
            return false
        }
        audioRecorder?.record()
        print("▶️ Recording resumed")
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
            
            var recordings: [Recording] = []
            for url in fileURLs where url.pathExtension.lowercased() == "m4a" {
                let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                let fileSize = attributes?[.size] as? Int ?? 0
                let createdAt = attributes?[.creationDate] as? Date ?? Date()
                
                // Get duration from file without using deprecated AVAsset APIs
                // For now, use 0 as placeholder - duration will be calculated on first access if needed
                let duration: TimeInterval = 0
                
                let recording = Recording(
                    filename: url.lastPathComponent,
                    url: url,
                    duration: duration,
                    fileSize: fileSize,
                    createdAt: createdAt
                )
                recordings.append(recording)
            }
            
            return recordings.sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("❌ Failed to get recordings: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Delete a recording file
    func deleteRecording(url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            print("✅ Recording deleted: \(url.lastPathComponent)")
            return true
        } catch {
            print("❌ Failed to delete recording: \(error.localizedDescription)")
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
            print("❌ Recording failed to finish successfully")
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

