//
//  ShowNearbyUserVC.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 2/6/2560 BE.
//  Copyright © 2560 Kolathee Payuhawattana. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ShowNearbyUserVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var connectedPeers = [MCPeerID]()

    override func viewDidLoad() {
        super.viewDidLoad()
        connectedPeers = (appDelegate.mpcManager?.connectedPeers)!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return connectedPeers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyUserCell", for: indexPath)
        cell.textLabel?.text = connectedPeers[indexPath.row].displayName
        return cell
    }
    
    @IBAction func exitButtonWasTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
