//
//  StartMealViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 7/11/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class StartMealViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var preMealHunger: Int = 0
    var mealProfileURL: NSURL?
    var mealNames = [String]()
    var mealDurations = [String]()
    var currentMeal = String()
    var inMealViewController: InMealViewController?
    
    var mealInfo: [String: String] = [:]

    
    // MARK: Outlets
    @IBOutlet weak var hungerSlider: UISlider!
    @IBOutlet var mealPicker: UIPickerView!
    

    // MARK: Actions
    @IBAction func hungerValueChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(hungerSlider.value)), animated: true)
        preMealHunger = lroundf(hungerSlider.value)
        print(preMealHunger)
    }
    
    @IBAction func startMeal(_ sender: UIButton) {
        // save pre-meal info to meal journal entry
        
        inMealViewController?.currentMeal(mealName: currentMeal, mealDuration: mealInfo[currentMeal]!)
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
                    mealNames.append(mealName[0].stringValue())
                    mealDurations.append(mealDuration[0].stringValue())
                    mealInfo[mealName[0].stringValue()] = mealDuration[0].stringValue()
                }
            }
        } catch {
            print(error)
        }
        
        currentMeal = mealNames[0]
        
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
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
