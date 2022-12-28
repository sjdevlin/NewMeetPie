
//
//  MicrophoneMonitor.swift
//  SoundVisualizer
//
//  Created by Stephen Devlin on 31/08/2022.
//

import Foundation

class MeetingMonitor: ObservableObject

{
    var bleManager = BLEManager()
    // this is the object that updates the view
    @Published var meeting:MeetingData
    
    init() {
                
        meeting = MeetingData()
        meeting.startTime = Date()
        meeting.participant.append(Participant()) // create participant for Coach
    }
    
    func ProcessBLEData(angle_array:[Int]) {
        
        // not sure what the optimum buffer size should be - i have guessed at 4096
        let timeDifference = Calendar.current.dateComponents([.minute], from: self.meeting.startTime, to:Date())
        self.meeting.elapsedTimeMins = timeDifference.minute ?? 0

        // All Angle stuff in here
        


            }
    
    // called during the meeting.  Just pauses the engine and disables the timing logic while user is
    // asked if they want to end or resume
    func pauseMonitoring() {
        
    }
        
    func stopMonitoring() {
        

    }
    
    
}
