//
//  PinAnnotation.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/30/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import Foundation
import MapKit

class PinAnnotation:NSObject, MKAnnotation {
    
    
    var coordinate = CLLocationCoordinate2D()
    var pinType:String
    var title: String?

    init (coordinate:CLLocationCoordinate2D ,type: String) {
        self.coordinate = coordinate
        self.pinType = type
        
        if pinType == "red_pin" {
            title = "Dangerous place!"
        } else if pinType == "green_pin" {
            title = "Safe place"
        }
    }
    
    init (coordinate:CLLocationCoordinate2D ,username: String) {
        self.coordinate = coordinate
        self.pinType = "person_pin"
        self.title = username
    }
}
