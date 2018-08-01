//
//  MealProfileViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 6/28/18.
//  Copyright © 2018 Food For Thought All rights reserved.
//

import UIKit

class MealProfileViewController: UIViewController, UITextFieldDelegate, XMLParserDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mealTable: UIView!
    @IBOutlet weak var newMealName: UITextField!
    @IBOutlet weak var newMealTime: UITextField!
    @IBOutlet weak var newMealDuration: UITextField!
    @IBOutlet weak var newMealNameWarning: UILabel!
    @IBOutlet weak var newMealTimeWarning: UILabel!
    @IBOutlet weak var newMealDurationWarning: UILabel!
    @IBOutlet weak var mealAlertSwitch: UISwitch!
    @IBOutlet weak var mealAlert: UITextField!
    @IBOutlet var mins: UILabel!
    
    var mealTableViewController: MealTableViewController?
    var mealAlertTime: String = "0"
    var mealProfileURL: NSURL?
    
 
    
    
    // MARK: Actions
    // Display meal alert box if meal alert status = on
    @IBAction func setMealAlertStatus(_ sender: UISwitch) {
        if sender.isOn {
            mealAlert.isEnabled = true
            mealAlert.isHidden = false
            mealAlertTime = mealAlert.text!
            mins.isEnabled = true
        } else {
            mealAlert.isEnabled = false
            mealAlert.isHidden = true
            mins.isEnabled = false
            mealAlertTime = "0"
        }
    }
    
    // Adds a new meal to scheduled meals
    @IBAction func addMeal(_ sender: UIButton) {
        // If no value entered for meal name or time, tell
        // user these must be entered
        var ready: Bool = true
        if newMealName.text == "" {
            newMealNameWarning.text = "Enter meal name"
            ready = false
        }
        if newMealTime.text == "" {
            newMealTimeWarning.text = "Enter meal time"
            ready = false
        }
        if newMealDuration.text == "" {
            newMealDurationWarning.text = "Enter meal duration"
            ready = false
        }
        
        // If all values have been entered, created new meal based
        // on user input and add to table
        if ready {
            guard let newMeal: ScheduledMeal = ScheduledMeal(mealName: newMealName.text!, mealTime: newMealTime.text!, mealDuration: newMealDuration.text!) else {
                fatalError("Unable to instantiate new meal")
            }
            
            mealTableViewController?.addMeal(newMeal: newMeal)
            
            // Reset fields
            newMealName.text = ""
            newMealTime.text = ""
            newMealDuration.text = ""
            newMealNameWarning.text = ""
            newMealTimeWarning.text = ""
            newMealDurationWarning.text = ""
        }
    }
    
    // Save all settings for meal profile, including scheduled meals
    // and meal alert time/state
    @IBAction func saveMealProfile(_ sender: UIButton) {
        // Save scheduled meal information in mealProfile.xml
        mealAlert.endEditing(true)
        self.mealTableViewController?.saveScheduledMeals()
        
        // Save user-defined meal alert warning time in mealProfile.xml;
        // first check that value is not empty, then construct xml string
        // with user-defined meal alert time/state
        if mealAlert.text == "" {
            mealAlert.text = "0"
        }
        var alert = "<alert><time>"
        alert.append(mealAlert.text!)
        alert.append("</time><state>")
        if mealAlertSwitch.isOn {
            alert.append("on")
        } else {
            alert.append("off")
        }
        alert.append("</state></alert></profile>")
        
        // Append xml data to end of mealProfile.xml
        let data = alert.data(using: .utf8)
        if let fileHandle = FileHandle(forUpdatingAtPath: (mealProfileURL?.path)!) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data!)
        } else {
            let xmlHeader = "<?xml version=\"1.0\"?><profile><meals></meals><alert></alert></profile>"
            do {
                try xmlHeader.write(to: mealProfileURL! as URL, atomically:true, encoding: .utf8)
            } catch {
                print(error)
            }
        }
        
        // Set notifications based on meal times and alert time
        self.mealTableViewController?.setMealNotifications(mealAlert: mealAlertTime)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newMealName.delegate = self
        self.newMealTime.delegate = self
        self.newMealDuration.delegate = self
        self.mealAlert.delegate = self
        var xmlData: Data
        var xmlDoc: GDataXMLDocument
        var alert: [GDataXMLElement]
        var alertTime: [GDataXMLElement]
        var alertState: [GDataXMLElement]
        
        // Access mealProfile.xml file from user's documents directory
        var documentsDirectory: NSURL?
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as NSURL
        mealProfileURL = documentsDirectory!.appendingPathComponent("mealProfile.xml")! as NSURL
        
        if (mealProfileURL!.checkResourceIsReachableAndReturnError(nil)) {
        }else{
            let xmlHeader = "<?xml version=\"1.0\"?><profile><meals></meals><alert></alert></profile>"
            do {
                try xmlHeader.write(to: mealProfileURL! as URL, atomically:true, encoding: .utf8)
            } catch {
                print(error)
            }
        }
        
        // Load meal alert time from meal profile
        do {
            xmlData = try Data.init(contentsOf: mealProfileURL! as URL)
            xmlDoc = try GDataXMLDocument(data: xmlData, options: 0)
            alert = xmlDoc.rootElement().elements(forName: "alert") as! [GDataXMLElement]
            if alert[0].childCount() != 0 {
                alertTime = alert[0].elements(forName: "time") as! [GDataXMLElement]
                mealAlert.text = alertTime[0].stringValue()
                alertState = alert[0].elements(forName: "state") as! [GDataXMLElement]
                if alertState[0].stringValue() == "on" {
                    mealAlertSwitch.isOn = true
                    mealAlertTime = mealAlert.text!
                } else {
                    mealAlertSwitch.isOn = false
                    mealAlert.isHidden = true
                    mealAlert.isEnabled = false
                }
            } else {
                mealAlert.text = ""
            }
        } catch {
            print(error)
        }
        
        // Create time picker for newMealTime
        var timePickerView: UIDatePicker = UIDatePicker()
        timePickerView.datePickerMode = UIDatePickerMode.time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        timePickerView.date = dateFormatter.date(from: "00:00")!
        
        newMealTime.inputView = timePickerView
        
        // datepicker toolbar setup
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneDatePickerPressed))
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        newMealTime.inputAccessoryView = toolBar
        
        timePickerView.addTarget(self, action: #selector(self.handleDatePicker), for: UIControlEvents.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        newMealTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneDatePickerPressed(){
        newMealTimeWarning.text = ""
        newMealTime.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == newMealName {
            newMealNameWarning.text = ""
        } else if textField == newMealDuration {
            newMealDurationWarning.text = ""
        } else if textField == mealAlert {
            if textField.text == "" {
                mealAlert.text = "0"
            } else {
                mealAlertTime = mealAlert.text!
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Ensure only numbers are entered as input
        let characterSet = CharacterSet(charactersIn: "0123456789")
        if textField == newMealDuration || textField == mealAlert {
            return string.rangeOfCharacter(from: characterSet.inverted) == nil
        } else {
            return true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedMealTable" {
            if let viewController1 = segue.destination as? MealTableViewController {
                self.mealTableViewController = viewController1
            }
        }
    }
}

