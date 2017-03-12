//
//  ChatVC.swift
//  ChatApp
//
//  Created by Marcus Tam on 3/11/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVKit
import MobileCoreServices
import Firebase
import SDWebImage

class ChatVC: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessageReceivedDelegate {
    
    private var messages = [JSQMessage]()
    
    let picker = UIImagePickerController()
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        MessagesHandler.Instance.delegate = self
        picker.delegate = self

        self.senderId = AuthProvider.Instance.userID()
        self.senderDisplayName = AuthProvider.Instance.userName
        MessagesHandler.Instance.observeMessages()
        MessagesHandler.Instance.observeMediaMessages()
    }
    
    //CollectionView Functions
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "Snapshot"), diameter: 30)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        let message = messages[indexPath.item]
        
        if message.senderId == self.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor.green)

        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: UIColor.blue)

        }
        
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
        let msg = messages[indexPath.item]
        
        if msg.isMediaMessage {
            if let mediaItem = msg.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.present(playerController, animated: true, completion: nil)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        return cell
    }

    //End CollectionView Functions
    
    //Sending Buttons FUnctions
    
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        MessagesHandler.Instance.sendMessage(senderID: senderId, senderName: senderDisplayName, text: text)
        
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()

        //This will remove text from the text field
        finishSendingMessage()
    }

    override func didPressAccessoryButton(_ sender: UIButton!) {
        let alert = UIAlertController(title: "Media Messages", message: "Please select a media", preferredStyle: .actionSheet)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let photos = UIAlertAction(title: "Photos", style: .default) { (alert) in
            self.chooseMedia(type: kUTTypeImage)
        }
        
        let videos = UIAlertAction(title: "Videos", style: .default) { (alert) in
            self.chooseMedia(type: kUTTypeMovie)
        }
        
        alert.addAction(photos)
        alert.addAction(cancel)
        alert.addAction(videos)

        present(alert, animated: true, completion: nil)
        
    }
    
    //End Sending Buttons Functions 
    
    //PickerView Functions
    
    private func chooseMedia(type: CFString) {
        picker.mediaTypes = [type as String]
        present(picker, animated: true, completion: nil)
        
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pic = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let data = UIImageJPEGRepresentation(pic, 0.1)
            
            MessagesHandler.Instance.sendMedia(image: data, video: nil, senderID: senderId, senderName: senderDisplayName)
            
        } else if let vidUrl = info[UIImagePickerControllerMediaURL] as? URL {
            
            MessagesHandler.Instance.sendMedia(image: nil, video: vidUrl, senderID: senderId, senderName: senderDisplayName)

            
        }
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
    
    //End PickerView Functions
    
    //Delegation Functions
    
    func messageReceived(senderID: String, senderName: String, text: String) {
        
        messages.append(JSQMessage(senderId: senderID, displayName: senderName, text: text))
        collectionView.reloadData()
    }
    
    func mediaReceived(senderID: String, senderName: String, url: String) {
        
        if let mediaURL = URL(string: url) {
            
            do {
                
                let data = try Data(contentsOf: mediaURL)
                
                if let _ = UIImage(data: data) {
                    
                    let _ = SDWebImageDownloader.shared().downloadImage(with: mediaURL, options: [], progress: nil, completed: { (image, data, error, finished) in
                        
                        DispatchQueue.main.async {
                            let photo = JSQPhotoMediaItem(image: image)
                            
                            if senderID == self.senderId {
                                photo?.appliesMediaViewMaskAsOutgoing = true
                                
                            } else {
                                photo?.appliesMediaViewMaskAsOutgoing = false
                            }
                            
                            self.messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: photo))
                            self.collectionView.reloadData()
                        }
                        
                    })
                    
                } else {
                    let video = JSQVideoMediaItem(fileURL: mediaURL, isReadyToPlay: true)
                    
                    if senderID == self.senderId {
                        video?.appliesMediaViewMaskAsOutgoing = true
                    } else {
                        video?.appliesMediaViewMaskAsOutgoing = false
                    }
                    
                    messages.append(JSQMessage(senderId: senderID, displayName: senderName, media: video))
                    self.collectionView.reloadData()
                }
                
            } catch {
                //Here we catch all potential errors
            }
            
        }
        
    }
    
    //End Delegation Functions
    
    
    @IBAction func backBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
}













