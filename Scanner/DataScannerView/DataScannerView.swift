//
//  DataScannerView.swift
//  Scanner
//
//  Created by willaim santos on 16/04/24.
//

import Foundation
import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    @Binding var recognizedItems: [RecognizedItem]
    let recognizedDataType: DataScannerViewController.RecognizedDataType
    let recognizedMultipleItems: Bool
    
    func makeUIViewController(context: Context) ->  DataScannerViewController {
        
        let viewController = DataScannerViewController(
            recognizedDataTypes: [recognizedDataType],
            qualityLevel: .accurate,
            recognizesMultipleItems: recognizedMultipleItems,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        uiViewController.delegate = context.coordinator
        try? uiViewController.startScanning()
    }
    
    ///Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizeItems: $recognizedItems)
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, 
                                          coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        
        @Binding var recognizeItems: [RecognizedItem]
        
        init(recognizeItems: Binding<[RecognizedItem]>) {
            self._recognizeItems = recognizeItems
        }
        
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            print("didTapOn \(item)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], 
                         allItems: [RecognizedItem]) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            recognizeItems.append(contentsOf: addedItems)
            
            print("didAddItems \(addedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], 
                         allItems: [RecognizedItem]) {
            
            self.recognizeItems = removedItems.filter { item in
                removedItems.contains(where: { $0.id == item.id})
            }
            
            print("didRemoveItems \(removedItems)")
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable) {
            print("Became unavailable with error \(error.localizedDescription)")
        }
    }
    
}
