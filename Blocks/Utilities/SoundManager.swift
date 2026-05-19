import AVFoundation
/// Loads and plays the game sound effects asynchronously.
/// Missing sound files are silently ignored — sound is non-critical.
@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private var players: [SoundEffect: AVAudioPlayer] = [:]
    private init() {
        Task { await loadAllSounds() }
    }
    func play(_ effect: SoundEffect) {
        guard let player = players[effect] else { return }
        player.currentTime = 0
        player.play()
    }
    private func loadAllSounds() async {
        for effect in SoundEffect.allCases {
            if let url = Bundle.main.url(forResource: effect.rawValue, withExtension: "wav"),
               let player = try? AVAudioPlayer(contentsOf: url) {
                players[effect] = player
            }
        }
    }
}
enum SoundEffect: String, CaseIterable {
    case place    = "place"
    case clear    = "clear"
    case combo    = "combo"
    case gameOver = "gameover"
}
