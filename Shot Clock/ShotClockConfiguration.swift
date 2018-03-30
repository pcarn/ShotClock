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
        case ncaa = 0, nba, fiba
    }

    struct Configuration {
        let shotClockLength: Int
        let middleResetAmount: Int
        let instructions: String
    }

    static func leagueConfiguration(league: League) -> Configuration {
        switch league {
        case League.ncaa:
            return Configuration(
                shotClockLength: 30,
                middleResetAmount: 20,
                instructions:
                """
                START shot clock when:
                    1. A team gains possession on a:
                        a. Rebound.
                        b. Jump ball.
                        c. Loose ball after a rebound or jump ball.
                    2. An official signals that an inbounds player legally touches the ball on a throw-in after it has been released.

                STOP shot clock when an official’s whistle sounds.

                FULL RESET to 30 seconds when:
                    1. There is a change of possession with a new team in control or when team control is re-established after the team loses control.
                    2. There is a single personal foul.
                    3. A double foul when one foul is flagrant.
                    4. There is a single technical foul on the defensive team.
                    5. A try/shot (not a pass) hits the rim or flange and either team gains possession of the ball.
                    6. There is a violation (except a kicking or fisting violation).
                    7. There is an inadvertent whistle with no team control.
                    8. There is a held ball and the arrow favors the defensive team.

                RESET to 20 seconds or the time remaining on the shot clock, whichever is greater, when
                    1. There is a personal foul against the defensive team and the ball is to be inbounded by the offense in the front court.
                    2. There is a technical foul committed by the defensive team and the ball is to be inbounded in the front court by the offense.
                    3. There is a kicked or fisted ball by the defensive team and the ball is to be inbounded in the front court by the offense.


                NO RESET when:
                    1. The offense retains possession after the following:
                        a. A held ball.
                        b. An out-of-bounds violation.
                    2. There is an intentionally kicked or fisted ball with 20 seconds or more on the shot clock.
                    3. There is an injured player or a player loses a contact lens.
                    4. There is a timeout.
                    5. A double foul occurs (except when one of the fouls is flagrant).
                    6. There is a technical foul on the offensive team.
                    7. There is an inadvertent whistle when there is team control.

                ALLOW shot clock to run:
                    1. During loose ball situations.
                    2. During a try for goal.

                TURN OFF shot clock when there is a reset situation and there is less than 30 seconds remaining on the game clock.
                """
            )
        case League.nba:
            return Configuration(
                shotClockLength: 24,
                middleResetAmount: 14,
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
                shotClockLength: 24,
                middleResetAmount: 14,
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
        }
    }
}
