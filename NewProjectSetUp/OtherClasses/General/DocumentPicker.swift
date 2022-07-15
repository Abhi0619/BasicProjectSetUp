//
//  DocumentPicker.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit
import MobileCoreServices
import AVFoundation
import Photos

/*DocumentPicker.shared.showAttachmentActionSheet(vc: self!, attType: [.photoLibrary,.file])
 DocumentPicker.shared.fileAttType =  [.public_image]
 DocumentPicker.shared.handleBlockAction(block: { (type, url, image) in
 /* get your data here */
 })*/


enum fileAttachmentType: String, CaseIterable {
    case public_image = "public.image"
    case public_item = "public.item"
    case public_data = "public.data"
    case public_content = "public.content"
    case public_audiovisual_content = "public.audiovisual-content"
    case public_movie = "public.movie"
    case public_video = "public.video"
    case public_audio = "public.audio"
    case public_text = "public.text"
    case public_zip = "public.zip-archive"
    case public_composite = "public.composite-content"
    case com_pages = "com.apple.iwork.pages.pages"
    case com_numbers = "com.apple.iwork.numbers.numbers"
    case com_keynote = "com.apple.iwork.keynote.key"
    case com_zip = "com.pkware.zip-archive"
    case com_application = "com.apple.application"
}


enum AttachmentType: String{
    case camera = "Camera"
    case video = "Video"
    case photoLibrary = "Phone Library"
    case file = "File"
}

class DocumentPicker: NSObject{
    static let shared = DocumentPicker()
    fileprivate var currentVC: UIViewController?
    var fileAttType: [fileAttachmentType] = []
    
    //MARK: - Internal Properties
    var actionBlock: ((_ attType: AttachmentType ,_ url: URL?, _ image: UIImage?) -> ())?
    
    
    func handleBlockAction(block: @escaping (_ attType: AttachmentType ,_ url: URL?, _ image: UIImage?) -> ()) {
        actionBlock = block
    }
    
