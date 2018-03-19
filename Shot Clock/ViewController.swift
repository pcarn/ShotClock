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

    let shotClockLength = 30 // parameterize this

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
                    timeInterval: 1,
                    target: self,
                    selector: (#selector(TimerViewController.decrementTimer)),
                    userInfo: nil,
                    repeats: true
                )

        isTimerRunning = true
    }

    @objc func decrementTimer() {
        currentTime -= 1
        updateTimer()
    }

    func updateTimer() {
        timerLabel.text = "\(currentTime)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
