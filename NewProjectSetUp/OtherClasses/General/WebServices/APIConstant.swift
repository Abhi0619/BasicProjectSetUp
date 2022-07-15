//
//  APIConstant.swift
//  FitFin
//
//  Created by MAC OS 13 on 07/12/21.
//

import Foundation
import UIKit
import Alamofire

enum APIReqPath {
    case login
    case register
    case photo
    
    var apiData: (method: HTTPMethod, path: String, title: String) {
        switch self {
        case .login:
            return (method: .post, path: "login", title: "LOGIN")
        case .register:
            return (method: .post, path: "register", title: "REGISTER")
        case .photo:
            return (method: .get, path: "photos", title: "PHOTOS")
        }
    }
    
}
