//
//  DataCollectionService.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/19/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import CoreMotion
import UIKit

enum BatteryState {
    case unknown
    case charging
    case full
    case unplugged
}

struct DataCollection {
    let timestamp: Int
    let userId: String
    let placeType: String
    let placeId: String
    let magX: Double
    let magY: Double
    let magZ: Double
    let batteryLevel: Float
    let batteryState: BatteryState
    let lowPowerMode: Bool
}

protocol DataCollectionUpdateProtocol {
    func dataCollectionDidUpdate()
}

class DataCollectionService {
    static let shared = DataCollectionService()
    var delegate:DataCollectionUpdateProtocol!
    
    var motionManager = CMMotionManager()
    
    func startDataCollection() {
        self.motionManager.startMagnetometerUpdates()
    }
    
    func determineBatteryState() -> BatteryState {
        var state: BatteryState
        switch UIDevice.current.batteryState {
        case .charging:
            state = .charging
        case .full:
            state = .full
        case .unplugged:
            state = .unplugged
        default:
            state = .unknown
        }
        return state
    }
    
    func collectData(place: RecordingPlace, epoch: Int) {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // save the location and magneticField data in the database
        guard let mf = motionManager.magnetometerData?.magneticField else { return }
        let date = Date()
        
        let data = DataCollection(
            timestamp: Int(date.timeIntervalSince1970 * 1000.0),
            userId: Settings.getUUID()!,
            placeType: place.placetype,
            placeId: place.placeid,
            magX: mf.x, magY: mf.y, magZ: mf.z,
            batteryLevel: UIDevice.current.batteryLevel,
            batteryState: determineBatteryState(),
            lowPowerMode: ProcessInfo.processInfo.isLowPowerModeEnabled)
        
        let filename = "\(place.placetype)_\(place.placeid)_\(epoch).csv"
        FileService.shared.recordData([data], in: filename)
        
        print("collect data in \(filename)")
        print(data)
    }
    
    func stopDataCollection() {
        self.motionManager.stopMagnetometerUpdates()
    }
}
