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
        VStack {
            Text ("Meeting Summary")
            Spacer()
            Text ("Duration: \(meetingModel.elapsedTimeMins) Mins")                .font(.system(size:24))

            Spacer()
            Text ("Number of People: \(meetingModel.numberOfParticipants)")
                .font(.system(size:24))
            Spacer()
            
//            Text ("Temp \(viewModel.path.count)")
            Text ("Turn History:")
            PieChartView(meeting: meetingModel)
                .frame(width:kRectangleWidth*0.8, height:kRectangleWidth*0.8)
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
                .padding(.top, 20)
        }.navigationBarBackButtonHidden()
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
