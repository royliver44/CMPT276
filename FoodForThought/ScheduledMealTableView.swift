//
//  ScheduledMealTableView.swift
//  FoodForThought
//
//  Created by Andy Adams on 2018-06-30.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class ScheduledMealTableView: UITableView {
   
    

   
//    // MARK: Properties
//    var scheduledMeals = [ScheduledMeal]()
//
//    func loadSavedMeals() {
//        guard let meal1 = ScheduledMeal(mealName: "Breakfast", startTime: 700, duration: 30) else {
//            fatalError("Unable to instantiate meal1")
//        }
//        guard let meal2 = ScheduledMeal(mealName: "Lunch", startTime: 1300, duration: 30) else {
//            fatalError("Unable to instantiate meal1")
//        }
//        scheduledMeals += [meal1, meal2]
//        print("loadSavedMeals called")
//        print(scheduledMeals)
//    }
//
//    func addMeal(meal: ScheduledMeal) {
//
//    }
//
//
//
//
//
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if scheduledMeals.count == 0 {
//            return 1
//        } else {
//            return scheduledMeals.count
//        }
//    }
//
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        // Table view cells are reused and should be dequeued using a cell identifier.
//        let cellIdentifier = "ScheduledMealTableViewCell"
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ScheduledMealTableViewCell else {
//            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
//        }
//
//        if scheduledMeals.count == 0 {
//            cell.scheduledMealDisplay.displayNoMealsScheduled()
//        } else {
//            let cellMeal = scheduledMeals[indexPath.row]
//            cell.scheduledMealDisplay.setMealProperties(meal: cellMeal)
//        }
//        return cell
//    }
//
//
//    //
//    //
//    //    func numberOfSections(in tableView: UITableView) -> Int {
//    //        return 1
//    //    }
//
//    
//
//
//    /*
//    // Only override draw() if you perform custom drawing.
//    // An empty implementation adversely affects performance during animation.
//    override func draw(_ rect: CGRect) {
//        // Drawing code
//    }
//    */

}
