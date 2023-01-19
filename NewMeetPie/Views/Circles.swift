//
//  SplineView.swift
//  NewMeetPie
//
//  Created by Stephen Devlin on 28/12/2022.
//

import SwiftUI

struct Circle_coord :Identifiable{
    var id:UUID
    var angle:Double
    var radius:Double
    var point = CGPoint(x:0,y:0)
    
    init(angle:Double, radius:Double)
    {
        let centrex = 0.0
        let centrey = 0.0

        self.id = UUID()
        self.angle = angle
        self.radius = radius
        let x = (centrex + (150.0) * cos(angle)) + radius
        let y = (centrey + (150.0) * sin(angle)) + radius
        self.point = CGPoint(x:x,y:y)
    }
    
}

struct CircleView: View {
    var circle_coord = [
        Circle_coord(angle: 1.5,radius: 30),
        Circle_coord(angle: 3,radius: 50),
        Circle_coord(angle: 4.5,radius: 40),
        Circle_coord(angle: 5.2,radius: 80),
        Circle_coord(angle: 6,radius: 50)]

    var body: some View {

        ZStack{
            Circle().stroke(lineWidth: 3)
                .frame(width:300, height: 300)
            Circle().stroke(lineWidth: 3)
                .frame(width:150, height: 150)
            Circle().foregroundColor(Color.black)
                .frame(width:10, height: 10)
            
            ForEach(circle_coord) { circle_coord in
                Circle().foregroundColor(Color.green)
                    .position(circle_coord.point)
                    .frame(width: circle_coord.radius*2, height: circle_coord.radius*2)
                .opacity(0.75)}

            ForEach(circle_coord) { circle_coord in
                Circle().foregroundColor(Color.yellow)
                    .position(circle_coord.point)
                    .frame(width: 40, height: 40)
                .opacity(0.75)}

            ForEach(circle_coord) { circle_coord in
                Circle().foregroundColor(Color.yellow)
                    .position(circle_coord.point)
                    .frame(width: 40, height: 40)
                .opacity(0.75)}

            ForEach(circle_coord) { circle_coord in
                    Circle().foregroundColor(Color.gray)
                        .position(circle_coord.point)
                        .frame(width: 20, height: 20)
                    .opacity(0.75)}

            
            }
        }
    }


struct CircleView_Previews: PreviewProvider {
    static var previews: some View {
        CircleView()
    }
}
