import SwiftUI

struct ContentView: View {
    @StateObject private var recordingState = RecordingState()
    
    var body: some View {
        ZStack {
            // Background
            Color(.controlBackgroundColor)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Meeting Recorder")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Record, organize, and manage your meeting audio")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                // Recording Controls Section
                if recordingState.isRecording {
                    recordingControlsView
                        .padding(.horizontal, 40)
                } else {
                    startRecordingView
                        .padding(.horizontal, 40)
                }
                
                // Recordings List
                if !recordingState.recordings.isEmpty {
                    recordingsListView
                        .padding(.horizontal, 40)
                } else if !recordingState.isRecording {
                    VStack(spacing: 16) {
                        Image(systemName: "waveform.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.gray)
                        
                        Text("Ready to record")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text("Phase 1: MVP - Record & Save Locally")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(nsColor: .controlBackgroundColor))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Footer with Settings & Help
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Label("Settings", systemImage: "gear")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: {}) {
                        Label("Help", systemImage: "questionmark.circle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            recordingState.loadRecordings()
        }
    }
    
    // MARK: - Recording Controls View
    
    @ViewBuilder
    private var recordingControlsView: some View {
        VStack(spacing: 16) {
            // Recording status
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 12, height: 12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recording in progress")
                        .font(.system(size: 14, weight: .semibold))
                    Text(formatDuration(recordingState.recordingDuration))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            
            // Control buttons
            HStack(spacing: 12) {
                // Pause/Resume button
                Button(action: {
                    if recordingState.isPaused {
                        recordingState.resumeRecording()
                    } else {
                        recordingState.pauseRecording()
                    }
                }) {
                    Label(recordingState.isPaused ? "Resume" : "Pause", 
                          systemImage: recordingState.isPaused ? "play.fill" : "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                // Stop button
                Button(action: {
                    recordingState.stopRecording()
                }) {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }
    
    // MARK: - Start Recording View
    
    @ViewBuilder
    private var startRecordingView: some View {
        VStack(spacing: 12) {
            Button(action: {
                recordingState.startRecording()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "record.circle.fill")
                    Text("Start Recording")
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            if let error = recordingState.errorMessage {
                Text(error)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Recordings List View
    
    @ViewBuilder
    private var recordingsListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recordings")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
            
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(recordingState.recordings) { recording in
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recording.filename)
                                    .font(.system(size: 14, weight: .semibold))
                                    .lineLimit(1)
                                
                                HStack(spacing: 12) {
                                    Label(recording.formattedDuration, systemImage: "clock")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                    
                                    Label(recording.formattedFileSize, systemImage: "doc")
                                        .font(.system(size: 12, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                recordingState.deleteRecording(recording)
                            }) {
                                Image(systemName: "trash.fill")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(8)
                        .border(Color.gray.opacity(0.2), width: 1)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
    }
    
    // MARK: - Helper Functions
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d", minutes, secs)
        }
    }
}

// Preview disabled - causes crashes in Xcode 15+
// Use the running app to test instead

