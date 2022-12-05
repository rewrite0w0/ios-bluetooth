//
//  Bluetooth.swift
//  app
//
//  Created by Sergey Romanenko on 26.10.2020.
//
//  Modified by rewrite0w0

import CoreBluetooth

protocol BluetoothProtocol {
    func state(state: Bluetooth.State)
    func list(list: [Bluetooth.Device])
    func value(data: Data)
    func rssi(value: Int)
}
// object-c 관련 기능인데 일단 넘어가자 뭔 소리인지 모르겠음 문서봐도
final class Bluetooth: NSObject {
    static let shared = Bluetooth()
    var delegate: BluetoothProtocol?
    
    var peripherals = [Device]()
    var current: CBPeripheral?
    var state: State = .unknown { didSet { delegate?.state(state: state) } }
    
    private var manager: CBCentralManager?
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?
    private var notifyCharacteristic: CBCharacteristic?
    private var timer: Timer?
    
    private override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: .none)
        manager?.delegate = self
//        print(manager)
    }
    
    func connect(_ peripheral: CBPeripheral) {
        print(peripheral)
        if current != nil {
            guard let current = current else { return }
            manager?.cancelPeripheralConnection(current)
            manager?.connect(peripheral, options: nil)
            
        } else { manager?.connect(peripheral, options: nil) }
    }
    
    func disconnect() {
        guard let current = current else { return }
        manager?.cancelPeripheralConnection(current)
    }
    
    func startScanning() {
        peripherals.removeAll()
        manager?.scanForPeripherals(withServices: nil, options: nil)
    }
    func stopScanning() {
        peripherals.removeAll()
        manager?.stopScan()
    }
    
    func send(_ value: [UInt8]) {
//        print("Read")
//        print(readCharacteristic)
//        print("noti")
//        print(notifyCharacteristic)
//        print("write")
//        print(writeCharacteristic)
//        print("qwer")
//        print(qwer)
        
    // 여기부터 문제임
        // hex 보내기
        // uuid 수동 입력하기
//        print("qweqwe)")
        guard let characteristic = writeCharacteristic else { return }

        print("i'm send")
//        if(characteristic.isNotifying){print("ok")} else {print("gg")}
        print(characteristic)
        current?.writeValue(Data(value), for: characteristic, type: .withResponse)
        print(value)
        
        print("send off fy")
    }
    
    enum State { case unknown, resetting, unsupported, unauthorized, poweredOff, poweredOn, error, connected, disconnected }
    
    struct Device: Identifiable {
        let id: Int
        let rssi: Int
        let uuid: String
        let peripheral: CBPeripheral
    }
}

extension Bluetooth: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch manager?.state {
        case .unknown: state = .unknown
        case .resetting: state = .resetting
        case .unsupported: state = .unsupported
        case .unauthorized: state = .unauthorized
        case .poweredOff: state = .poweredOff
        case .poweredOn: state = .poweredOn
        default: state = .error
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let uuid = String(describing: peripheral.identifier)
        let filtered = peripherals.filter{$0.uuid == uuid}
        if filtered.count == 0{
            guard let _ = peripheral.name else { return }
            let new = Device(id: peripherals.count, rssi: RSSI.intValue, uuid: uuid, peripheral: peripheral)
            peripherals.append(new)
            delegate?.list(list: peripherals)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) { print(error!) }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        current = nil
        state = .disconnected
        timer?.invalidate()
//        print(timer)
    }
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        current = peripheral
        state = .connected
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        timer = .scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            peripheral.readRSSI()
        }
    }
}

extension Bluetooth: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
   
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        
        
//        print(peripheral)
        
//        print("@@@@@@@@@@@@@@@@@@")
//        let uuid = service.characteristics
//        print(uuid)
        
//        print(service.uuid.uuidString)
        guard let characteristics = service.characteristics else { return }

//        print("yo")
        
//        print(type(of:characteristics)) 배열인거 ㅇㅋ
//        print(characteristics.count) 길이 4개 ㅇㅋ ff01 02 03 04
        
//        print(characteristics)
//        print(characteristics)
        
        
        
        for characteristic in characteristics  {
//            print(characteristic.uuid.uuidString)

            
            if characteristic.uuid.uuidString == "FF01" {
                notifyCharacteristic = characteristic

                peripheral.setNotifyValue(true, for: characteristic)
            }
            
            if characteristic.uuid.uuidString == "FF02" {
                print(characteristic.uuid.uuidString)
                writeCharacteristic = characteristic
                
            }

        }
        
        
//            for characteristic in characteristics  {
//
//                switch characteristic.properties {
//
//                case .read:
//
//                    readCharacteristic = characteristic
//                    peripheral.readValue(for: characteristic)
//                    print(readCharacteristic)
//
//                case .write:
//                    writeCharacteristic = characteristic
//
//                case .notify:
//                    notifyCharacteristic = characteristic
//
//                    peripheral.setNotifyValue(true, for: characteristic)
//                case .indicate: break //print("indicate")
//                case .broadcast: break //print("broadcast")
//
//                default: break
//            }
//        }
        
    }
    
    // peripheral으로 전송(쓰기
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(characteristic)
//                      peripheral.writeValue(data, for: characteristic)

        print("characteristic.uuid.uuidString:- \(characteristic.uuid.uuidString)")
        if let error = error{
            print("error :< \(error)")
            return
        }
        else{
            print("@@@@@@@@@@@@@@@@@@")
            print(characteristic)
        }
        

    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print(peripheral)

        }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
        if(characteristic.isNotifying){
            print("get set ready notify")
//            print(characteristic.isNotifying)
            
        } else {
            peripheral.setNotifyValue(true, for: characteristic)
            print(characteristic.isNotifying)

}
    }
    
    
    // 센트럴로 데이터 전송(읽기
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        peripheral.readValue(for: characteristic)

        guard let value = characteristic.value else { return print("메롱 ;<") }
        delegate?.value(data: value)
//        print(value)

    }
    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
//        <#code#>
//    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        delegate?.rssi(value: Int(truncating: RSSI))
    }
}
