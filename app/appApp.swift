//
//  appApp.swift
//  app
//
//  Created by Sergey Romanenko on 26.10.2020.
//
//  Modified by rewrite0w0

// 애플리케이션의 시작점
// @main

import SwiftUI

@main
struct appApp: App {
    var body: some Scene {
        // swift ui 관련 무엇 같은데 이게 뭔지 모르겠음
        WindowGroup{
            // ContentView로 이동 ㅇㅇ
            ContentView()
        }
    }
}


// .module.css 같이 글로벌 스타일인듯?

struct appButton: ButtonStyle {
    let color: Color
    
    public init(color: Color = .accentColor) {
        self.color = color
    }
    
    
    // 일일히 다 넣어줘야함?
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundColor(.accentColor)
            .background(Color.accentColor.opacity(0.4))
            .cornerRadius(8)
    }
}


struct appTextField: TextFieldStyle {
    @Binding var focused: Bool
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 50, style: .continuous)
                    .stroke(focused ? Color.accentColor : Color.accentColor.opacity(0.2), lineWidth: 2)
            ).padding()
    }
}
