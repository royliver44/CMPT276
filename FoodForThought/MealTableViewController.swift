//
//  MealTableViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 2018-06-30.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class MealTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, MealCellDelegate, XMLParserDelegate {
    
    // MARK: Table view data source
    var scheduledMeals = [ScheduledMeal]()
    
    // MARK: Properties
    var activeTextField: UITextField?
    var eName: String = String()
    var mealName: String = String()
    var mealTime: String = String()
    
    // MARK: Outlets
    @IBOutlet var mealTable: UITableView!
    
    // MARK: Actions
    // Write changes to mealProfile.xml
    // NOTE: not yet implemented; changes will not be saved
    @IBAction func saveMealProfile(_ sender: UIButton) {
        // write to xml
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadSavedMeals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Load saved meal information from mealProfile.xml
    func loadSavedMeals() {
        // Parse mealProfile.xml
        if let path = Bundle.main.url(forResource: "mealProfile", withExtension: "xml")  {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                if parser.parse() {
                    print("parsed")
                } else {
                    print("unable to parse")
                }
            }
        }
    }
    
    
    // Add new meal
    func addMeal(newMeal: ScheduledMeal) {
        scheduledMeals.append(newMeal)
        tableView.reloadData()
    }
    
    // Update mealTime for edited meal
    func timeWasEdited(_ mealTimeTextField: UITextField, row: Int) {
        // Update data source with edited value
        scheduledMeals[row].mealTime = mealTimeTextField.text!
    }
    
    // Update meal name if edited
    func nameWasEdited(_ mealNameTextField: UITextField, row: Int) {
        scheduledMeals[row].mealName = mealNameTextField.text!
    }
    
    // Delete meal cell if "delete" button pressed
    func mealWasDeleted(row: Int) {
        scheduledMeals.remove(at: row)
        tableView.reloadData()
    }

    // TABLE VIEW CONTROLLER METHODS
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
        
        cell.mealCellDelegate = self

        // If there are no saved meals, display empty cell;
        // else, populate cell with meal info from saved meal
        if scheduledMeals.count == 0 {
           cell.displayNoMealsScheduled()
        } else {
            let cellMeal = scheduledMeals[indexPath.row]
            cell.setMealProperties(meal: cellMeal)
            cell.indexPathRow = indexPath.row
        }
        return cell
    }
   
    // TEXTFIELD DELEGATE FUNCTIONS
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
    
    
    // PARSER DELEGATE FUNCTIONS
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        eName = elementName
        if elementName == "meal" {
            mealName = String()
            mealTime = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "meal" {
            let meal = ScheduledMeal(mealName: self.mealName, mealTime: self.mealTime, duration: 30)
            scheduledMeals.append(meal!)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if (!data.isEmpty) {
            if eName == "name" {
                mealName += data
            } else if eName == "time" {
                mealTime += data
            }
        }
    }
}
