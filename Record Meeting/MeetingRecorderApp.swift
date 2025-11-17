import SwiftUI

@main
struct MeetingRecorderApp: App {
    @StateObject private var recordingState = RecordingState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(recordingState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
