//
//  LoggedUser.swift
//  FitFin
//
//  Created by MAC OS 13 on 20/12/21.
//

import Foundation
import CoreData

//class LoggedUser: NSManagedObject ,ParentManagedObject {
//    
//    @NSManaged var userId: String
//    @NSManaged var isFirstTimeLoggedIn: Bool
//    @NSManaged var isAdmin: Bool
//    @NSManaged var email: String
//    @NSManaged var accessToken: String
//    
//    func initWith(_ dict: [String: Any]) {
//        
//        userId = RawdataConverter.string(dict["UserId"])
//        isFirstTimeLoggedIn = RawdataConverter.boolean(dict["IsFirstTimeLoggedIn"])
//        isAdmin = RawdataConverter.boolean(dict["IsAdmin"])
//        email = RawdataConverter.string(dict["Email"])
//        accessToken = RawdataConverter.string(dict["AccessToken"])
//        
//        WebService.shared.storeAuthorizationToken(accessToken)
//        //        if accessToken.isEmpty {
//        //            accessToken = RawdataConverter.string(dict["accessToken"])
//        //            WebService.shared.storeAuthorizationToken(accessToken)
//        //        }
//
//    }
//}
