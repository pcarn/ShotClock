//
//  ShotClockConfiguration.swift
//  Shot Clock
//
//  Created by Peter Carnesciali on 3/30/18.
//  Copyright © 2018 Peter Carnesciali. All rights reserved.
//

import UIKit

class ShotClockConfiguration: NSObject {
    enum League: Int {
        case ncaa = 0, nba, fiba, custom
    }

    struct Configuration {
        let shotClockLength: Double
        let middleResetAmount: Double
        let round: String
        let showTenthsUnder: Double
        let instructions: String
    }
    
    static func watchLeagueList() -> [[String: Any]] {
        return [
            [
                "title": "NCAA",
                "league": League.ncaa
            ],
            [
                "title": "NBA",
                "league": League.nba
            ],
            [
                "title": "FIBA",
                "league": League.fiba
            ],
        ]
    }

    static func leagueConfiguration(league: League) -> Configuration {
        switch league {
        case League.ncaa:
            return Configuration(
                shotClockLength: 30.0,
                middleResetAmount: 20.0,
                round: "down",
                showTenthsUnder: 5.0,
                instructions:
                """
                START shot clock when:
                    1. A team gains possession on a:
                        a. Rebound.
                        b. Jump ball.
                        c. Loose ball after a rebound or jump ball.
                    2. An official signals that an inbounds player legally touches the ball on a throw-in after it has been released.
                
                STOP shot clock when an official’s whistle sounds or the official signals to stop the clock.
                
                NO RESET when there is team control and:
                    1. The offense retains possession after the following:
                        a. A held ball.
                        b. An out-of-bounds violation.
                    2. There is an intentionally kicked or fisted ball with 20 seconds or more on the shot clock.
                    3. There is an injured player or a player loses a contact lens.
                    4. There is a timeout.
                    5. A double personal or technical foul occurs when there is team control(unless the penalty for the foul results in a change of possession).
                    6. There is a technical foul on the offensive team.
                    7. There is an inadvertent whistle when there is team control.
                    8. After a simultaneous held ball occurs during a throw-in or after an unsuccessful try that does not contact the rim and the A.P. arrow favors the team whose try was unsuccessful.
                    9. After the ball goes out of bounds and was last touched simultaneously by two opponents, both of whom are either in bounds or out of bounds.
                
                FULL RESET to 30 seconds when:
                    1. There is a change of possession with a new team in control and the ball remains live or when team control is re-established in the backcourt after the team loses control or after a score by the opponent.
                    2. There is a single personal or technical foul assessed to the defensive team while the offensive team is in control in its backcourt.
                    3. There is a double foul when only one foul is flagrant and it is assessed against the offense in its front court.
                    4. A try/shot (not a pass) hits the rim or flange and control is gained by the non-shooting team.
                    5. There is a violation (except a kicking or fisting violation or the defense causing the ball to be out of bounds and the ball is awarded to the defense in the backcourt.
                    6. There is an inadvertent whistle with no team control and the ball is awarded to either team in its backcourt.
                    7. There is a held ball or any other situation occurs where the AP arrow determines possession and the arrow favors the defensive team with a throw-in in its backcourt.
                
                RESET to 20 seconds or the time remaining on the shot clock, whichever is greater, when:
                    1. There is a personal or technical foul committed by the defensive team prior to a try for goal which hits the ring or flange and the ball is to be inbounded in the front court by the offense.
                    2. There is a kicked or fisted ball by the defensive team and the ball is to be inbounded in the front court by the offense.
                    3. There is an inadvertent whistle when there was no player or team possession and the AP arrow favors either team for a throw-in in its front court.
                
                RESET to 20 seconds when:
                    1. The offense gains control of the ball in their front court after an unsuccessful field goal attempt that contacts the ring or flange.
                    2. The offense gains control of the ball in their front court after an unsuccessful free throw that remains in play.
                    3. The defense is assessed a loose ball foul after an unsuccessful free throw that remains in play, or an unsuccessful field goal that contacts the ring or flange, or during a successful try provided that the offensive team will inbound the ball in the front court.
                    4. After the defense causes the ball to be out of bounds in the front court following an unsuccessful free throw or an unsuccessful field goal attempt that contacts the ring or flange.
                    5. When there is no team control, after the offense is awarded possession in their front court when the alternating possession arrow favors the offense following an unsuccessful free throw that remains in play, an unsuccessful field goal that hits the rim or an Instant Replay for basket interference/goaltending. Exception-Rule 2-11.6.b.8
                    6. There is a kicked or fisted ball in the backcourt by the defense with 19 seconds or less remaining.
                    7. A violation occurs, other than an opponent causing the ball to be out of bounds or kicking the ball, and the defense is awarded the ball in its front court.
                    8. After any double personal foul when only one of the fouls is flagrant, and it is assessed against the offense and the defense is awarded possession in its front court.
                
                ALLOW shot clock to run:
                    1. During loose ball situations when the offense retains control.
                    2. During a try for goal that fails to hit the ring or flange.
                
                TURN OFF shot clock when there is a reset situation and there are less than 30 seconds remaining on the game clock. Reactivate the shot-clock to 20 seconds when any of the situations in Rule 2-11.6.d occur.
                """
            )
        case League.nba:
            return Configuration(
                shotClockLength: 24.0,
                middleResetAmount: 14.0,
                round: "down",
                showTenthsUnder: 5.0,
                instructions:
                """
                Rule 7-IV - Resetting 24-Second Clock
                    a. The 24-second clock shall be reset when a special situation occurs which warrants such action.
                    b. The 24-second clock is never reset on technical fouls called on the offensive team.
                    c. The 24-second clock shall be reset to 24 seconds anytime the following occurs:
                        (1) Change of possession
                        (2) Ball contacting the basket ring of the team which is in possession
                        (3) Personal foul where ball is being inbounded in backcourt
                        (4) Violation where ball is being inbounded in backcourt
                        (5) Jump balls which are not the result of a held ball caused by the defense
                    d. The 24-second clock shall remain the same as when play was interrupted or reset to 14 seconds, whichever is greater, anytime the following occurs:
                        (1) Personal foul by the defense where ball is being inbounded in frontcourt
                        (2) Defensive three-second violation
                        (3) Technical fouls and/or delay-of-game warnings on the defensive team
                        (4) Kicked or punched ball by the defensive team with the ball being inbounded in the offensive team's front-court
                        (5) Infection control
                        (6) Jump balls retained by the offensive team as the result of a held ball caused by the defense
                        (7) All flagrant and punching fouls
                """
            )
        case League.fiba:
            return Configuration(
                shotClockLength: 24.0,
                middleResetAmount: 14.0,
                round: "down",
                showTenthsUnder: 5.0,
                instructions:
                """
                The shot clock shall be:

                Started or restarted when:
                    * On the playing court a team gains control of a live ball. After that, the mere touching of the ball by an opponent does not start a new shot clock period if the same team remains in control of the ball.
                    * On a throw-in, the ball touches or is legally touched by any player on the playing court.

                Stopped, but not reset, with the remaining time visible, when the same team that previously had control of the ball is awarded a throw-in as a result of:
                    * A ball having gone out-of-bounds.
                    * A player of the same team having been injured.
                    * A jump ball situation.
                    * A double foul.
                    * A cancellation of equal penalties against both teams.

                Stopped and reset to 24 seconds, with no display visible, when:
                    * The ball legally enters the basket.
                    * The ball touches the ring of the opponent's basket (unless the ball lodges between the ring and the backboard) and it is controlled by the team that was not in control of the ball before it has touched the ring.
                    * The team is awarded a backcourt throw-in:
                        * As the result of a foul or violation.
                        * The game being stopped because of an action not connected with the team in control of the ball.
                        * The game being stopped because of an action not connected with either team, unless the opponents would be placed at a disadvantage.
                    * The team is awarded free throw(s).
                    * The infraction of the rules is committed by the team in control of the ball.

                Stopped but not reset to 24 seconds, with the remaining time visible, when the same team that previously had control of the ball is awarded a frontcourt throw-in and 14 seconds or more are displayed on the shot clock:
                    * As the result of a foul or violation.
                    * The game being stopped because of an action not connected with the team in control of the ball.
                    * The game being stopped because of an action not connected with either team, unless the opponents would be placed at a disadvantage.

                Stopped and reset to 14 seconds, with 14 seconds visible, when:
                    * The same team that previously had control of the ball is awarded a frontcourt throw-in and 13 seconds or less are displayed on the shot clock:
                        * As the result of a foul or violation.
                        * The game being stopped because of an action not connected with the team in control of the ball.
                        * The game being stopped because of an action not connected with either team, unless the opponents would be placed at a disadvantage.
                    * After the ball has touched the ring on an unsuccessful shot for a field goal, a last or only free throw, or on a pass, if the team which regains control of the ball is the same team that was in control of the ball before the ball touched the ring.

                Switched off, after the ball becomes dead and the game clock has been stopped in any period when there is a new control of the ball for either team and there are fewer than 14 seconds on the game clock.
                The shot clock signal does not stop the game clock or the game, nor causes the ball to become dead, unless a team is in a control of the ball.
                """
            )

        case League.custom:
            return Configuration(
                shotClockLength: 30.0,
                middleResetAmount: 20.0,
                round: "down",
                showTenthsUnder: 5.0,
                instructions:
                """
                In Custom mode, you can provide your own Shot Clock Length and Middle Reset amount.
                """
            )
        }
    }
}
