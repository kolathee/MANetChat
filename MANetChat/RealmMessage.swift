//
//  RealmMessage.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 5/18/2560 BE.
//  Copyright © 2560 Kolathee Payuhawattana. All rights reserved.
//

import Foundation
import RealmSwift

class RealmMessage: Object {
    dynamic var sender      : String?
    dynamic var receiver    : String?
    dynamic var message     : String?
    dynamic var timestamp   : NSDate?
}
