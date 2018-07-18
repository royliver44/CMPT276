//
//  addItemViewController.swift
//  FoodForThought
//
//  Created by Russell Wong on 2018-07-17.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//
import UIKit
import CoreData
import Foundation


class addItemViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var itemEntryTextView: UITextView?
    
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
            newEntry.name = itemEntryTextView?.text!
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemEntryTextView?.delegate = self
        
        // Do any additional setup after loading the view.
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


