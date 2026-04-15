import UIKit
class TimerRingView: UIView {

    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        setupLayers()
    }

    private func setupLayers() {
        trackLayer.strokeColor = UIColor.systemGray5.cgColor
        trackLayer.lineWidth = 12
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round

        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        progressLayer.lineWidth = 12
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0

        layer.addSublayer(trackLayer)
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let radius = min(bounds.width, bounds.height) / 2 - 12
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)

        let path = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
            clockwise: true
        )

        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
    }

    func setProgress(_ progress: CGFloat) {
        progressLayer.strokeEnd = progress
    }
}

class timerViewController: UIViewController {

    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var durationSelector: UIDatePicker!
    @IBOutlet weak var doctorsRecommandation: UILabel!
    @IBOutlet weak var ringView: TimerRingView!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    var isRunning = false
    var isPaused = false
    
    var onSave: (() -> Void)?
    var activityItem: TodayActivityItem?
    var patient:      Patient?{
        didSet{
            print("patient set")
        }
    }
    private var elapsedSeconds:Int = 0

    var timer: Timer?
    var totalTime: Int = 0
    var remainingTime: Int = 0
//    var isRunning = false

    override func viewDidLoad() {
        super.viewDidLoad()
        playButton.isEnabled = false

        durationSelector.datePickerMode = .countDownTimer
        doctorsRecommandation.text = activityItem?.assignment.doctorNote

        updateUI()
    }

    // MARK: - Start / Stop / Resume
//    @IBAction func startStop(_ sender: UIButton) {
//        
//        if sender.currentImage == UIImage(systemName: "play.fill") {
//            if remainingTime == 0 {
//                totalTime = Int(durationSelector.countDownDuration)
//                guard totalTime > 0 else { return }
//                remainingTime = totalTime
//            }
//            
//            remainingTime = totalTime
//            isRunning = true
//
//            sender.setImage(UIImage(systemName: "stop.fill"), for: .normal)
//            sender.tintColor = .systemRed
//            durationSelector.isUserInteractionEnabled = false
//
//            timer?.invalidate()
//            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//                self.tick(sender: sender)
//            }
//        }
//        else {
//            if playButton.currentImage == UIImage(systemName: "play.fill"){
//                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//            }
//            // STOP (full reset)
//            timer?.invalidate()
//            isRunning = false
//
//            remainingTime = totalTime
//            updateUI()
//
//            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
//            sender.tintColor = .systemBlue
//            durationSelector.isUserInteractionEnabled = true
//
//        }
//    }
//
//    // MARK: - Pause (NO RESET)
//    @IBAction func pause(_ sender: UIButton) {
//        if startButton.currentImage == UIImage(systemName: "play.fill") {
//            print("p..............")
//            return
//        }
//        if sender.currentImage == UIImage(systemName: "pause.fill") {
//            timer?.invalidate()
//            isRunning = false
//            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
//        }else {
//            timer?.invalidate()
//            isRunning = true
//            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//                self.tick(sender: sender)
//                sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
//            }
//        }
//        
//    }
//
//    // MARK: - Timer Tick
//    func tick(sender: UIButton) {
//
//        if remainingTime > 0 {
//            remainingTime -= 1
//            updateUI()
//        } else {
//            // Completed
//            timer?.invalidate()
//            isRunning = false
//
//            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
//
//            durationSelector.isUserInteractionEnabled = true
//        }
//    }
//
//    // MARK: - Update UI (Label + Ring)
//    func updateUI() {
//
//        let hrs = remainingTime / 3600
//        let mins = (remainingTime % 3600) / 60
//        let secs = remainingTime % 60
//
//        timerLabel.text = String(format: "%02d:%02d:%02d", hrs, mins, secs)
//
//        // Ring Progress
//        if totalTime > 0 {
//            let progress = 1 - (CGFloat(remainingTime) / CGFloat(totalTime))
//            ringView.setProgress(progress)
//        } else {
//            ringView.setProgress(0)
//        }
//    }
    @IBAction func startStop(_ sender: UIButton) {

            if isRunning {
                // 🔴 STOP → reset everything
                timer?.invalidate()
                timer = nil

                isRunning = false
                isPaused = false

                remainingTime = 0
                totalTime = 0

                updateUI()

                startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                startButton.tintColor = .systemBlue

                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                playButton.isEnabled = false

                durationSelector.isUserInteractionEnabled = true

            } else {
                // 🟢 START

                totalTime = Int(durationSelector.countDownDuration)
                guard totalTime > 0 else { return }

                remainingTime = totalTime

                isRunning = true
                isPaused = false

                startButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                startButton.tintColor = .systemRed

                playButton.isEnabled = true
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)

                durationSelector.isUserInteractionEnabled = false

                startTimer()
            }
        }

        // MARK: - PAUSE / RESUME
        @IBAction func pause(_ sender: UIButton) {

            guard isRunning else { return }

            if isPaused {
                // ▶️ RESUME
                isPaused = false
                sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                startTimer()
            } else {
                // ⏸ PAUSE
                timer?.invalidate()
                timer = nil

                isPaused = true
                sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        }

        // MARK: - TIMER START
        private func startTimer() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tick()
            }
        }

        // MARK: - TIMER TICK
        private func tick() {

            guard remainingTime > 0 else {
                // ✅ Completed
                timer?.invalidate()
                timer = nil

                isRunning = false
                isPaused = false

                startButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                startButton.tintColor = .systemBlue
                playButton.isEnabled = false

                durationSelector.isUserInteractionEnabled = true
                return
            }

            remainingTime -= 1
            updateUI()
        }

        // MARK: - UI UPDATE
        private func updateUI() {

            let hrs = remainingTime / 3600
            let mins = (remainingTime % 3600) / 60
            let secs = remainingTime % 60

            timerLabel.text = String(format: "%02d:%02d:%02d", hrs, mins, secs)

            if totalTime > 0 {
                let progress = 1 - (CGFloat(remainingTime) / CGFloat(totalTime))
                ringView.setProgress(progress)
            } else {
                ringView.setProgress(0)
            }
        }
    // MARK: - Log Activity
    @IBAction func logActivity(_ sender: UIBarButtonItem) {
        
        let duration = totalTime - remainingTime

        guard duration > 0 else {
            let alert = UIAlertController(
                title: "No Activity",
                message: "Start the timer before logging.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        guard let item = activityItem, let patient = patient else {
            print(activityItem)
            print(patient)
            print("timerVC logActivity: missing activityItem or patient")
            dismiss(animated: true)
            return
        }

        timer?.invalidate()
        isRunning = false

        Task {
            do {
                let formatter        = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let timeString       = formatter.string(from: Date())
                let log = ActivityLog(
                    logID:      UUID(),
                    assignedID: item.assignment.assignedID,
                    activityID: item.activity.activityID,
                    patientID:  patient.patientID,
                    date:       Date(),
                    time:       timeString,
                    duration:   duration,
                    uploadPath: nil ,
                    summary: nil
                )

                let saved = try await AccessSupabase.shared.saveActivityLog(log)
                print("timerVC: log saved \(saved.logID), duration: \(duration)s")
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("ActivityLogSaved"),
                        object: nil
                    )
                    self.onSave?()
                    self.dismiss(animated: true)
                }

            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "Save Failed",
                        message: "\(error)",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }

    // MARK: - Close
    @IBAction func close(_ sender: UIBarButtonItem) {
        timer?.invalidate()
        dismiss(animated: true)
    }
}
