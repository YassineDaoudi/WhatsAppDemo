//
//  CustomChatCell.swift
//  Flash Chat
//
//  Created by Findl MAC on 25/09/2018.
//

import UIKit

class CustomChatCell: UITableViewCell {

    @IBOutlet weak var receivedTimeLabel: UILabel!
    @IBOutlet weak var senderAvatar: UIImageView!
    @IBOutlet weak var senderNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
