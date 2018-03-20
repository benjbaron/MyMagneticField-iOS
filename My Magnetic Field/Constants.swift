//
//  Constants.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/18/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct defaultsKeys {
        static let lastRecordingPlacesUpdate = "lastRecordingPlacesUpdate"
        static let uploadedFiles = "uploadedFiles"
    }
    
    struct variables {
        static let minimumDurationBetweenRecordingPlacesUpdates: TimeInterval = 3600 // one hour
    }
    
    struct colors {
        static let defaultColor = UIColor.init(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0);
        static let primaryDark = UIColor.init(red: 48.0/255.0, green: 63.0/255.0, blue: 159.0/255.0, alpha: 1)
        static let primaryLight = UIColor.init(red: 167.0/255.0, green: 175.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        static let descriptionColor = UIColor.gray
        static let titleColor = UIColor.white
        static let black = UIColor.black
        static let white = UIColor.white
        static let green = UIColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
        static let noColor = UIColor.clear
        static let superLightGray = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        static let lightGray = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        static let darkRed = UIColor(red: 0.698, green: 0.1529, blue: 0.1529, alpha: 1.0)
        static let orange = UIColor(red: 247/255, green: 148/255, blue: 29/255, alpha: 1.0)
        static let lightOrange = UIColor(red: 244/255, green: 197/255, blue: 146/255, alpha: 1.0)
        static let lightPurple = UIColor(red: 198/255, green: 176/255, blue: 188/255, alpha: 1.0)
        static let midPurple = UIColor(red: 80/255, green: 7/255, blue: 120/255, alpha: 1.0)
        static let darkPurple = UIColor(red: 75/255, green: 56/255, blue: 76/255, alpha: 1.0)
    }
    
    struct urls {
        static let recordingPlacesURL = "https://iss-lab.geog.ucl.ac.uk/semantica/recordingplaces"
        static let magUploadURL = "https://iss-lab.geog.ucl.ac.uk/semantica/uploadmag"
    }
}
