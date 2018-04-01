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

    @IBAction func resetButtonTapped() {
        timerLabel.setText("69")
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}