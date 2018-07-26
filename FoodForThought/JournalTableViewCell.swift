//
//  JournalTableViewCell.swift
//  FoodForThought
//
//  Created by Andy Adams on 7/24/18.
//  Copyright © 2018 Food For Thought. All rights reserved.
//

import UIKit

class JournalTableViewCell: UITableViewCell {


    @IBOutlet var entryTitle: UILabel!
    @IBOutlet var entryDate: UILabel!
    @IBOutlet var entryText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
