//
//  FileService.swift
//  My Magnetic Field
//
//  Created by Benjamin BARON on 11/20/17.
//  Copyright © 2017 Benjamin BARON. All rights reserved.
//

import Foundation
import Alamofire

class FileService: NSObject {
    static let shared = FileService()
    var dir: URL?
    
    override init() {
        self.dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    class func upload(file: URL, callback: @escaping (DataResponse<Any>) -> Void) {
        NSLog("upload file \(file)")
        let id: String = Settings.getUUID() ?? ""
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(file,
                                         withName: "trace",
                                         fileName: "\(id)_\(file.lastPathComponent)",
                    mimeType: "text/csv")
        },
            to: Constants.urls.magUploadURL,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        callback(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
    
    func listFiles() -> [URL] {
        guard let dir = dir else { return [] }
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil, options: [])
            
            var res: [URL] = []
            for url in directoryContents {
                let name = url.deletingPathExtension().lastPathComponent
                let match = matches(for: "^([A-Za-z]+)_([0-9A-Za-z]+)_([0-9]+)$", in: name)
                if !match.isEmpty {
                    res.append(url)
                }
            }
            return res
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    func delete(file: URL) {
        do {
            try FileManager.default.removeItem(at: file)
        } catch {
            print("Could not delete file: \(file.path)")
        }
    }
    
    func read(from file: URL) -> String {
        do {
            let text = try String(contentsOf: file, encoding: .utf8)
            return text
        } catch {
            NSLog("Error when reading file \(file)")
        }
        return ""
    }
    
    func fileExists(file: String) -> Bool {
        guard let dir = dir else { return false }
        let path = dir.appendingPathComponent(file).path
        let fileManager = FileManager.default
        return fileManager.fileExists(atPath: path)
    }
    
    func createOrAppend(_ string: String, in file: String) {
        if fileExists(file: file) {
            append(string, in: file)
        } else {
            write(string, in: file)
        }
    }
    
    func append(_ string: String, in file: String) {
        guard let dir = dir else { return }
        let path = dir.appendingPathComponent(file)
        let fileHandle = FileHandle(forUpdatingAtPath: path.path)
        if let fileHandle = fileHandle {
            fileHandle.seekToEndOfFile()
            fileHandle.write(string.data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            NSLog("could not write in file \(file)")
        }
    }
    
    func write(_ string: String, in file: String) {
        guard let dir = dir else { return }
        let path = dir.appendingPathComponent(file)
        do {
            try string.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            NSLog("could not write in file \(file)")
        }
    }
    
    func recordLocations(_ locations: [UserLocation], in file: String) {
        if fileExists(file: file) {
            var text = ""
            for loc in locations {
                let line = "\(loc.userID),\(loc.latitude),\(loc.longitude),\(loc.timestamp),\(loc.magX),\(loc.magY),\(loc.magZ),\(loc.type)\n"
                text.append(line)
            }
            append(text, in: file)
        } else  {
            var text = "User,Lat,Lon,Timestamp,magX,magY,magZ,type\n"
            for loc in locations {
                let line = "\(loc.userID),\(loc.latitude),\(loc.longitude),\(loc.timestamp),\(loc.magX),\(loc.magY),\(loc.magZ),\(loc.type)\n"
                text.append(line)
            }
            write(text, in: file)
        }
    }
    
    func recordData(_ data: [DataCollection], in file: String) {
        if fileExists(file: file) {
            var text = ""
            for d in data {
                let line = "\(d.userId),\(d.timestamp),\(d.placeType),\(d.placeId),\(d.magX),\(d.magY),\(d.magZ)\n"
                text.append(line)
            }
            append(text, in: file)
        } else  {
            var text = "UserId,Timestamp,PlaceType,PlaceId,magX,magY,magZ\n"
            for d in data {
                let line = "\(d.userId),\(d.timestamp),\(d.placeType),\(d.placeId),\(d.magX),\(d.magY),\(d.magZ)\n"
                text.append(line)
            }
            write(text, in: file)
        }
    }
    
    func log(_ text: String, classname: String) {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let filename = "log-" + formatter.string(from: date) + ".log"
        formatter.dateFormat = "HH:mm:ss"
        let time = formatter.string(from: date)
        
        let logText = "\(time) [\(classname)] \(text)\n"
        createOrAppend(logText, in: filename)
        
        NSLog("[\(classname)] \(text)")
    }
}
