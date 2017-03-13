//
//  FriendsRequestTableViewCell.swift
//  MANetChat
//
//  Created by Kolathee Payuhawatthana on 12/24/2559 BE.
//  Copyright © 2559 Kolathee Payuhawattana. All rights reserved.
//

import UIKit

class RequestsCell: UITableViewCell {

    @IBOutlet weak var FriendEmailLabel: UILabel!
    @IBOutlet weak var acceptRequestButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
