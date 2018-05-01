//
//  ShotClock.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 4/23/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import Foundation

class ShotClock {
    var timer = Timer()
    lazy var config = ShotClockConfiguration.leagueConfiguration(league: currentLeague)
    lazy var currentTime = config.shotClockLength
    var isTimerRunning = false
    var recallAmount = -1.0
    var currentLeague = ShotClockConfiguration.League.ncaa

    func reset() {
        recallAmount = currentTime
        currentTime = config.shotClockLength
    }

    func start() {

    }

    func stop() {
        
    }

    func setTime(time: Double) {
        currentTime = time
    }

    func recall() {
        if recallAmount != -1.0 {
            currentTime = recallAmount
            recallAmount = -1.0
        }
    }

    func middleReset() {
        recallAmount = currentTime
        currentTime = config.middleResetAmount
    }

    func changeLeague(selectedLeague: ShotClockConfiguration.League) {
        currentLeague = selectedLeague
        config = ShotClockConfiguration.leagueConfiguration(league: currentLeague)
        currentTime = config.shotClockLength
        recallAmount = -1.0
    }
}
