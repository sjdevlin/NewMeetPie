//
//  BLEManager.swift
//  NewMeetPie
//
//  Created by Stephen Devlin on 08/12/2022.
//

import Foundation
import CoreBluetooth

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate,CBPeripheralDelegate {
    
    var myPeripheral: CBPeripheral!
    var myCentral: CBCentralManager!
    
    @Published var isConnected = false
    @Published var BleStr:String = ""
    
    override init() {
            super.init()
            myCentral = CBCentralManager(delegate: self, queue: nil)
            myCentral.delegate = self
        }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
           }
           else {
               print("Something wrong with BLE")
           }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        peripheral.discoverServices([K.MeetPieCBUUID])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.properties.contains(.notify) {
                print("\(characteristic.uuid): has notify")
                peripheral.setNotifyValue(true, for: characteristic)
                self.isConnected = true

            }
        }
    }
        
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
       
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
                       print (name)
                       if name == K.BTServiceName {
                           central.stopScan()
                           self.myPeripheral = peripheral
                           self.myPeripheral.delegate = self
                           central.connect(peripheral, options: nil)
                       }
                   }

        }
       
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        switch characteristic.uuid {
        case K.MeetPieDataCBUUID:

            BleStr = String(decoding: characteristic.value!, as: UTF8.self)
            print (BleStr)

            
            default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }

    }
    
    
    
    
    
    
    
    
}

