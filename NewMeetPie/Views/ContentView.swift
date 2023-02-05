//
//  ContentView.swift
//  Profiles
//
//  Created by Stephen Devlin on 13/09/2022.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var appState: AppState // for pop to root

    @State var userData: [MeetingLimits] = getMeetingLimits() // Create struct that monitors mics and tracks conversation
    @State private var path = NavigationPath()
    
    var body: some View
    {
        NavigationStack(path: $path)
        {
            VStack
            {
                Text("Select Meeting Type").padding(.top,20)
                    .font(Font.system(size: 28))

                List ($userData, id: \.id)
                {
                    $meetingDetails in
                    NavigationLink(destination: DetailView(limits: $meetingDetails, path:$path, isNew:false, isEditing: false))
                    {
                        Text(meetingDetails.meetingName)
                            .font(Font.system(size: 24))
                            .padding(6)
                    }
                    .swipeActions
                    {
                        Button
                        {
                            if let index:Int = userData.firstIndex(where:{$0.id == meetingDetails.id})
                            {
                                userData.remove(at: index)
                                saveMeetingLimits(meetingLimits: userData)
                            }
                        }
                        label :
                        {
                            Label("Delete", systemImage:"trash.circle.fill")
                        }
                    }
                }}
            .navigationBarItems(trailing: Button
                {
                userData.append(MeetingLimits(meetingName: "New Meeting", meetingDurationMins: 30, maxShareVoice: 125, minShareVoice: 80, maxTurnLengthSecs: 90, alwaysVisible: true))
                saveMeetingLimits(meetingLimits: userData)
                }
                label:
                {
                Label("Add", systemImage:"plus.circle.fill")
                }).tint(.orange)
       //        .id(appState.rootViewId)
                .font(Font.system(size: 30))
                .navigationBarTitleDisplayMode(.inline)

        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portraitUpsideDown)
            .preferredColorScheme(.dark)
    }
    
}

