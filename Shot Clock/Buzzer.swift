//
//  Buzzer.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 11/21/20.
//  Copyright © 2020 Peter Carnesciali. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class Buzzer {
    var expirationSoundPlayer: AVAudioPlayer?
    let expirationSoundFile = NSDataAsset(name:"BuzzerSound")
    
    init() {
        if (expirationSoundFile != nil) {
            do {
                expirationSoundPlayer = try AVAudioPlayer(data:expirationSoundFile!.data, fileTypeHint: "mp3")
                expirationSoundPlayer?.prepareToPlay()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("Buzzer sound not found")
        }
    }
    
    func startExpirationSound() {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        expirationSoundPlayer?.currentTime = 0
        expirationSoundPlayer?.play()
    }
    
    func stopExpirationSound() {
        expirationSoundPlayer?.stop()
    }
}
