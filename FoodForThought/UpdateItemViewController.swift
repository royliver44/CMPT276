//
//  UpdateItemViewController.swift
//  FoodForThought
//
//  Created by Russell Wong on 2018-07-17.
//  Copyright © 2018 Food For Thought All rights reserved.
//

import UIKit
import CoreData
import Foundation

class UpdateItemViewController: UIViewController, UITextViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var item: Item!
    
    @IBOutlet weak var entryText: UITextView!
    @IBOutlet var sliderData: UITextView!
    
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateAction(_ sender: Any) {
        // updates journal entries with new items 
        guard let newEntry = entryText.text else  {
            return
        }
        
        item.entryText = newEntry
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        entryText!.delegate = self
        entryText!.becomeFirstResponder()
        configureEntryData(entry: item)
        
        sliderData.isEditable = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func configureEntryData(entry: Item) {
        
        guard let text = entry.entryText else {
            return
        }
        
        entryText!.text = text
        
        if entry.mealType != "none" {
            sliderData.text = "\t\t\tPre-meal\tPost-meal\n"
            sliderData.text.append("Hunger:\t\t\(entry.preMealHunger)\t\t\t\(entry.postMealHunger)\n")
            sliderData.text.append("Focus:\t\t\(entry.preMealFocus)\t\t\t\(entry.postMealFocus)\n")
            sliderData.text.append("Calmness:\t\(entry.preMealCalmness)\t\t\t\(entry.postMealCalmness)\n")
            sliderData.text.append("Happiness:\t\(entry.preMealHappiness)\t\t\t\(entry.postMealHappiness)\n")
        }
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
}
