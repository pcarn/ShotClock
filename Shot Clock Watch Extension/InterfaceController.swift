//
//  InterfaceController.swift
//  Shot Clock Watch Extension
//
//  Created by Peter Carnesciali on 4/1/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var timerLabel: WKInterfaceLabel!
    @IBOutlet var startStopButton: WKInterfaceButton!

    let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: 102.0, weight: .regular)

    var timer = Timer()
    var shotClockLength = 7.0
    lazy var currentTime = shotClockLength
    let showTenthsUnder = 5.0
    var isTimerRunning = false

    enum NotificationType {
        case onTheSecond
        case buzzer
    }

    @IBAction func resetButtonTapped() {
        currentTime = shotClockLength
        updateTimer()
    }

    @IBAction func startStopButtonTapped() {
        if isTimerRunning {
            timer.invalidate()
            isTimerRunning = false
            startStopButton.setTitle("Start")
        } else {
            runTimer()
            isTimerRunning = true
            startStopButton.setTitle("Stop")
        }
    }

    func monospacedString(string: String) -> NSAttributedString? {
        return NSAttributedString(string: string, attributes: [.font: monospacedFont])
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

        if roundedTime <= showTenthsUnder && roundedTime.truncatingRemainder(dividingBy: 1) == 0 {
            generateFeedback(type: NotificationType.onTheSecond)
        }
        updateTimer()
    }

    func round(_ value: Double, toNearest: Double) -> Double {
        return Darwin.round(value / toNearest) * toNearest
    }

    func updateTimer() {
        DispatchQueue.main.async {
            if self.showTenths() {
                self.timerLabel.setAttributedText(self.monospacedString(string: String(format: "%.1f", self.currentTime)))
//                self.timerLabel.setText(String(format: "%.1f", self.currentTime))
            } else {
                self.timerLabel.setAttributedText(
                    self.monospacedString(
                        string: String(
                            format: "%.0f",
                            ceil(self.round(self.currentTime, toNearest: 0.1))
                        )
                    )
                )
            }
        }
    }

    func showTenths() -> Bool {
        return round(currentTime, toNearest: 0.1) < showTenthsUnder
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

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
//        timerLabel.setFont .font = UIFont.monospacedDigitSystemFont(
//            ofSize: timerLabel.font.pointSize,
//            weight: UIFont.Weight.light
//        )
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
