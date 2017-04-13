//
//  TabBarController.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/22/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class TabBarController: UITabBarController {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor.white
        setUpData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.selectedIndex != 0 {
            self.selectedIndex = 0
        }
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginPageController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginPage")
        present(loginPageController, animated:true, completion:nil)
    }
    
    func setUpData(){
        
        //Get uid, email
        self.appDelegate.currentUser = FIRAuth.auth()?.currentUser
        self.appDelegate.myEmail = FIRAuth.auth()?.currentUser?.email
        self.appDelegate.myUID = FIRAuth.auth()?.currentUser?.uid
        
        //Get user's name
        let myReference = FIRDatabase.database().reference(fromURL: "https://manetchat.firebaseio.com")
        myReference.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).queryLimited(toLast:3).observe(.value, with: { (snapshot) in
            if let user = snapshot.value as? Dictionary<String,AnyObject>{
                for (key,value) in user {
                    if key == "name" {
                        self.appDelegate.myName = value as? String
                        //Create MPCManager with User's name
                        self.appDelegate.mpcManager = MPCManager(userName: self.appDelegate.myName!)
                        self.appDelegate.mpcManager?.advertiser.startAdvertisingPeer()
                        self.appDelegate.mpcManager?.browser.startBrowsingForPeers()
                    }
                }
            }
        })
    }
}
