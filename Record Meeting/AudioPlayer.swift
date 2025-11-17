import AVFoundation
import Foundation

/// Handles audio playback
class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioPlayer()
    
    private var audioPlayer: AVAudioPlayer?
    
    var isPlaying: Bool {
        audioPlayer?.isPlaying ?? false
    }
    
    var currentTime: TimeInterval {
        audioPlayer?.currentTime ?? 0
    }
    
    var duration: TimeInterval {
        audioPlayer?.duration ?? 0
    }
    
    // MARK: - Playback Control
    
    func play(url: URL) -> Bool {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            print("▶️ Playing: \(url.lastPathComponent)")
            return true
        } catch {
            print("❌ Failed to play audio: \(error.localizedDescription)")
            return false
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        print("⏸️ Playback paused")
    }
    
    func resume() {
        audioPlayer?.play()
        print("▶️ Playback resumed")
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        print("⏹️ Playback stopped")
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            print("✅ Playback finished")
        } else {
            print("❌ Playback error")
        }
    }
}
