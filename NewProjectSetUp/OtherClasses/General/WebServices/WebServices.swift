//
//  WebServices.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import Alamofire
import UIKit

enum WSAPICancelRequestType: Int {
    case downloadTask = 1
    case dataTask = 2
    case uploadTask = 3
    case all = 0
    case none = 220
}
/// File Upload class using with key name, filename, file mime type, etc. value using for on upload file on the server using.
class WSAPIUploadFile {
    var fileData: Data
    var image: UIImage?
    var file_name: String
    var key_name: String
    var mime_type: String
    var file_extension: String? = nil
    var progress: Progress?
    var isUploaded: Bool = false
    var isFailed: Bool = false

    init(data: Data, keyName: String, ext: String? = nil) {
        fileData = data
        key_name = keyName
        if let exten = ext {
            file_extension = exten
            mime_type = exten.getFileMimeType()
            file_name = "file_\(Date().timeIntervalSince1970).\(exten)"
        }else{
            file_extension = "jpeg"
            file_name = "file_\(Date().timeIntervalSince1970).jpeg"
            mime_type = "image/jpeg"
        }
    }
}

/// API Response status code used for handling.
enum WSAPIStatus: Int {
    case unAuthorised = 401
    case noDataFound = 404
    case somethingWrong = 405
    case noInternet = -1009
}

struct WSCertificates {
    static let cap =
        WSCertificates.certificate(filename: "")

    private static func certificate(filename: String) -> (data: Data?,certificate: SecCertificate?) {
        guard let asset = NSDataAsset(name: filename) else {
            print("Missing data asset: \(filename)")
            return (data: nil, certificate: nil)
        }
        let data = asset.data
        let certificate = SecCertificateCreateWithData(nil, data as CFData)
        return (data: data, certificate: certificate)
    }
}
/// WSAPIEnvironment enum use for identities current environment like production, local or staging and base on base path use
enum WSAPIEnvironment: Int {
    case local
    case staging
    case production

    static var currentType: WSAPIEnvironment = .staging

    static var basePath: String {
        
        switch currentType {
        case .local:
            return "http://fitfin.project-demo.info:8068/api/"
        case .staging:
            return "http://fitfin.net/fitfinnew/api/"
        case .production:
            return ""
        }
    }
}

// MARK:-  Closer
typealias WSBlock       = (_ json: Any?, _ statusCode: Int) -> ()
typealias WSUploadProgress = (_ progress: Progress?) -> ()
typealias WSFileBlock = (_ path: String?,_ error: Error?, _ statusCode: Int) -> ()

// MARK:- AccessTokenAdapter
struct AccessTokenAdapter: RequestInterceptor {


    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var adaptedRequest = urlRequest
        guard let authorizationToken = WebService.shared.getAuthorizationToken()else {
            completion(.success(adaptedRequest))
            return
        }
        adaptedRequest.setValue("Bearer \(authorizationToken)", forHTTPHeaderField: "Authorization")
        completion(.success(adaptedRequest))
    }
    
    private let accessToken: String = ""
//    let interceptor = AuthenticationInterceptor(authenticator: authenticator,
//                                                credential: credential)

}

// MARK:  WebService Class
class WebService: NSObject {

    static var shared: WebService = WebService()

    let manager =  Alamofire.Session.default
    let backgroundManager: UploadManager
    var networkManager: NetworkReachabilityManager

    var headers: HTTPHeaders = ["Accept": "application/json"]
    
    var paramEncode: ParameterEncoding = URLEncoding.default
    var successBlock: (String, HTTPURLResponse?, Any?, WSBlock) -> Void
    var errorBlock: (String, HTTPURLResponse?, NSError, WSBlock) -> Void


    var backgroundCompletionHandler: (() -> Void)? {
        get {
            return backgroundManager.backgroundCompletionHandler
        }
        set {
            backgroundManager.backgroundCompletionHandler = newValue
        }
    }

