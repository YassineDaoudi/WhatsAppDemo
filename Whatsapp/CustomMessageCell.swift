//
//  CustomMessageCell.swift
//  Flash Chat
//
//  Created by Angela Yu on 30/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {


    @IBOutlet var messageBackground: UIView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet weak var messageTameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code goes here
       
    }


}
extension UITableViewCell {
    func setTransparent() {
        let bgView: UIView = UIView()
        bgView.backgroundColor = .clear
        
        self.backgroundView = bgView
        self.backgroundColor = .clear
    }
}
