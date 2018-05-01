//
//  ShotClockViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/18/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit
import AudioToolbox

protocol isAbleToSetLeague {
    func changeLeague(selectedLeague: ShotClockConfiguration.League)
}

class ShotClockViewController: UIViewController, isAbleToSetLeague {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopButton: UIControl!
    @IBOutlet weak var startButton: UIControl!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var middleResetAmountButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var recallButton: UIButton!
    @IBOutlet weak var expirationNotice: DesignableView!

    var timer = Timer()
    var shotClock = ShotClock()
    var impactFeedbackGenerator : UIImpactFeedbackGenerator? = nil

    enum NotificationType {
        case onTheSecond
        case buzzer
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        shotClock.reset()
        self.impactFeedbackGenerator = nil
        updateTimer()
        if !shotClock.isTimerRunning {
            recallButton.isEnabled = true
            recallButton.alpha = 1.0
        }
    }

    @IBAction func resetButtonReleased(_ sender: Any) {
        if shotClock.isTimerRunning {
            runTimer()
        }
    }

    func stopTimer() {
        timer.invalidate()
        shotClock.isTimerRunning = false
        stopButton.isHidden = true
        startButton.isHidden = false
        var controlsToEnable: Array<UIControl> = [stepper, settingsButton]
        if shotClock.recallAmount != -1.0 {
            controlsToEnable.append(recallButton)
        }
        for control in controlsToEnable {
            control.isEnabled = true
            control.alpha = 1.0
        }
        self.impactFeedbackGenerator = nil

    }

    @IBAction func stopButtonTapped(_ sender: Any) {
        stopTimer()
    }

    func startTimer() {
        runTimer()
        startButton.isHidden = true
        stopButton.isHidden = false
        let controlsToDisable: Array<UIControl> = [stepper, settingsButton, recallButton]
        for control in controlsToDisable {
            control.isEnabled = false
            control.alpha = 0.3
        }
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        startTimer()
    }

    @IBAction func stepperChanged(sender: UIStepper) {
        if self.round(sender.value, toNearest: 0.1) <= shotClock.config.showTenthsUnder {
            shotClock.setTime(time: sender.value)
        } else {
            let roundedTime = self.round(shotClock.currentTime, toNearest: 0.1)
            let flooredTime = shotClock.config.round == "down" ? floor(roundedTime) : ceil(roundedTime)
            let currentTime = flooredTime + (sender.value < shotClock.currentTime ? -1.0 : 1.0)
            shotClock.setTime(time: [shotClock.config.shotClockLength, currentTime].min()!)
        }

        updateTimer()
    }

    @IBAction func recallButtonTapped(_ sender: Any) {
        shotClock.recall()
        recallButton.isEnabled = false
        recallButton.alpha = 0.3
        updateTimer()
    }

    @IBAction func middleResetAmountButtonTapped(_ sender: Any) {
        shotClock.middleReset()
        recallButton.isEnabled = true
        recallButton.alpha = 1.0
        updateTimer()
    }

    func runTimer() {
        timer = Timer.scheduledTimer(
                    timeInterval: 0.1,
                    target: self,
                    selector: (#selector(ShotClockViewController.decrementTimer)),
                    userInfo: nil,
                    repeats: true
                )

        shotClock.isTimerRunning = true
    }

    @objc func decrementTimer() {
        shotClock.setTime(time: shotClock.currentTime - 0.1)
        let roundedTime = round(shotClock.currentTime, toNearest: 0.1)
        if roundedTime <= 0 {
            shotClock.setTime(time: 0) // To prevent "-0.0"
            timer.invalidate()
            generateFeedback(type: NotificationType.buzzer)
        }

        updateTimer()
        if roundedTime <= shotClock.config.showTenthsUnder && roundedTime.truncatingRemainder(dividingBy: 1) == 0 {
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
            self.timerLabel.text = self.formattedStringForTime(time: self.shotClock.currentTime)
            self.stepper.value = self.shotClock.currentTime
            self.expirationNotice.isHidden = (self.round(self.shotClock.currentTime, toNearest: 0.1) > 0.0)
        }
    }

    func formattedStringForTime(time: Double) -> String {
        if self.showTenths() {
            return String(format: "%.1f", time)
        } else {
            var roundedTime:Double
            if shotClock.config.round == "down" {
                roundedTime = floor(self.round(time, toNearest: 0.1))
            } else {
                roundedTime = ceil(self.round(time, toNearest: 0.1))
            }
            return String(format:"%.0f", roundedTime)
        }
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }

    func showTenths() -> Bool {
        return round(shotClock.currentTime, toNearest: 0.1) < shotClock.config.showTenthsUnder
    }

    func changeLeague(selectedLeague: ShotClockConfiguration.League) {
        shotClock.changeLeague(selectedLeague: selectedLeague)
        middleResetAmountButton.setTitle("\(String(format: "%.0f", Darwin.round(shotClock.config.middleResetAmount)))s", for: .normal)
        recallButton.isEnabled = false
        recallButton.alpha = 0.3
        stepper.maximumValue = shotClock.config.shotClockLength
        updateTimer()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        timerLabel.adjustsFontSizeToFitWidth = true
        timerLabel.font = UIFont.monospacedDigitSystemFont(
            ofSize: timerLabel.font.pointSize,
            weight: UIFont.Weight.light
        )

        var currentLeague = ShotClockConfiguration.League.ncaa
        if let league = ShotClockConfiguration.League(rawValue: UserDefaults.standard.integer(forKey: "leagueSetting")) {
            currentLeague = league
        }
        changeLeague(selectedLeague: currentLeague)

        stepper.minimumValue = 0
        stepper.maximumValue = shotClock.config.shotClockLength
        stepper.stepValue = 0.1
        updateTimer()

        UIApplication.shared.isIdleTimerDisabled = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SettingsViewController {
            let newViewController = segue.destination as! SettingsViewController
            newViewController.delegate = self
        }
    }
}
