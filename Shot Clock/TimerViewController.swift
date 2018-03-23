//
//  TimerViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/18/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopButton: UIControl!
    @IBOutlet weak var startButton: UIControl!
    @IBOutlet var mainView: UIView!

    let shotClockLength = 30.0 // parameterize this
//    let orangeColor = UIColor(red: 253/255.0, green: 122/255.0, blue: 46/255.0, alpha: 1.0)

    lazy var currentTime = shotClockLength
    var timer = Timer()
    var isTimerRunning = false
    var impactFeedbackGenerator : UIImpactFeedbackGenerator? = nil
    var notificationFeedbackGenerator : UINotificationFeedbackGenerator? = nil
    enum NotificationType {
        case onTheSecond
        case buzzer
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        currentTime = shotClockLength
        updateTimer()
    }

    @IBAction func resetButtonReleased(_ sender: Any) {
        if isTimerRunning {
            runTimer()
        }
    }

    @IBAction func stopButtonTapped(_ sender: Any) {
        timer.invalidate()
        isTimerRunning = false
        stopButton.isHidden = true
        startButton.isHidden = false
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        runTimer()
        startButton.isHidden = true
        stopButton.isHidden = false
    }

    @IBAction func stepperChanged(_ sender: Any) {
    }

    func runTimer() {
        timer = Timer.scheduledTimer(
                    timeInterval: 0.1,
                    target: self,
                    selector: (#selector(TimerViewController.decrementTimer)),
                    userInfo: nil,
                    repeats: true
                )

        isTimerRunning = true
    }

    @objc func decrementTimer() {
        currentTime -= 0.1
        let roundedTime = round(currentTime, toNearest: 0.1)
        if roundedTime <= 0 {
            currentTime = 0 // To prevent "-0.0"
            timer.invalidate()
            generateFeedback(type: NotificationType.buzzer)
        }

        updateTimer()
        if roundedTime <= 5 && roundedTime.truncatingRemainder(dividingBy: 1) == 0 {
            generateFeedback(type: NotificationType.onTheSecond)
        }

    }

    func generateFeedback(type: NotificationType) {
        DispatchQueue.main.async {
            if type == NotificationType.onTheSecond {
                self.impactFeedbackGenerator = UIImpactFeedbackGenerator()
                self.impactFeedbackGenerator?.prepare()
                self.impactFeedbackGenerator?.impactOccurred()
                self.impactFeedbackGenerator = nil
            } else if type == NotificationType.buzzer {
                self.notificationFeedbackGenerator = UINotificationFeedbackGenerator()
                self.notificationFeedbackGenerator?.prepare()
                self.notificationFeedbackGenerator?.notificationOccurred(UINotificationFeedbackType.error)
                self.notificationFeedbackGenerator = nil
            }
        }
    }

    func updateTimer() {
        DispatchQueue.main.async {
            if self.showTenths() {
                self.timerLabel.text = "\(String(format: "%.1f", self.currentTime))"
            } else {
                self.timerLabel.text = "\(String(format: "%.0f", ceil(self.round(self.currentTime, toNearest: 0.1))))"
            }
        }
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }

    func showTenths() -> Bool {
        if true { // nba
            return currentTime < 5.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        timerLabel.font = UIFont.monospacedDigitSystemFont(
            ofSize: timerLabel.font.pointSize,
            weight: UIFont.Weight.light
        )
        timerLabel.text = "\(String(format: "%.0f", currentTime))"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
