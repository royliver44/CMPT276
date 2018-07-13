//
//  MealProfileViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 6/28/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
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
    
    
    var mealTableViewController: MealTableViewController?
    var mealAlertTime: Int = 0
    var mealProfileURL: NSURL?
    
    
     // MARK: Actions
    
    @IBAction func setMealAlertStatus(_ sender: UISwitch) {
        if sender.isOn {
            mealAlert.isEnabled = true
            mealAlert.isHidden = false
            mealAlertTime = Int(mealAlert.text!)!
            print(mealAlertTime)
        } else {
            mealAlert.isEnabled = false
            mealAlert.isHidden = true
            mealAlertTime = 0
            print(mealAlertTime)
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
    
    @IBAction func saveMealProfile(_ sender: UIButton) {
        self.mealTableViewController?.saveScheduledMeals()
        self.mealTableViewController?.setMealNotifications(mealAlert: mealAlert.text!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newMealName.delegate = self
        self.newMealTime.delegate = self
        self.newMealDuration.delegate = self
        self.mealAlert.delegate = self
        
        // Access mealProfile.xml file from user's documents directory
        var documentsDirectory: NSURL?
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as NSURL
        mealProfileURL = documentsDirectory!.appendingPathComponent("mealProfile.xml")! as NSURL
        
        if (mealProfileURL!.checkResourceIsReachableAndReturnError(nil)) {
           
        }else{
            NSData().write(to: mealProfileURL! as URL, atomically:true)
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
        textField.endEditing(true)
        textField.resignFirstResponder()
        if textField == newMealName {
            newMealNameWarning.text = ""
        } else if textField == newMealDuration {
            newMealDurationWarning.text = ""
        } else if textField == mealAlert {
            if textField.text == "" {
                mealAlert.text = "0"
            }
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == newMealDuration || textField == mealAlert {
            return string.rangeOfCharacter(from: CharacterSet.letters) == nil
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
    
//    // PARSER DELEGATE FUNCTIONS
//    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
//        eName = elementName
//        if elementName == "meal" {
//            mealName = String()
//            mealTime = String()
//            mealDuration = String()
//        }
//    }
//
//    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
//        if elementName == "meal" {
//            let meal = ScheduledMeal(mealName: self.mealName, mealTime: self.mealTime, mealDuration: self.mealDuration)
//            scheduledMeals.append(meal!)
//        }
//    }
//
//    func parser(_ parser: XMLParser, foundCharacters string: String) {
//        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//        if (!data.isEmpty) {
//            if eName == "name" {
//                mealName += data
//            } else if eName == "time" {
//                mealTime += data
//            } else if eName == "duration" {
//                mealDuration += data
//            }
//        }
//    }
    
    
}
