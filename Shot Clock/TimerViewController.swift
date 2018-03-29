//
//  TimerViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/18/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit
import AudioToolbox

class TimerViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopButton: UIControl!
    @IBOutlet weak var startButton: UIControl!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet var mainView: UIView!

    let shotClockLength = 7.0 // parameterize this
    let showTenthsUnder = 3.0
//    let orangeColor = UIColor(red: 253/255.0, green: 122/255.0, blue: 46/255.0, alpha: 1.0)

    lazy var currentTime = shotClockLength
    var timer = Timer()
    var isTimerRunning = false
    var impactFeedbackGenerator : UIImpactFeedbackGenerator? = nil
    enum NotificationType {
        case onTheSecond
        case buzzer
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        self.impactFeedbackGenerator = nil
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
        stepper.isEnabled = true
        stepper.alpha = 1.0
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        runTimer()
        startButton.isHidden = true
        stopButton.isHidden = false
        stepper.isEnabled = false
        stepper.alpha = 0.3
    }

    @IBAction func stepperChanged(sender: UIStepper) {
        if self.round(sender.value, toNearest: 0.1) <= showTenthsUnder {
            currentTime = sender.value
        } else {
            currentTime = ceil(self.round(currentTime, toNearest: 0.1)) + (sender.value < currentTime ? -1.0 : 1.0)

            if currentTime > shotClockLength {
                currentTime = shotClockLength
            }
        }

        updateTimer()
    }

    @IBAction func setToArbitaryAmountButtonTapped(_ sender: Any) {
        NSLog("set to something")
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
        if roundedTime <= showTenthsUnder && roundedTime.truncatingRemainder(dividingBy: 1) == 0 {
            generateFeedback(type: NotificationType.onTheSecond)
        }

    }

    func generateFeedback(type: NotificationType) {
        DispatchQueue.main.async {
            if type == NotificationType.onTheSecond {
                if self.impactFeedbackGenerator == nil {
                    self.impactFeedbackGenerator = UIImpactFeedbackGenerator()
                }
                self.impactFeedbackGenerator?.prepare()
                self.impactFeedbackGenerator?.impactOccurred()
            } else if type == NotificationType.buzzer {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
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
            self.stepper.value = self.currentTime
        }
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }

    func showTenths() -> Bool {
        return currentTime < showTenthsUnder
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        timerLabel.font = UIFont.monospacedDigitSystemFont(
            ofSize: timerLabel.font.pointSize,
            weight: UIFont.Weight.light
        )
        updateTimer()
        self.stepper.minimumValue = 0
        self.stepper.maximumValue = shotClockLength
        self.stepper.stepValue = 0.1
        self.stepper.value = currentTime
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
