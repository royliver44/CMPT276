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
    @IBOutlet weak var deleteMealButton: UIButton!
    
    var activeTextField: UITextField?
    var mealCellDelegate: MealCellDelegate?
    var indexPathRow: Int = 0
    
    // MARK: Actions
    @IBAction func deleteMeal(_ sender: UIButton) {
        mealName.text = ""
        mealTime.text = ""
        self.mealCellDelegate?.mealWasDeleted(row: indexPathRow)
    }
    
    @IBAction func editMealName(_ sender: UITextField) {
        activeTextField = sender
        self.mealCellDelegate?.nameWasEdited(activeTextField!, row: indexPathRow)
    }
    
    
    @IBAction func setTime(_ sender: UITextField) {
        activeTextField = sender
        
        var TimePickerView: UIDatePicker = UIDatePicker()
        TimePickerView.datePickerMode = UIDatePickerMode.time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        TimePickerView.date = dateFormatter.date(from: mealTime.text!)!
        
        sender.inputView = TimePickerView
        
        // datepicker toolbar setup
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
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        mealTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneTimePickerPressed(){
        self.endEditing(true)
        self.mealCellDelegate?.timeWasEdited(activeTextField!, row: indexPathRow)
    }
    
    func displayNoMealsScheduled(){
        mealName.isHidden = true
        mealTime.isHidden = true
        deleteMealButton.isHidden = true
        deleteMealButton.isEnabled = false
    }
    
    func setMealProperties(meal: ScheduledMeal) {
        mealName.isHidden = false
        mealTime.isHidden = false
        deleteMealButton.isHidden = false
        deleteMealButton.isEnabled = true
        mealName.text = meal.mealName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        let date = dateFormatter.date(from: meal.mealTime)
        let time = dateFormatter.string(from: date!)
    
        mealTime.text = time
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mealName.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

// Custom protocol to enable MealTableViewController to update meal data source
// with edited values
protocol MealCellDelegate {
    func timeWasEdited(_ mealTimeTextField: UITextField, row: Int)
    func nameWasEdited(_ mealNameTextField: UITextField, row: Int)
    func mealWasDeleted(row: Int)
}