     override init() {

        backgroundManager = UploadManager()
        let configuration = URLSessionConfiguration.default
        configuration.headers = .default

        networkManager = NetworkReachabilityManager()!

        // Will be called on success of web service calls.
        successBlock = { (relativePath, res, respObj, block) -> Void in
            // Check for response it should be there as it had come in success block
            if let response = res{
                jprint("Response Code: \(response.statusCode)")
                jprint("Response(\(relativePath)): \(String(describing: respObj))")

                if response.statusCode == 200 {
                    block(respObj, response.statusCode)
                } else {
                    // check if response statuscode is unAuthorised then session Expired
                    if response.statusCode == WSAPIStatus.unAuthorised.rawValue{ //Session Expired
                        block(respObj, response.statusCode)
                    }else {
                        block(respObj, response.statusCode)
                    }
                }
            } else {
                // There might me no case this can get execute
                block(["message": "Something went wrong".localized()], WSAPIStatus.somethingWrong.rawValue)
            }
        }

        // Will be called on Error during web service call
        errorBlock = { (relativePath, res, error, block) -> Void in
            // First check for the response if found check code and make decision
            jprint("Error(\(relativePath)): \((error))")

            if let response = res {
                jprint("Response Code: \(response.statusCode)")
                jprint("Error Code: \(error.code)")

                // check if response statuscode is unAuthorised then session Expired
                if response.statusCode == WSAPIStatus.unAuthorised.rawValue{ //Session Expired
                    block(response, response.statusCode)
                    return
                } else if response.statusCode == 502 { //Bad Request: 502
                    block(["message": "Bad request".localized()], response.statusCode)
                    return
                }else if response.statusCode == 504 { //504 Gateway Time-out
                    block(["message": "Gateway timeOut".localized()], response.statusCode)
                    return
                }
                if let data = error.userInfo["com.alamofire.serialization.response.error.data"] as? Data {
                    if let errorDict = (try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any]{
                        block(errorDict, response.statusCode)
                        return
                    }
                }
            }

            jprint("message Error \((error))")
            if  error.code == -2102  {
                block(["message": "API TimeOut".localized()], error.code)
            } else if error.code == NSURLErrorNotConnectedToInternet  {
                block(["message": "No internet available".localized()], error.code)
            } else if error.code == NSURLErrorNetworkConnectionLost  {
                block(["message": "connection lost".localized()], error.code)
            } else if error.code == NSURLErrorCannotFindHost  {
                block(["message": "API host down".localized()], error.code)
            } else if error.code == NSURLErrorTimedOut  {
                block(["message": "API Timeout".localized()], error.code)
            }else if !error.localizedDescription.isEmpty {
                block(["message": error.localizedDescription], error.code)
            } else {
                block(["message": "Something went wrong".localized()], error.code)
            }
        }
        super.init()
        addInterNetListner()
    }



    deinit {
        networkManager.stopListening()
    }
}

// MARK: - Internet Availability
extension WebService{

     func addInterNetListner() {
           networkManager.startListening { (status) in
//               guard let weakSelf = self else{return}
               if case .reachable(_) = status {
                   jprint("Internet Available")
               }else{
                jprint("No internet available")
               }
           }
       }

       func isInternetAvailable() -> Bool {
           if networkManager.isReachable {
               return true
           }else{
               return false
           }
       }
}

// MARK: Other methods
extension WebService{
    func getFullUrl(_ relPath : String) throws -> URL{
        do{
            if relPath.lowercased().contains("http") || relPath.lowercased().contains("www") {
                return try relPath.asURL()
            } else {
                if let lastC =  WSAPIEnvironment.basePath.last, let firstC =  relPath.first{
                    if lastC != "/" && firstC != "/"  {
                        return try ("\(WSAPIEnvironment.basePath)/\(relPath)").asURL()
                    }else if lastC == "/" && firstC == "/"{
                        let strRelPath = String(relPath.dropFirst())
                        return try ("\(WSAPIEnvironment.basePath)/\(strRelPath)").asURL()
                    }
                }

                return try ("\(WSAPIEnvironment.basePath)\(relPath)").asURL()
            }
        } catch let err {
            throw err
        }
    }

    func storeAuthorizationToken(_ token: String) {
        APKeychainWrapper.shared.set(token, forKey: "accessToken")
    }

    func getAuthorizationToken() -> String? {
        let accessToken = APKeychainWrapper.shared.string(forKey: "accessToken")
        return accessToken
    }

