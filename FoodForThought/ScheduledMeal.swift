//
//  ScheduledMeal.swift
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
    var duration: Int
 
    init?(mealName: String, mealTime: String, duration: Int) {
        // Initialization should fail if there is no name or values are negative
        if mealName.isEmpty || mealTime.isEmpty || duration < 0  {
            return nil
        }
        
        self.mealName = mealName
        self.mealTime = mealTime
        self.duration = duration
    }
    

}
