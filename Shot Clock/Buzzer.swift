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
    let expirationSoundFile = NSDataAsset(name: "ExpirationBuzzerSound")
    var warningSoundPlayer: AVAudioPlayer?
    let warningSoundFile = NSDataAsset(name: "WarningBuzzerSound")
    let impactFeedbackGenerator = UIImpactFeedbackGenerator()
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        if (expirationSoundFile != nil) {
            expirationSoundPlayer = createAudioPlayer(data: expirationSoundFile!.data, fileTypeHint: "mp3")
        } else {
            print("Expiration buzzer sound not found")
        }
        if (warningSoundFile != nil) {
            warningSoundPlayer = createAudioPlayer(data: warningSoundFile!.data, fileTypeHint: "mp3")
        } else {
            print("Warning buzzer sound not found")
        }
    }
    
    func createAudioPlayer(data: Data, fileTypeHint: String?) -> AVAudioPlayer? {
        do {
            let soundPlayer = try AVAudioPlayer(data: data, fileTypeHint: fileTypeHint)
            soundPlayer.prepareToPlay()
            return soundPlayer
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func startExpirationSound(soundEnabled: Bool) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        if (soundEnabled) {
            expirationSoundPlayer?.currentTime = 0
            expirationSoundPlayer?.play()
        }
    }
    
    func stopExpirationSound() {
        expirationSoundPlayer?.stop()
    }
    
    func startWarningSound(soundEnabled: Bool) {
        impactFeedbackGenerator.impactOccurred()
        if (soundEnabled) {
            warningSoundPlayer?.currentTime = 0
            warningSoundPlayer?.play()
        }
    }
    
    func stopWarningSound() {
        warningSoundPlayer?.stop()
    }
}
