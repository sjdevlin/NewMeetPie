//
//  MonitorView2.swift
//  Profiles
//
//  Created by Stephen Devlin on 18/09/2022.
//

import SwiftUI

// This view is the real time monitoring view for the meeting
// it connects to the BLE peripheral and maintains all the meeting
// stats using the MeetingModel struct


struct MonitorView: View
{
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
                // The link here is to the summary screen.  This is only activated when meeting as ended,
                // which is set in the button logic
                
                NavigationLink(destination: SummaryView(meetingModel: meetingModel, limits: limits), isActive: $meetingEnded,
                               label: { EmptyView()            }
                    
                ).navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
  
                
                VStack
                {
                    // The two styles of conveying share and turn info are both horizontal tab views
                    // each can be scrolled independently

                    TabView
                    {
                        ShareView()  //  This is the spline version of the meeting speech map
                        ShareViewCircle()  //  This is the circle version of the speech map
                    }.frame( height: kRectangleHeight, alignment: .center)
                    
                    TabView
                    {
                        AllTurnsView( maxTurnLength: limits.maxTurnLengthSecs) // this is the history bar
                        CurrentTurnTimeView( maxTurnLength: limits.maxTurnLengthSecs) // this is the timer for current turn
                    }
                    
                    
                    
                    
                    // The button logic here allows pausing and ending
                    
                    Button(bleConnection.isConnected ?
                           "Pause" : "Connecting") {
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
                        .background(RoundedRectangle(cornerRadius: 12   ).fill((bleConnection.isConnected ? Color.orange : Color.red)).opacity(0.6))
                        .font(.system(size: 20))
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)

                
                Spacer()
                
            }
            .navigationBarHidden(true)
            .environmentObject(meetingModel)
            .navigationBarBackButtonHidden(true)
            .tabViewStyle(.page)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear(
                perform: {
// could do something here
                }
            )

        // This modifier ensures the updating of the view every time
        // that new data is available from the BLE peripheral
            .onChange(
                of: bleConnection.BleStr)                 {newValue in
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

  /*                  Circle()
                        .stroke(Color.gray)
                        .frame(width: 2 * kShareCircleRadius, height: 2 * kShareCircleRadius)
                        .position(x:kOriginX,
                                  y:kOriginY )
    */
                    Circle()
                        .stroke(Color.white)
                        .frame(width: kShareCircleRadius * 1.5, height:  kShareCircleRadius * 1.5 )
                        .position(x:kOriginX,
                                  y:kOriginY )
                    
/*                    Circle()
                        .stroke(Color.gray)
                        .frame(width: kShareCircleRadius * 2.5, height:  kShareCircleRadius * 2.5)
                        .position(x:kOriginX,
                                  y:kOriginY )
  */
                    VStack {
                        Text("Duration")
                            .font(.system(size: 20))
                            .foregroundColor( Color.white                 )
                        
                        Text(String(meetingModel.elapsedTimeMins) + " mins").foregroundColor(Color.white)
                            .font(.system(size: 32))
                    }
                    
                    Blob(input_points: meetingModel.participant)
        //                .foregroundColor(Color(.darkGray))
                        .fill(Color.gray)
//                        .stroke(Color.white, lineWidth: 2)
                        .opacity(0.4)
                      //  .blur(radius: 15, opaque: false)
                        .frame(width: kShareRadius, height:kShareRadius, alignment: .center)



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

/*                Circle()
                    .stroke(Color.gray)
                    .frame(width: 2 * kShareCircleRadius, height: 2 * kShareCircleRadius)
                    .position(x:kOriginX,
                              y:kOriginY )
  */
                Circle()
                    .stroke(Color.white)
                    .frame(width: kShareCircleRadius * 1.5, height:  kShareCircleRadius * 1.5 )
                    .position(x:kOriginX,
                              y:kOriginY )
                
/*                Circle()
                    .stroke(Color.gray)
                    .frame(width: kShareCircleRadius * 2.5, height:  kShareCircleRadius * 2.5)
                    .position(x:kOriginX,
                              y:kOriginY )
*/
                VStack {
                    Text("Duration")
                        .font(.system(size: 20))
                        .foregroundColor( Color.white                 )
                    
                    Text(String(meetingModel.elapsedTimeMins) + " mins").foregroundColor(Color.white)
                        .font(.system(size: 32))
                }
                
                ForEach (meetingModel.participant)
                {person in
                    Circle()
                        .fill(Color.gray)
                        .opacity(0.5)
                        .frame(width: kCircleWidth * 2 * CGFloat(person.voiceShareDeviation), height: kCircleWidth * 2 * CGFloat(person.voiceShareDeviation))
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
                        

                        VStack {
                            Text("Current Turn")
                                .font(.system(size: 20))
                                .foregroundColor( Color.white                 )
                            
                            Text(String(meetingModel.currentTurnLength) + " s")
                                .font(.system(size: 28))
                                .foregroundColor( Color.white                 )
                        }
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

            Text("Turn History")
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
                    .background(RoundedRectangle(cornerRadius: 12   ).fill(Color.orange).opacity(0.75))
                    .font(.system(size: 24))
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
            Spacer()
            
            
        }
    }
    

struct Spline_data {
    var point:CGPoint
    var cp1:CGPoint
    var cp2:CGPoint}

    
struct Blob: Shape {