    //MARK: - SETTINGS ALERT
    func addAlertForSettings(_ attachmentTypeEnum: AttachmentType) {
        var alertTitle: String = ""
        if attachmentTypeEnum == AttachmentType.camera{
            alertTitle = "kCameraAccess_Msg".localizeWithFormat(arguments: _appName, _appName)
        }
        if attachmentTypeEnum == AttachmentType.photoLibrary{
            alertTitle = "kPhotosAccess_Msg".localizeWithFormat(arguments: _appName, _appName)
        }
        if attachmentTypeEnum == AttachmentType.video{
            alertTitle = "kVideoAccess_Msg".localizeWithFormat(arguments: _appName, _appName)
        }
        
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .destructive) { (_) -> Void in
            let settingUrl = URL(string: UIApplication.openSettingsURLString)
            if let url = settingUrl {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
        cameraUnavailableAlertController .addAction(settingsAction)
        currentVC?.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
}


// MARK: - Action sheet
extension DocumentPicker {
    //MARK: - showAttachmentActionSheet
    // This function is used to show the attachment sheet for image, video, photo and file.
    func showAttachmentActionSheet(vc: UIViewController, attType: [AttachmentType]) {
        currentVC = vc
        
        let actionSheet = UIAlertController(title: "Select image option", message: "", preferredStyle: .actionSheet)
        
        for type in attType {
            if type == .camera {
                actionSheet.addAction(UIAlertAction(title: AttachmentType.camera.rawValue, style: .default, handler: { (action) -> Void in
                    self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
                }))
            }else if type == .photoLibrary {
                actionSheet.addAction(UIAlertAction(title: AttachmentType.photoLibrary.rawValue, style: .default, handler: { (action) -> Void in
                    self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
                }))
            }else if type == .video {
                actionSheet.addAction(UIAlertAction(title: AttachmentType.video.rawValue, style: .default, handler: { (action) -> Void in
                    self.authorisationStatus(attachmentTypeEnum: .video, vc: self.currentVC!)
                }))
            }else if type == .file {
                actionSheet.addAction(UIAlertAction(title: AttachmentType.file.rawValue, style: .default, handler: { (action) -> Void in
                    self.documentPicker()
                }))
            }
        }
        actionSheet.view.tintColor = AppColor.app_light_green_006622.color()
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
}


// MARK: - Open Controller
extension DocumentPicker {
    
    //MARK: - CAMERA PICKER
    //This function is used to open camera from the iphone and
    func openCamera(){
        DispatchQueue.main.async {
            
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .camera
                self.currentVC?.present(myPickerController, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: - PHOTO PICKER
    func photoLibrary(){
        DispatchQueue.main.async {
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .photoLibrary
                myPickerController.isEditing = true
                self.currentVC?.present(myPickerController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - VIDEO PICKER
    func videoLibrary(){
        DispatchQueue.main.async {
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .photoLibrary
                myPickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
                self.currentVC?.present(myPickerController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - FILE PICKER
    func documentPicker(){
        var arrType: [String] = []
        for type in fileAttType {
            arrType.append(type.rawValue)
        }
        
        let importMenu = UIDocumentPickerViewController(documentTypes: arrType, in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        currentVC?.present(importMenu, animated: true, completion: nil)
    }
    
}

//MARK: - IMAGE PICKER DELEGATE
// This is responsible for image picker interface to access image, video and then responsibel for canceling the picker

extension DocumentPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.actionBlock?(.photoLibrary,nil,pickedImage)
        }else{
            jprint("Something went wrong in  image")
        }
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let data = NSData(contentsOf: videoUrl as URL)!
            jprint("File size before compression: \(Double(data.length / 1048576)) mb")
            compressWithSessionStatusFunc(videoUrl)
            
        }else{
            jprint("Something went wrong in  video")
        }
        
        
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Video Compressing technique
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: URL) {
        let compressedUrl = URL(fileURLWithPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        compressVideo(inputURL: videoUrl, outputURL: compressedUrl) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedUrl) else {
                    return
                }
                jprint("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                
                DispatchQueue.main.async {
                    self.actionBlock?(.video,compressedUrl,nil)
                }
                
            case .failed:
                break
            case .cancelled:
                break
            @unknown default:
                jprint("Fatal Error")
            }
        }
    }
    
    // Now compression is happening with medium quality, we can change when ever it is needed
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}


// MARK: - Permission
extension DocumentPicker {
    //MARK: - Authorisation Status
    // This is used to check the authorisation status whether user gives access to import the image, photo library, video.
    // if the user gives access, then we can import the data safely
    // if not show them alert to access from settings.
    func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController){
        currentVC = vc
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.camera{
                openCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary{
                photoLibrary()
            }
            if attachmentTypeEnum == AttachmentType.video{
                videoLibrary()
            }
        case .denied:
            jprint("permission denied")
            DispatchQueue.main.async {
                self.addAlertForSettings(attachmentTypeEnum)
            }
        case .notDetermined:
            jprint("Permission Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized{
                    // photo library access given
                    jprint("access given")
                    if attachmentTypeEnum == AttachmentType.camera{
                        self.openCamera()
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary{
                        self.photoLibrary()
                    }
                    if attachmentTypeEnum == AttachmentType.video{
                        self.videoLibrary()
                    }
                }else{
                    jprint("restriced manually")
                    DispatchQueue.main.async {
                        self.addAlertForSettings(attachmentTypeEnum)
                    }
                }
            })
        case .restricted:
            jprint("permission restricted")
            DispatchQueue.main.async {
                self.addAlertForSettings(attachmentTypeEnum)
            }
        default:
            break
        }
    }
}


//MARK: - FILE IMPORT DELEGATE
extension DocumentPicker: UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let myURL = urls.first else {
            return
        }
        print("import result : \(myURL)")
        self.actionBlock?(.file,myURL,nil)
//        controller.delegate = self
        //~/Library/Developer/CoreSimulator/Devices/012B6124-BA74-4D9D-9179-CBDD73D15181/data/Containers/Data/Application/A26F8C8D-8620-4384-9976-CC3DB33578AA/tmp/com.mytab.customer-Inbox
//        currentVC?.present(controller, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        controller.delegate = self
        currentVC?.present(controller, animated: true, completion: nil)
//        jprint("url", url)
//        self.actionBlock?(.file,url,nil)
    }
    
    //    Method to handle cancel action.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
}