    func removedAuthoriaztionToken() {
        APKeychainWrapper.shared.removeObject(forKey: "accessToken")
    }

    func setAccesTokenToHeader(token: String){
        jprint("#ACCESS TOKEN : \(token)")
//        manager.adapter = AccessTokenAdapter(accessToken: token)
    }
//
//    func removeAccessTokenFromHeader(){
//        manager.adapter = nil
//    }

    func cancel(taskRequest request: WSAPICancelRequestType){
        
        manager.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            switch request {
            case .dataTask:
                dataTasks.forEach { $0.cancel() }
                jprint("---  Data Tasks was canceled!  ---")
                break
            case .uploadTask:
                uploadTasks.forEach { $0.cancel() }
                jprint("---  Upload Tasks was canceled!  ---")

                break
            case .downloadTask:
                downloadTasks.forEach { $0.cancel() }
                jprint("---  Download Tasks was canceled!  ---")
                break

            case .all:
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
                jprint("--- Data Tasks, Upload Tasks, and Download Tasks was canceled!  ---")
                break

            default:
                break
            }
        }
    }
}

// MARK: - Request, ImageUpload and Dowanload methods

extension WebService {

    @discardableResult func urlSessionRequest(method: HTTPMethod = .get, relPath : String, param: [String: Any]?, auth_token: String? = nil, headerParam: HTTPHeaders? = nil, encoding: ParameterEncoding = URLEncoding.default, block: @escaping WSBlock) -> URLSessionDataTask? {
//        if self.isInternetAvailable(){
            do {
                jprint("Url: \(try getFullUrl( relPath))")
                var originalRequest = try URLRequest(url: try getFullUrl(relPath), method: method, headers: headerParam ?? headers)
                if let token = auth_token{
                    originalRequest.addValue(token, forHTTPHeaderField: "Authorization")
                }
                let encodedURLRequest = try encoding.encode(originalRequest, with: param)
                let dataTask = URLSession.shared.dataTask(with: encodedURLRequest) { (data, response, error) in
                    DispatchQueue.main.async {
                        if let resData = data, let res = response as? HTTPURLResponse {
                            jprint("success")
                            if !resData.isEmpty {
                                do {
                                    let result = try JSONSerialization.jsonObject(with: resData, options: .allowFragments)
                                    self.successBlock(relPath, res, result, block)
                                } catch let errParse{
                                    jprint("errParse: \(errParse)")
                                    self.errorBlock(relPath, res, errParse as NSError, block)
                                }
                            }else{
                                self.successBlock(relPath, res, nil, block)
                            }
                        } else if let err = error {
                            jprint("failure: \(err)")
                            self.errorBlock(relPath, nil, err as NSError, block)
                        }else{
                            self.successBlock(relPath, nil, nil, block)
                        }
                    }
                }
                dataTask.resume()
                return dataTask
            } catch let error {
                jprint("error: \(error)")
                errorBlock(relPath, nil, error as NSError, block)
                return nil
            }
//        }else{
//            block(["message": "kAPI_NoInternet_Msg".localized()], NSURLErrorNotConnectedToInternet)
//            return nil
//        }
    }

    @discardableResult func request(method: HTTPMethod = .get, relPath: String, param: [String : Any]?, headerParam: HTTPHeaders? = nil, encoding: ParameterEncoding = JSONEncoding.default, block: @escaping WSBlock) -> DataRequest? {
//        if self.isInternetAvailable(){
            do{
                
//                if _loggedUser != nil && !_loggedUser.accessToken.isEmpty {
//                    headers["Authorization"] = "Bearer \(_loggedUser.accessToken)"
//                }
                
                jprint("Url: \(try getFullUrl( relPath))")
                jprint("Param: \(String(describing: param))")
                jprint("Headers")
                jprint(headerParam ?? headers)


                return manager.request(try getFullUrl( relPath), method: method, parameters: param, encoding: encoding, headers: headerParam ?? headers).responseJSON { (resObj) in
                    jprint("resObj: \(resObj.debugDescription))")

                    switch resObj.result{
                    case .success:
                        jprint("success")

                        if let resData = resObj.data, !resData.isEmpty{
                            do {
                                let res = try JSONSerialization.jsonObject(with: resData, options: .allowFragments)
                                self.successBlock(relPath, resObj.response, res, block)
                            } catch let errParse{
                                jprint("errParse: \(errParse)")
                                self.errorBlock(relPath, resObj.response, errParse as NSError, block)
                            }
                        }else{
                            self.successBlock(relPath, nil, nil, block)
                        }
                        break
                    case .failure(let err):
                        jprint("failure: \(err)")
                        self.errorBlock(relPath, resObj.response, err as NSError, block)
                        break
                    }
                }
            }catch let error{
                jprint("error: \(error)")
                self.errorBlock(relPath, nil, error as NSError, block)
                return nil
            }
//        }else{
//            block(["message": "kAPI_NoInternet_Msg".localized()], NSURLErrorNotConnectedToInternet)
//            return nil
//        }
    }

