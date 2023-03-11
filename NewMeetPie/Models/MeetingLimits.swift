//
//  Models.swift
//  Profiles
//
//  Created by Stephen Devlin on 14/09/2022.
//

import Foundation
import SwiftUI

// Struct for storing settings and limits for different types of meeting



struct MeetingLimits: Codable
{
    let  id:UUID
    var  meetingName: String
    var  meetingDurationMins: Int
    var  maxShareVoice: Int
    var  minShareVoice: Int
    var  maxTurnLengthSecs: Int
    var  alwaysVisible: Bool
    
    static let example = MeetingLimits(meetingName: "Interview", meetingDurationMins: 45, maxShareVoice: 130, minShareVoice: 65, maxTurnLengthSecs: 60, alwaysVisible: false)
    
    init(meetingName: String, meetingDurationMins: Int, maxShareVoice: Int, minShareVoice: Int, maxTurnLengthSecs: Int, alwaysVisible: Bool)
    {
        self.id = UUID()
        self.meetingName = meetingName
        self.meetingDurationMins = meetingDurationMins
        self.maxShareVoice = maxShareVoice
        self.minShareVoice = minShareVoice
        self.maxTurnLengthSecs = maxTurnLengthSecs
        self.alwaysVisible = alwaysVisible
    }
}


// Save and retrieve meeting limit data

func updateMeetingLimits(updatedMeetingLimits: MeetingLimits){
    
    let jsonMeetingLimits = UserDefaults.standard.object(forKey: "userMeetingLimits") as? Data
    let decoder = JSONDecoder()
    var userMeetingLimits: [MeetingLimits] = [] // put this into the catch below
    
    do { try userMeetingLimits = decoder.decode([MeetingLimits].self, from: jsonMeetingLimits!)}
    catch {print("Err")}
    
    if let row = userMeetingLimits.firstIndex(where: {$0.id == updatedMeetingLimits.id}) {
        userMeetingLimits[row] = updatedMeetingLimits  // can i do this simpler?
    } else {userMeetingLimits.append(updatedMeetingLimits)}
    
    let encoder = JSONEncoder()
    do {let jsonMeetingLimits = try encoder.encode(userMeetingLimits)
        UserDefaults.standard.set(jsonMeetingLimits, forKey: "userMeetingLimits")
    }catch {print("err")}
    
}

func saveMeetingLimits(meetingLimits: [MeetingLimits]){
    
    let encoder = JSONEncoder()
    do {let jsonMeetingLimits = try encoder.encode(meetingLimits)
        UserDefaults.standard.set(jsonMeetingLimits, forKey: "userMeetingLimits")
    }catch {print("err")}
    
}

//retrieve data method
//sets defaults if there is no data stored (usually only at first run)

func getMeetingLimits() -> [MeetingLimits]{
    
    guard let jsonMeetingLimits = UserDefaults.standard.object(forKey: "userMeetingLimits") as? Data else
    
    // no data returned.  So set to default and save
    {
        let userMeetingLimits = defaultMeetingData()
        saveMeetingLimits(meetingLimits: userMeetingLimits)
        return(userMeetingLimits)}
    
    // data returned in json format, so decode and return
    do{
        let decoder = JSONDecoder()
        let userMeetingLimits = try decoder.decode([MeetingLimits].self, from: jsonMeetingLimits)
        return userMeetingLimits
    }catch {
        return([])
    }
}

func defaultMeetingData() -> [MeetingLimits]{
    
    var defaultMeetingLimits:[MeetingLimits] = []
    
    // max share needs to be calculated as the percentage OVER the average
    // based on number of participants
    
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Weekly Team Meeting", meetingDurationMins: 45, maxShareVoice: 130, minShareVoice: 75, maxTurnLengthSecs: 90, alwaysVisible: true))
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Brainstorming", meetingDurationMins: 60, maxShareVoice: 120, minShareVoice: 80,maxTurnLengthSecs: 180, alwaysVisible: false))
    defaultMeetingLimits.append(MeetingLimits(meetingName: "Counselling Session", meetingDurationMins: 50, maxShareVoice: 110, minShareVoice: 90, maxTurnLengthSecs: 60, alwaysVisible: false))
    
    return(defaultMeetingLimits)
}
