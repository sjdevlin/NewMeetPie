//
//  Constants.swift
//  Profiles
//
//  Created by Stephen Devlin on 22/09/2022.
//

import SwiftUI

let kAmber = 0.85 // how close to limit before alert is triggered

let kCoach = 0 // the meeting organiser

let kMaxParticipants = 7
let kAngleSpread = 15

let kOriginX = UIScreen.main.bounds.width * 0.5
let kOriginY = UIScreen.main.bounds.width * 0.5

let kParticipantColors: [Color] = [Color.white, Color.green, Color.red, Color.blue, Color.orange, Color.cyan, Color.indigo]

let kCircleWidth:CGFloat = 30.0

let kRectangleWidth:CGFloat = UIScreen.main.bounds.width * 0.9
let kRectangleHeight:CGFloat = UIScreen.main.bounds.height * 0.5
let kShareCircleRadius:CGFloat = kRectangleWidth / 2.5

let kShareRadius:CGFloat = 30.0

let kShareArc:CGFloat = 350

var kShareTangentPoint:CGFloat = pow((UIScreen.main.bounds.width / 2),2) / ((pow(kShareArc,2) - pow((UIScreen.main.bounds.width / 2),2)).squareRoot())

