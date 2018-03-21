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

    let shotClockLength = 30.0 // parameterize this

    lazy var currentTime = shotClockLength
    var timer = Timer()
    var isTimerRunning = false
    
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
        updateTimer()
    }

    func updateTimer() {
        if showTenths() {
            timerLabel.text = "\(String(format: "%.1f", currentTime))"
        } else {
            timerLabel.text = "\(String(format: "%.0f", ceil(currentTime)))"
        }
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
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
