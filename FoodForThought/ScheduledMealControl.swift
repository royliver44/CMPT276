//
//  ScheduledMealControl.swift
//  FoodForThought
//
//  Created by Andy Adams on 6/29/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class ScheduledMealControl: UIStackView, UITextFieldDelegate {

    // MARK: Properties
    var mealNameLabel: UILabel = UILabel()
    var mealNameText: UITextField = UITextField()

    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func displayNoMealsScheduled(){
        let noMealsLabel = UILabel()
        noMealsLabel.text = "No scheduled meals"
        addArrangedSubview(noMealsLabel)
    }
    
    func setMealProperties(meal: ScheduledMeal) {
        print("setMealProps called")
        print(meal.mealName)
        mealNameLabel.text = meal.mealName
        mealNameText.text = meal.mealName
        addArrangedSubview(mealNameText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        endEditing(true)
        resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        mealNameText.text = textField.text
        print("text field edited")
        print(mealNameText.text)
    }
}
