//
//  TimerViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/18/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit

protocol isAbleToSetLeague {
    func changeLeague(selectedLeague: ShotClockConfiguration.League, customShotClockLength: Double, customMiddleResetAmount: Double)
}

protocol isAbleToChangeBuzzerSettings {
    func setWarningBuzzerSoundEnabled(enabled: Bool)
    func setExpirationBuzzerSoundEnabled(enabled: Bool)
}

class TimerViewController: UIViewController, @preconcurrency isAbleToSetLeague, @preconcurrency isAbleToChangeBuzzerSettings {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var stopButton: UIControl!
    @IBOutlet weak var startButton: UIControl!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var middleResetAmountButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var recallButton: UIButton!
    @IBOutlet weak var expirationNotice: DesignableView!

    let warningBuzzerSoundAt = 5.0
    
    var timer = Timer()
    var buzzer = Buzzer()
    var isTimerRunning = false
    var recallAmount = -1.0
    var currentLeague = ShotClockConfiguration.League.ncaa
    lazy var config = ShotClockConfiguration.leagueConfiguration(league: currentLeague)
    var shotClockLength = 30.0
    var middleResetAmount = 20.0
    lazy var currentTime = shotClockLength
    var warningBuzzerSoundEnabled = true
    var expirationBuzzerSoundEnabled = true

    enum NotificationType {
        case warning
        case expiration
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        timer.invalidate()
        buzzer.stopExpirationSound()
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

    func stopTimer() {
        timer.invalidate()
        isTimerRunning = false
        buzzer.stopExpirationSound()
        stopButton.isHidden = true
        startButton.isHidden = false
        var controlsToEnable: Array<UIControl> = [stepper, settingsButton]
        if recallAmount != -1.0 {
            controlsToEnable.append(recallButton)
        }
        for control in controlsToEnable {
            control.isEnabled = true
            control.alpha = 1.0
        }

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
        if self.round(sender.value, toNearest: 0.1) <= config.showTenthsUnder {
            currentTime = sender.value
        } else {
            let roundedTime = self.round(currentTime, toNearest: 0.1)
            let flooredTime = config.round == "down" ? floor(roundedTime) : ceil(roundedTime)
            currentTime = flooredTime + (sender.value < currentTime ? -1.0 : 1.0)
            currentTime = [shotClockLength, currentTime].min()!
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
            generateFeedback(type: NotificationType.expiration)
        } else if roundedTime <= warningBuzzerSoundAt && roundedTime.truncatingRemainder(dividingBy: 1) == 0 {
                generateFeedback(type: NotificationType.warning)
        }
        
        updateTimer()
    }
    
    func setWarningBuzzerSoundEnabled(enabled: Bool) {
        warningBuzzerSoundEnabled = enabled
    }
    
    func setExpirationBuzzerSoundEnabled(enabled: Bool) {
        expirationBuzzerSoundEnabled = enabled
    }

    func generateFeedback(type: NotificationType) {
        DispatchQueue.main.async {
            if type == NotificationType.warning {
                self.buzzer.startWarningSound(soundEnabled: self.warningBuzzerSoundEnabled)
            } else if type == NotificationType.expiration {
                self.buzzer.startExpirationSound(soundEnabled: self.expirationBuzzerSoundEnabled)
            }
        }
    }

    func updateTimer() {
        DispatchQueue.main.async {
            self.timerLabel.text = self.formattedStringForTime(time: self.currentTime)
            self.stepper.value = self.currentTime
            self.expirationNotice.isHidden = (self.round(self.currentTime, toNearest: 0.1) > 0.0)
        }
    }

    func formattedStringForTime(time: Double) -> String {
        if self.showTenths() {
            return String(format: "%.1f", time)
        } else {
            var roundedTime:Double
            if config.round == "down" {
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
        return round(currentTime, toNearest: 0.1) < config.showTenthsUnder
    }

    func changeLeague(selectedLeague: ShotClockConfiguration.League, customShotClockLength: Double, customMiddleResetAmount: Double) {
        currentLeague = selectedLeague
        config = ShotClockConfiguration.leagueConfiguration(league: currentLeague)

        if (selectedLeague == ShotClockConfiguration.League.custom) {
            shotClockLength = customShotClockLength
            middleResetAmount = customMiddleResetAmount
        } else {
            shotClockLength = config.shotClockLength
            middleResetAmount = config.middleResetAmount
        }
        middleResetAmountButton.setTitle("\(String(format: "%.0f", Darwin.round(middleResetAmount)))s", for: UIControl.State.normal)
        currentTime = shotClockLength
        recallAmount = -1.0
        recallButton.isEnabled = false
        recallButton.alpha = 0.3
        stepper.maximumValue = shotClockLength
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
            currentLeague = league
            if currentLeague == ShotClockConfiguration.League.custom {
                let savedShotClockLength = UserDefaults.standard.double(forKey: "customShotClockLength")
                if savedShotClockLength > 0 {
                    shotClockLength = savedShotClockLength
                }
                let savedMiddleResetAmount = UserDefaults.standard.double(forKey: "customMiddleResetAmount")
                if savedMiddleResetAmount > 0 {
                    middleResetAmount = savedMiddleResetAmount
                }
            }
        }
        changeLeague(selectedLeague: currentLeague, customShotClockLength: shotClockLength, customMiddleResetAmount: middleResetAmount)

        if let warningBuzzerSoundConfig = UserDefaults.standard.object(forKey: "warningBuzzerSoundEnabled") {
            warningBuzzerSoundEnabled = warningBuzzerSoundConfig as! Bool
        }

        if let expirationBuzzerSoundConfig = UserDefaults.standard.object(forKey: "expirationBuzzerSoundEnabled") {
            expirationBuzzerSoundEnabled = expirationBuzzerSoundConfig as! Bool
        }

        stepper.minimumValue = 0
        stepper.maximumValue = shotClockLength
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
            newViewController.leagueSettingsDelegate = self
            newViewController.buzzerSettingsDelegate = self
        }
    }
}
