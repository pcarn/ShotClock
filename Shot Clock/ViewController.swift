//
//  ViewController.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/18/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var timberLabel: UILabel!
    
    var seconds = 30 // parameterize this
    var timer = Timer()
    var isTimerRunning = false
    
    @IBAction func resetButtonTapped(_ sender: Any) {
    }
    @IBAction func resetButtonReleased(_ sender: Any) {
    }
    @IBAction func stopButtonTapped(_ sender: Any) {
    }
    @IBAction func startButtonTapped(_ sender: Any) {
    }
    @IBAction func stepperChanged(_ sender: Any) {
    }
}

