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
    @IBOutlet weak var newMealNameWarning: UILabel!
    @IBOutlet weak var newMealTimeWarning: UILabel!
    
    // MARK: Actions
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
        
        // If all values have been entered, created new meal
        // and add to table
        if ready {
            guard let newMeal: ScheduledMeal = ScheduledMeal(mealName: newMealName.text!, mealTime: newMealTime.text!, duration: 30) else {
                fatalError("Unable to instantiate new meal")
            }
            let mealTableVC = self.childViewControllers.first as? MealTableViewController
            mealTableVC?.addMeal(newMeal: newMeal)
            
            // Reset fields
            newMealName.text = ""
            newMealTime.text = ""
            newMealNameWarning.text = ""
            newMealTimeWarning.text = ""
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.newMealName.delegate = self
        self.newMealTime.delegate = self
        
        var datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        datePickerView.date = dateFormatter.date(from: "00:00")!
        
        newMealTime.inputView = datePickerView
        
        // datepicker toolbar setup
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneDatePickerPressed))
        
        // if you remove the space element, the "done" button will be left aligned
        // you can add more items if you want
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        newMealTime.inputAccessoryView = toolBar
        
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker), for: UIControlEvents.valueChanged)
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
        print("done button pressed")
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
    
    
   
    
    
    
    
    
//

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
