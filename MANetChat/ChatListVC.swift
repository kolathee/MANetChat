//
//  ChatListVC.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/27/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit

class ChatListVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "privateChatCell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }
}
