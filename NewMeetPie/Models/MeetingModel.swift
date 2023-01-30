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
    var color:Color
    var angleRad:CGFloat
    var isTalking:Bool
    var numTurns: Int = 1 //  Need to check this
    var totalTalkTimeSecs: Int = 0
    var voiceShare:Float = 0.01
    var voiceShareNormal:Float = 2.0
    var voiceShareDeviation: Float = 1.0
    
    init(angle:Int, isTalking:Bool, participantNumber:Int)
    {
        self.id = UUID()
        self.color = kParticipantColors[participantNumber]
        self.angle = angle
        self.angleRad = CGFloat (angle) * 3.142 / 180
        self.isTalking = isTalking
        self.numTurns = 0
        self.totalTalkTimeSecs = 0
        self.voiceShare = 0.01
        self.voiceShareDeviation = 1
        
        print ("Particiapnt created")

    }
    
    init(angle:Int, isTalking:Bool, participantNumber:Int, numTurns:Int, totalTalkTimeSecs:Int, voiceShare:Float, voiceShareDeviation:Float)
    {
        self.id = UUID()
        self.color = kParticipantColors[participantNumber]
        self.angle = angle
        self.angleRad = CGFloat (angle) * 3.142 / 180
        self.isTalking = isTalking
        self.numTurns = numTurns
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
        
        print("turn created")
    }
}


class MeetingModel:ObservableObject {
    
    let id:UUID
    @Published var participant:[Participant] = []
    @Published var lastTalker: Int?
    @Published var CurrentTalker: Int?
    @Published var currentTalker: Int = kCoach
    @Published var history:[Turn] = []
    @Published var startTime:Date
    @Published var timeOfLastUpdate:Date
    @Published var elapsedTimeMins:Int
    @Published var totalTalkTimeSecs:Int = 0
    @Published var participantAtAngle = [Int](repeating: -1, count: 360)
    @Published var numberOfParticipants:Int = 1
    @Published var timeLastSpeakerChange:Date?
    @Published var currentTurnLength:Int = 0

    private var numberTalking:Int = 0
    private var meetingPaused: Bool = false
    private var FirstTurnStarted: Bool = false

    
    // this version of init only used to create example date
    init(participant:[Participant], history:[Turn], elapsedTimeMins:Int, currentTurnLength:Int) {
        self.id = UUID()
        self.startTime = Date()
        self.timeOfLastUpdate = Date()
        self.participant = participant
        self.history = history
        self.elapsedTimeMins = elapsedTimeMins
        self.currentTurnLength = currentTurnLength
        
    }

