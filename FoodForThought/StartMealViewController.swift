//
//  StartMealViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 7/11/18.
//  Copyright © 2018 Food For Thought All rights reserved.
//

import UIKit
import CoreData
import Foundation

class StartMealViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var entryDate = String()
    var preMealHunger: Int = 0
    var preMealFocus: Int = 0
    var preMealCalmness: Int = 0
    var preMealHappiness: Int = 0
    var mealProfileURL: NSURL?
    var mealNames = [String]()
    var mealTimes = [String]()
    var currentMeal = String()
    var inMealViewController: InMealViewController?
    var imagePicker: UIImagePickerController!
    var mealDurationInfo: [String: String] = [:]
    var mealTimeInfo: [String: String] = [:]

    
    // MARK: Outlets
    @IBOutlet weak var hungerSlider: UISlider!
    @IBOutlet var focusSlider: UISlider!
    @IBOutlet var mealPicker: UIPickerView!
    @IBOutlet var calmnessSlider: UISlider!
    @IBOutlet var happinessSlider: UISlider!
    @IBOutlet var unscheduledMealName: UITextField!
    @IBOutlet var enterNewMeal: UILabel!
    @IBOutlet weak var textfiled: UITextField!
    
    
    @IBOutlet weak var myImageView: UIImageView!

    // MARK: Actions
    @IBAction func takePhoto(_ sender: UIButton) {
        let image =  UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.camera
        
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            //After it is complete
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textfiled.resignFirstResponder()
        return(true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            myImageView.image = image
        }
        else{
            //error message
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(sender.value)), animated: true)
        
        switch sender {
        case hungerSlider:
            preMealHunger = lroundf(sender.value)
            print(preMealHunger)
        case focusSlider:
            preMealFocus = lroundf(sender.value)
            print(preMealFocus)
        case calmnessSlider:
            preMealCalmness = lroundf(sender.value)
            print(preMealCalmness)
        case happinessSlider:
            preMealHappiness = lroundf(sender.value)
            print(preMealHappiness)
        default:
            print("default")
        }
        
    }
    
    @IBAction func startMeal(_ sender: UIButton) {
        // save pre-meal info to meal journal entry
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newEntry = Item(context: context)
        
        if currentMeal != "Other" {
            newEntry.mealType = "scheduled"
            newEntry.name = currentMeal
            newEntry.scheduledTime = mealTimeInfo[currentMeal]
            newEntry.scheduledDuration = Int32(mealDurationInfo[currentMeal]!)!
        } else {
            newEntry.mealType = "unscheduled"
            newEntry.scheduledTime = "none"
            newEntry.scheduledDuration = 0
            if unscheduledMealName.text != "" {
                newEntry.name = unscheduledMealName.text
            } else {
                newEntry.name = "Untitled"
            }
        }
        
        newEntry.date = entryDate
        newEntry.preMealHunger = Int32(self.preMealHunger)
        newEntry.preMealFocus = Int32(self.preMealFocus)
        newEntry.preMealCalmness = Int32(self.preMealCalmness)
        newEntry.preMealHappiness = Int32(self.preMealHappiness)
        
        inMealViewController?.currentMeal(mealItem: newEntry)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mealPicker.delegate = self
        mealPicker.dataSource = self
        
        var xmlData: Data
        var xmlDoc: GDataXMLDocument
        var meals: [GDataXMLElement]
        var meal: [GDataXMLElement]
        var mealDuration: [GDataXMLElement]
        var mealName: [GDataXMLElement]
        var mealTime: [GDataXMLElement]
       
        // Access mealProfile.xml file from user's documents directory
        var documentsDirectory: NSURL?
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last! as NSURL
        mealProfileURL = documentsDirectory!.appendingPathComponent("mealProfile.xml")! as NSURL
        
        if (mealProfileURL!.checkResourceIsReachableAndReturnError(nil)) {
        }else{
            let xmlHeader = "<?xml version=\"1.0\"?><profile><meals></meals><alert></alert></profile>"
            do {
                try xmlHeader.write(to: mealProfileURL! as URL, atomically:true, encoding: .utf8)
            } catch {
                print(error)
            }
        }
        
        // Load meal name/duration info from meal profile
        do {
            xmlData = try Data.init(contentsOf: mealProfileURL! as URL)
            xmlDoc = try GDataXMLDocument(data: xmlData, options: 0)
            meals = xmlDoc.rootElement().elements(forName: "meals") as! [GDataXMLElement]
            if meals[0].childCount() != 0 {
                meal = meals[0].elements(forName: "meal") as! [GDataXMLElement]
                for each in meal {
                    mealName = each.elements(forName: "name") as! [GDataXMLElement]
                    mealDuration = each.elements(forName: "duration") as! [GDataXMLElement]
                    mealTime = each.elements(forName: "time") as! [GDataXMLElement]
                    mealNames.append(mealName[0].stringValue())
                    mealDurationInfo[mealName[0].stringValue()] = mealDuration[0].stringValue()
                    mealTimeInfo[mealName[0].stringValue()] = mealTime[0].stringValue()
                }
            }
        } catch {
            print(error)
        }
        
        // Set current meal to be first in list or "Other"
        mealNames.append("Other")
        currentMeal = mealNames[0]
        
        if currentMeal != "Other" {
            unscheduledMealName.isHidden = true
            unscheduledMealName.isEnabled = false
            enterNewMeal.isHidden = true
        } else {
            unscheduledMealName.isHidden = false
            unscheduledMealName.isEnabled = true
        }
        
        // Get current date to save with entry
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        entryDate = "\(month)/\(day)/\(year), \(hour):\(minute)"
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startMeal" {
            if let viewController1 = segue.destination as? InMealViewController {
                self.inMealViewController = viewController1
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        imagePicker.dismiss(animated: true, completion: nil)
        // do something here to get image from camera
//        "where/how we store the photo" = info[UIImagePickerControllerOriginalImage] as? UIImage
    }

    // PICKER VIEW DELEGATE METHODS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mealNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mealNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentMeal = mealNames[row]
        
        if currentMeal != "Other" {
            unscheduledMealName.isHidden = true
            unscheduledMealName.isEnabled = false
            enterNewMeal.isHidden = true
        } else {
            unscheduledMealName.isHidden = false
            unscheduledMealName.isEnabled = true
            enterNewMeal.isHidden = false
        }
    }
}
