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
    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text ("Meeting Summary")
Spacer()
            Text ("Meeting Duration: \(meetingModel.elapsedTimeMins) Minutes")
            Spacer()
            Text ("Number of Attendees: \(meetingModel.numberOfParticipants)")
            Spacer()
            Text ("Turn History:")
            Spacer()
            Button("Done", action: {path.removeLast(path.count)})
                .font(.system(size:24))
                .padding(.top, 10)
                .padding(.bottom, 10)
                .padding(.leading, 30)
                .padding(.trailing, 30)
                .foregroundColor(.white)
                .background(Color(.orange))
                .clipShape(Capsule())
                .padding(.top, 20)


            
            
            
        }.navigationBarBackButtonHidden()
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        
        SummaryView(meetingModel: MeetingModel.example, limits: MeetingLimits.example, path: .constant(NavigationPath()))
            .preferredColorScheme(.dark)
        
    }
}

