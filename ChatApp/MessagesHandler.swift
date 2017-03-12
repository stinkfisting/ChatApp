//
//  MessagesHandler.swift
//  ChatApp
//
//  Created by Marcus Tam on 3/11/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import Foundation
import Firebase

protocol MessageReceivedDelegate: class {
    
    func messageReceived(senderID: String, senderName: String, text: String)
    func mediaReceived(senderID: String, senderName: String, url: String)
}

class MessagesHandler {
    
    weak var delegate: MessageReceivedDelegate?
    
    private static let _instance = MessagesHandler()
    
    private init() {}
    
    static var Instance: MessagesHandler {
        return _instance
    }

    
    func sendMessage(senderID: String, senderName: String, text: String) {
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID: senderID,
                                             Constants.SENDER_NAME: senderName,
                                             Constants.TEXT: text]
        
        DBProvider.Instance.messagesREF.childByAutoId().setValue(data)
    }
    
    func sendMediaMessage(senderID: String, senderName: String, url: String) {
        
        let data: Dictionary<String, Any> = [Constants.SENDER_ID :senderID,
                                              Constants.SENDER_NAME: senderName,
                                              Constants.URL: url]
        
        DBProvider.Instance.mediaMessagesREF.childByAutoId().setValue(data)
    }
    
    
    func sendMedia(image: Data?, video: URL?, senderID: String, senderName: String) {
        if image != nil {
            
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DBProvider.Instance.imageStorageREF.child(senderID + "\(NSUUID().uuidString).jpg").put(image!, metadata: metadata, completion: { (metadata, err) in
                
                if err != nil {
                    //INFORM the user that there was a problem uploading the image
                } else {
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
                    
                }
            })
            
        } else {
            
            DBProvider.Instance.videoStorageREF.child(senderID + "\(NSUUID().uuidString)").putFile(video!, metadata: nil, completion: { (MetaData, error) in
                
                if error != nil {
                    //Inform the user that there was sa problem uploading the Video
                } else {
                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: MetaData!.downloadURL()!))
                }
            
            })
        }
    }
    
    func observeMessages() {
        DBProvider.Instance.messagesREF.observe(.childAdded, with: { (snapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let senderID = data[Constants.SENDER_ID] as? String {
                    if let senderName = data[Constants.SENDER_NAME] as? String {
                        if let text = data[Constants.TEXT] as? String {
                            self.delegate?.messageReceived(senderID: senderID, senderName: senderName, text: text)
                        }
                    }
                }
            }
        })
    }
    
    func observeMediaMessages() {
        DBProvider.Instance.mediaMessagesREF.observe(.childAdded, with: { (snapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let senderID = data[Constants.SENDER_ID] as? String {
                    if let name = data[Constants.SENDER_NAME] as? String {
                        if let fileUrl = data[Constants.URL] as? String {
                            self.delegate?.mediaReceived(senderID: senderID, senderName: name, url: fileUrl)
                        }
                    }
                }
            }
        })
    }
    
    
} //Class



