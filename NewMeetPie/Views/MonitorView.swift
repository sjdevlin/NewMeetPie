//
//  MonitorView2.swift
//  Profiles
//
//  Created by Stephen Devlin on 18/09/2022.
//

import SwiftUI

struct MonitorView: View {
    
    @StateObject var meetingModel = MeetingModel()
    @EnvironmentObject var bleConnection:BLEManager
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
                        TimeView()
                        ShareView()
                        TurnView( maxTurnLength: limits.maxTurnLengthSecs)
                    }
                    
                    Button("Pause") {
                        meetingModel.pauseMonitoring()
                        showingAlert = true
                    }.alert(isPresented:$showingAlert)
                    {
                        Alert(title: Text("Meeting Paused"),
                              primaryButton: .destructive(Text("End")) {
                            meetingModel.stopMonitoring()
                            meetingEnded = true
                        },
                              secondaryButton: .destructive(Text("Resume")) {
                            meetingModel.startResumeMonitoring()
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
            .onAppear(
                perform: {
                    meetingModel.startResumeMonitoring()
                }
            )
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .environmentObject(meetingModel)
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
                    
                    let path = UIBezierPath()
                    
                    ForEach (meetingModel.participant)
                    {perpe in
                        Circle()
                            .fill(perpe.isTalking ? Color.white : Color.gray)
                            .frame(width: kCircleWidth, height: kCircleWidth)
                            .position(x:kOriginX + (cos(perpe.angleRad) * kShareCircleRadius),
                                      y:kOriginY + (sin(perpe.angleRad) * kShareCircleRadius))
                        
                    }
                    
                }
                Text(String(meetingModel.elapsedTimeMins) + " Mins").foregroundColor(Color.white)
                    .font(.system(size: 28))
                Spacer()
            }

        }
    }
    
    struct TurnView: View
    {
        @EnvironmentObject var meetingModel:MeetingModel
        let maxTurnLength:Int
        
        let radius: CGFloat = 120
        let pi = Double.pi
        let dotLength: CGFloat = 4
        let spaceLength: CGFloat = 10.8
        let dotCount = 60
        let circumference: CGFloat = 754.1

        let clientRadius: CGFloat = 75
        let clientDotLength: CGFloat = 3
        let clientSpaceLength: CGFloat = 8
        let clientCircumference: CGFloat = 471.3

        
        var body: some View {
            
            let arcFractionLimit = CGFloat(maxTurnLength)/60
            let arcFraction = CGFloat(meetingModel.participant[kCoach].currentTurnDuration)/60
            ZStack{
                VStack{

                    ZStack{
                        Circle()
                            .trim(from: 0.0, to: arcFraction)
                            .rotation(.degrees(-90))
                            .stroke(Color.white,
                                style: StrokeStyle(lineWidth: 12, lineCap: .butt, lineJoin: .miter, miterLimit: 0, dash: [dotLength, spaceLength], dashPhase: 0))
                            .frame(width: radius * 2, height: radius * 2)
                        
                        Circle()
                            .trim(from: 0.0, to: arcFractionLimit)
                            .rotation(.degrees(-90))
                            .stroke(Color.gray,style: StrokeStyle(lineWidth:8))
                            .frame(width:radius * 2.2, height:radius * 2.2)
                        
                        Text(String(meetingModel.participant[kCoach].currentTurnDuration)+" s")
                            .font(.system(size: 65))
                            .foregroundColor( Color.orange                 )
                    }
                }

                
                
                VStack {
                    HStack {
                        Spacer()
                        Text ("Turn\nLength")
                            .font(.system(size: 32))
                            .foregroundColor(Color.white)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }.padding(.top, 20)
                    
                    Spacer()
                }
                
                
            }
        }
    }
    
    struct ShareView_Previews: PreviewProvider {
        static var previews: some View {
            
            ShareView().environmentObject(MeetingModel.example)
                .preferredColorScheme(.dark)

        }
    }
    
    
    
    
    // this struct and view extension allows individually rounded corners
    
    
    
