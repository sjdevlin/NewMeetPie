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
            VStack(alignment: .center)
            {
                NavigationLink(destination: MonitorView(limits: limits), isActive: $readyToMonitor,
                               label: { EmptyView() }
                ).navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                
                
                
                Spacer()
                Text ("Place your phone on the desk.\n\n Ensure the dot on the Meetpie\nis pointing towards you ")
                    .font(.system(size: 22))
                    .frame(width:300)
                    .multilineTextAlignment(.center)
                Spacer()
                Spacer()
                Image("iphoneline")
                    .resizable()
                    .frame(width: 200, height:200)
                    .scaledToFit()
                    .onAppear(perform: {DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
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
                LayFlat(limits:MeetingLimits.example).preferredColorScheme(.dark)
            }
        }


