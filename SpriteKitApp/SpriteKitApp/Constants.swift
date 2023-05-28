//
//  Constants.swift
//  SpriteKitApp
//
//  Created by NikoS on 26.05.2023.
//

import Foundation

final class Constants {
    
    static let finishGameTaps = 7
    static let resultPathURL = "https://2llctw8ia5.execute-api.us-west-1.amazonaws.com/prod"
    static let gameRules = "Game Rules:\n\n After pressing the start button you will see aim in random place on the screen. After touching the aim it moves to another random position. Game finishes when you press the aim 10 times. You win if you do it faster than 7 seconds. You lose if you are slower."
    static let appFont = "Arial"
    static let gameTime = 10.00
    static let rulesMenuKey = "hasShownRulesMenu"
    static let rulesWindowButtonNodeName = "gotItButton"
    static let rulesWindowButtonLabelText = "Got it!"
    static let startButtonNodeName = "startButtonNode"
    static let startButtonLabelText = "Start"
    static let gameAimNodeName = "aimNode"
    static let backButtonTitleText = "Back"
    
}
