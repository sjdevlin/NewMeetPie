//
//  MeetingDetail.swift
//  Profiles
//
//  Created by Stephen Devlin on 13/09/2022.
//

import SwiftUI

// this little struct just allows me to use the slider tool with an integer value

struct IntDoubleBinding {
    let intValue : Binding<Int>
    let doubleValue : Binding<Double>
    init(_ intValue : Binding<Int>) {
        self.intValue = intValue
        
        self.doubleValue = Binding<Double>(get: {
            return Double(intValue.wrappedValue)
        }, set: {
            intValue.wrappedValue = Int($0)
        })
    }
}


struct DetailView: View
{
    // This struct is passed from the parent - and can be changed
    // hence binding

    @Binding var limits: MeetingLimits

    // limitsCopy is used to detect if the user has changed any values
    // and allows "prompt to save" logic
    @State private var limitsCopy:MeetingLimits?

    @State var isNew:Bool
    @State var isEditing:Bool
    @State var isChanged:Bool = false
    @State var showingAlert:Bool = false

    
    var body: some View
    {
        GeometryReader { reader in

            VStack
            {

                if isEditing == true
                {
                    TextField("Name:",text:$limits.meetingName)
                        .font(Font.system(size: 28))
                        .frame(alignment: .center)
                        .padding(20)
                }
                else
                {
                    Text(limits.meetingName)
                        .font(Font.system(size: 28))
                        .frame(alignment: .center)
                        .padding(20)
                }
                
                VStack
                {
                    HStack{
                        Text("Duration")
                        Spacer()
                        Text(String(limits.meetingDurationMins))
                        Text(" m")
                    }.font(Font.system(size: 24))
                        .padding([.leading,.trailing],35)
                        .padding(.top, 20)
                    
                    
                    if isEditing == true
                    {
                        Slider(value: IntDoubleBinding($limits.meetingDurationMins).doubleValue, in: 10...90.0, step: 5.0)
                            .padding([.leading,.trailing],35).onChange(of: limits.meetingDurationMins, perform: {_ in isChanged = true})
                    }
                    
                    HStack{
                        Text("Max. Share")
                        Spacer()
                        Text(String(limits.maxShareVoice))
                        Text(" %")
                    }
                    .font(Font.system(size: 24))
                    .padding([.leading,.trailing],35)
                    .padding(.top, 20)
                    
                    
                    if isEditing == true
                    {
                        Slider(value: IntDoubleBinding($limits.maxShareVoice).doubleValue, in: 100...150.0, step: 5.0)
                            .padding([.leading,.trailing],35).onChange(of: limits.maxShareVoice, perform: {_ in isChanged = true})
                    }
                    

                    HStack{
                        Text("Min. Share")
                        Spacer()
                        Text(String(limits.minShareVoice))
                        Text(" %")
                    }
                    .font(Font.system(size: 24))
                    .padding([.leading,.trailing],35)
                    .padding(.top, 20)
                    
                    
                    if isEditing == true
                    {
                        Slider(value: IntDoubleBinding($limits.minShareVoice).doubleValue, in: 10...80.0, step: 5.0)
                            .padding([.leading,.trailing],35).onChange(of: limits.minShareVoice, perform: {_ in isChanged = true})
                    }

                    
                    
                    
                    HStack{
                        Text("Max. Turn Length")
                        Spacer()
                        Text(limits.maxTurnLengthSecs == 180 ? "Off" : String(limits.maxTurnLengthSecs))
                        Text(" s")
                    }
                    .font(Font.system(size: 24))
                    .padding([.leading,.trailing],35)
                    .padding(.top, 20)

                    
                    
                    
                    
                    if isEditing == true
                    {
                        Slider(value: IntDoubleBinding($limits.maxTurnLengthSecs).doubleValue, in: 30...180.0, step: 15.0)
                            .padding([.leading,.trailing],30).onChange(of: limits.maxTurnLengthSecs, perform: {_ in isChanged = true})
                    }
                    
                    Toggle("Always Visible",
                           isOn: $limits.alwaysVisible).disabled(!self.isEditing)
                        .onChange(of: limits.alwaysVisible, perform: {_ in isChanged = true})
                        .listRowBackground(Color.cyan)
                        .font(Font.system(size: 24))
                        .padding([.leading,.trailing],35)
                        .padding([.top, .bottom], 20)
                    
                    
                }.background(RoundedRectangle(cornerRadius: 16, style: RoundedCornerStyle.continuous).fill(Color(.systemGray6))
                    .padding([.leading,.trailing],20)

                )
                
                Spacer()
                
                // the destination screen is really just a poster
                // shown for 3 or 4 seconds.
                
                // limits need to be sent through this screen as they
                // are required by the monitoring screen
                
                NavigationLink(destination: LayFlat(limits: limits))
                {
                    Text ("Start").font(.system(size: 28).bold())
                        .foregroundColor(Color.white)
                        .frame(minWidth: 200, minHeight: 60)

                }
                .navigationBarBackButtonHidden(true)
                .background(RoundedRectangle(cornerRadius: 12   ).fill(Color.red))
                .opacity(isEditing ? 0.0 : 100.0) // only shown when not editing !
                .padding()
    
            }
            
        }
        .navigationBarItems(trailing: Button(isEditing ? "Save" : "Edit")
        {
            withAnimation
            {
                if self.isEditing == true
                {
                    updateMeetingLimits(updatedMeetingLimits: limits)
                    self.isEditing = false
                } else
                {
                    self.isEditing = true
                }
                
            }
        })
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarBackButtonHidden(isEditing ? true :  false)
        .navigationBarItems(leading: Button(isEditing ? "Cancel" : "")
        {
            withAnimation
            {
                showingAlert = isChanged ? true : false
                self.isEditing = isChanged ?  true : false
            }
        }.alert(isPresented:$showingAlert)
            {
                Alert(
                    title: Text("Changes not Saved"),
                    primaryButton: .destructive(Text("Save")) {
                        withAnimation
                        {

                        updateMeetingLimits(updatedMeetingLimits: limits)
                            self.isEditing = false}

                    },
                    secondaryButton: .destructive(Text("Discard")) {
                        withAnimation
                        {
                        limits = limitsCopy!
                        self.isEditing = false
                        }
                    }
                )
        }
        ).onAppear(){self.limitsCopy = limits
        }  // this creates a saved copy for when changes are discarded
        
    }
    
}
