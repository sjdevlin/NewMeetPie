//
//  SplineView.swift
//  NewMeetPie
//
//  Created by Stephen Devlin on 28/12/2022.
//

import SwiftUI


typealias Curve = (p: CGPoint, cp1: CGPoint, cp2: CGPoint)





struct Radar:Shape
{
    struct Energy_coord {
        var angle:Double
        var radius:Double
    }

    func path(in rect:CGRect) -> Path {

        let energy_coord = [
            Energy_coord(angle: 1.5,radius: 130),
            Energy_coord(angle: 3,radius: 150),
            Energy_coord(angle: 4.5,radius: 180),
            Energy_coord(angle: 5.2,radius: 120),
            Energy_coord(angle: 6,radius: 150)
        ]

        let centrex = 150.0
        let centrey = 150.0
        var startp = CGPoint(x:0, y:0)
        var lastangle = 0.1
        var lastradius = 0.1

        var path = Path()
        var blob = [Curve]()

        var firstElement:Bool = true

        for coord in energy_coord {
            let x = centrex + coord.radius * cos(coord.angle)
            let y = centrey + coord.radius * sin(coord.angle)
            let point = CGPoint(x:x,y:y)

            
            if firstElement {
                startp = point
                path.move(to: startp)
                firstElement = false
                lastangle = coord.angle
                lastradius = coord.radius
            }
            else
            {
                let x2 = centrex + ((lastradius + coord.radius)/2)  * 0.75 * cos((lastangle+coord.angle)/2)
                let y2 = centrey + ((lastradius + coord.radius)/2) * 0.75 * sin((lastangle+coord.angle)/2)
                let point2 = CGPoint(x:x2,y:y2)
                lastangle = coord.angle
                lastradius = coord.radius

                blob.append(Curve(point2, point2, point2))
                blob.append(Curve(point, point, point))
            }
        }


        for curve in blob {
            path.addCurve(to: curve.p, control1: curve.cp1, control2: curve.cp2)
        }
        
        path.addCurve(to: startp, control1: startp, control2: startp)

        return path
    }
    
}



struct SplineView: View {

    
    var body: some View {

        ZStack{
            Circle().foregroundColor(Color.red)
                .frame(width:300, height: 300)
            Circle().foregroundColor(Color.white)
                .frame(width:150, height: 150)
            Circle().foregroundColor(Color.black)
                .frame(width:10, height: 10)
            Radar().stroke(Color.black, lineWidth: 2)
                .frame(width:300, height: 300)
            
        }
    }
}

struct SplineView_Previews: PreviewProvider {
    static var previews: some View {
        SplineView()
    }
}
