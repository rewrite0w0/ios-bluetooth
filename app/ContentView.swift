//
//  ContentView.swift
//  app
//
//  Created by Sergey Romanenko on 26.10.2020.
//
//  Modified by rewrite0w0

import SwiftUI

// swiftui 사용 선언


// 클래스가 하나의 파일이듯 struct도 하나의 파일로 뽑아 쓸 수 있다.
// 클래스는 객체지향스럽게 쓰고, struct는 함수형처럼 쓸 수 있다.

struct ContentView: View {
    
    // Bluetooth.swift 끌어다 쓴다. 따로 import는 없다.
    var bluetooth = Bluetooth.shared
    
    // 변경가능한 State
    // 변경가능하려면 불변이 아닌 var를 사용해야 한다.
    @State var presented: Bool = false
    @State var list = [Bluetooth.Device]()
    @State var isConnected: Bool = Bluetooth.shared.current != nil { didSet { if isConnected { presented.toggle() } } }
    
    @State var response = Data()
    @State var rssi: Int = 0
    @State var string: String = ""
    @State var value: Float = 0
    @State var state: Bool = false { didSet { bluetooth.send([UInt8(state.int)]) } }
    
    @State var editing = false
    
    
 // 보여지는 부분이다.
 // react로 치면 function SomePage{ return (이부분이다.)}
    
    var body: some View {
        VStack{
            HStack{
                Button("scan"){ presented.toggle() }.buttonStyle(appButton()).padding()
                Spacer()
                if isConnected {
                    Button("disconnect"){ bluetooth.disconnect() }.buttonStyle(appButton()).padding()
                }
            
            }
            if isConnected {
//                Slider(value: Binding( get: { value }, set: {(newValue) in sendValue(newValue) } ), in: 0...100).padding(.horizontal)
//                Button("toggle"){ state.toggle() }.buttonStyle(appButton())
//                TextField("how to string convert byte", text: $string, onEditingChanged: { editing = $0 })
//                    .onChange(of: string){ bluetooth.send(Array($0.utf8)) }
//                    .textFieldStyle(appTextField(focused: $editing))
                Text("returned byte value from \(bluetooth.current?.name ?? ""): \(response)")
//                Button("how to on notify"){bluetooth.peripherals}
                Button("MAC"){bluetooth.send(Array("FF0770AABBCCDDEEFFFE".utf8))}
                Spacer()
//                Button("Print"){print(Array("FF0770AAAAAAAAAAAAFE".utf8))}
                Text("returned string: \(String(data: response, encoding: .utf8) ?? "")")
//                Button("qweqwe"){print(bluetooth.send)}
                Text("rssi: \(rssi)")
                
//                Button("NOTIFY"){bluetooth.peripheral(, didUpdateNotificationStateFor: , error: print("notify error"))}
            }
            Spacer()
        }.sheet(isPresented: $presented){ ScanView(bluetooth: bluetooth, presented: $presented, list: $list, isConnected: $isConnected) }
            .onAppear{ bluetooth.delegate = self }
    }
    
    func sendValue(_ value: Float) {
        if Int(value) != Int(self.value) {
            guard let sendValue = map(Int(value), of: 0...100, to: 0...255) else { return }
            bluetooth.send([UInt8(state.int), UInt8(sendValue)])
        }
        self.value = value
    }
    
    func map(_ value: Int, of: ClosedRange<Int>, to: ClosedRange<Int>) -> Int? {
        guard let ofmin = of.min(), let ofmax = of.max(), let tomin = to.min(), let tomax = to.max() else { return nil }
        return Int(tomin + (tomax - tomin) * (value - ofmin) / (ofmax - ofmin))
    }
}

extension ContentView: BluetoothProtocol {
    // 접속 상태에 대한 부분이다.
    // 그럼 기능은 어떻게 사용할 수 있지?
    // 서비스는 어디서 어떻게 볼 수 있지?
    // 문서로는 알지만 눈으로 직접 보고 싶다만
    func state(state: Bluetooth.State) {
        switch state {
        case .unknown: print("◦ .unknown")
        case .resetting: print("◦ .resetting")
        case .unsupported: print("◦ .unsupported")
        case .unauthorized: print("◦ bluetooth disabled, enable it in settings")
        case .poweredOff: print("◦ turn on bluetooth")
        case .poweredOn: print("◦ everything is ok")
        case .error: print("• error")
        case .connected:
            print("◦ connected to \(bluetooth.current?.name ?? "")")
//            print("bluetooth is \(bluetooth)")
//            print(bluetooth)
           
            isConnected = true
        case .disconnected:
            print("◦ disconnected")
            isConnected = false
        }
    }
    
    func list(list: [Bluetooth.Device]) { self.list = list }
    
    func value(data: Data) { response = data; print(response) }
    
    func rssi(value: Int) { rssi = value;  }
}
