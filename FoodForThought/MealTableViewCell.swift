//
//  ScheduledMealTableViewCell.swift
//  FoodForThought
//
//  Created by Andy Adams on 6/29/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell, UIPickerViewDelegate {

    // MARK: Properties
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var mealTime: UITextField!
    
    var activeTextField: UITextField?
    var editTimeDelegate: EditTimeDelegate?
    
    // MARK: Actions
    @IBAction func setTime(_ sender: UITextField) {
        activeTextField = sender
        
        var datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        datePickerView.date = dateFormatter.date(from: mealTime.text!)!
        
        sender.inputView = datePickerView
        
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
        
        sender.inputAccessoryView = toolBar
        
        datePickerView.addTarget(self, action: #selector(self.handleDatePicker), for: UIControlEvents.valueChanged)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        mealTime.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneDatePickerPressed(){
        print("done button pressed")
        self.endEditing(true)
        self.editTimeDelegate?.timeWasEdited(activeTextField!)
        
    }
    
    func displayNoMealsScheduled(){
        let noMealsLabel = UILabel()
        noMealsLabel.text = "No scheduled meals"
        addSubview(noMealsLabel)
    }
    
    func setMealProperties(meal: ScheduledMeal) {
        print("setMealProps called")
        print(meal.mealName)
        mealName.text = meal.mealName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "HH:mm"
        
        let date = dateFormatter.date(from: meal.mealTime)
        let time = dateFormatter.string(from: date!)
    
        mealTime.text = time
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

protocol EditTimeDelegate {
    func timeWasEdited(_ mealTimeTextField: UITextField)
}