    init() {
        self.id = UUID()
        self.startTime = Date()
        self.timeOfLastUpdate = Date()
        self.elapsedTimeMins = 0
        self.participant = []
        self.history = []

        // make sure that meeting has at least one person - the chair !
        self.participant.append(Participant(angle:90, isTalking: false, participantNumber: kCoach)) // create participant for Coach
        
        // make sure that the chair person is already assigned to the right angle arc
        for i in (90-kAngleSpread...90+kAngleSpread)
        {
            self.participantAtAngle[i] = kCoach
        }
        
        print ("Meeting created")

    }

    
    func update (newAngles:String)
    {
        // parse the angles
        var activeSourceAngles:[Int] = []
        let stringArray = newAngles.components(separatedBy: ",")
        print ("New Angles String received: \(stringArray)")
        
        for string in stringArray {
            if string != "" {activeSourceAngles.append(Int(string) ?? -1) }}
        
        // update elapsed time
        
        let timeNow = Date()
        let timeDifference = Calendar.current.dateComponents([.second], from: self.timeOfLastUpdate, to:timeNow)
        self.timeOfLastUpdate = timeNow

        let timeElapsed = Calendar.current.dateComponents([.minute], from: self.startTime, to:timeNow)
        self.elapsedTimeMins = timeElapsed.minute ?? 0

        // All Angle stuff in here
        
        self.numberTalking = 0;
        
        for participant in self.participant
        {
            participant.isTalking = false;
            participant.voiceShare = Float(participant.totalTalkTimeSecs) / Float(self.totalTalkTimeSecs)
            if (participant.voiceShare.isNaN ) {participant.voiceShare = 0.01}
            participant.voiceShareNormal = participant.voiceShare * Float(self.numberOfParticipants)
        }
        
        for nextAngle in activeSourceAngles {
            
            if self.participantAtAngle[nextAngle] == -1 && self.numberOfParticipants < kMaxParticipants
            {
                let newParticipantNumber = self.numberOfParticipants
                self.numberOfParticipants += 1
                self.numberTalking += 1// another person is talking in this session
                
                print("new participant added")
                
                self.participant.append(Participant(angle: nextAngle, isTalking: true, participantNumber: newParticipantNumber))
                
                // increment total_talk_time;
                
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
            }else  // known talker
            {
                

                self.numberTalking += 1
                if (self.numberTalking == 1) {
                    self.currentTurnLength += timeDifference.second ?? 0
                    self.totalTalkTimeSecs += timeDifference.second ?? 0
                } // this logic avoids double counting the turn length when multiple talkers

                print ("Known talker.  Number: \(self.participantAtAngle[nextAngle])")
                print ("Total Talk: \(self.totalTalkTimeSecs)  Voice Share: \(self.participant[self.participantAtAngle[nextAngle]].voiceShare)")


                self.participant[self.participantAtAngle[nextAngle]].totalTalkTimeSecs +=
                timeDifference.second ?? 0 // add the num secs from last update
                self.participant[self.participantAtAngle[nextAngle]].isTalking = true
            }
            
            // Turn logic - only applies when sole talker changes
            
        }
        if (self.numberTalking == 1) {

            // only assign turn holder when they are sole talker
            
            for (index, participant) in self.participant.enumerated()
            {
                if (participant.isTalking) {

                    if (!self.FirstTurnStarted)
                    {
                        self.FirstTurnStarted = true
                        self.lastTalker = index
                        self.timeLastSpeakerChange = timeNow
                    }

                    
                    if (self.lastTalker != index )
                    {
                      //  new turn created - save last turn
                        self.history.append(Turn(talker: self.lastTalker!, turnLengthSecs: self.currentTurnLength))
                        self.lastTalker = index
                        self.timeLastSpeakerChange = timeNow
                        participant.numTurns += 1
                        self.currentTurnLength = 0
                    }
                }
            }

        
        }
        else if (self.numberTalking > 1)
        {
        print ("more than 1 talking")
        }
        else if (self.numberTalking == 0)
        {
        print ("No-one talking")
            
        }
    }

    

//  FOR PREVIEWS

    static let exampleParticipant = [Participant(angle: 90, isTalking: true, participantNumber: 0, numTurns: 5, totalTalkTimeSecs: 456, voiceShare: 0.34, voiceShareDeviation: 1.1),
    Participant(angle: 150, isTalking: false, participantNumber: 1, numTurns: 5,   totalTalkTimeSecs: 999, voiceShare: 0.66, voiceShareDeviation: 0.8),
                                     Participant(angle: 220, isTalking: false, participantNumber: 2, numTurns: 2,  totalTalkTimeSecs: 999, voiceShare: 0.16, voiceShareDeviation: 0.5),
                                     Participant(angle: 280, isTalking: false, participantNumber: 3, numTurns: 5,   totalTalkTimeSecs: 999, voiceShare: 0.46, voiceShareDeviation: 1.3),
                                     Participant(angle: 340, isTalking: false, participantNumber: 4, numTurns: 5,   totalTalkTimeSecs: 999, voiceShare: 0.46, voiceShareDeviation: 1.3),
                                     Participant(angle: 40, isTalking: false, participantNumber: 5, numTurns: 5,   totalTalkTimeSecs: 999, voiceShare: 0.46, voiceShareDeviation: 1.3)
    ]

    static let exampleHistory = [Turn(talker: 0, turnLengthSecs: 12),Turn(talker: 1, turnLengthSecs: 22), Turn(talker: 3, turnLengthSecs: 6),Turn(talker: 1, turnLengthSecs: 32),Turn(talker: 0,turnLengthSecs: 8),Turn(talker: 2,turnLengthSecs: 75),Turn(talker: 0, turnLengthSecs: 32),Turn(talker: 2, turnLengthSecs: 8),Turn(talker: 3, turnLengthSecs: 14),Turn(talker: 1, turnLengthSecs: 62), Turn(talker: 0,turnLengthSecs: 30)
    ]

static let example = MeetingModel(participant:exampleParticipant, history: exampleHistory, elapsedTimeMins: 48, currentTurnLength: 23)









}
