//
//  ContactsVC.swift
//  ChatApp
//
//  Created by Marcus Tam on 3/10/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import UIKit

class ContactsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FetchData {

    @IBOutlet weak var myTable: UITableView!
    private let CHAT_SEGUE = "ChatSegue"
    
    private var contacts = [Contact]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        DBProvider.Instance.delegate = self
        DBProvider.Instance.getContacts()
    }
    
    func dataReceived(contacts: [Contact]) {
        self.contacts = contacts
        
        // Get the name of current user 
        for contact in contacts {
            if contact.id == AuthProvider.Instance.userID() {
                
            }
        }
        
        myTable.reloadData()
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = contacts[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: CHAT_SEGUE, sender: nil)
    }

    @IBAction func logOut(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            dismiss(animated: true, completion: nil)
        }

    }
    

} //Class
