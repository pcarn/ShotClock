//
//  TimerViewController.swift
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

class TimerViewController: UIViewController, isAbleToSetLeague {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopButton: UIControl!
    @IBOutlet weak var startButton: UIControl!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var middleResetAmountButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var recallButton: UIButton!

    var timer = Timer()
    var shotClockLength = 30.0 // parameterize this
    lazy var currentTime = shotClockLength
    var middleResetAmount = 14.0
    let showTenthsUnder = 5.0
    var isTimerRunning = false
    var impactFeedbackGenerator : UIImpactFeedbackGenerator? = nil
    var recallAmount = -1.0

    enum NotificationType {
        case onTheSecond
        case buzzer
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        self.impactFeedbackGenerator = nil
        recallAmount = currentTime
        currentTime = shotClockLength
        updateTimer()
        if !isTimerRunning {
            recallButton.isEnabled = true
            recallButton.alpha = 1.0
        }
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
        var controlsToEnable: Array<UIControl> = [stepper, middleResetAmountButton, settingsButton]
        if recallAmount != -1.0 {
            controlsToEnable.append(recallButton)
        }
        for control in controlsToEnable {
            control.isEnabled = true
            control.alpha = 1.0
        }
        self.impactFeedbackGenerator = nil
    }

    @IBAction func startButtonTapped(_ sender: Any) {
        runTimer()
        startButton.isHidden = true
        stopButton.isHidden = false
        let controlsToDisable: Array<UIControl> = [stepper, middleResetAmountButton, settingsButton, recallButton]
        for control in controlsToDisable {
            control.isEnabled = false
            control.alpha = 0.3
        }
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

    @IBAction func recallButtonTapped(_ sender: Any) {
        if recallAmount != -1.0 {
            currentTime = recallAmount
        }
        recallAmount = -1.0
        recallButton.isEnabled = false
        recallButton.alpha = 0.3
        updateTimer()
    }

    @IBAction func middleResetAmountButtonTapped(_ sender: Any) {
        recallAmount = currentTime
        currentTime = middleResetAmount
        recallButton.isEnabled = true
        recallButton.alpha = 1.0
        updateTimer()
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
                self.timerLabel.text = String(format: "%.1f", self.currentTime)
            } else {
                self.timerLabel.text = String(format: "%.0f", ceil(self.round(self.currentTime, toNearest: 0.1)))
            }
            self.stepper.value = self.currentTime
        }
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }

    func showTenths() -> Bool {
        return round(currentTime, toNearest: 0.1) < showTenthsUnder
    }

    func changeLeague(selectedLeague: ShotClockConfiguration.League) {
        let config = ShotClockConfiguration.leagueConfiguration(league: selectedLeague)
        shotClockLength = Double(config.shotClockLength)
        middleResetAmount = Double(config.middleResetAmount)
        middleResetAmountButton.setTitle("\(String(format: "%.0f", Darwin.round(middleResetAmount)))s", for: .normal)
        currentTime = shotClockLength
        recallAmount = -1.0
        recallButton.isEnabled = false
        recallButton.alpha = 0.3
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


        if let league = ShotClockConfiguration.League(rawValue: UserDefaults.standard.integer(forKey: "leagueSetting")) {
            changeLeague(selectedLeague: league)
        } else {
            changeLeague(selectedLeague: ShotClockConfiguration.League.ncaa)
        }

        stepper.minimumValue = 0
        stepper.maximumValue = shotClockLength
        stepper.stepValue = 0.1
        stepper.value = currentTime

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
