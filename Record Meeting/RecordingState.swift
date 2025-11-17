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
    @Published var isPlaying = false
    @Published var currentlyPlayingId: UUID?
    
    private let audioRecorder = AudioRecorder.shared
    private let audioPlayer = AudioPlayer.shared
    private let permissionManager = MicrophonePermissionManager.shared
    private var timer: Timer?
    private var recordingStartTime: Date?
    private var playbackTimer: Timer?
    
    init() {
        // Delay loading recordings to avoid crashes in previews
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.loadRecordings()
        }
    }
    
    // MARK: - Recording Control
    
    func startRecording() {
        // Check microphone permission first
        if !permissionManager.hasMicrophonePermission() {
            print("⚠️ Microphone permission not granted, requesting...")
            permissionManager.requestMicrophonePermission { [weak self] granted in
                if granted {
                    print("✅ Microphone permission granted!")
                    DispatchQueue.main.async {
                        self?.startRecordingInternal()
                    }
                } else {
                    print("❌ Microphone permission denied")
                    DispatchQueue.main.async {
                        self?.errorMessage = "Microphone permission denied. Please allow microphone access in System Settings > Security & Privacy."
                    }
                }
            }
        } else {
            startRecordingInternal()
        }
    }
    
    private func startRecordingInternal() {
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let loadedRecordings = self?.audioRecorder.getAllRecordings() ?? []
            DispatchQueue.main.async {
                self?.recordings = loadedRecordings
            }
        }
    }
    
    func deleteRecording(_ recording: Recording) {
        if audioRecorder.deleteRecording(url: recording.url) {
            loadRecordings()
        } else {
            errorMessage = "Failed to delete recording"
        }
    }
    
    func renameRecording(_ recording: Recording, newName: String) {
        // Ensure filename has .m4a extension
        let finalName = newName.hasSuffix(".m4a") ? newName : "\(newName).m4a"
        
        if audioRecorder.renameRecording(url: recording.url, newName: finalName) != nil {
            loadRecordings()
        } else {
            errorMessage = "Failed to rename recording"
        }
    }
    
    // MARK: - Playback Control
    
    func playRecording(_ recording: Recording) {
        // Stop any currently playing recording
        if isPlaying {
            stopPlayback()
        }
        
        if audioPlayer.play(url: recording.url) {
            isPlaying = true
            currentlyPlayingId = recording.id
            startPlaybackTimer()
        } else {
            errorMessage = "Failed to play recording"
        }
    }
    
    func stopPlayback() {
        audioPlayer.stop()
        isPlaying = false
        currentlyPlayingId = nil
        stopPlaybackTimer()
    }
    
    func openRecordingInFinder(_ recording: Recording) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        process.arguments = ["-R", recording.url.path]
        try? process.run()
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
    
    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Update UI if needed - playback state will be reflected in the UI
            if self?.audioPlayer.isPlaying == false {
                self?.isPlaying = false
                self?.currentlyPlayingId = nil
                self?.stopPlaybackTimer()
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    deinit {
        stopTimer()
        stopPlaybackTimer()
        stopPlayback()
    }
}
