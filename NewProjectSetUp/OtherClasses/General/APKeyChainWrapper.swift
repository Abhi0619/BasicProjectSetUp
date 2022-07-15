//
//  APKeyChainWrapper.swift
//  FitFin
//
//  Created by MAC OS 13 on 20/12/21.
//

import Foundation
import Security


class APKeychainWrapper: NSObject {
    
    static let shared: APKeychainWrapper = APKeychainWrapper()
    
    /// ServiceName is used for the kSecAttrService property to uniquely identify this keychain accessor. If no service name is specified, KeychainWrapper will default to using the bundleIdentifier.
    private (set) public var serviceName: String

    /// AccessGroup is used for the kSecAttrAccessGroup property to identify which Keychain Access Group this entry belongs to. This allows you to use the KeychainWrapper with shared keychain access between different applications.
    private (set) public var accessGroup: String?

    private static let defaultServiceName: String = {
        return Bundle.main.bundleIdentifier ?? "SwiftKeychainWrapper"
    }()

    private convenience override init() {
        self.init(serviceName: APKeychainWrapper.defaultServiceName)
    }
    
    /// Create a custom instance of KeychainWrapper with a custom Service Name and optional custom access group.
       ///
       /// - parameter serviceName: The ServiceName for this instance. Used to uniquely identify all keys stored using this keychain wrapper instance.
       /// - parameter accessGroup: Optional unique AccessGroup for this instance. Use a matching AccessGroup between applications to allow shared keychain access.
       public init(serviceName: String, accessGroup: String? = nil) {
           self.serviceName = serviceName
           self.accessGroup = accessGroup
       }
}


// MARK:- Public Methods
extension APKeychainWrapper {
    /// Checks if keychain data exists for a specified key.
    ///
    /// - parameter forKey: The key to check for.
    /// - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item. kSecAttrAccessibleAfterFirstUnlock
    /// - returns: True if a value exists for the key. False otherwise.
//    open func hasValue(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
//        if let _ = data(forKey: key, withAccessibility: accessibility) {
//            return true
//        } else {
//            return false
//        }
//    }
    
    
     /// Get the keys of all keychain entries matching the current ServiceName and AccessGroup if one is set.
     open func allKeys() -> Set<String> {
        var keychainQueryDictionary: [AnyHashable: Any] = [
             kSecClass: kSecClassGenericPassword,
             kSecAttrService: serviceName,
             kSecReturnAttributes: kCFBooleanTrue!,
             kSecMatchLimit: kSecMatchLimitAll,
         ]

         if let accessGroup = self.accessGroup {
             keychainQueryDictionary[kSecAttrAccessGroup] = accessGroup
         }

       
         var result: AnyObject?
         let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
 
         guard status == errSecSuccess else { return [] }

         var keys = Set<String>()
         if let results = result as? [[AnyHashable: Any]] {
             for attributes in results {
                if let accountData = attributes[kSecAttrAccount] as? Data,
                     let key = String(data: accountData, encoding: String.Encoding.utf8) {
                     keys.insert(key)
                 }
             }
         }
         return keys
     }
     
}
// MARK:-  Public Getters
extension APKeychainWrapper {
    
