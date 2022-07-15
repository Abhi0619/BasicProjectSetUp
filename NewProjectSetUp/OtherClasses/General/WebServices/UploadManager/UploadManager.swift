//
//  UploadManager.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import Alamofire

class UploadManager: NSObject {

    private lazy var session: URLSession = {
        var configuration = URLSessionConfiguration.background(withIdentifier: backgroundIdentifier)
        configuration.headers = .default
        // delegate not call for This iOS version. Upcoming next new iOS version we need check it working or not.
        if #available(iOS 13.2.3, *){
            configuration.isDiscretionary = false
        }else{
            configuration.isDiscretionary = true
        }
        configuration.sessionSendsLaunchEvents = true
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    var uploadTasks: [URLSessionTask: UploadTask] = [:]
    var uploadTasksData: [URLSessionTask: Data] = [:]

    var backgroundCompletionHandler: (() -> Void)?


    func uploadFile(method: HTTPMethod, url: URL, arrFiles: [WSAPIUploadFile], param: [String: Any]? = nil, headerParam: HTTPHeaders? = nil, progress: WSUploadProgress? = nil, block: @escaping UploadCompletionHandler) -> UploadTask? {
        do {

            var urlRequest = try URLRequest(url: url, method: method , headers: headerParam)

            #warning("UnComment Below line")
//            if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields, !allHTTPHeaderFields.keys.contains("Authorization"), let accessToken = _loggedUser?.access_token{
//                urlRequest.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
//            }
            
            jprint("Headers")
            jprint(headerParam)


            let formData = MultipartFormData()
            arrFiles.forEach({ (obj) in
                formData.append(obj.fileData, withName: obj.key_name, fileName: obj.file_name, mimeType: obj.mime_type)
            })
            if let aParam = param{
                for (key, value) in aParam{
                    let str = RawdataConverter.string(value)
                    if let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false){
                        formData.append(data, withName: key)
                    }
                }
            }

            var urlRequestWithContentType = try urlRequest.asURLRequest()
            urlRequestWithContentType.setValue(formData.contentType, forHTTPHeaderField: "Content-Type")

            let isBackgroundSession = self.session.configuration.identifier != nil

//            if formData.contentLength < Session.multipartFormDataEncodingMemoryThreshold && !isBackgroundSession {

            if !isBackgroundSession {
                let data = try formData.encode()
                let uploadTask = upload(request: urlRequestWithContentType, fromData: data)
                uploadTask.uploadProgressHandler = progress
                uploadTask.completionHandler = block
                return uploadTask
            }else{
                let fileManager = FileManager.default
                let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
                let directoryURL = tempDirectoryURL.appendingPathComponent(".")
                let fileName = UUID().uuidString
                let fileURL = directoryURL.appendingPathComponent(fileName)

                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                try formData.writeEncodedData(to: fileURL)

                let uploadTask = upload(request: urlRequestWithContentType, fromFile: fileURL)
                uploadTask.uploadProgressHandler = progress
                uploadTask.completionHandler = block
                return uploadTask
            }
        } catch let error{
            jprint("error: \(error)")
            block(nil, nil, error)
        }
        return nil
    }

    func upload(request: URLRequest, fromData data: Data) -> UploadTask {
        let isBackgroundSession = session.configuration.identifier != nil

        if isBackgroundSession {
            let fileManager = FileManager.default
            let tempDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory())
            let directoryURL = tempDirectoryURL.appendingPathComponent(".")
            let fileName = UUID().uuidString
            let fileURL = directoryURL.appendingPathComponent(fileName)

            do {
                try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
                try data.write(to: fileURL)
            } catch { }

            return upload(request: request, fromFile: fileURL)
        } else {
            let task = session.uploadTask(with: request, from: data)
            let uploadTask = UploadTask(task: task)
            uploadTasks[task] = uploadTask
            task.resume()

            return uploadTask
        }
    }

    func upload(request: URLRequest, fromFile fileUrl: URL) -> UploadTask {
        let task = session.uploadTask(with: request, fromFile: fileUrl)
        let uploadTask = UploadTask(task: task)
        uploadTasks[task] = uploadTask
        task.resume()

        return uploadTask
    }

}
// MARK: - URLSessionTaskDelegate
extension UploadManager: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let uploadTask = uploadTasks[task] else { return }
        let data = uploadTasksData[task]
        DispatchQueue.main.async {
            uploadTask.completionHandler?(data, task, error)
            uploadTask.isUploadFinshed = true
        }
         uploadTasksData.removeValue(forKey: task)
        uploadTasks.removeValue(forKey: task)
    }


    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else { return completionHandler(.useCredential, nil) }

        // SSL Setup
        if let certi = WSCertificates.cap.certificate {
            let policy = SecPolicyCreateSSL(true, WSAPIEnvironment.basePath as CFString)
            SecTrustSetPolicies(serverTrust, policy)

            SecTrustSetAnchorCertificates(serverTrust, [certi] as CFArray)
            SecTrustSetAnchorCertificatesOnly(serverTrust, true)

        }
        completionHandler(.useCredential, URLCredential(trust: serverTrust))
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard let uploadTask = uploadTasks[task] else { return }
        uploadTask.urlSession(session, task: task, didSendBodyData: bytesSent, totalBytesSent: totalBytesSent, totalBytesExpectedToSend: totalBytesExpectedToSend)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        jprint("urlSessionDidFinishEvents")
        backgroundCompletionHandler?()
    }
}

// MARK: - URLSessionDataDelegate
extension UploadManager: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let responseData = uploadTasksData[dataTask] else {
            uploadTasksData[dataTask] = data
            return
        }
        var resData = responseData
        resData.append(data)
        uploadTasksData[dataTask] = resData
     }
}
