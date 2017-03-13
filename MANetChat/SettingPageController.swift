//
//  SettingPageController.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/23/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SettingPageController: UIViewController {
    
    @IBOutlet weak var profileBackground: UIImageView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        profileBackground.layer.cornerRadius = profileBackground.frame.size.width/2

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleLogout() {
        
        do {
        //1.Logout
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
            return
        }
        //2.Remove all observers
        let rootNodeReference = FIRDatabase.database().reference(fromURL: "https://manetchat.firebaseio.com")
        rootNodeReference.removeAllObservers()
        
        //3.Remove all data
        appDelegate.clearAllData()
        
        //4.Show Login view
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func logoutButtonWasTapped(_ sender: Any) {
        handleLogout()
    }
}
