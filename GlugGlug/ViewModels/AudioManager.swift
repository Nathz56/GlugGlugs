//
//  AudioManager.swift
//  GlugGlug
//
//  Created by Nur Fajar Sayyidul Ayyam on 08/04/25.
//


import AVFoundation

class AudioManager {
    static let shared = AudioManager()

    private var player: AVAudioPlayer?

    func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            print("🔇 Sound file not found")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("⚠️ Could not play sound: \(error.localizedDescription)")
        }
    }
}
