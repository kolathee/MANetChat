//
//  User.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/25/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit

class User: NSObject {
    
    private var _name:String!
    private var _uid:String!
    private var _email:String!
    
    var name:String {
        get {
            return _name
        }
        set(name) {
            _name = name
        }
    }
    
    var uid:String {
        get {
            return _uid
        }
        set(uid) {
            _uid = uid
        }
    }
    
    var email:String {
        get {
            return _email
        }
        set(email){
            _email = email
        }
    }
}
