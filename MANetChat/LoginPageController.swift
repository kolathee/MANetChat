//
//  LoginPageController.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/23/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginPageController: UIViewController {
    
    @IBOutlet weak var inputEmailTextBox: UITextField!
    @IBOutlet weak var inputPasswordTextBox: UITextField!
    
    
    //used to count FriendsRequest in createFriendRequestListener() function.
    var friendRequestsUIDList = [String]()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil {
            createFriendRequestListener()
            goToUserMainView()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        handleLogin()
    }
    
    func handleLogin() {
        
        let email = inputEmailTextBox.text
        let password = inputPasswordTextBox.text
        
        guard email != "" , password != "" else {
            print("Form is not valid")
            self.alertUser(title: "Form is not vaild", message: "Please try again")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!, completion: { (user, error) in
            if error != nil{
                print("Sign in error - code:\(error)")
                self.alertUser(title: "Error", message: "Please try again")
                return
            } else {
                self.appDelegate.currentUser = FIRAuth.auth()?.currentUser
                self.appDelegate.myEmail = self.appDelegate.currentUser?.email
                self.appDelegate.myUID = self.appDelegate.currentUser?.uid

                self.createFriendRequestListener()
                self.goToUserMainView()
            }
        })
    }
    
    func alertUser(title:String , message:String) -> Void {
        let messageWindows = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "done", style: .cancel, handler: nil)
        messageWindows.addAction(action)
        self.present(messageWindows, animated: true, completion: nil)
    }
    
    func goToUserMainView() {
        let tabBarPage = self.storyboard?.instantiateViewController(withIdentifier: "tabBarPage") as! TabBarController
        self.present(tabBarPage, animated: false, completion: nil)
    }
    
    func createFriendRequestListener(){
        if let myUID = FIRAuth.auth()?.currentUser?.uid {
            //Create listener
            let friendRequestReferance = FIRDatabase.database().reference(fromURL:"https://manetchat.firebaseio.com/").child("users").child(myUID).child("friendRequests")
            friendRequestReferance.observe(.value, with: { (snapshot) in
                //Get friendsRequest and put it into friendsRequest in AppDelegate
                if let users = snapshot.value as? Dictionary<String,AnyObject>{

                    for (key, value) in users {
                        let name = value.objectAt(0)
                        let email = value.objectAt(1)
                        let uid = key

                        if !self.friendRequestsUIDList.contains(uid){
                            let user = User()
                            user.uid = uid
                            user.email = email as! String
                            user.name = name as! String
                            self.friendRequestsUIDList.append(uid)
                            //keep each user's requesting into friendsRequest in share application.
                            self.appDelegate.friendsRequest.append(user)
                        }
                    }
                }
            })
        }
    }
}