    @discardableResult func uploadFile(method: HTTPMethod, relPath: String, arrFiles: [WSAPIUploadFile], param: [String: Any]? = nil, headerParam: HTTPHeaders? = nil, block: @escaping WSBlock, progress: WSUploadProgress? = nil)-> UploadTask?{
//        if self.isInternetAvailable(){
            do{
                
//                if _loggedUser != nil && !_loggedUser.accessToken.isEmpty {
//                    headers["Authorization"] = "Bearer \(_loggedUser.accessToken)"
//                }

                jprint("Url: \(try getFullUrl( relPath))")
                jprint("Param: \(String(describing: param))")
                jprint("Headers")
                jprint(headerParam ?? headers)

                let uploadTask = backgroundManager.uploadFile(method: method ,url: try getFullUrl( relPath), arrFiles: arrFiles, param: param, headerParam: headerParam ?? headers, progress: progress){ (data, task, error) in
                    DispatchQueue.main.async {
                        if let resData = data, let res = task?.response as? HTTPURLResponse {
                            jprint("success")
                            if !resData.isEmpty {
                                do {
                                    let result = try JSONSerialization.jsonObject(with: resData, options: .allowFragments)
                                    self.successBlock(relPath, res, result, block)
                                } catch let errParse{
                                    jprint("errParse: \(errParse)")
                                    self.errorBlock(relPath, res, errParse as NSError, block)
                                }
                            }else{
                                self.successBlock(relPath, res, nil, block)
                            }
                        } else if let err = error {
                            jprint("failure: \(err)")
                            self.errorBlock(relPath, nil, err as NSError, block)
                        }else{
                            self.successBlock(relPath, nil, nil, block)
                        }
                    }

                }

                return uploadTask
            }catch let err{
                jprint("err: \(err)")
                self.errorBlock(relPath, nil, err as NSError, block)
            }

//        }else{
//            block(["message": "kAPI_NoInternet_Msg".localized()], NSURLErrorNotConnectedToInternet)
//        }
        return nil
    }
    
}
// MARK: - Show API Error Handling Methods
extension WebService {
    class func showAPIError(viewController: UIViewController? = nil, data: Any?, statusCode: Int, showError: Bool = true, isLogin: Bool = false, ignoreStatus: [Int] = [200, 15]) {
        var response_code: Int = 0
        if let jsonData = RawdataConverter.dictionary(data){
            response_code = RawdataConverter.integer(jsonData["code"])
        }

