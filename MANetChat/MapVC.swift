//
//  MapVC.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/26/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import FirebaseDatabase
import GeoFire

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var victims = [PinAnnotation]()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    var geoFireRedNoti: GeoFire!
    var geoFireGreenNoti: GeoFire!
    var geoFireVictims: GeoFire!
    
    var geoFireRedNotiRef: FIRDatabaseReference!
    var geoFireGreenNotiRef: FIRDatabaseReference!
    var geoFireVictimsRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFireRedNotiRef = FIRDatabase.database().reference().child("geoFire/red")
        geoFireGreenNotiRef = FIRDatabase.database().reference().child("geoFire/green")
        geoFireVictimsRef = FIRDatabase.database().reference().child("geoFire/victims")
        
        geoFireRedNoti = GeoFire(firebaseRef: geoFireRedNotiRef)
        geoFireGreenNoti = GeoFire(firebaseRef: geoFireGreenNotiRef)
        geoFireVictims = GeoFire(firebaseRef: geoFireVictimsRef)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        locationAuthStatus()
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        showSightingsOnMap(location: loc)
    }
    
    // Called when annotation is added to mapView.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annoIdentifier = "Pokemon"
        var annotationView: MKAnnotationView?
        
        if annotation.isKind(of: MKUserLocation.self) {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.image = UIImage(named: "ash")
            
        } else if let deqAnno = mapView.dequeueReusableAnnotationView(withIdentifier: annoIdentifier) {
            annotationView = deqAnno
            annotationView?.annotation = annotation
            
        } else {
            let annoView = MKAnnotationView(annotation: annotation, reuseIdentifier: annoIdentifier)
            annoView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            annotationView = annoView
        }
        
        if let annotationView = annotationView, let anno = annotation as? PinAnnotation {
            
            annotationView.canShowCallout = true
            annotationView.image = UIImage(named: "\(anno.pinType)")
            let btn = UIButton()
            btn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            btn.setImage(UIImage(named: "map"), for: .normal)
            annotationView.rightCalloutAccessoryView = btn
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if let anno = view.annotation as? PinAnnotation {
            
            var place: MKPlacemark!
            if #available(iOS 10.0, *) {
                place = MKPlacemark(coordinate: anno.coordinate)
            } else {
                place = MKPlacemark(coordinate: anno.coordinate, addressDictionary: nil)
            }
            
            let destination = MKMapItem(placemark: place)
            destination.name = "\(anno.title!)"
            
            let regionDistance: CLLocationDistance = 1000
            let region = MKCoordinateRegionMakeWithDistance(anno.coordinate, regionDistance, regionDistance)
            
            let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: region.center), MKLaunchOptionsMapSpanKey:  NSValue(mkCoordinateSpan: region.span), MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving] as [String : Any]
            
            MKMapItem.openMaps(with: [destination], launchOptions: options)
        }
        
    }
    
    func showSightingsOnMap(location: CLLocation) {
        
        //Reset(REMOVE ALL) all of annotation on the map.
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        
        let circleQueryRedNoti = geoFireRedNoti!.query(at: location, withRadius: 5)
        let circleQueryGreenNoti = geoFireGreenNoti!.query(at: location, withRadius: 5)
        
        let circleQueryVictimEntered = geoFireVictims!.query(at: location, withRadius: 5)
        let circleQueryVictimExited = geoFireVictims!.query(at: location, withRadius: 5)
        
        //Victim Notification Observer
        _ = circleQueryVictimEntered?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let key = key, let location = location {
                let anno = PinAnnotation(coordinate: location.coordinate, username: key)
                self.mapView.addAnnotation(anno)
                print("Found : \(key)")
            }
        })
        
        _ = circleQueryVictimExited?.observe(GFEventType.keyExited, with: { (key, location) in
            if let key = key, let location = location {
                print("Exited : \(key)")
            }
        })
        
        //Red Pin Notification Observer
        _ = circleQueryRedNoti?.observe(GFEventType.keyEntered, with: { (key, location) in
            if let key = key, let location = location {
                let anno = PinAnnotation(coordinate: location.coordinate, type: "red_pin")
                self.mapView.addAnnotation(anno)
            }
        })
        //Green Pin Notification Observer
        _ = circleQueryGreenNoti?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            if let key = key, let location = location {
                let anno = PinAnnotation(coordinate: location.coordinate, type: "green_pin")
                self.mapView.addAnnotation(anno)
                print("Found Green Pin : \(key)")
            }
        })
        
    }
    
    func saveVictimLocationToFirebase(forLocation location: CLLocation, withUsername name: String) {
        geoFireVictims.setLocation(location, forKey: "\(name)")
        showSightingsOnMap(location:location)
    }
    
    @IBAction func sendLocationButtonWasTapped(_ sender: AnyObject) {
        let loc = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        saveVictimLocationToFirebase(forLocation: loc, withUsername: (appDelegate?.myName)!)
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    //Back to current user location
    @IBAction func userLogoTapped(_ sender: Any) {
        let userLocation = locationManager.location
        centerMapOnLocation(location: userLocation!)
    }
}
