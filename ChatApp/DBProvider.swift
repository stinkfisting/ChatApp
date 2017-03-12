//
//  DBProvider.swift
//  ChatApp
//
//  Created by Marcus Tam on 3/11/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import Foundation
import Firebase

protocol FetchData: class {
    
    func dataReceived(contacts: [Contact])
    
}

class DBProvider {
    
    private static let _instance = DBProvider()
    
    weak var delegate: FetchData?
    
    private init() {} //Make sure that none other class will be able to create another object from this class 
    
    static var Instance: DBProvider {
        return _instance
    }
    
    
    var dbREF: FIRDatabaseReference {
        return FIRDatabase.database().reference()
    }
    
    var contactsREF: FIRDatabaseReference {
        return dbREF.child(Constants.CONTACTS)
    }
    
    var messagesREF: FIRDatabaseReference {
        return dbREF.child(Constants.MESSAGES)
    }
    
    var mediaMessagesREF: FIRDatabaseReference {
        return dbREF.child(Constants.MEDIA_MESSAGES)
    }
    
    var storageREF: FIRStorageReference {
        return FIRStorage.storage().reference(forURL: "gs://socialmedia-41d3d.appspot.com/")
    }
    
    var imageStorageREF: FIRStorageReference {
        return storageREF.child(Constants.IMAGE_STORAGE)
    }
    
    var videoStorageREF: FIRStorageReference {
        return storageREF.child(Constants.VIDEO_STORAGE)
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email,
                                             Constants.PASSWORD: password]
        
        contactsREF.child(withID).setValue(data)
    }
    
    func getContacts() {
        
        contactsREF.observeSingleEvent(of: .value, with: { (snapshot) in
            var contacts = [Contact]()
            
            if let myContacts = snapshot.value as? NSDictionary {
                for (key, value) in myContacts {
                    if let contactData = value as? NSDictionary {
                        if let email = contactData[Constants.EMAIL] as? String {
                            
                            let id = key as! String
                            let newContact = Contact(id: id, name: email)
                            contacts.append(newContact)
                        }
                    }
                }
            }
         
            self.delegate?.dataReceived(contacts: contacts)
        })
        
    }
    
}






































