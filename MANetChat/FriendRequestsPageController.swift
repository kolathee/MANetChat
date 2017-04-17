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
    let dbRef = FIRDatabase.database().reference()
    
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
        
        let date = FIRServerValue.timestamp()
        let friend = appDelegate.friendsRequest[indexOfRowSelected] // Get information whose senting request.
        
        //2.Insert their information into "friends" child in my database ==================
        let myRef = dbRef.child("users").child(appDelegate.myUID!)
        let myInsertRef = myRef.child("friends").child(friend.uid)
        let myDeleteRef = myRef.child("friendRequests").child(friend.uid)
        let myinsertValue = ["name":friend.name, "email":friend.email, "date": date] as [String : Any]
        myInsertRef.updateChildValues(myinsertValue)
        myDeleteRef.removeValue()

        let friendRef = dbRef.child("users").child(friend.uid)
        let friendInsertRef = friendRef.child("friends").child(appDelegate.myUID!)
        let friendDeleteRef = friendRef.child("requested").child(appDelegate.myUID!)
        let friendInsertValue = ["name":appDelegate.myName!,"email":appDelegate.myEmail!,"date": date] as [String : Any]
        friendInsertRef.updateChildValues(friendInsertValue)
        friendDeleteRef.removeValue()

        //6.Delete frined who sent requesting from frinedsReuest in appDelegate
        appDelegate.friendsRequest.remove(at: indexOfRowSelected)
        
        //7.Reload Table
        tableView.reloadData()
    }
}
