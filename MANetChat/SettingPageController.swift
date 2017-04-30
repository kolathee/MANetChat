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
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var coreDataManager : CoreDataManager?

    override func viewDidLoad(){
        super.viewDidLoad()
        coreDataManager = appDelegate.coreDataManager
    }
    
    func handleLogout() {
        
        do {
        //1.Logout
            try FIRAuth.auth()?.signOut()
            
            //2.Remove all observers
            let rootNodeReference = FIRDatabase.database().reference(fromURL: "https://manetchat.firebaseio.com")
            rootNodeReference.removeAllObservers()
            
            //3.Remove all data
            appDelegate.clearAllData()
            coreDataManager?.deleteAllData(entity: "Friend")
            coreDataManager?.deleteAllData(entity: "MyInformation")
            
            //4.Show Login view
            dismiss(animated: false, completion: nil)
            
        } catch let logoutError {
            print(logoutError)
            showAlertMessage(title: "Fail to logout", message: "Please try again")
            return
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        handleLogout()
    }
    
    func showAlertMessage(title : String, message : String){
        let messageWindow = UIAlertController(title: title, message:message , preferredStyle: .alert)
        let action = UIAlertAction(title: "done", style: .cancel, handler: nil)
        messageWindow.addAction(action)
        self.present(messageWindow, animated: true, completion: nil)
    }
}
