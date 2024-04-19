//
//  ContentView.swift
//  Scanner
//
//  Created by willaim santos on 16/04/24.
//

import SwiftUI
import VisionKit

typealias TextContentType = [(title: String,textContentType: DataScannerViewController.TextContentType?)]

struct ContentView: View {
    
    @EnvironmentObject var vm: AppViewModel
    
    private let textContentTypes: TextContentType  = [
        ("All", .none),
        ("URL", .URL),
        ("Phone", .telephoneNumber),
        ("Email",.emailAddress),
        ("Address", .fullStreetAddress)
    ]
    
    var body: some View {
        switch vm.dataScannerAccessStatus {
        
        case .scannerAvailable:
            mainView
        case .cameraAccessNotGranted:
            Text("Please provide access to the camera in settings")
        case .cameraNotAvailable:
            Text("Your device doesn't have a camera")
        case .scannerNotAvailable:
            Text("Your device doesn't have support for scanning barcode with this app")
        case .notDetermined:
            Text("Require camera access")
        }
        
    }
    
    private var mainView: some View {
        DataScannerView(recognizedItems: $vm.recognizeItems,
                        recognizedDataType: vm.recognizedDataType,
                        recognizedMultipleItems: vm.recognizesMultipleItems)
        .background { Color.gray.opacity(0.3) }
        .ignoresSafeArea()
        .id(vm.dataScannerViewId)
        .sheet(isPresented: .constant(true), content: {
            bottomContainerView
                .background(.ultraThinMaterial)
                .presentationDetents([.medium, .fraction(0.25)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .onAppear {
                    guard
                        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let controller = windowScene.windows.first?.rootViewController?.presentedViewController else  {
                        return
                    }
                    controller.view.backgroundColor = .clear
                }
        })
        .onChange(of: vm.scanType) { vm.recognizeItems = []}
        .onChange(of: vm.textContentType) {  vm.recognizeItems = []}
        .onChange(of: vm.recognizesMultipleItems) { vm.recognizeItems = [] }
    }
    
    private var headerView: some View {
        
        VStack {
            HStack {
                Picker("Scan type", selection: $vm.scanType) {
                    Text("Barcode").tag(ScannerType.barcode)
                    Text("Text").tag(ScannerType.text)
                }.pickerStyle(.segmented)
                
                Toggle("Scan mutiple", isOn: $vm.recognizesMultipleItems)
            }.padding(.top)
             
            if vm.scanType == .text {
                Picker("Text content type", selection: $vm.textContentType) {
                    ForEach(textContentTypes, id: \.self.textContentType) { option in
                        Text(option.title).tag(option.textContentType)
                    }
                }.pickerStyle(.segmented)
            }
            Text(vm.heardText).padding(.top)
        }.padding(.horizontal)
    }
    
    private var bottomContainerView: some View {
        VStack {
            headerView
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(vm.recognizeItems) { item in
                        switch item {
                        case let .barcode(barcode):
                            Text(barcode.payloadStringValue ?? "Unknown barcode")
                        case let .text(text):
                            Text(text.transcript)
                            
                        @unknown default :
                            Text("Unknown")
                        }
                        
                    }
                }.padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
