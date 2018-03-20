//
//  RecodingPlace.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 3/18/18.
//  Copyright © 2018 Benjamin BARON. All rights reserved.
//

import Foundation
import Alamofire


struct RecordingPlaceType {
    let type: String
    let icon: String
}

class RecordingPlace: NSObject, NSCoding, Decodable {
    
    // MARK: Properties
    var placeid: String
    var placetype: String
    var typeid: String
    var name: String
    var icon: String
    var longitude: Double
    var latitude: Double
    var recordings: [URL]?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("recordingplaces")
    
    // MARK: Types
    struct PropertyKey {
        static let placeid = "placeid"
        static let placetype = "placetype"
        static let typeid = "typeid"
        static let name = "name"
        static let icon = "icon"
        static let longitude = "longitude"
        static let latitude = "latitude"
        static let recordings = "recordings"
    }
    
    // MARK: Initialization
    init?(placeid: String, placetype: String, typeid: String, name: String, icon: String, lon: Double, lat: Double, recordings: [URL]) {
        self.placeid = placeid
        self.placetype = placetype
        self.typeid = typeid
        self.name = name
        self.icon = icon
        self.longitude = lon
        self.latitude = lat
        self.recordings = recordings
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(placeid, forKey: PropertyKey.placeid)
        aCoder.encode(placetype, forKey: PropertyKey.placetype)
        aCoder.encode(typeid, forKey: PropertyKey.typeid)
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(icon, forKey: PropertyKey.icon)
        aCoder.encode(longitude, forKey: PropertyKey.longitude)
        aCoder.encode(latitude, forKey: PropertyKey.latitude)
        aCoder.encode(recordings, forKey: PropertyKey.recordings)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // this retrieves our saved placeid and casts it as a String
        guard let placeid = aDecoder.decodeObject(forKey: PropertyKey.placeid) as? String else {
            return nil // initializer should fail
        }
        
        let placetype = aDecoder.decodeObject(forKey: PropertyKey.placetype) as! String
        let typeid = aDecoder.decodeObject(forKey: PropertyKey.typeid) as? String ?? ""
        let name = aDecoder.decodeObject(forKey: PropertyKey.name) as! String
        let icon = aDecoder.decodeObject(forKey: PropertyKey.icon) as! String
        let longitude = aDecoder.decodeDouble(forKey: PropertyKey.longitude)
        let latitude = aDecoder.decodeDouble(forKey: PropertyKey.latitude)
        let recordings = aDecoder.decodeObject(forKey: PropertyKey.recordings) as? [URL] ?? []
        
        self.init(placeid: placeid, placetype: placetype, typeid: typeid, name: name, icon: icon, lon: longitude, lat: latitude, recordings: recordings)
    }
    
    // MARK: Class functions to save and load the personal information categories
    class func saveRecordingPlaces(places: [RecordingPlace]) -> Bool {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(places, toFile: RecordingPlace.ArchiveURL.path)
        return isSuccessfulSave
    }
    
    class func loadRecordingPlaces() -> [RecordingPlace]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: RecordingPlace.ArchiveURL.path) as? [RecordingPlace]
    }
    
    class func getRecordingPlace(with placeid: String) -> RecordingPlace? {
        if let places = loadRecordingPlaces() {
            for place in places {
                if place.placeid == placeid {
                    return place
                }
            }
        }
        return nil
    }
    
    class func getRecordingPlaces(for placetype: String) -> [RecordingPlace] {
        var res: [RecordingPlace] = []
        if let places = loadRecordingPlaces() {
            for place in places {
                if place.placetype == placetype {
                    res.append(place)
                }
            }
        }
        return res
    }
    
    // MARK: - Update the recording places from the server
    class func retrieveLatestRecordingPlaces(callback: (()->Void)? = nil) {
        let userid = Settings.getUUID() ?? ""
        let parameters: Parameters = ["userid": userid]
        Alamofire.request(Constants.urls.recordingPlacesURL, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                guard let data = response.data else { return }
                do {
                    let decoder = JSONDecoder()
                    let places = try decoder.decode([RecordingPlace].self, from: data)
                    _ = saveRecordingPlaces(places: places)
                    FileService.shared.log("Retrieved latest recording places from server", classname: "RecordingPlaces")
                    callback?()
                } catch {
                    print("Error serializing the json", error)
                }
            }
        }
    }
    
    class func updateIfNeeded(force: Bool = false, callback: (()->Void)? = nil) {
        print("update if needed")
        if let lastUpdate = Settings.getLastRecordingPlacesUpdate() {
            let places = loadRecordingPlaces()
            
            if force || places == nil || places?.count == 0 ||
               abs(lastUpdate.timeIntervalSinceNow) > Constants.variables.minimumDurationBetweenRecordingPlacesUpdates {
                FileService.shared.log("update the recording places in the background", classname: "RecordingPlaces")
                DispatchQueue.global(qos: .background).async {
                    RecordingPlace.retrieveLatestRecordingPlaces(callback: callback)
                    Settings.saveLastRecordingPlacesUpdate(with: Date())
                }
            }
        }
    }
    
    class func getRecordingPlaceTypes() -> [RecordingPlaceType] {
        var res: [RecordingPlaceType] = []
        var placeTypes: Set<String> = Set()
        if let places = loadRecordingPlaces() {
            for place in places {
                if !placeTypes.contains(place.placetype) {
                    placeTypes.insert(place.placetype)
                    res.append(RecordingPlaceType(type: place.placetype, icon: place.icon))
                }
                
            }
        }
        return res.sorted(by: { $0.type < $1.type })
    }
}