    open func integer(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Int? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }
        return numberValue.intValue
    }
    open func float(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Float? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }
        
        return numberValue.floatValue
    }
    
    open func double(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Double? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }
        
        return numberValue.doubleValue
    }
    
    open func bool(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool? {
        guard let numberValue = object(forKey: key, withAccessibility: accessibility) as? NSNumber else {
            return nil
        }
        
        return numberValue.boolValue
    }
    
    /// Returns a string value for a specified key.
    ///
    /// - parameter forKey: The key to lookup data for.
    /// - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
    /// - returns: The String associated with the key if it exists. If no data exists, or the data found cannot be encoded as a string, returns nil.
    open func string(forKey key: String, withAccessibility accessibility: CFString? = nil) -> String? {
        guard let keychainData = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }
        
        return String(data: keychainData, encoding: String.Encoding.utf8) as String?
    }
    /// Returns an object that conforms to NSCoding for a specified key.
    ///
    /// - parameter forKey: The key to lookup data for.
    /// - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
    /// - returns: The  object associated with the key if it exists. If no data exists, or the data  not found returns nil.
    open func object(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Any? {
        guard let keychainData = data(forKey: key, withAccessibility: accessibility) else {
            return nil
        }
        do {
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(keychainData)
        } catch _ {
            
        }
        return nil
    }
    
    /// Returns a Data object for a specified key.
    ///
    /// - parameter forKey: The key to lookup data for.
    /// - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
    /// - returns: The Data object associated with the key if it exists. If no data exists, returns nil.
    open func data(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        
        // Limit search results to one
        keychainQueryDictionary[kSecMatchLimit] = kSecMatchLimitOne
        
        // Specify we want Data/CFData returned
        keychainQueryDictionary[kSecReturnData] = kCFBooleanTrue
        
        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
    
    
    /// Returns a persistent data reference object for a specified key.
    ///
    /// - parameter forKey: The key to lookup data for.
    /// - parameter withAccessibility: Optional accessibility to use when retrieving the keychain item.
    /// - returns: The persistent data reference object associated with the key if it exists. If no data exists, returns nil.
    open func dataRef(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Data? {
        var keychainQueryDictionary = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        
        // Limit search results to one
        keychainQueryDictionary[kSecMatchLimit] = kSecMatchLimitOne
        
        // Specify we want persistent Data/CFData reference returned
        keychainQueryDictionary[kSecReturnPersistentRef] = kCFBooleanTrue
        
        // Search
        var result: AnyObject?
        let status = SecItemCopyMatching(keychainQueryDictionary as CFDictionary, &result)
        
        return status == noErr ? result as? Data : nil
    }
}
// MARK: - Public Setters
extension APKeychainWrapper {
    
    @discardableResult open func set(_ value: Int, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
          return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
      }
      
      @discardableResult open func set(_ value: Float, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
          return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
      }
      
      @discardableResult open func set(_ value: Double, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
          return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
      }
      
      @discardableResult open func set(_ value: Bool, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
          return set(NSNumber(value: value), forKey: key, withAccessibility: accessibility)
      }

      /// Save a String value to the keychain associated with a specified key. If a String value already exists for the given key, the string will be overwritten with the new value.
      ///
      /// - parameter value: The String value to save.
      /// - parameter forKey: The key to save the String under.
      /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
      /// - returns: True if the save was successful, false otherwise.
      @discardableResult open func set(_ value: String, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
          if let data = value.data(using: .utf8) {
              return set(data, forKey: key, withAccessibility: accessibility)
          } else {
              return false
          }
      }

      /// Save an NSCoding compliant object to the keychain associated with a specified key. If an object already exists for the given key, the object will be overwritten with the new value.
      ///
      /// - parameter value: The NSCoding compliant object to save.
      /// - parameter forKey: The key to save the object under.
      /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
      /// - returns: True if the save was successful, false otherwise.
    @discardableResult open func set(_ value: Any, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: value, requiringSecureCoding: true)
            return set(data, forKey: key, withAccessibility: accessibility)
        } catch _ {
            
        }
        return false
    }

      /// Save a Data object to the keychain associated with a specified key. If data already exists for the given key, the data will be overwritten with the new value.
      ///
      /// - parameter value: The Data object to save.
      /// - parameter forKey: The key to save the object under.
      /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item.
      /// - returns: True if the save was successful, false otherwise.
      @discardableResult open func set(_ value: Data, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
          var keychainQueryDictionary: [AnyHashable: Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
          
          keychainQueryDictionary[kSecValueData] = value
          
          if let accessibility = accessibility {
              keychainQueryDictionary[kSecAttrAccessible] = accessibility
          } else {
              // Assign default protection - Protect the keychain entry so it's only valid when the device is unlocked
              keychainQueryDictionary[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
          }
          
          let status: OSStatus = SecItemAdd(keychainQueryDictionary as CFDictionary, nil)
          
          if status == errSecSuccess {
              return true
          } else if status == errSecDuplicateItem {
              return update(value, forKey: key, withAccessibility: accessibility)
          } else {
              return false
          }
      }

      
      
      /// Remove an object associated with a specified key. If re-using a key but with a different accessibility, first remove the previous key value using removeObjectForKey(:withAccessibility) using the same accessibilty it was saved with.
      ///
      /// - parameter forKey: The key value to remove data for.
      /// - parameter withAccessibility: Optional accessibility level to use when looking up the keychain item.
      /// - returns: True if successful, false otherwise.
      @discardableResult open func removeObject(forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
          let keychainQueryDictionary: [AnyHashable: Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)

          // Delete
          let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)

          if status == errSecSuccess {
              return true
          } else {
              return false
          }
      }

      /// Remove all keychain data added through KeychainWrapper. This will only delete items matching the currnt ServiceName and AccessGroup if one is set.
      @discardableResult open func removeAllKeys() -> Bool {
          // Setup dictionary to access keychain and specify we are using a generic password (rather than a certificate, internet password, etc)
          var keychainQueryDictionary: [AnyHashable: Any] = [kSecClass: kSecClassGenericPassword]
          
          // Uniquely identify this keychain accessor
          keychainQueryDictionary[kSecAttrService] = serviceName
          
          // Set the keychain access group if defined
          if let accessGroup = self.accessGroup {
              keychainQueryDictionary[kSecAttrAccessGroup] = accessGroup
          }
          
          let status: OSStatus = SecItemDelete(keychainQueryDictionary as CFDictionary)
          
          if status == errSecSuccess {
              return true
          } else {
              return false
          }
      }
      
      /// Remove all keychain data, including data not added through keychain wrapper.
      ///
      /// - Warning: This may remove custom keychain entries you did not add via SwiftKeychainWrapper.
      ///
      open class func wipeKeychain() {
          deleteKeychainSecClass(kSecClassGenericPassword) // Generic password items
          deleteKeychainSecClass(kSecClassInternetPassword) // Internet password items
          deleteKeychainSecClass(kSecClassCertificate) // Certificate items
          deleteKeychainSecClass(kSecClassKey) // Cryptographic key items
          deleteKeychainSecClass(kSecClassIdentity) // Identity items
      }
}
// MARK:- Private Methods
extension APKeychainWrapper {
    
    /// Remove all items for a given Keychain Item Class
    @discardableResult private class func deleteKeychainSecClass(_ secClass: Any) -> Bool {
        let query: [AnyHashable: Any] = [kSecClass: secClass]
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }
    
    /// Update existing data associated with a specified key name. The existing data will be overwritten by the new data.
    private func update(_ value: Data, forKey key: String, withAccessibility accessibility: CFString? = nil) -> Bool {
        var keychainQueryDictionary: [AnyHashable: Any] = setupKeychainQueryDictionary(forKey: key, withAccessibility: accessibility)
        let updateDictionary: [AnyHashable: Any] = [kSecValueData: value]
        
        // on update, only set accessibility if passed in
        if let accessibility = accessibility {
            keychainQueryDictionary[kSecAttrAccessible] = accessibility
        }
        
        // Update
        let status: OSStatus = SecItemUpdate(keychainQueryDictionary as CFDictionary, updateDictionary as CFDictionary)

        if status == errSecSuccess {
            return true
        } else {
            return false
        }
    }

    /// Setup the keychain query dictionary used to access the keychain on iOS for a specified key name. Takes into account the Service Name and Access Group if one is set.
    ///
    /// - parameter forKey: The key this query is for
    /// - parameter withAccessibility: Optional accessibility to use when setting the keychain item. If none is provided, will default to .WhenUnlocked
    /// - returns: A dictionary with all the needed properties setup to access the keychain on iOS
    private func setupKeychainQueryDictionary(forKey key: String, withAccessibility accessibility: CFString? = nil) -> [AnyHashable: Any] {
        // Setup default access as generic password (rather than a certificate, internet password, etc)
        var keychainQueryDictionary: [AnyHashable: Any] = [kSecClass: kSecClassGenericPassword]
        
        // Uniquely identify this keychain accessor
        keychainQueryDictionary[kSecAttrService] = serviceName
        
        // Only set accessibiilty if its passed in, we don't want to default it here in case the user didn't want it set
        if let accessibility = accessibility {
            keychainQueryDictionary[kSecAttrAccessible] = accessibility
        }
        
        // Set the keychain access group if defined
        if let accessGroup = self.accessGroup {
            keychainQueryDictionary[kSecAttrAccessGroup] = accessGroup
        }
        
        // Uniquely identify the account who will be accessing the keychain
        let encodedIdentifier: Data? = key.data(using: String.Encoding.utf8)
        
        keychainQueryDictionary[kSecAttrGeneric] = encodedIdentifier
        
        keychainQueryDictionary[kSecAttrAccount] = encodedIdentifier
        
        return keychainQueryDictionary
    }
}


//STORE
//          APKeychainWrapper.shared.set(email, forKey: "email") // True if the save was successful, false otherwise.
//
//
//FETCH
//
//let email = APKeychainWrapper.shared.string(forKey: "email") //  If no data exists, or the data found cannot be encoded as a string, returns nil.
//
//DELETE
//          APKeychainWrapper.shared.removeObject(forKey: "email")

