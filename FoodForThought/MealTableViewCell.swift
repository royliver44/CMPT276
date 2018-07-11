//
//  ScheduledMealTableViewCell.swift
//  FoodForThought
//
//  Created by Andy Adams on 6/29/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell, UIPickerViewDelegate, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var mealTime: UITextField!
    @IBOutlet weak var mealDuration: UITextField!
    @IBOutlet weak var deleteMealButton: UIButton!
    
    var activeTextField: UITextField?
    var activeTextFieldTextBeforeEdit: String = String()
    var mealCellDelegate: MealCellDelegate?
    var indexPathRow: Int = 0
    
    // MARK: Actions
    // Deletes scheduled meal in cell
    @IBAction func deleteMeal(_ sender: UIButton) {
        mealName.text = ""
        mealTime.text = ""
        mealDuration.text = ""
        self.mealCellDelegate?.mealWasDeleted(row: indexPathRow)
    }
    
    // Edits meal name of meal in cell
    @IBAction func editMealName(_ sender: UITextField) {
        if sender.text == "" {
            sender.text = activeTextFieldTextBeforeEdit
        }
        self.mealCellDelegate?.nameWasEdited((sender.text)!, row: indexPathRow)
    }
    
    // Edits meal time of meal in cell
    @IBAction func setTime(_ sender: UITextField) {
        activeTextField = sender
        
        var TimePickerView: UIDatePicker = UIDatePicker()
        TimePickerView.datePickerMode = UIDatePickerMode.time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        TimePickerView.date = dateFormatter.date(from: mealTime.text!)!
        
        sender.inputView = TimePickerView
        
        // Set up timepicker tool bar
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneTimePickerPressed))
        toolBar.setItems([space, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        sender.inputAccessoryView = toolBar
        
        TimePickerView.addTarget(self, action: #selector(self.handleDatePicker), for: UIControlEvents.valueChanged)
    }
    
    // Update time value in textfield as timepicker is changed
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        mealTime.text = dateFormatter.string(from: sender.date)
    }
    
    // Finishes using timepicker to edit meal time
    @objc func doneTimePickerPressed(){
        self.endEditing(true)
        self.mealCellDelegate?.timeWasEdited(activeTextField!.text!, row: indexPathRow)
    }
    
    // Edit meal duration
    @IBAction func editDuration(_ sender: UITextField) {
        if sender.text == "" {
            sender.text = activeTextFieldTextBeforeEdit
        }
        self.mealCellDelegate?.durationWasEdited(duration: sender.text!, row: indexPathRow)
    }
    
    // If there are no scheduled meals, hide/disable all fields in cell
    func displayNoMealsScheduled(){
        mealName.isHidden = true
        mealTime.isHidden = true
        mealDuration.isHidden = true
        deleteMealButton.isHidden = true
        deleteMealButton.isEnabled = false
    }
    
    // Sets meal properties from data in a ScheduledMeal object
    func setMealProperties(meal: ScheduledMeal) {
        // Unhide and enable all fields in cell
        mealName.isHidden = false
        mealTime.isHidden = false
        mealDuration.isHidden = false
        deleteMealButton.isHidden = false
        deleteMealButton.isEnabled = true
        
        mealName.text = meal.mealName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        let date = dateFormatter.date(from: meal.mealTime)
        let time = dateFormatter.string(from: date!)
        mealTime.text = time
        
        mealDuration.text = meal.mealDuration
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        activeTextFieldTextBeforeEdit = (activeTextField?.text)!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if activeTextField == mealName {
            if textField.text != "" {
                if (self.mealCellDelegate?.isNameUnique(mealName: textField.text!))! || textField.text == activeTextFieldTextBeforeEdit {
                    textField.endEditing(true)
                    textField.resignFirstResponder()
                } else {
                    textField.text = activeTextFieldTextBeforeEdit
                }
            }
        } else if activeTextField == mealDuration {
            textField.endEditing(true)
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "" {
            textField.text = activeTextFieldTextBeforeEdit
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mealName.delegate = self
        mealDuration.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

// Custom protocol to enable MealTableViewController to update meal data source
// with edited values
protocol MealCellDelegate {
    func nameWasEdited(_ mealName: String, row: Int)
    func isNameUnique(mealName: String) -> Bool
    func timeWasEdited(_ mealTime: String, row: Int)
    func durationWasEdited(duration: String, row: Int)
    func mealWasDeleted(row: Int)
}
