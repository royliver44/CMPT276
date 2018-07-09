//
//  MealProfileViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 6/28/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class MealProfileViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var mealTable: UIView!
    @IBOutlet weak var newMealName: UITextField!
    @IBOutlet weak var newMealTime: UITextField!
    @IBOutlet weak var newMealDuration: UITextField!
    @IBOutlet weak var newMealNameWarning: UILabel!
    @IBOutlet weak var newMealTimeWarning: UILabel!
    @IBOutlet weak var newMealDurationWarning: UILabel!
    
    var mealTableViewController: MealTableViewController?
    
    // MARK: Actions
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.newMealName.delegate = self
        self.newMealTime.delegate = self
        
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
        newMealNameWarning.text = ""
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedMealTable" {
            if let viewController1 = segue.destination as? MealTableViewController {
                self.mealTableViewController = viewController1
            }
        }
    }
}
