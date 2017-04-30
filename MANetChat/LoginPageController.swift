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

class LoginPageController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var inputEmailTextBox: UITextField!
    @IBOutlet weak var inputPasswordTextBox: UITextField!
    
    //used to count FriendsRequest in createFriendRequestListener() function.
    var friendRequestsUIDList = [String]()
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var coreDataManager : CoreDataManager!
    var friendsListComplete : Bool!
    var myInformationComplete : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FIRAuth.auth()?.currentUser != nil {
            setUpData()
        }
    }

    func setUpData(){
        appDelegate.coreDataManager = CoreDataManager()
        coreDataManager = appDelegate.coreDataManager
        friendsListComplete = false
        myInformationComplete = false
        getFriendRequestsFromFirebase()
        getMyInformationFromFirebase()
        getFriendsListFromFirebase()
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
                print("Sign in error - code:\(String(describing: error))")
                self.alertUser(title: "Error", message: "Please try again")
                return
            } else {
                self.appDelegate.currentUser = FIRAuth.auth()?.currentUser
                self.appDelegate.myEmail = self.appDelegate.currentUser?.email
                self.appDelegate.myUID = self.appDelegate.currentUser?.uid
                self.setUpData()
            }
        })
    }
    
    func getMyInformationFromFirebase(){
        //Get user's name
        let ref = FIRDatabase.database().reference()
        ref.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).queryLimited(toLast:3).observe(.value, with: { (snapshot) in
            if let user = snapshot.value as? Dictionary<String,AnyObject>{
                let uid = snapshot.key
                let name = user["name"] as! String
                let email = user["email"] as! String
                self.appDelegate.myName = name
                //Create MPCManager with User's name
                self.setUpMPCManager(with_name: self.appDelegate.myName!)
                if !(self.coreDataManager.addMyInformation(uid: uid, name: name, email: email)){
                    print("Error : It's not able to add user data to CoreData")
                }
                
                self.myInformationComplete = true
                if self.myInformationComplete && self.friendsListComplete {
                    self.goToUserMainView()
                }
            }
        })
    }
    
    func getFriendsListFromFirebase(){
        if let myUID = FIRAuth.auth()?.currentUser?.uid {
            let ref = FIRDatabase.database().reference().child("users").child(myUID).child("friends")
            ref.queryOrdered(byChild: "date").observe(.value, with: { (snapshot) in
                self.appDelegate.friends.removeAll()
                if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                    for snap in snapshot {
                        if let detail = snap.value as? [String:AnyObject] {
                            let user = User()
                            user.uid = snap.key
                            user.name = detail["name"] as! String
                            user.email = detail["email"] as! String
                            user.date = String(describing:detail["date"])
                            
                            if !(self.coreDataManager.addFriend(uid: user.uid,
                                                                name: user.name,
                                                                email: user.email,
                                                                date: user.date)){
                                print("Error : can't add user uid '\(user.uid)' to CoreData")
                            }
                            self.appDelegate.friends.append(user)
                            print(self.appDelegate.friends)
                        }
                    }
                    
                    self.friendsListComplete = true
                    if self.myInformationComplete && self.friendsListComplete {
                        self.goToUserMainView()
                    }
                }
            })
        }
    }

    func getFriendRequestsFromFirebase(){
        if let myUID = FIRAuth.auth()?.currentUser?.uid {
            let ref = FIRDatabase.database().reference()
            //Create listener
            let friendRequestReferance = ref.child("users").child(myUID).child("friendRequests")
            friendRequestReferance.observe(.value, with: { (snapshot) in
                //Get friendsRequest and put it into friendsRequest in AppDelegate
                print(snapshot)
                if let users = snapshot.value as? Dictionary<String,AnyObject>{
                    for (key, value) in users {
                        let name = value.objectAt(0)
                        let email = value.objectAt(1)
                        let uid = key
                        
                        let user = User()
                        user.uid = uid
                        user.email = email as! String
                        user.name = name as! String
                        
                        self.appDelegate.friendsRequest.append(user)
                        print(self.appDelegate.friendsRequest)
                    }
                }
            })
        }
    }
    
    func alertUser(title:String , message:String) -> Void {
        let messageWindows = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "done", style: .cancel, handler: nil)
        messageWindows.addAction(action)
        self.present(messageWindows, animated: true, completion: nil)
    }
    
    func goToUserMainView() {
        let tabBarPage = self.storyboard?.instantiateViewController(withIdentifier: "tabBarPage") as! TabBarController
        self.present(tabBarPage, animated: false, completion: nil)
    }
    
    func setUpMPCManager(with_name name:String){
        self.appDelegate.mpcManager = MPCManager(userName: name)
        self.appDelegate.mpcManager?.advertiser.startAdvertisingPeer()
        self.appDelegate.mpcManager?.browser.startBrowsingForPeers()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            if textField == inputEmailTextBox {
                inputPasswordTextBox.becomeFirstResponder()
            } else if textField == inputPasswordTextBox {
                inputPasswordTextBox.resignFirstResponder()
                handleLogin()
            }
            return false
        }
        return true
    }

}
