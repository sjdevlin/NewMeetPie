//
//  Constants.swift
//  Profiles
//
//  Created by Stephen Devlin on 22/09/2022.
//

import SwiftUI

let kAmber = 0.85 // how close to limit before alert is triggered

let kCoach = 0 // the meeting organiser

let kMaxParticipants = 6
let kAngleSpread = 15
let kOriginX = UIScreen.main.bounds.width * 0.5
let kOriginY = UIScreen.main.bounds.width * 0.5 + 100
let kShareCircleRadius:CGFloat = 150

let kCircleWidth:CGFloat = 30.0

let kRectangleWidth:CGFloat = UIScreen.main.bounds.width * 0.6
let kRectangleHeight:CGFloat = UIScreen.main.bounds.height * 0.6

let kShareRectangleWidth = UIScreen.main.bounds.width * 0.6
let kShareRadius:CGFloat = 30.0

let kShareArc:CGFloat = 350
var kShareTangentPoint:CGFloat = pow((UIScreen.main.bounds.width / 2),2) / ((pow(kShareArc,2) - pow((UIScreen.main.bounds.width / 2),2)).squareRoot())