    var calc_points:[Spline_data] = []

    init(input_points:[Participant])
    {
        var angleCp1:Double
        var angleCp2:Double
        var radiusCp1:Double
        var radiusCp2:Double

        var nextPoint:CGPoint
        var nextCp1:CGPoint
        var nextCp2:CGPoint
        
        let LastPoint = input_points.count-1
        let inputPointsSorted = input_points.sorted(by: { $0.angle > $1.angle })
        
        for i in 0...LastPoint
        {
            // point
            let angle = inputPointsSorted[i].angleRad
            let radius = CGFloat(inputPointsSorted[i].voiceShareDeviation) * kShareCircleRadius
            
            let previousAngle =
            (i != 0 ?
             inputPointsSorted[i-1].angleRad
             :
                inputPointsSorted[LastPoint].angleRad
            )

            let previousRadius =
            (i != 0 ?
             CGFloat(inputPointsSorted[i-1].voiceShareDeviation) * kShareCircleRadius             :
                CGFloat(inputPointsSorted[LastPoint].voiceShareDeviation) * kShareCircleRadius            )

            let angleMid = abs(angle - previousAngle) / 1.5 > 0.4 ?
            0.4 : abs(angle - previousAngle) / 1.5
            
            nextPoint = CGPoint(
                x : CGFloat (radius * cos(angle)),
                y : CGFloat (radius * sin(angle))
            )
            
            // cp1
            angleCp1 = previousAngle - angleMid
            radiusCp1 = previousRadius / cos (angleMid)
            
            nextCp1 = CGPoint (
                x: CGFloat(radiusCp1 * cos(angleCp1)),
                y:   CGFloat(radiusCp1 * sin(angleCp1)))
            
            
            // cp2
            radiusCp2 =
            CGFloat(inputPointsSorted[i].voiceShareDeviation) * kShareCircleRadius
            / cos(angleMid)

            angleCp2 = angle + angleMid
            
            nextCp2 = CGPoint (
            x :CGFloat (radiusCp2 * cos(angleCp2)),
        y: CGFloat (radiusCp2 * sin(angleCp2)))
                        
            self.calc_points.append(Spline_data(point: nextPoint, cp1: nextCp1, cp2: nextCp2))
        }
    }
    
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        
        path.move (to: calc_points[calc_points.count-1].point)

        for curve in calc_points {
            path.addCurve (to: curve.point, control1: curve.cp1, control2: curve.cp2)
        }
        
        return path.offsetBy(dx: rect.midX, dy: rect.midY)
    }
        
}


