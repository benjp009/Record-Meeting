import Foundation

/// Global app configuration and constants
struct AppConfig {
    
    // MARK: - App Info
    static let appName = "Meeting Recorder"
    static let version = "0.1.0"
    static let minimumMacOSVersion = "13.0"
    
    // MARK: - Recording Settings
    struct Recording {
        /// Default audio quality (samples per second)
        static let defaultSampleRate: Int = 44100
        
        /// Default bit rate for audio encoding
        static let defaultBitRate: Int = 128000
        
        /// Default recordings folder
        static let defaultFolder = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("Meetings") ?? URL(fileURLWithPath: "~/Meetings")
        
        /// Auto-stop delay after meeting ends (seconds)
        static let autoStopDelay: TimeInterval = 300 // 5 minutes
        
        /// Meeting detection notification time (seconds before meeting)
        static let notificationAdvance: TimeInterval = 30
    }
    
    // MARK: - UI Constants
    struct UI {
        static let mainWindowWidth: CGFloat = 800
        static let mainWindowHeight: CGFloat = 600
        static let cornerRadius: CGFloat = 12
        static let animationDuration: CGFloat = 0.3
    }
    
    // MARK: - Keyboard Shortcuts
    struct Shortcuts {
        static let toggleRecording = "r" // Cmd+Shift+R
        static let openLibrary = "l"     // Cmd+Shift+L
    }
    
    // MARK: - Feature Flags
    struct Features {
        static let enableCloudSync = false // Phase 5
        static let enableMeetingDetection = false // Phase 2
        static let enableLibraryView = false // Phase 4
    }
}

/// Logging utility for debugging
struct Logger {
    enum LogLevel: String {
        case debug = "🔍"
        case info = "ℹ️"
        case warning = "⚠️"
        case error = "❌"
    }
    
    static func log(
        _ message: String,
        level: LogLevel = .info,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        let filename = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print(
            "[\(timestamp)] \(level.rawValue) [\(filename):\(line)] \(function): \(message)"
        )
        #endif
    }
}
