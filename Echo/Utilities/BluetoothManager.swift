//
//  BluetoothManager.swift
//  Echo
//
//  Created by Rohini on 06/03/20.
//  Copyright © 2020 Rohini. All rights reserved.
//

import UIKit
import CoreBluetooth

let advertisedDeviceName = "\"ECHO: \(UIDevice.current.name)\""


protocol BluetoothManagerDelegate: class {
    func fetchHeartRate(hearRate: UInt8)
}

class BluetoothManager: NSObject, CBPeripheralManagerDelegate
{
    
    var peripheralManager: CBPeripheralManager!
    
    static let sharedInstance = BluetoothManager()
    
    fileprivate let heartRateCharacteristicUUID = CBUUID(string: "0x2A37")
    fileprivate let heartRateServiceUUID = CBUUID(string: "0x180D")
    fileprivate let heartRateSensorLocationCharacteristicUUID = CBUUID(string: "0x2A38")
    
    fileprivate var heartRate: UInt8 = 0
    var timer: Timer?
    var heartRateCharacteristic: CBMutableCharacteristic!
    var heartRateService: CBMutableService!
    
    
    weak var delegate: BluetoothManagerDelegate?
    override init() {
        super.init()
    }
    
    func startBLE()
    {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    
    func addHeartRateService()
    {
        self.heartRateCharacteristic = CBMutableCharacteristic(type: heartRateCharacteristicUUID, properties: [.notify, .read, .write], value: nil, permissions: [.readable, .writeable])
        self.heartRateService = CBMutableService(type: heartRateServiceUUID, primary: true)
        var sensorLocation = 2
        let heartRateSensorLocationCharacteristic = CBMutableCharacteristic(type: heartRateSensorLocationCharacteristicUUID, properties: .read,
                                                                            value: Data(bytes: &sensorLocation, count: MemoryLayout.size(ofValue: sensorLocation)), permissions: .readable)
        
        heartRateService.characteristics = [heartRateCharacteristic, heartRateSensorLocationCharacteristic]
        peripheralManager.add(heartRateService)
    }
    
    
    func startHeartRateSensor() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let weakSelf = self else {
                return
            }
            
            var heartRate = UInt8(arc4random_uniform(60) + 60) // 60bpm ~ 120bpm
            
            weakSelf.delegate?.fetchHeartRate(hearRate: heartRate)
            var heartRateData = Data()
            heartRateData.append(0)
            
            heartRateData.append(Data(bytes: &heartRate,
                                      count: MemoryLayout.size(ofValue: heartRate)))
            
            _ = weakSelf.peripheralManager.updateValue(
                heartRateData,
                for: weakSelf.heartRateCharacteristic,
                onSubscribedCentrals: nil)
            
            DispatchQueue.main.async {
                weakSelf.heartRate = heartRate
                
            }
        }
    }
    
    func isAdvertising() -> Bool
    {
        return peripheralManager.isAdvertising
    }
    
    func startAdvertising()
    {
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: advertisedDeviceName, CBAdvertisementDataServiceUUIDsKey: [CBUUID(string: "180D")]] as [String : Any])
    }
    
    func stopAdvertising()
    {
        peripheralManager.stopAdvertising()
    }
    
    
    func cleanUpPeripheral()
    {
        peripheralManager.removeAllServices()
    }
    
    //MARK: - CBPeripheralManagerDelegate
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        NotificationCenter.default.post(name: .didUpdatePeripheralState, object: peripheral.state)
        switch peripheral.state {
        case .poweredOn:
            print("BLE is poweredOn")
            addHeartRateService()
            
        case .unknown:
            print("BLE is unknown")
            
        case .resetting:
            print("BLE is resetting")
            
        case .unsupported:
            print("BLE is unsupported")
            
        case .unauthorized:
            print("BLE is unauthorized")
            
        case .poweredOff:
            print("BLE is poweredOff")
            
        @unknown default:
            print("BLE is @unknown default")
            
        }
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        //add new service
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        guard let error = error else {
            startAdvertising()
            print("Added heart rate service")
            return
        }
        print("Error in adding service: \(error.localizedDescription)")
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        guard let error = error else {
            
            return
        }
        print("Error in advertising: \(error.localizedDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        stopAdvertising()
        NotificationCenter.default.post(name: .didSomeoneSubscribe, object: true)
        
        print("Yes! Someone subscribed to BLE! with service: \(characteristic.service)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        startAdvertising()
        NotificationCenter.default.post(name: .didSomeoneSubscribe, object: false)
        
        print("No device connected")
    }
    
}


extension Notification.Name{
    static let didUpdatePeripheralState = Notification.Name("didUpdatePeripheralState")
    static let isWatchAppInstalled = Notification.Name("isWatchAppInstalled")
    static let didSomeoneSubscribe = Notification.Name("didSomeoneSubscribe")
    static let isWatchAppPaired = Notification.Name("isWatchAppPaired")
    
}
