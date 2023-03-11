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
    @EnvironmentObject var appState:AppState
    
    var body: some View {
        ScrollView {
            VStack {
                Text ("Meeting Summary")
                    .font(.system(size:24))
                    .frame(height: 50)
                
                Text ("\(meetingModel.elapsedTimeMins) Mins")                .font(.system(size:28))
                    .frame(height: 45)
                Text ("\(meetingModel.numberOfParticipants) Participants")
                    .font(.system(size:24))
                
                TurnShareView(meetingModel: meetingModel, limits: limits)
                    .frame(height:kRectangleWidth * 0.85)

                PieChartView(meeting: meetingModel)
                    .frame(width:kRectangleWidth*0.75, height:kRectangleWidth)

                TurnHistoryView(meetingModel: meetingModel, limits: limits)

                
                Spacer()
                Button("Done", action: {appState.rootViewId = UUID()})
                    .font(.system(size:24))
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                    .foregroundColor(.white)
                    .background(Color(.orange))
                    .clipShape(Capsule())
                    .padding(.top, 40)
            }.navigationBarBackButtonHidden()
        }
    }
}


struct TurnShareView: View {
    let meetingModel: MeetingModel
    let limits: MeetingLimits

    var body: some View {
    
        VStack{
            ZStack{

                Circle()
                    .stroke(Color.white)
                    .frame(width: kShareCircleRadius, height:  kShareCircleRadius)
                    .position(x:kOriginX,
                              y:kOriginY - 50)
                
            ForEach (meetingModel.participant)
                {person in
                    Circle()
                        .fill(person.color)
                        .frame(width: kCircleWidth * 0.7, height: kCircleWidth * 0.7 )
                        .position(x:kOriginX + (cos(person.angleRad) * kShareCircleRadius * 0.7),
                                  y:kOriginY + (sin(person.angleRad) * kShareCircleRadius * 0.7) - 50)
                }
            }
        }
    }
    
}


struct TurnHistoryView: View {
    let meetingModel: MeetingModel
    let limits: MeetingLimits

    var body: some View {
        
        VStack{
            
            Text("Turn History")
                .frame(height: 45)

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
            
            Text("Average Turn Duration: \(meetingModel.totalTalkTimeSecs / meetingModel.history.count ) s")
            
        }

    }
}


struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        
        SummaryView(meetingModel: MeetingModel.example, limits: MeetingLimits.example)
            .preferredColorScheme(.dark)

        PieChartView(meeting: MeetingModel.example)
            .preferredColorScheme(.dark)
            .frame(width: 300, height: 300)

    }
}

struct PieChartView: View {
    public let meeting: MeetingModel
    
    var slices: [PieSliceData] {
        let sum = meeting.totalTalkTimeSecs
        var endDeg: Double = 90
        var tempSlices: [PieSliceData] = []
                
        for person in meeting.participant {
            let degrees: Double = Double(person.totalTalkTimeSecs * 360 / sum)
            tempSlices.append(PieSliceData(startAngle: Angle(degrees: endDeg), endAngle: Angle(degrees: endDeg + degrees), text: String(format: "%d%%", (person.totalTalkTimeSecs * 100) / sum), color: person.color))
            endDeg += degrees
        }
        return tempSlices
    }


    var body: some View {
        GeometryReader { geometry in
            VStack{
                Text("Share of voice")
                    .frame(height: 45)


                ZStack{
                    ForEach(0..<meeting.participant.count){ i in
                        PieSliceView(pieSliceData: self.slices[i])
                    }
                    .frame(width: geometry.size.width, height: geometry.size.width)
                    
                    Circle()
                        .fill(.black)
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                    
                    VStack {
                        Text("Total")
                            .font(.title)
                            .foregroundColor(Color.gray)
                        Text(String(meeting.totalTalkTimeSecs))
                            .font(.title)
                    }
                }
            }
            .background(.black)
            .foregroundColor(Color.white)
        }
    }
}



struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var text: String
    var color: Color
}


struct PieSliceView: View {
    var pieSliceData: PieSliceData
    var midRadians: Double {
        return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Path { path in
                    let width: CGFloat = min(geometry.size.width, geometry.size.height)
                    let height = width
                    
                    let center = CGPoint(x: width * 0.5, y: height * 0.5)
                    
                    path.move(to: center)
                    
                    path.addArc(
                        center: center,
                        radius: width * 0.5,
                        startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                        endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                        clockwise: false)
                    
                }
                .fill(pieSliceData.color)
                
                Text(pieSliceData.text)
                    .position(
                        x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(self.midRadians)),
                        y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(self.midRadians))
                    )
                    .foregroundColor(Color.black)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
