//
//  ScheduledMeal.swift
//  A data model for a ScheduledMeal object
//  FoodForThought
//
//  Created by Andy Adams on 6/29/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class ScheduledMeal{

    //MARK: Properties
    var mealName: String
    var mealTime: String
    var mealDuration: String
 
    init?(mealName: String, mealTime: String, mealDuration: String) {
        // Initialization should fail if there is no name or values are negative
        if mealName.isEmpty || mealTime.isEmpty || mealDuration.isEmpty  {
            return nil
        }
        
        self.mealName = mealName
        self.mealTime = mealTime
        self.mealDuration = mealDuration
    }
    

}