        if (response_code == WSAPIStatus.unAuthorised.rawValue || statusCode == WSAPIStatus.unAuthorised.rawValue) && !isLogin{ // Session Expired
            #warning("UnComment below line")
//            if _loggedUser != nil{
//                _appDelegator.prepareToLogout(sessionExpired:true)
//            ValidationToast.show(message: "Session Expire", viewController: _appDelegator.window?.rootViewController, type: .error, presentType: .top, animationStlye: .slide, completion: nil)
//                ValidationToast.show(message: "kSession_Expired".localized(), viewController: _appDelegator.window?.rootViewController)
//            }
        }else if showError && statusCode != NSURLErrorCancelled && !ignoreStatus.contains(statusCode) && !ignoreStatus.contains(response_code){
            if let dict = RawdataConverter.dictionary(data){
                var errorMsg = ""
                
                if let errors = RawdataConverter.array(dict["errors"]) as? [String], errorMsg.isEmpty {
                    for msg in errors {
                        if errorMsg.isEmpty {
                            errorMsg = msg
                        }else{
                            errorMsg += "\n\(msg)"
                        }
                    }
                }
                if let dictError = RawdataConverter.dictionary(dict["error"]), errorMsg.isEmpty{
                    if let msg = RawdataConverter.optionalString(dictError["message"]){
                        errorMsg = msg
                    }
                }

                //Check message parameter on empty string for message
                if errorMsg.isEmpty, let msg = RawdataConverter.optionalString(dict["message"]){
                    errorMsg = msg
                }

                //Check message parameter on empty string for error
                if errorMsg.isEmpty, let msg = RawdataConverter.optionalString(dict["error"]){
                    errorMsg = msg
                }
                //if empty string then show kInternalError message
                if errorMsg.isEmpty{
                    errorMsg = "Internal error".localized()
                }
                ValidationToast.show(message: errorMsg, viewController: viewController, type: .error, presentType: .top, animationStlye: .slide, completion: nil)
                
            }else{
                ValidationToast.show(message: "Something went wrong".localized(), viewController: viewController)
            }
        }
    }

    class func showAPISuccess(viewController: UIViewController? = nil, data: Any?, statusCode: Int = 200) {
        if  statusCode != NSURLErrorCancelled{
            if let dict = RawdataConverter.dictionary(data){

                let successMsg = RawdataConverter.string(dict["message"])

                if !successMsg.isEmpty{
                    ValidationToast.show(message: successMsg, viewController: viewController, type: .success, presentType: .top, animationStlye: .slide, completion: nil)
                }
            }
        }
    }
    
    class func checkAPIStatus(viewController: UIViewController? = nil, data: Any?, statusCode: Int = 0, showError: Bool = true,showSuccess: Bool = false, block: @escaping ((_ isSuccess: Bool)->())) {
        if statusCode == 200, let jsonData = RawdataConverter.dictionary(data) {
            let isSuccess = RawdataConverter.boolean(jsonData["success"])
            let msg = RawdataConverter.string(jsonData["message"])
            if isSuccess {
                if showSuccess {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        showAPISuccess(data: data, statusCode: statusCode)
                    }
                }
                block(true)
            }else if showError && statusCode != NSURLErrorCancelled {
                ValidationToast.show(message: msg, viewController: viewController, type: .error, presentType: .top, animationStlye: .slide) {
                }
                block(false)
            }else if statusCode != 404 && showError {
                jprint("Else-----------")
                ValidationToast.show(message: msg, viewController: viewController, type: .error, presentType: .top, animationStlye: .slide) {
                }
                block(false)
            }
        }else{
            WebService.showAPIError(viewController: viewController, data: data, statusCode: statusCode, showError: showError)
            block(false)
        }
    }
}
//MARK: - distinory in array parameter
extension WebService {
    
    struct JSONArrayEncoding: ParameterEncoding {
        private let array: [Parameters]

        init(array: [Parameters]) {
            self.array = array
        }

        func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
            var urlRequest = try urlRequest.asURLRequest()

            let data = try JSONSerialization.data(withJSONObject: array, options: [])

            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }

            urlRequest.httpBody = data

            return urlRequest
        }
    }
}
//MARK: - Login Related
extension WebService {
        
    @discardableResult func loginWScall(param: [String: Any] ,block: @escaping WSBlock) -> DataRequest? {
        jprint("----- LOGIN -----")
        let relPath = "login"
        return request(method: .post, relPath: relPath, param: param, block: block)
    }

    @discardableResult func registerWScall(param: [String: Any] ,block: @escaping WSBlock) -> DataRequest? {
        jprint("----- REGISTER -----")
        let relPath = "register"
        return request(method: .post, relPath: relPath, param: param, block: block)
    }
    
    @discardableResult func forgotPassWScall(param: [String: Any] ,block: @escaping WSBlock) -> DataRequest? {
        jprint("----- FORGOT PASSWORD -----")
        let relPath = "forgotpassword"
        return request(method: .post, relPath: relPath, param: param, block: block)
    }
    
}

    
    


//MARK: - Download and upload
extension WebService {
    
