import Foundation
import Combine

/// ViewModel for managing recording state and UI updates
class RecordingState: ObservableObject {
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordings: [Recording] = []
    @Published var currentRecordingName: String = ""
    @Published var recordingDuration: TimeInterval = 0
    @Published var errorMessage: String?
    
    private let audioRecorder = AudioRecorder.shared
    private var timer: Timer?
    private var recordingStartTime: Date?
    
    init() {
        // Delay loading recordings to avoid crashes in previews
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.loadRecordings()
        }
    }
    
    // MARK: - Recording Control
    
    func startRecording() {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let filename = "Meeting_\(timestamp).m4a"
        
        if audioRecorder.startRecording(filename: filename) {
            isRecording = true
            isPaused = false
            currentRecordingName = filename
            recordingStartTime = Date()
            startTimer()
            errorMessage = nil
        } else {
            errorMessage = "Failed to start recording"
        }
    }
    
    func stopRecording() {
        if audioRecorder.stopRecording() != nil {
            isRecording = false
            isPaused = false
            stopTimer()
            recordingDuration = 0
            currentRecordingName = ""
            loadRecordings()
        } else {
            errorMessage = "Failed to stop recording"
        }
    }
    
    func pauseRecording() {
        audioRecorder.pauseRecording()
        isPaused = true
        stopTimer()
    }
    
    func resumeRecording() {
        if audioRecorder.resumeRecording() {
            isPaused = false
            startTimer()
        } else {
            errorMessage = "Failed to resume recording"
        }
    }
    
    // MARK: - Recording Management
    
    func loadRecordings() {
        recordings = audioRecorder.getAllRecordings()
    }
    
    func deleteRecording(_ recording: Recording) {
        if audioRecorder.deleteRecording(url: recording.url) {
            loadRecordings()
        } else {
            errorMessage = "Failed to delete recording"
        }
    }
    
    // MARK: - Timer Management
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            if let startTime = self?.recordingStartTime {
                self?.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        stopTimer()
    }
}
