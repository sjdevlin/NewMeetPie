//
//  MonitorView2.swift
//  Profiles
//
//  Created by Stephen Devlin on 18/09/2022.
//

import SwiftUI

struct MonitorView: View {

    @StateObject var bleConnection = BLEManager() // Create object that monitors mics and tracks conversation.  We do this here to ensure connection is there before starting meeting

    @StateObject var meetingModel = MeetingModel()
//    @EnvironmentObject var bleConnection:BLEManager
    @State private var showingAlert = false
    @State private var meetingEnded = false
    
    let limits:MeetingLimits
    
    var body: some View
    {
        
            ZStack
            {
                NavigationLink(destination: SummaryView(meetingModel: meetingModel, limits: limits), isActive: $meetingEnded,
                               label: { EmptyView() }
                ).navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
  
                
                VStack
                {
                    TabView
                    {
//                        TimeView()  // these need to be circle
                        ShareView()  //  and bezier
                        ShareViewCircle()  //  and bezier
                    }.frame( height: kRectangleHeight, alignment: .center)
                    
                    TabView
                    {
                        AllTurnsView( maxTurnLength: limits.maxTurnLengthSecs) // this is the history bar thing
                        CurrentTurnTimeView( maxTurnLength: limits.maxTurnLengthSecs) // this is the timer for current turn
                    }
                    
                    
                    
                    
                    
                    Button("Pause") {
                        showingAlert = true
                    }.alert(isPresented:$showingAlert)
                    {
                        Alert(title: Text("Meeting Paused"),
                              primaryButton: .destructive(Text("End")) {
                            meetingEnded = true
                        },
                              secondaryButton: .destructive(Text("Resume")) {
                            showingAlert = false
                        }
                        )
                    }.foregroundColor(Color.white)
                        .frame(minWidth: 200, minHeight: 60)
                        .background(RoundedRectangle(cornerRadius: 12   ).fill(Color.orange).opacity(0.5))
                        .font(.system(size: 20))
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
                
                Spacer()
                
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
                
            .tabViewStyle(.page)
/*            .onAppear(
                perform: {
                    meetingModel.startResumeMonitoring()
                }
 )*/  //may want to put this back
        
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .environmentObject(meetingModel)
            .onChange(of: bleConnection.BleStr)                 {newValue in
                guard !showingAlert else {return}
                meetingModel.update(newAngles: bleConnection.BleStr)}
            
    }

    }
    
    
    
    struct TimeView: View {
        var body: some View {Text("View 1")}
    }
    
    struct ShareView: View {
        @EnvironmentObject var meetingModel:MeetingModel
        
        var body: some View {
            
            VStack{
                ZStack{

                    Circle()
                        .stroke(Color.gray)
                        .frame(width: 2 * kShareCircleRadius, height: 2 * kShareCircleRadius)
                        .position(x:kOriginX,
                                  y:kOriginY )
                    
                    Circle()
                        .stroke(Color.white)
                        .frame(width: kShareCircleRadius * 1.5, height:  kShareCircleRadius * 1.5 )
                        .position(x:kOriginX,
                                  y:kOriginY )
                    
                    Circle()
                        .stroke(Color.gray)
                        .frame(width: kShareCircleRadius * 2.5, height:  kShareCircleRadius * 2.5)
                        .position(x:kOriginX,
                                  y:kOriginY )
                    
                    Text(String(meetingModel.elapsedTimeMins) + " mins").foregroundColor(Color.white)
                        .font(.system(size: 32))

                    
                    
                    ForEach (meetingModel.participant)
                    {person in
                        Circle()
                            .fill(person.color)
                            .opacity(person.isTalking ? 1:0.5)
                            .frame(width: kCircleWidth, height: kCircleWidth)
                            .position(x:kOriginX + (cos(person.angleRad) * kShareCircleRadius),
                                      y:kOriginY + (sin(person.angleRad) * kShareCircleRadius))
                    }

                    
                }
            }


        }
    }


struct ShareViewCircle: View {
    @EnvironmentObject var meetingModel:MeetingModel
    
    var body: some View {
        
        VStack{
            ZStack{

                Circle()
                    .stroke(Color.gray)
                    .frame(width: 2 * kShareCircleRadius, height: 2 * kShareCircleRadius)
                    .position(x:kOriginX,
                              y:kOriginY )
                
                Circle()
                    .stroke(Color.white)
                    .frame(width: kShareCircleRadius * 1.5, height:  kShareCircleRadius * 1.5 )
                    .position(x:kOriginX,
                              y:kOriginY )
                
                Circle()
                    .stroke(Color.gray)
                    .frame(width: kShareCircleRadius * 2.5, height:  kShareCircleRadius * 2.5)
                    .position(x:kOriginX,
                              y:kOriginY )
                
                Text(String(meetingModel.elapsedTimeMins) + " mins").foregroundColor(Color.white)
                    .font(.system(size: 32))

                
                ForEach (meetingModel.participant)
                {person in
                    Circle()
                        .fill(Color.gray)
                        .opacity(0.5)
                        .frame(width: kCircleWidth * 2 * CGFloat(person.voiceShareNormal), height: kCircleWidth * 2 * CGFloat(person.voiceShareNormal))
                    // consider squaring ?
                        .position(x:kOriginX + (cos(person.angleRad) * kShareCircleRadius),
                                  y:kOriginY + (sin(person.angleRad) * kShareCircleRadius))
                }

                
                ForEach (meetingModel.participant)
                {person in
                    Circle()
                        .fill(person.color)
                        .opacity(person.isTalking ? 1:0.5)
                        .frame(width: kCircleWidth , height: kCircleWidth )
                        .position(x:kOriginX + (cos(person.angleRad) * kShareCircleRadius),
                                  y:kOriginY + (sin(person.angleRad) * kShareCircleRadius))
                }


                
            }
        }

    }
}


    struct CurrentTurnTimeView: View
    {
        @EnvironmentObject var meetingModel:MeetingModel
        let maxTurnLength:Int
        
        let radius: CGFloat = kShareCircleRadius * 1.5
        let pi = Double.pi
        let dotLength: CGFloat = 4
        let spaceLength: CGFloat = 10.95
        let dotCount = 60

        
        var body: some View {
            
            let arcFractionLimit = CGFloat(maxTurnLength)/60
            let arcFraction = CGFloat(meetingModel.currentTurnLength)/60
            let turnPercentage = CGFloat(meetingModel.currentTurnLength) / CGFloat(maxTurnLength)
            ZStack{
                VStack{

                    ZStack{
                        Circle()
                            .trim(from: 0.0, to: arcFraction)
                            .rotation(.degrees(-90))
                            .stroke((turnPercentage < kAmber) ?  Color.white: Color.orange,
                                style: StrokeStyle(lineWidth: 10, lineCap: .butt, lineJoin: .miter, miterLimit: 0, dash: [dotLength, spaceLength], dashPhase: 0))
                            .frame(width: radius - 10 , height: radius - 10)
                        
                       Circle()
                            .trim(from: 0.0, to: arcFractionLimit)
                            .rotation(.degrees(-90))
                            .stroke(Color.white,style: StrokeStyle(lineWidth:1))
                            .frame(width:radius, height:radius)
                        

                        Text(String(meetingModel.currentTurnLength) + " s")
                            .font(.system(size: 28))
                            .foregroundColor( Color.white                 )
                    }
                }
            }
        }
    }

struct AllTurnsView: View {
    @EnvironmentObject var meetingModel:MeetingModel
    let maxTurnLength:Int
    
    var body: some View {
        
        VStack{

            HStack (alignment: .bottom, spacing:0 ){
                ForEach (meetingModel.history) { turn in
                    
                    Rectangle ()
                        .fill(kParticipantColors[turn.talker])
                        .frame(width:
                            (meetingModel.history.count < 15 ?
                             20 :  (300 / CGFloat(meetingModel.history.count)))
                            , height:CGFloat(2 * turn.turnLengthSecs))
                    
                }
                
            }
            
            Divider()
                .frame(height:2)
                .overlay(Color(.lightGray))
                .navigationBarTitle("Meeting Summary", displayMode: .inline)
                .padding(.top, -10)
                .padding(.leading, 50)
                .padding(.trailing, 50)

            
        }
        
    }
}
    
    struct ShareView_Previews: PreviewProvider {
        static var previews: some View {
            
            
            VStack
            {
                TabView
                {
                    ShareView().environmentObject(MeetingModel.example)
                        .preferredColorScheme(.dark)
                    ShareViewCircle().environmentObject(MeetingModel.example)
                        .preferredColorScheme(.dark)
                }.frame(height: kRectangleHeight)

                TabView
                {
                    CurrentTurnTimeView(maxTurnLength: 90).environmentObject(MeetingModel.example)
                        .preferredColorScheme(.dark)

                    AllTurnsView(maxTurnLength: 90).environmentObject(MeetingModel.example)
                        .preferredColorScheme(.dark)
                }
                
                Button("Pause") {
                }.foregroundColor(Color.white)
                    .frame(minWidth: 200, minHeight: 60)
                    .background(RoundedRectangle(cornerRadius: 12   ).fill(Color.orange).opacity(0.5))
                    .font(.system(size: 20))
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
            Spacer()
            
            
        }
    }
    
    
    
    
    // this struct and view extension allows individually rounded corners
    
    
    
