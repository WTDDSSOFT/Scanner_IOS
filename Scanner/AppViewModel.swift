//
//  AppViewModel.swift
//  Scanner
//
//  Created by willaim santos on 16/04/24.
//
import AVKit
import Foundation
import SwiftUI
import VisionKit

enum ScannerType: String {
    case  barcode, text
}

enum DataScannerAccessStatusType {
    case notDetermined
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

protocol appViewModelProtocols {
    func requestDataScannerAccessStatus() async
}

@MainActor
final class AppViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatusType = . notDetermined
    @Published var recognizeItems: [RecognizedItem] = []
    @Published var scanType: ScannerType = .barcode
    @Published var textContentType: DataScannerViewController.TextContentType?
    @Published var recognizesMultipleItems = true
    
    var recognizedDataType: DataScannerViewController.RecognizedDataType {
        scanType == .barcode ? .barcode() : .text(textContentType: textContentType)
    }
    
    var heardText: String {
        if recognizeItems.isEmpty {
            return "Scanning \(scanType.rawValue)"
        } else  {
            return "Recognized \(recognizeItems.count) item(s)"
        }
    }
    
    var dataScannerViewId: Int {
        
        var hasher = Hasher()
        
        hasher.combine(scanType)
        hasher.combine(recognizesMultipleItems)
        
        if let textContentType {
            hasher.combine(textContentType)
        }
        
        return hasher.finalize()
    }
    
    private var isScannerAvailable: Bool {
        DataScannerViewController.isAvailable && DataScannerViewController.isSupported
    }
    
    
}

extension AppViewModel: appViewModelProtocols {
    
    func requestDataScannerAccessStatus() async {
        
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }

        ///request user authorization
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            
        case .authorized:
            dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = isScannerAvailable ? .scannerAvailable : .scannerNotAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
            
         default: break
        }
    }
    
}
