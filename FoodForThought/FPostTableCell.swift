//
//  BrowseTableViewCell.swift
//  FPostTableCell
//
//  Created by Jordan Ehrenholz on 7/25/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class FPostTableCell: UITableViewCell
{
    var postData: Post = Post()
    var authorData: Author = Author()
    
    // UI outlets
    @IBOutlet var authorView: UIView!
    @IBOutlet var usernameButton: UIButton!
    @IBOutlet var reputationLabel: UILabel!
    @IBOutlet var postView: UIView!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var loveLabel: UILabel!
    @IBOutlet var loveButton: UIButton!
    @IBOutlet var hateButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    // triggered when the love button of this cell is pressed
    @IBAction func LoveButtonPressed(_ sender: UIButton)
    {
        // update the database with this users new love status for this post
        let signInStatus: String = GenerateUIDandTicket()
        var request: String = "CL" + signInStatus + delimChar + postData.ID! + delimChar
        if (postData.userLoveStatus == "0")
        {
            // set loveStatus was 0, set it to 1
            request = request + "1"
            let response: String = TalkToServer(outgoingMessage: request)
            if (response != successHeader)
            {
                // cannot reach server, visual error message and return
                return
            }
            else
            {
                // update love count, user love status, and UI
                postData.userLoveStatus = "1"
                postData.loveCount = String(Int(postData.loveCount!)! + 1)
                UpdateUI()
            }
        }
        else if (postData.userLoveStatus == "1")
        {
            // loveStatus was 1, set it to 0 (unlove)
            request = request + "0"
            let response: String = TalkToServer(outgoingMessage: request)
            if (response != successHeader)
            {
                // cannot reach server, visual error message and return
            }
            else
            {
                // update love count, user love status, and UI
                postData.userLoveStatus = "0"
                postData.loveCount = String(Int(postData.loveCount!)! - 1)
                UpdateUI()
            }
        }
    }
    
    // triggered when the hate button of this cell is pressed
    @IBAction func HateButtonPressed(_ sender: UIButton)
    {
        let signInStatus: String = GenerateUIDandTicket()
        if (signInStatus == "0")
        {
            // segue to login view
            return
        }
        
        // change the user's love status for this post
        var request: String = "CL" + signInStatus + delimChar + postData.ID! + delimChar
        if (postData.userLoveStatus == "0")
        {
            // set loveStatus was 0, set it to -1
            request = request + "-1"
            let response: String = TalkToServer(outgoingMessage: request)
            if (response != successHeader)
            {
                // cannot reach server, visual error message and return
                return
            }
            else
            {
                // update love count, user love status, and UI
                postData.userLoveStatus = "-1"
                postData.loveCount = String(Int(postData.loveCount!)! - 1)
                UpdateUI()
            }
        }
        else if (postData.userLoveStatus == "-1")
        {
            // LoveStatus was -1, set it to 0 (unhate)
            request = request + "0"
            let response: String = TalkToServer(outgoingMessage: request)
            if (response != successHeader)
            {
                // cannot reach server, visual error message and return
                return
            }
            else
            {
                // update love count, user love status, and UI
                postData.userLoveStatus = "0"
                postData.loveCount = String(Int(postData.loveCount!)! + 1)
                UpdateUI()
            }
        }
    }
    
    // refreshes the UI objects of this post cell
    func UpdateUI()
    {
        // user's name
        if (authorData.ID == "0")
        {
            usernameButton.setTitle("anonymous", for: UIControlState.normal)
            usernameButton.setTitleColor(UIColor.black, for: UIControlState.normal)
        }
        else
        {
            usernameButton.setTitle(authorData.name, for: UIControlState.normal)
            if (authorData.ID == userID_s)
            {
                usernameButton.setTitleColor(UIColor(hue: 0.3361, saturation: 1, brightness: 0.66, alpha: 1.0), for: UIControlState.normal)
            }
            else
            {
                usernameButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
            }
        }
        
        // user's reputation
        reputationLabel.text = authorData.reputation
        if (authorData.ID == "0") // anonymous post
        {
            reputationLabel.text = ""
        }
        else
        {
            reputationLabel.text = "rep: " + authorData.reputation!
        }
        
        bodyLabel.text = postData.bodyText
        bodyLabel.sizeToFit()
        loveLabel.text = "Love: " + postData.loveCount!
        if (postData.userLoveStatus == "-1")
        {
            hateButton.setTitle("Unhate", for: UIControlState.normal)
            hateButton.setTitleColor(UIColor.red, for: UIControlState.normal)
            loveButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            loveButton.isEnabled = false
        }
        else if (postData.userLoveStatus == "0")
        {
            if (userID_s == "0")
            {
                hateButton.isEnabled = false
                loveButton.isEnabled = false
            }
            else
            {
                hateButton.setTitle("Hate", for: UIControlState.normal)
                loveButton.setTitle("Love", for: UIControlState.normal)
                hateButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
                loveButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
                hateButton.isEnabled = true
                loveButton.isEnabled = true
            }
        }
        else //postData.userLoveStatus == "0"
        {
            loveButton.setTitle("Unlove", for: UIControlState.normal)
            loveButton.setTitleColor(UIColor(hue: 0.3361, saturation: 1, brightness: 0.66, alpha: 1.0), for: UIControlState.normal)
            hateButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
            hateButton.isEnabled = false
        }
    }
    
}


