//
//  Settings.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/18/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import UIKit

open class Settings {
    open class func registerDefaults() {
        let defaults = UserDefaults.standard
        
        // Install defaults
        if (!defaults.bool(forKey: "DEFAULTS_INSTALLED")) {
            defaults.set(true, forKey: "DEFAULTS_INSTALLED")
            defaults.set(Date(), forKey: Constants.defaultsKeys.lastRecordingPlacesUpdate)
            defaults.set([], forKey: Constants.defaultsKeys.uploadedFiles)
        }
    }
    
    open class func getUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString ?? nil
    }
    
    // lastRecordingPlacesUpdate default key
    open class func getLastRecordingPlacesUpdate() -> Date? {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: Constants.defaultsKeys.lastRecordingPlacesUpdate) as? Date
    }
    
    open class func saveLastRecordingPlacesUpdate(with value: Date) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: Constants.defaultsKeys.lastRecordingPlacesUpdate)
    }
    
    // uploadedFiles default key
    open class func getUploadedFiles() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.array(forKey: Constants.defaultsKeys.uploadedFiles) as? [String] ?? []
    }
    
    open class func addUploadedFile(fname: String) {
        var files = Set(getUploadedFiles())
        files.insert(fname)
        
        let defaults = UserDefaults.standard
        defaults.set(Array(files), forKey: Constants.defaultsKeys.uploadedFiles)
    }
    
}
