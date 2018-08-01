//
//  addItemViewController.swift
//  FoodForThought
//
//  Created by Russell Wong on 2018-07-17.
//  Copyright © 2018 Food For Thought All rights reserved.
//
import UIKit
import CoreData
import Foundation


class addItemViewController: UIViewController, UITextViewDelegate {
    
    var entryDate = String()
    
    @IBOutlet var itemEntryTextView: UITextView?
    @IBOutlet var mealName: UITextField!
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveContact(_ sender: Any) {
        
        if (itemEntryTextView?.text.isEmpty)! || itemEntryTextView?.text == "Type anything..."{
            print("No Data")
            // checks if user has typed a jounral entry or not if not it prompts them to type something
            let alert = UIAlertController(title: "Please Type Something", message: "Your entry was left blank.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default) { action in
                
            })
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            // Saves new entry
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newEntry = Item(context: context)
            if mealName.text != "" {
                newEntry.name = mealName.text
            } else {
                newEntry.name = "Untitled"
            }
            
            newEntry.entryText = itemEntryTextView?.text!
            newEntry.date = entryDate
            newEntry.mealType = "none"
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemEntryTextView?.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        entryDate = "\(month)/\(day)/\(year), \(hour):\(minute)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Checks if user is editing a journal entry
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
        textView.textColor = UIColor.black
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}


