//
//  ContentView.swift
//  AirTennis
//
//  Created by 谢增添 on 2025/11/4.
//
//  注意：此文件已被 MainView.swift 替代，保留用于向后兼容

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        MainView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: SwingData.self, inMemory: true)
}
