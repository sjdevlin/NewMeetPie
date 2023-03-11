//
//  Sheet.swift
//  Profiles
//
//  Created by Stephen Devlin on 05/10/2022.
//

import SwiftUI
import CoreMotion

struct LayFlat: View {

    let limits:MeetingLimits

    // maybe we dont need environment object below
    @State var readyToMonitor:Bool = false
    
    var body: some View {
        NavigationView
        {
            ZStack(alignment: .center)
            {
                NavigationLink(destination: MonitorView(limits: limits), isActive: $readyToMonitor,
                               label: { EmptyView() }
                ).navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                
                
                VStack{
                    Text ("Place your phone on the desk.\n\n Ensure the dot on the Meetpie\nis pointing towards you ")
                        .position(x:UIScreen.main.bounds.width/2, y:150)
                        .font(.system(size: 22))
                        .frame(width:UIScreen.main.bounds.width)
                        .multilineTextAlignment(.center)
                }
                Image("iphoneline")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height*0.9)
                    .scaledToFit()
                    .onAppear(perform: {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        readyToMonitor = true
                        print ("ready to start monitoring")
                    }
                    })
                
                Spacer()
            }
        }.navigationViewStyle(.stack)
        
    }
}
        
        struct Sheet_Previews: PreviewProvider {
            static var previews: some View {
                LayFlat(limits:MeetingLimits.example)
                    .preferredColorScheme(.dark)
            }
        }


