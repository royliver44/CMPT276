//
//  PostMealViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 7/24/18.
//  Copyright © 2018 Food For Thought. All rights reserved.
//

import UIKit
import CoreData

class PostMealViewController: UIViewController, UITextViewDelegate {

    var mealJournalItem = Item()
    var postMealHunger: Int = 0
    var postMealFocus: Int = 0
    var postMealCalmness: Int = 0
    var postMealHappiness: Int = 0
    var journalEntryPlaceholder = "Write a journal entry about your eating experience..."
    
    // MARK: Outlets
    @IBOutlet var hungerSlider: UISlider!
    @IBOutlet var focusSlider: UISlider!
    @IBOutlet var calmnessSlider: UISlider!
    @IBOutlet var happinessSlider: UISlider!
    @IBOutlet var journalEntry: UITextView!
    
    @IBAction func saveMeal(_ sender: UIButton) {
        journalEntry.endEditing(true)
        mealJournalItem.postMealHunger = Int32(self.postMealHunger)
        mealJournalItem.postMealFocus = Int32(self.postMealFocus)
        mealJournalItem.postMealCalmness = Int32(self.postMealCalmness)
        mealJournalItem.postMealHappiness = Int32(self.postMealHappiness)
        mealJournalItem.entryText = journalEntry.text
        print(journalEntry.text)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        // Snap to closest whole number
        sender.setValue(Float(lroundf(sender.value)), animated: true)

        // Update value for appropriate slider
        switch sender {
        case hungerSlider:
            postMealHunger = lroundf(sender.value)
            print(postMealHunger)
        case focusSlider:
            postMealFocus = lroundf(sender.value)
            print(postMealFocus)
        case calmnessSlider:
            postMealCalmness = lroundf(sender.value)
            print(postMealCalmness)
        case happinessSlider:
            postMealHappiness = lroundf(sender.value)
            print(postMealHappiness)
        default:
            print("default")
        }
    }
    
    func currentMeal(mealItem: Item) {
        mealJournalItem = mealItem
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        journalEntry.delegate = self
        journalEntry.text = journalEntryPlaceholder
        journalEntry.textColor = UIColor.lightGray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if journalEntry.text == journalEntryPlaceholder {
            journalEntry.text = ""
            journalEntry.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print("end editing")
        if journalEntry.text == "" {
            journalEntry.text = journalEntryPlaceholder
            journalEntry.textColor = UIColor.lightGray
        }
        journalEntry.resignFirstResponder()
    }
}
