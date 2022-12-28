//
//  SummaryView.swift
//  Profiles
//
//  Created by Stephen Devlin on 25/09/2022.
//

import SwiftUI

struct SummaryView: View {
    let meetingModel: MeetingModel
    let limits: MeetingLimits
    
    var body: some View {
        VStack {
            Text ("Meeting Summary")
        }
    }
}
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        
        SummaryView(meetingModel: MeetingModel.example, limits: MeetingLimits.example)
            .preferredColorScheme(.dark)
        
    }
}

