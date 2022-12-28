//
//  MeetingModel.swift
//  NewMeetPie
//
//  Created by Stephen Devlin on 27/12/2022.
//

import SwiftUI

class Participant:Identifiable {
    var id: UUID
    var angle:Int
    var angleRad:CGFloat
    var isTalking:Bool
    var numTurns: Int = 1 //  Need to check this
    var currentTurnDuration: Int = 0
    var totalTalkTimeSecs: Int = 0
    var voiceShare:Float = 0.01
    var voiceShareDeviation: Float = 1.0
    
    init(angle:Int, isTalking:Bool)
    {
        self.id = UUID()
        self.angle = angle
        self.angleRad = CGFloat (angle) * 3.142 / 180
        self.isTalking = isTalking
        self.numTurns = 0
        self.currentTurnDuration = 0
        self.totalTalkTimeSecs = 0
        self.voiceShare = 0.01
        self.voiceShareDeviation = 1
    }
    
    init(angle:Int, isTalking:Bool, numTurns:Int, currentTurnDuration:Int, totalTalkTimeSecs:Int, voiceShare:Float, voiceShareDeviation:Float)
    {
        self.id = UUID()
        self.angle = angle
        self.angleRad = CGFloat (angle) * 3.142 / 180
        self.isTalking = isTalking
        self.numTurns = numTurns
        self.currentTurnDuration = currentTurnDuration
        self.totalTalkTimeSecs = totalTalkTimeSecs
        self.voiceShare = voiceShare
        self.voiceShareDeviation = voiceShareDeviation
    }
}


class Turn: Identifiable {
    var id: UUID
    var talker:Int
    var turnLengthSecs: Int

    init(talker:Int, turnLengthSecs:Int)
    {
        self.id = UUID()
        self.talker = talker
        self.turnLengthSecs = turnLengthSecs
    }
}


class MeetingModel:ObservableObject {
    
    let id:UUID
    @Published var participant:[Participant] = []
    @Published var lastTalker: Int = kCoach
    @Published var currentTalker: Int = kCoach
    @Published var history:[Turn] = []
    @Published var startTime:Date
    @Published var timeOfLastUpdate:Date
    @Published var elapsedTimeMins:Int
    @Published var totalTalkTimeSecs:Int = 0
    @Published var participantAtAngle = [Int](repeating: -1, count: 360)
    @Published var numberOfParticipants:Int = 1
    
    private var numberTalking:Int = 0
    private var meetingPaused: Bool = false
        
    
    // this version of init only used to create example date
    init(participant:[Participant], history:[Turn], elapsedTimeMins:Int) {
        self.id = UUID()
        self.startTime = Date()
        self.timeOfLastUpdate = Date()
        self.participant = participant
        self.history = history
        self.elapsedTimeMins = elapsedTimeMins
    }

    init() {
        self.id = UUID()
        self.startTime = Date()
        self.timeOfLastUpdate = Date()
        self.elapsedTimeMins = 0
        self.participant = []
        self.history = []
        self.participant.append(Participant(angle:180, isTalking: false)) // create participant for Coach
    }

    
    func update (newAngles:String)
    {
        if self.meetingPaused {return}

        // parse the angles
        var activeSourceAngles:[Int] = []
        let stringArray = newAngles.components(separatedBy: ",")
        for string in stringArray {
            if string != "" {activeSourceAngles.append(Int(string) ?? -1) }}

        // update elapsed time

        let timeNow = Date()
        let timeDifference = Calendar.current.dateComponents([.minute], from: self.timeOfLastUpdate, to:timeNow)
        self.elapsedTimeMins += timeDifference.minute ?? 0
        self.timeOfLastUpdate = timeNow
        // can use time of last update to check for connectivity ?
        
        // All Angle stuff in here

        self.numberTalking = 0;
        for participant in self.participant
            {
            participant.isTalking = false;
            }
        
        for nextAngle in activeSourceAngles {

            if self.participantAtAngle[nextAngle] == -1 && numberOfParticipants < kMaxParticipants
            {
                let newParticipantNumber = numberOfParticipants
                numberOfParticipants += 1
                numberTalking += 1// another person is talking in this session
                self.participant.append(Participant(angle: nextAngle, isTalking: true))
// increment particiapnt talk time 1!
// increment total_talk_time;
//participant[num_participants].angle = target_angle;
                
                self.participantAtAngle[nextAngle] = newParticipantNumber;

                // write a buffer around them

                for index in 1...kAngleSpread
                {
                    if nextAngle + index < 360
                    {
                        self.participantAtAngle[nextAngle + index] = newParticipantNumber
                    }else
                    {
                        self.participantAtAngle[index - 1] = newParticipantNumber
                    }
                    if nextAngle - index >= 0
                    {
                        self.participantAtAngle[nextAngle - index] = newParticipantNumber
                    }else
                    {
                        self.participantAtAngle[361 - index] = newParticipantNumber
                    }
                }
            }else
            {
                self.participant[self.participantAtAngle[nextAngle]].isTalking = true
                self.numberTalking += 1

// need to increment talk time
            }
            
        }
        
    }

    func pauseMonitoring ()
    {}
    func stopMonitoring ()
    {}
    func startResumeMonitoring ()
    {
        self.meetingPaused = !self.meetingPaused
    }

    

//  FOR PREVIEWS

    static let exampleParticipant = [Participant(angle: 90, isTalking: true, numTurns: 5, currentTurnDuration: 44,totalTalkTimeSecs: 456, voiceShare: 0.34, voiceShareDeviation: 1.1),
    Participant(angle: 150, isTalking: false, numTurns: 5, currentTurnDuration: 0,   totalTalkTimeSecs: 999, voiceShare: 0.66, voiceShareDeviation: 0.8),
                                     Participant(angle: 220, isTalking: false, numTurns: 2, currentTurnDuration: 0,   totalTalkTimeSecs: 999, voiceShare: 0.16, voiceShareDeviation: 0.5),
                                     Participant(angle: 280, isTalking: false, numTurns: 5, currentTurnDuration: 0,   totalTalkTimeSecs: 999, voiceShare: 0.46, voiceShareDeviation: 1.3),
                                     Participant(angle: 340, isTalking: false, numTurns: 5, currentTurnDuration: 0,   totalTalkTimeSecs: 999, voiceShare: 0.46, voiceShareDeviation: 1.3),
                                     Participant(angle: 40, isTalking: false, numTurns: 5, currentTurnDuration: 0,   totalTalkTimeSecs: 999, voiceShare: 0.46, voiceShareDeviation: 1.3)
    ]

    static let exampleHistory = [Turn(talker: 0, turnLengthSecs: 12),Turn(talker: 1, turnLengthSecs: 22), Turn(talker: 3, turnLengthSecs: 6),Turn(talker: 1, turnLengthSecs: 32),Turn(talker: 0,turnLengthSecs: 8),Turn(talker: 2,turnLengthSecs: 75),Turn(talker: 0, turnLengthSecs: 32),Turn(talker: 2, turnLengthSecs: 8),Turn(talker: 3, turnLengthSecs: 14),Turn(talker: 1, turnLengthSecs: 62), Turn(talker: 0,turnLengthSecs: 30)
    ]

static let example = MeetingModel(participant:exampleParticipant, history: exampleHistory, elapsedTimeMins: 48)









}
