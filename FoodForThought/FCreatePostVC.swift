//
//  FCreatePostVC.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 7/21/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class FCreatePostVC: UIViewController, UITextViewDelegate
{
    @IBOutlet var signedInAsLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var signInOutButton: UIButton!
    @IBOutlet var bodyText: UITextView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var submitButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        UpdateUI()
        bodyText.text = "Enter your post here!"
        bodyText.textColor = UIColor.lightGray
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    // triggered when the submit button is pressed
    // sends the post to the server to be stored in the database
    @IBAction func SubmitPost(_ sender: UIButton)
    {
        if (bodyText.text == "Enter Your Message Here!" || bodyText.text == "")
        {
            // visual error
            return
        }
        let message: String = "CP" + GenerateUIDandTicket() + delimChar + "'" + bodyText.text + "'"
        let response: String = TalkToServer(outgoingMessage: message)
        if (response == successHeader)
        {
            performSegue(withIdentifier: "afterSubmitPost", sender: self)
        }
        else
        {
            // visual error
        }
    }
    
    // triggered when the sign in button is pressed
    // either logs the user out or transitions to the login page
    @IBAction func SignInButtonPressed(_ sender: UIButton)
    {
        if (userID_s == "0")
        {
            performSegue(withIdentifier: "goToSignIn", sender: self)
        }
        else
        {
            let response: String = TalkToServer(outgoingMessage: "UO" + GenerateUIDandTicket())
            if (response == successHeader)
            {
                userID_s = "0"
                userName_s = ""
                userTicket_s = "0"
                UpdateUI()
            }
            else
            {
                // visual error
                return
            }
        }
    }
    
    // refreshes the UI objects that depend on login state
    func UpdateUI()
    {
        if (userID_s == "0")
        {
            signedInAsLabel.text = "You are anonymous at the moment"
            nameLabel.text = ""
            signInOutButton.setTitle("Sign In", for: UIControlState.normal)
        }
        else
        {
            signedInAsLabel.text = "Signed in as:"
            nameLabel.text = userName_s
            signInOutButton.setTitle("Sign Out", for: UIControlState.normal)
        }
    }
    
    // deletes the placeholder text in the
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if textView.textColor == UIColor.lightGray
        {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if textView.text.isEmpty {
            textView.text = "Enter your message!"
            textView.textColor = UIColor.lightGray
        }
    }
    
}


