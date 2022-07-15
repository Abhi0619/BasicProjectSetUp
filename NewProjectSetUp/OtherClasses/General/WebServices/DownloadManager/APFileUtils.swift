//
//  APFileUtils.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

class APFileUtils: NSObject {
    
    // MARK:- Helpers
    
    static func moveFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?) {
        var newUrl:URL
        if let directory = directory {
            let directoryCreationResult = self.createDirectoryIfNotExists(withName: directory)
            guard directoryCreationResult.0 else {
                return (false, directoryCreationResult.1, nil)
            }
            newUrl = self.cacheDirectoryPath().appendingPathComponent(directory).appendingPathComponent(name)
        } else {
            newUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        }
        do {
            try FileManager.default.moveItem(at: url, to: newUrl)
            return (true, nil, newUrl)
        } catch {
            return (false, error, nil)
        }
    }
    
    static func cacheDirectoryPath() -> URL {
        let cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return URL(fileURLWithPath: cachePath)
    }
    
    static func createDirectoryIfNotExists(withName name:String) -> (Bool, Error?)  {
        let directoryUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            return (true, nil)
        }
        do {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            return (true, nil)
        } catch  {
            return (false, error)
        }
    }
 
    static func deleteFile(fromUrl url:URL,
                         toDirectory directory:String? ,
                         withName name:String) -> (Bool, Error?, URL?) {
        var newUrl:URL
        if let directory = directory {
            if !name.isEmpty {
                newUrl = self.cacheDirectoryPath().appendingPathComponent(directory).appendingPathComponent(name)
            }else{
                newUrl = self.cacheDirectoryPath().appendingPathComponent(directory)
            }
        } else {
            newUrl = self.cacheDirectoryPath().appendingPathComponent(name)
        }
        do {
            try FileManager.default.removeItem(at: newUrl)
            return (true, nil, newUrl)
        } catch {
            return (false, error, nil)
        }
    }
}
