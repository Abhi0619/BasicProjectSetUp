//
//  UploadTask.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
typealias UploadProgressHandler = (_ progress: Progress?) -> Void
typealias UploadCompletionHandler = (_ data: Data?,_ task: URLSessionTask?,_ error: Error?) -> Void

public protocol Cancelable {
    func cancel()
}
class UploadTask: NSObject, Cancelable {
    private var uploadProgress: Progress = Progress(totalUnitCount: 0)
    private var isUploaded: Bool = false
    var uploadProgressHandler: UploadProgressHandler?
    var completionHandler: UploadCompletionHandler?
    var progress: Float{
        return Float(uploadProgress.fractionCompleted)
    }
    var isUploadFinshed: Bool {
        get {
            return isUploaded
        }
        set (new) {
            isUploaded = new
            uploadProgressHandler?(uploadProgress)
        }
    }
    let task: URLSessionTask

    init(task: URLSessionTask) {
        self.task = task
    }

    func cancel() {
        task.cancel()
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        uploadProgress.totalUnitCount = totalBytesExpectedToSend
        uploadProgress.completedUnitCount = totalBytesSent
        
        uploadProgressHandler?(uploadProgress)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let obj = object as? Progress{
            return self.uploadProgress == obj
        }else if let obj = object as? UploadTask{
            return self == obj
        }
        return false
    }
      
}

