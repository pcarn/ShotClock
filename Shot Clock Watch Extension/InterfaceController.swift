//
//  InterfaceController.swift
//  Shot Clock Watch Extension
//
//  Created by Peter Carnesciali on 4/1/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController, WKCrownDelegate {
    @IBOutlet weak var timerLabel: WKInterfaceButton!
    @IBOutlet weak var startStopButton: WKInterfaceButton!
    @IBOutlet weak var leaguePicker: WKInterfacePicker!

    let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 102.0, weight: .regular)

    var timer = Timer()
    lazy var currentTime = config.shotClockLength
    var isTimerRunning = false
    var timeStarted:Date?
    var currentLeague = ShotClockConfiguration.League.ncaa
    lazy var config = ShotClockConfiguration.leagueConfiguration(league: currentLeague)
    var autorotateExtension = WKExtension.shared()

    enum NotificationType {
        case onTheSecond
        case buzzer
    }

    @IBAction func leaguePickerChanged(_ value: Int) {
        changeLeague(
            selectedLeague: ShotClockConfiguration.watchLeagueList()[value]["league"] as! ShotClockConfiguration.League
        )
    }
    
    func stopPickingLeague() {
        leaguePicker.resignFocus()
        crownSequencer.focus()
    }

    @IBAction func timerLabelTapped() {
        stopPickingLeague()
    }

    func changeLeague(selectedLeague: ShotClockConfiguration.League) {
        currentLeague = selectedLeague
        config = ShotClockConfiguration.leagueConfiguration(league: selectedLeague)
        stopTimer()
        currentTime = config.shotClockLength
        updateTimer()
    }

    @IBAction func resetButtonTapped() {
        stopPickingLeague()
        currentTime = config.shotClockLength
        updateTimer()
        if isTimerRunning {
            timeStarted = Date()
            if !timer.isValid {
                runTimer()
            }
        }
    }

    func stopTimer() {
        timer.invalidate()
        isTimerRunning = false
        timeStarted = nil
        startStopButton.setTitle("Start")
        leaguePicker.setEnabled(true)
        autorotateExtension.isAutorotating = false
    }

    func startTimer() {
        runTimer()
        isTimerRunning = true
        timeStarted = Date().addingTimeInterval((config.shotClockLength - currentTime) * -1)
        startStopButton.setTitle("Stop")
        leaguePicker.setEnabled(false)
        autorotateExtension.isAutorotating = true
    }

    @IBAction func startStopButtonTapped() {
        stopPickingLeague()
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
        }
    }

    func monospacedString(string: String) -> NSAttributedString? {
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.font: monospacedFont])
    }

    func runTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: (#selector(InterfaceController.decrementTimer)),
            userInfo: nil,
            repeats: true
        )
    }

    @objc func decrementTimer() {
        currentTime -= 0.1
        let roundedTime = round(currentTime, toNearest: 0.1)
        if roundedTime <= 0 {
            currentTime = 0 // To prevent "-0.0"
            timer.invalidate()
            generateFeedback(type: NotificationType.buzzer)
        }

        if roundedTime <= 5.0 && roundedTime.truncatingRemainder(dividingBy: 1) == 0 {
            generateFeedback(type: NotificationType.onTheSecond)
        }
        updateTimer()
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }

    func updateTimer() {
        DispatchQueue.main.async {
            self.timerLabel.setAttributedTitle(
                self.monospacedString(string: self.formattedStringForTime(time: self.currentTime))
            )
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

    func showTenths() -> Bool {
        return round(currentTime, toNearest: 0.1) < config.showTenthsUnder
    }

    func generateFeedback(type: NotificationType) {
        DispatchQueue.main.async {
            if type == NotificationType.onTheSecond {
                WKInterfaceDevice.current().play(WKHapticType.directionDown)
            } else if type == NotificationType.buzzer {
                WKInterfaceDevice.current().play(WKHapticType.failure)
            }
        }
    }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        if !isTimerRunning {
            var delta = rotationalDelta
            if !showTenths() {
                delta *= 8
            }
            currentTime += delta
            currentTime = [config.shotClockLength, currentTime].min()!
            currentTime = [0, currentTime].max()!
            updateTimer()
        }
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let pickerItems: [WKPickerItem] = ShotClockConfiguration.watchLeagueList().map {
            let pickerItem = WKPickerItem()
            pickerItem.title = $0["title"] as? String
            return pickerItem
        }
        leaguePicker.setItems(pickerItems)

        crownSequencer.delegate = self
        crownSequencer.focus()
        if isTimerRunning {
            currentTime = config.shotClockLength - Date().timeIntervalSince(timeStarted!)
            currentTime = [currentTime, 0].max()!
        }
        updateTimer()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
