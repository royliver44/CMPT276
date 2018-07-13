//
//  MealTableViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 2018-06-30.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit
import UserNotifications

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
    
    
    // MEAL CELL DELEGATE METHODS
    
    // Checks that the entered name is a unique name among saved meals
    func isNameUnique(mealName: String) -> Bool {
        var uniqueName = true
        print("in uniqueName")
        for each in scheduledMeals {
            if each.mealName == mealName {
                print("meal names equal")
                uniqueName = false
                print(uniqueName)
            }
        }
        print(uniqueName)
        return uniqueName
    }
    
    // Update edited mealName
    func nameWasEdited(_ mealName: String, row: Int) {
        scheduledMeals[row].mealName = mealName
    }
    
    // Update edited mealTime
    func timeWasEdited(_ mealTime: String, row: Int) {
        // Update data source with edited meal time value, then sort meals
        // by time to display in chronological order
        scheduledMeals[row].mealTime = mealTime
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
    
    // Sets notifications to warn user of impending start times of all scheduled meals
    func setMealNotifications(mealAlert: String) {
        // Remove previously saved notifications
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // For every scheduled meal, create a notification trigger based on the meal time;
        // schedule notification to repeat daily based on meal time trigger.
        // Default warning time for notification is 30 minutes.
        var upcomingIdentifier: String = "upcoming"
        var nowIdentifier: String = "now"
        var mealAlertHour: Int = 0
        var mealAlertMinute: Int = 0
        let mealAlertWarningTime: Int = 30
        for each in scheduledMeals {
            // Create new notification based on current element in scheduledMeals, warning user a certain amount of time before meal
            upcomingIdentifier.append(each.mealName)
            let contentUpcoming = UNMutableNotificationContent()
            contentUpcoming.title = "Time to eat soon."
            contentUpcoming.subtitle = "What are you hungry for?"
            contentUpcoming.body = each.mealName + " is coming up in " + String(mealAlertWarningTime) + " minutes."
            contentUpcoming.sound = UNNotificationSound.default()
            contentUpcoming.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
            
            // Create new notification based on current element in scheduledMeals, warning user when meal time arrives
            nowIdentifier.append(each.mealName)
            let contentNow = UNMutableNotificationContent()
            contentNow.title = "Time to eat!"
            contentNow.subtitle = "What are you having?"
            contentNow.body = each.mealName + " is now."
            contentNow.sound = UNNotificationSound.default()
            contentNow.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
            
            // Get hour and minute of meal for calculating advance notification time
            var hourAndMinute = [Int]()
            let timeArray = each.mealTime.split(separator: ":")
            for each in timeArray {
                if let intVal = Int(each) {
                    hourAndMinute.append(intVal)
                }
            }

            // Calculate advance notification time (mealAlertHour and mealAlertMinuted)
            // based on meal time and how much of a warning is to be given
            if hourAndMinute[1] < mealAlertWarningTime {
                mealAlertHour = hourAndMinute[0] - 1
                mealAlertMinute = 60 - (mealAlertWarningTime - hourAndMinute[1])
            } else {
                mealAlertHour = hourAndMinute[0]
                mealAlertMinute = hourAndMinute[1] - mealAlertWarningTime
            }
            
            // Create repeating notification triggers based on date/time;
            // first trigger is to alert user of coming meal time,
            // second trigger is to alert user of meal time that has arrived
            let mealTimeIsComing = Calendar.current.date(bySettingHour: mealAlertHour, minute: mealAlertMinute, second: 0, of: Date())!
            let triggerComingMealAlertDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: mealTimeIsComing)
            let triggerUpcoming = UNCalendarNotificationTrigger(dateMatching: triggerComingMealAlertDaily, repeats: true)
            
            let mealTimeIsNow = Calendar.current.date(bySettingHour: hourAndMinute[0], minute: hourAndMinute[1], second: 0, of: Date())!
            let triggerPresentMealAlertDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: mealTimeIsNow)
            let triggerNow = UNCalendarNotificationTrigger(dateMatching: triggerPresentMealAlertDaily, repeats: true)
            
            // Create notification requests based on triggers and add to notification center
            let requestUpcoming = UNNotificationRequest(identifier: upcomingIdentifier, content: contentUpcoming, trigger: triggerUpcoming)
            UNUserNotificationCenter.current().add(requestUpcoming, withCompletionHandler: {(error) in
                if let error = error {
                    print("SOMETHING WENT WRONG")
                }
            })
            
            let requestNow = UNNotificationRequest(identifier: nowIdentifier, content: contentNow, trigger: triggerNow)
            UNUserNotificationCenter.current().add(requestNow, withCompletionHandler: {(error) in
                if let error = error {
                    print("SOMETHING WENT WRONG")
                }
            })
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
