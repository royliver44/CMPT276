//
//  MealTableViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 2018-06-30.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, EditTimeDelegate {
    
    // MARK: Table view data source
    var scheduledMeals = [ScheduledMeal]()
    
    // MARK: Properties
    var activeTextField: UITextField?
    
    // MARK: Outlets
    @IBOutlet var mealTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSavedMeals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Load saved meal information from mealProfile.xml
    // NOTE: For now this method creates default meals to load until .xml interface is figured out
    func loadSavedMeals() {
        guard let meal1 = ScheduledMeal(mealName: "Breakfast", mealTime: "07:00", duration: 30) else {
            fatalError("Unable to instantiate meal1")
        }
        guard let meal2 = ScheduledMeal(mealName: "Lunch", mealTime: "13:00", duration: 30) else {
            fatalError("Unable to instantiate meal1")
        }
        scheduledMeals += [meal1, meal2]
        print("loadSavedMeals called")
    }
    
    // Add new meal
    func addMeal() {
        print("mealtablevc addMeal called")
        guard let newMeal = ScheduledMeal(mealName: "Dinner", mealTime: "17:00", duration: 30) else {
            fatalError("Unable to instantiate new meal")
        }
        scheduledMeals.append(newMeal)
        tableView.reloadData()
    }
    
    // Update mealTime for edited meal
    func timeWasEdited(_ mealTimeTextField: UITextField) {
        // To identify which meal time was edited, get indexPath of UITextField position
        let textFieldPosition:CGPoint = mealTimeTextField.convert(CGPoint.init(x: 5.0, y: 5.0), to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: textFieldPosition)
        
        // Update data source with edited value
        scheduledMeals[(indexPath?.row)!].mealTime = mealTimeTextField.text!
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if scheduledMeals.count == 0 {
            return 1
        } else {
            return scheduledMeals.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "mealTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for:
            indexPath) as? MealTableViewCell else {
        fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        cell.mealName.delegate = self
        cell.editTimeDelegate = self
       // var mealTimeTextField: UITextField = cell.mealTime
        if scheduledMeals.count == 0 {
           cell.displayNoMealsScheduled()
        } else {
           let cellMeal = scheduledMeals[indexPath.row]
           cell.setMealProperties(meal: cellMeal)
        }
        return cell
    }
   
    // became first responder
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let textFieldPosition:CGPoint = textField.convert(CGPoint.init(x: 5.0, y: 5.0), to:self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: textFieldPosition)
        scheduledMeals[(indexPath?.row)!].mealName = textField.text!
        print("textfield did end editing")
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
