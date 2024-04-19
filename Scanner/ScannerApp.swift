//
//  ScannerApp.swift
//  Scanner
//
//  Created by willaim santos on 16/04/24.
//

import SwiftUI

@main
struct ScannerApp: App {
    
    @StateObject private var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(vm)
                .task {
                    await vm.requestDataScannerAccessStatus()
                }
        }
    }
}