    //Background download demo
    private func backgroundDownloadDemo() {
        let downloadManager = APDownloadManager.shared
        let request = URLRequest(url: URL(string: "")!)
        
        downloadManager.showLocalNotificationOnBackgroundDownloadDone = true
        downloadManager.localNotificationText = "All background downloads complete"
        
        let downloadKey = downloadManager.downloadFile(withRequest: request, inDirectory: directoryName, withName: directoryName, shouldDownloadInBackground: true, onProgress: { (progress) in
            let percentage = String(format: "%.1f %", (progress * 100))
            debugPrint("Background progress : \(percentage)")
        }) { [weak self] (error, url) in
            if let error = error {
                print("Error is \(error as NSError)")
            } else {
                if let url = url {
                    print("Downloaded file's url is \(url.path)")
                    print(url.path)
                }
            }
        }
        print("The key is \(downloadKey!)")
    }
    
    //Upload
    func updateProfileWSCall(image: UIImage? = nil,param: [String: String], _ block: @escaping WSBlock) {
        jprint("----- EDIT PROFILE -----")
        let relPath: String = "user/editprofile"
        if let data = image?.jpeg(.medium) {
            uploadFile(method: .post, relPath: relPath, arrFiles: [WSAPIUploadFile(data: data, keyName: "profile_image")], param: param, headerParam: headers, block: block)
        }else{
            uploadFile(method: .post, relPath: relPath, arrFiles: [], param: param, headerParam: headers, block: block)
        }
    }
    
}

private let arrayParametersKey = "arrayParametersKey"

/// Extenstion that allows an array be sent as a request parameters
extension Array {
    /// Convert the receiver array to a `Parameters` object.
    func asParameters() -> Parameters {
        return [arrayParametersKey: self]
    }
}



extension WebService {
    
        /// Convert the parameters into a json array, and it is added as the request body.
        /// The array must be sent as parameters using its `asParameters` method.
        public struct ArrayEncoding: ParameterEncoding {

            /// The options for writing the parameters as JSON data.
            public let options: JSONSerialization.WritingOptions


            /// Creates a new instance of the encoding using the given options
            ///
            /// - parameter options: The options used to encode the json. Default is `[]`
            ///
            /// - returns: The new instance
            public init(options: JSONSerialization.WritingOptions = []) {
                self.options = options
            }

            public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
                var urlRequest = try urlRequest.asURLRequest()

                guard let parameters = parameters,
                    let array = parameters[arrayParametersKey] else {
                        return urlRequest
                }

                do {
                    let data = try JSONSerialization.data(withJSONObject: array, options: options)

                    if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }

                    urlRequest.httpBody = data

                } catch {
                    throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
                }

                return urlRequest
            }
        }
        
        
    func callTest() {

//        var request = URLRequest(url: try! "http://fitfin.net/fitfinnew/api/user/5/fixedcost".asURL())
//        request.httpMethod = "PUT"
//        //some header examples
//
//        guard let authorizationToken = WebService.shared.getAuthorizationToken()else {
//            return
//        }
//
//
//        request.httpMethod = "POST"
//        request.setValue(authorizationToken,
//                         forHTTPHeaderField: "Authorization")
//
//
//        request.setValue("application/json", forHTTPHeaderField: "Accept")

        //parameter array

        var arr: [[String: Any]] = []
        var param: [String: Any] = [:]
        
        param["Id"] = 30936
        param["UserId"] = 5
        param["FixedCostName"] = "LOL"
        param["FixedCostValue"] = "6000.00"
        param["IsDeletable"] = false
        arr.append(param)
        jprint(param)
//        request.httpBody = try! JSONSerialization.data(withJSONObject: arr)

        //now just use the request with Alamofire
        let url = URL(string: "http://fitfin.net/fitfinnew/api/user/5/fixedcost")!
        AF.request(url,
                          method: .put,
                          parameters: arr.asParameters(),
                   encoding: ArrayEncoding(),headers: headers).responseJSON { response in
            switch (response.result) {
            case .success:
        jprint(response.result)
                break
                //success code here
                
            case .failure(let error):
                break
                //failure code here
            }

        }
    }
    
    
    
}
