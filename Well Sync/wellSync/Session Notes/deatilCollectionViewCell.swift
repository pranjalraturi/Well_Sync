//
//  deatilCollectionViewCell.swift
//  wellSync
//
//  Created by Vidit Agarwal on 15/03/26.
//

import UIKit
import AVFoundation

class deatilCollectionViewCell: UICollectionViewCell,AVAudioPlayerDelegate {
    @IBOutlet var timeer: UIProgressView!
    @IBOutlet var totalTime: UILabel!
    @IBOutlet var playedTime: UILabel!
    @IBOutlet var recordingLabel: UILabel!
    var audioPlayer: AVAudioPlayer?
    var isPlaying = false
    var timer: Timer?
    override func awakeFromNib() {
        super.awakeFromNib()
        audioPlayer?.delegate = self
        setupAudioPlayer()
    }
    func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "test", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()

            let duration = audioPlayer?.duration ?? 0
            totalTime.text = formatTime(duration)
            playedTime.text = "00:00"
            timeer.progress = 0

        } catch {
            print("Error initializing audio player: \(error.localizedDescription)")
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func skipRecording(_ sender: UIButton) {
        guard let player = audioPlayer else { return }

            let newTime = player.currentTime + 10

            if newTime < player.duration {
                player.currentTime = newTime
            } else {
                player.currentTime = player.duration
            }
    }
    @IBAction func backRecording(_ sender: UIButton) {
            guard let player = audioPlayer else { return }

            let newTime = player.currentTime - 10

            if newTime > 0 {
                player.currentTime = newTime
            } else {
                player.currentTime = 0
            }
        }
    @IBAction func play(_ sender: UIButton) {
        guard let player = audioPlayer else { return }

            if isPlaying {

                sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
                player.pause()
                stopTimer()
                isPlaying = false

            } else {

                sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)

                player.play()

                playedTime.text = formatTime(player.currentTime)
                timeer.progress = Float(player.currentTime / player.duration)

                startTimer()

                isPlaying = true
            }
    }
    
    func startTimer() {

        stopTimer()   // prevent multiple timers

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer else { return }

            let current = player.currentTime
            let total = player.duration

            self.playedTime.text = self.formatTime(current)

            if total > 0 {
                let progress = Float(current / total)
                self.timeer.setProgress(progress, animated: false)
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopTimer()
        isPlaying = false
        timeer.progress = 0
        playedTime.text = "00:00"
    }
}
