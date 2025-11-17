import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var recordingState: RecordingState
    
    var body: some View {
        VStack(spacing: 8) {
            if recordingState.isRecording {
                // Recording in progress
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    Text("Recording...")
                        .font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Text(formatDuration(recordingState.recordingDuration))
                        .font(.system(size: 11, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                Divider()
                
                HStack(spacing: 8) {
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                
                HStack(spacing: 8) {
                    // Stop button
                    Button(action: {
                        recordingState.stopRecording()
                    }) {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            } else {
                // Not recording
                HStack(spacing: 8) {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                    Text("Ready to Record")
                        .font(.system(size: 13, weight: .semibold))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                
                Divider()
                
                HStack(spacing: 8) {
                    Button(action: {
                        recordingState.startRecording()
                    }) {
                        Label("Start Recording", systemImage: "record.circle.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.red)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            
            Divider()
            
            // Open app button
            HStack(spacing: 8) {
                Button(action: {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first {
                        window.makeKeyAndOrderFront(nil)
                    }
                }) {
                    Label("Open App", systemImage: "window")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            
            // Quit button
            HStack(spacing: 8) {
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Label("Quit", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .padding(.vertical, 4)
        .frame(width: 220)
    }
    
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

// Preview disabled - causes crashes in Xcode 15+
