//
//  APDownloadManager.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UserNotifications
import UIKit


final public class APDownloadManager: NSObject {
    
    public typealias DownloadCompletionBlock = (_ error : Error?, _ fileUrl:URL?) -> Void
    public typealias DownloadProgressBlock = (_ progress : CGFloat) -> Void
    public typealias BackgroundDownloadCompletionHandler = () -> Void
    
    // MARK :- Properties
    
    private var session: URLSession!
    private var ongoingDownloads: [String : APDownloadObject] = [:]
    private var backgroundSession: URLSession!
    
    public var backgroundCompletionHandler: BackgroundDownloadCompletionHandler?
    public var showLocalNotificationOnBackgroundDownloadDone = true
    public var localNotificationText: String?

    public static let shared: APDownloadManager = { return APDownloadManager() }()

    //MARK:- Public methods
    
    public func downloadFile(withRequest request: URLRequest,
                            inDirectory directory: String? = nil,
                            withName fileName: String? = nil,
                            shouldDownloadInBackground: Bool = false,
                            onProgress progressBlock:DownloadProgressBlock? = nil,
                            onCompletion completionBlock:@escaping DownloadCompletionBlock) -> String? {
        
        guard let url = request.url else {
            debugPrint("Request url is empty")
            return nil
        }
        
        if let _ = self.ongoingDownloads[url.absoluteString] {
            debugPrint("Already in progress")
            return nil
        }
        var downloadTask: URLSessionDownloadTask
        if shouldDownloadInBackground {
            downloadTask = self.backgroundSession.downloadTask(with: request)
        } else{
            downloadTask = self.session.downloadTask(with: request)
        }
        
        let download = APDownloadObject(downloadTask: downloadTask,
                                        progressBlock: progressBlock,
                                        completionBlock: completionBlock,
                                        fileName: fileName,
                                        directoryName: directory)

        let key = self.getDownloadKey(withUrl: url)
        self.ongoingDownloads[key] = download
        downloadTask.resume()
        return key;
    }
    
    public func getDownloadKey(withUrl url: URL) -> String {
        return url.absoluteString
    }
    
    public func currentDownloads() -> [String] {
        return Array(self.ongoingDownloads.keys)
    }
    
    public func cancelAllDownloads() {
        for (_, download) in self.ongoingDownloads {
            let downloadTask = download.downloadTask
            downloadTask.cancel()
        }
        self.ongoingDownloads.removeAll()
    }
    
    public func cancelDownload(forUniqueKey key:String?) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                download.downloadTask.cancel()
                self.ongoingDownloads.removeValue(forKey: key!)
            }
        }
    }
    
    public func pause(forUniqueKey key:String?) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                let downloadTask = download.downloadTask
                downloadTask.suspend()
            }}
    }
    
    public func resume(forUniqueKey key:String?) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                let downloadTask = download.downloadTask
                downloadTask.resume()
            }}
    }
    
    public func isDownloadInProgress(forKey key:String?) -> Bool {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        return downloadStatus.0
    }
    
    public func alterDownload(withKey key: String?,
                              onProgress progressBlock:DownloadProgressBlock?,
                              onCompletion completionBlock:@escaping DownloadCompletionBlock) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                download.progressBlock = progressBlock
                download.completionBlock = completionBlock
            }
        }
    }
    //MARK:- Private methods
    
    private override init() {
        super.init()
        let sessionConfiguration = URLSessionConfiguration.default
        self.session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier!)
        self.backgroundSession = URLSession(configuration: backgroundConfiguration, delegate: self, delegateQueue: OperationQueue())
    }

    private func isDownloadInProgress(forUniqueKey key:String?) -> (Bool, APDownloadObject?) {
        guard let key = key else { return (false, nil) }
        for (uniqueKey, download) in self.ongoingDownloads {
            if key == uniqueKey {
                return (true, download)
            }
        }
        return (false, nil)
    }
    
    private func showLocalNotification(withText text:String) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else {
                debugPrint("Not authorized to schedule notification")
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = text
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1,
                                                            repeats: false)
            let identifier = "SDDownloadManagerNotification"
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    debugPrint("Could not schedule notification, error : \(error)")
                }
            })
        }
    }
}

extension APDownloadManager : URLSessionDelegate, URLSessionDownloadDelegate {
    
    // MARK:- Delegates
    
    public func urlSession(_ session: URLSession,
                             downloadTask: URLSessionDownloadTask,
                             didFinishDownloadingTo location: URL) {
        
        let key = (downloadTask.originalRequest?.url?.absoluteString)!
        if let download = self.ongoingDownloads[key]  {
            if let response = downloadTask.response {
                let statusCode = (response as! HTTPURLResponse).statusCode
                
                guard statusCode < 400 else {
                    let error = NSError(domain:"HttpError", code:statusCode, userInfo:[NSLocalizedDescriptionKey : HTTPURLResponse.localizedString(forStatusCode: statusCode)])
                    OperationQueue.main.addOperation({
                        download.completionBlock(error,nil)
                    })
                    return
                }
                let fileName = download.fileName ?? downloadTask.response?.suggestedFilename ?? (downloadTask.originalRequest?.url?.lastPathComponent)!
                let directoryName = download.directoryName
                
                let fileMovingResult = APFileUtils.moveFile(fromUrl: location, toDirectory: directoryName, withName: fileName)
                let didSucceed = fileMovingResult.0
                let error = fileMovingResult.1
                let finalFileUrl = fileMovingResult.2
                
                OperationQueue.main.addOperation({
                    (didSucceed ? download.completionBlock(nil,finalFileUrl) : download.completionBlock(error,nil))
                })
            }
        }
        self.ongoingDownloads.removeValue(forKey:key)
    }
    
    public func urlSession(_ session: URLSession,
                             downloadTask: URLSessionDownloadTask,
                             didWriteData bytesWritten: Int64,
                             totalBytesWritten: Int64,
                             totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else {
            debugPrint("Could not calculate progress as totalBytesExpectedToWrite is less than 0")
            return;
        }
        
        if let download = self.ongoingDownloads[(downloadTask.originalRequest?.url?.absoluteString)!],
            let progressBlock = download.progressBlock {
            let progress : CGFloat = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
            OperationQueue.main.addOperation({
                progressBlock(progress)
            })
        }
    }
    
    public func urlSession(_ session: URLSession,
                             task: URLSessionTask,
                             didCompleteWithError error: Error?) {
        
        if let error = error {
            let downloadTask = task as! URLSessionDownloadTask
            let key = (downloadTask.originalRequest?.url?.absoluteString)!
            if let download = self.ongoingDownloads[key] {
                OperationQueue.main.addOperation({
                    download.completionBlock(error,nil)
                })
            }
            self.ongoingDownloads.removeValue(forKey:key)
        }
    }

    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if downloadTasks.count == 0 {
                OperationQueue.main.addOperation({
                    if let completion = self.backgroundCompletionHandler {
                        completion()
                    }
                    
                    if self.showLocalNotificationOnBackgroundDownloadDone {
                        var notificationText = "Download completed"
                        if let userNotificationText = self.localNotificationText {
                            notificationText = userNotificationText
                        }
                        
                        self.showLocalNotification(withText: notificationText)
                    }
                    
                    self.backgroundCompletionHandler = nil
                })
            }
        }
    }
}
