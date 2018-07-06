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
    var mealDuration: String = String()
    var mealProfileURL: NSURL?
    
    // MARK: Outlets
    @IBOutlet var mealTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Access mealProfile.xml file from user's documents directory; if file exists,
        // load saved meals based on file data; if file does not exist, create it
        var documentsDirectory: NSURL?
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as NSURL
        mealProfileURL = documentsDirectory!.appendingPathComponent("mealProfile.xml")! as NSURL
        
        if (mealProfileURL!.checkResourceIsReachableAndReturnError(nil)) {
            self.loadSavedMeals()
        }else{
            NSData().write(to: mealProfileURL! as URL, atomically:true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Load saved meal information from mealProfile.xml
    func loadSavedMeals() {
        // Parse mealProfile.xml; parser methods create ScheduledMeal objects
        // and load them into the scheduledMeals data source array
        if let parser = XMLParser(contentsOf: mealProfileURL! as URL) {
            parser.delegate = self
            parser.parse()
        }
    }
    
    // Add new meal
    func addMeal(newMeal: ScheduledMeal) {
        // Add newly scheduled meal to scheduledMeals data source array,
        // then sort array by meal time so meals are displayed in chronological order
        scheduledMeals.append(newMeal)
        scheduledMeals.sort {
            $0.mealTime < $1.mealTime
        }
        tableView.reloadData()
    }
    
    // Update edited mealName
    func nameWasEdited(_ mealNameTextField: UITextField, row: Int) {
        scheduledMeals[row].mealName = mealNameTextField.text!
    }
    
    // Update edited mealTime
    func timeWasEdited(_ mealTimeTextField: UITextField, row: Int) {
        // Update data source with edited meal time value, then sort meals
        // by time to display in chronological order
        scheduledMeals[row].mealTime = mealTimeTextField.text!
        scheduledMeals.sort {
            $0.mealTime < $1.mealTime
        }
        tableView.reloadData()
    }
    
    // Update edited mealDuration
    func durationWasEdited(duration: String, row: Int) {
        scheduledMeals[row].mealDuration = duration
        tableView.reloadData()
    }
    
    // Delete meal cell if "delete" button pressed
    func mealWasDeleted(row: Int) {
        scheduledMeals.remove(at: row)
        tableView.reloadData()
    }
    
    func saveScheduledMeals() {
        // For each meal in scheduled meal, create an XML string and append it
        // to the growing master string; then append closing tag
        var masterXMLString: String = "<?xml version=\"1.0\"?>\n<meals>\n"
        for each in scheduledMeals {
            masterXMLString.append(createXMLString(meal: each))
        }
        masterXMLString.append("</meals>\n")
        
        // Write XML data to mealProfile.xml
        let data = Data(masterXMLString.utf8)
            do {
                try data.write(to: mealProfileURL! as URL, options: .atomic)
            } catch {
                print(error)
            }
    }
        
    // Creates an XML string from meal data
    private func createXMLString(meal: ScheduledMeal) -> String {
        var mealXML: String = "<meal>\n<name>\n"
        mealXML.append(meal.mealName)
        mealXML.append("\n</name>\n<time>\n")
        mealXML.append(meal.mealTime)
        mealXML.append("\n</time>\n<duration>\n")
        mealXML.append(meal.mealDuration)
        mealXML.append("\n</duration>\n</meal>\n")
        return mealXML
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
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        eName = elementName
        if elementName == "meal" {
            mealName = String()
            mealTime = String()
            mealDuration = String()
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "meal" {
            let meal = ScheduledMeal(mealName: self.mealName, mealTime: self.mealTime, mealDuration: self.mealDuration)
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
            } else if eName == "duration" {
                mealDuration += data
            }
        }
    }
}
