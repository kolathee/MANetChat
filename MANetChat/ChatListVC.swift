//
//  ChatListVC.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/27/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit

class ChatListVC: UIViewController,UITableViewDataSource,UITableViewDelegate,MPCManagerConnectionStatus {
    
    @IBOutlet weak var tableView: UITableView!
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mpcManager:MPCManager?
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        mpcManager = appDelegate.mpcManager
        mpcManager?.connectionStatusDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.items?[1].badgeValue = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.onlineFriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "privateChatCell", for: indexPath) as! FriendViewCell
        cell.friendName.text = appDelegate.onlineFriends[indexPath.row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPrivateChat" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = segue.destination as! PrivateChatVC
                let friend = appDelegate.onlineFriends[indexPath.row]
                controller.chatingFriend = friend.name
                controller.friendUID = friend.uid
            }
        }
    }
    
    func connectionDidChange() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
