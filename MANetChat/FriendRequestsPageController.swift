//
//  friendRequestsPageController.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/24/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendRequestsPageController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func refreshButtonTapped(_ sender: Any) {
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.friendsRequest.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequestCell", for: indexPath) as! RequestsCell
        cell.FriendEmailLabel.text = appDelegate.friendsRequest[indexPath.row].name
        cell.acceptRequestButton.tag = indexPath.row
        return cell
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptButtonTapped(_ sender: Any) {
        acceptFriendRequest(indexOfRowSelected: (sender as AnyObject).tag)
    }
    
    func acceptFriendRequest(indexOfRowSelected:Int) {
        
        //1.Prepare data ==================================================================
        let rootNodeReference = FIRDatabase.database().reference(fromURL:"https://manetchat.firebaseio.com")
        let friend = appDelegate.friendsRequest[indexOfRowSelected] // Get information of who sent requesting.
        
        //2.Insert their information into "friends" child in my database ==================
        let myInsertReference = rootNodeReference.child("users").child(appDelegate.myUID!).child("friends").child(friend.uid)
        
        let myinsertValue = ["name":friend.name,"email":friend.email]
        myInsertReference.updateChildValues(myinsertValue)
        
        //3.Delete a friend in friendRequests from my database ============================
        let myDeleteReference = rootNodeReference.child("users").child(appDelegate.myUID!).child("friendRequests").child(friend.uid)
        myDeleteReference.removeValue()
        
        //4.insert my information into "friends" child in their database ==================
        let friendInsertReference = rootNodeReference.child("users").child(friend.uid).child("friends").child(appDelegate.myUID!)
        
        let friendInsertValue = ["name":appDelegate.myName,"email":appDelegate.myEmail]
        friendInsertReference.updateChildValues(friendInsertValue)
        
        //5.Delete the request from friend's requested database ===========================
        let friendDeleteReference = rootNodeReference.child("users").child(friend.uid).child("requested").child(appDelegate.myUID!)
        friendDeleteReference.removeValue()

        //6.Delete frined who sent requesting from frinedsReuest in appDelegate
        appDelegate.friendsRequest.remove(at: indexOfRowSelected)
    }
}
