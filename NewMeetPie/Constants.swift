//
//  Constants.swift
//  NewMeetPie
//
//  Created by Stephen Devlin on 13/12/2022.
//

import Foundation
import CoreBluetooth

struct K {
    static let MeetPieCBUUID = CBUUID(string: "00000001-1E3C-FAD4-74E2-97A033F1BFAA")
    static let MeetPieDataCBUUID = CBUUID(string: "00000002-1E3C-FAD4-74E2-97A033F1BFAA")
    static let MeetPieDataNotifyCBUUID = CBUUID(string: "00000003-1E3C-FAD4-74E2-97A033F1BFAA")

    static let BTServiceName = "Gobbledego"

}
