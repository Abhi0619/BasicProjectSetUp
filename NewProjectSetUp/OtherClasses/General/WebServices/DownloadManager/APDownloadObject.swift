//
//  APDownloadObject.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit

class APDownloadObject: NSObject {

    var completionBlock: APDownloadManager.DownloadCompletionBlock
    var progressBlock: APDownloadManager.DownloadProgressBlock?
    let downloadTask: URLSessionDownloadTask
    let directoryName: String?
    let fileName:String?
    
    init(downloadTask: URLSessionDownloadTask,
         progressBlock: APDownloadManager.DownloadProgressBlock?,
         completionBlock: @escaping APDownloadManager.DownloadCompletionBlock,
         fileName: String?,
         directoryName: String?) {
        
        self.downloadTask = downloadTask
        self.completionBlock = completionBlock
        self.progressBlock = progressBlock
        self.fileName = fileName
        self.directoryName = directoryName
    }
    
}
