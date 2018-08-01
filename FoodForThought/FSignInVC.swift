//
//  FSignInVC.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 7/31/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class FSignInVC: UIViewController
{
    // UI outlets
    @IBOutlet var nameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var CANameField: UITextField!
    @IBOutlet var CAPasswordField: UITextField!
    @IBOutlet var CARepeatPasswordField: UITextField!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        nameField.autocorrectionType = .no
        CAPasswordField.isSecureTextEntry = true
        CARepeatPasswordField.isSecureTextEntry = true
        CANameField.autocorrectionType = .no
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func SubmitPressed(_ sender: UIButton)
    {
        let request: String = "UI'" + nameField.text! + "'" + delimChar + "'" + passwordField.text! + "'"
        var response = TalkToServer(outgoingMessage: request)
        if (response.prefix(1) == "G")
        {
            // save the userid and ticket
            response = String(response.dropFirst(1))
            var parts = response.components(separatedBy: delimChar)
            userName_s = parts[1]
            parts = parts[0].components(separatedBy: ticketDelimChar)
            userID_s = parts[0]
            userTicket_s = parts[1]
            performSegue(withIdentifier: "toCreatePost", sender: self)
        }
        else
        {
            // visual error
        }
    }
    
    @IBAction func CreateAccountPressed(_ sender: UIButton)
    {
        if (CAPasswordField.text != CARepeatPasswordField.text)
        {
            // visual error
            return
        }
        let request: String = "CU'" + CANameField.text! + "'" + delimChar + "'" + CAPasswordField.text! + "'"
        var response = TalkToServer(outgoingMessage: request)
        if (response.prefix(1) == successHeader)
        {
            userName_s = CANameField.text!
            response = String(response.dropFirst(1))
            let parts = response.components(separatedBy: ticketDelimChar)
            userID_s = parts[0]
            userTicket_s = parts[1]
            performSegue(withIdentifier: "toCreatePost", sender: self)
        }
        else
        {
            // visual error
        }
    }
    
    @IBAction func BackPressed(_ sender: UIButton)
    {
        performSegue(withIdentifier: "toCreatePost", sender: self)
    }

}
