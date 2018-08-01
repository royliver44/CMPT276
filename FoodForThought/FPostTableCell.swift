//
//  BrowseTableViewCell.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 7/25/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class BrowseTableViewCell: UITableViewCell {

    @IBOutlet var authorView: UIView!
    @IBOutlet var usernameButton: UIButton!
    @IBOutlet var reputationLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    
    @IBOutlet var postView: UIView!
    @IBOutlet var bodyTextButton: UIButton!
    @IBOutlet var likesLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var postDetailsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func FollowPressed() {
        print("follow")
    }
    
    @IBAction func PostDetailsButtonPressed(_ sender: Any){
        print("details");
    }
}
