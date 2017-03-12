//
//  Contact.swift
//  ChatApp
//
//  Created by Marcus Tam on 3/11/17.
//  Copyright © 2017 Marcus Tam. All rights reserved.
//

import Foundation


class Contact {
    
    private var _name = ""
    private var _id = ""
    
    init(id: String, name: String) {
        _id = id
        _name = name
    }
    
    var name: String {
        get {
            return _name
        }
    }
    
    var id: String {
        
        return _id
    }
    
}
































