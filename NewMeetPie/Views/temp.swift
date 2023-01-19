//
//  temp.swift
//  NewMeetPie
//
//  Created by Stephen Devlin on 28/12/2022.
//

import SwiftUI

struct temp: View {
    var body: some View {

        ZStack
        {
            Rectangle().frame(width:100, height:100)
                .position(x:0,y:0)
            
            Rectangle().frame(width:100, height:100)
                .foregroundColor(Color.red)
                .position(x:200,y:200)

            Circle().frame(width:100, height:100)
                .foregroundColor(Color.green)
                .position(x:0,y:0)

        }.background(Color.gray)
    }
}

struct temp_Previews: PreviewProvider {
    static var previews: some View {
        temp()
    }
}
