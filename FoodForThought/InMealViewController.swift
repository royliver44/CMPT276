//
//  InMealViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 7/11/18.
//  Copyright © 2018 Food For Thought All rights reserved.
//

import UIKit
import CoreData

class InMealViewController: UIViewController {

    var mealName = String()
    var mealDuration: Int = 0
    var mealTimer = Timer()
    var messageTimer = Timer()
    var randomPromptIndex: Int = 0
    var isTimerRunning = false
    var postMealViewController: PostMealViewController?
    var mealItem: Item?
    var mindfulEatingPrompts: [String]?
    
    // MARK: Outlets
    @IBOutlet var timeRemaining: UILabel!
    @IBOutlet var prompt: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Populate mindfulEatingPrompts array with prompts from text file in bundle
        do {
            if let path = Bundle.main.path(forResource: "mindfulEatingPrompts", ofType: "txt"){
                let data = try String(contentsOfFile:path, encoding: String.Encoding.utf8)
                mindfulEatingPrompts = data.components(separatedBy: "\n")
            }
        } catch let err as NSError {
            // do something with Error
            print(err)
        }
        
        timeRemaining.text = "\(mealDuration) mins"
        updateMessage()
        
        // Create meal timer to show remaining meal time
        mealTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: (#selector(updateTime)), userInfo: nil, repeats: true)
        
        // Create message timer to display mindful eating prompts
        let messageInterval = 60 * 5
        messageTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(updateMessage)), userInfo: nil, repeats: true)
    }

    
    func currentMeal(mealItem: Item) {
        self.mealDuration = Int(mealItem.scheduledDuration)
        self.mealItem = mealItem
    }
    
    func updateTime() {
        mealDuration -= 1
        timeRemaining.text = "\(mealDuration) mins"
    }
    
    func updateMessage() {
        let messageCount = mindfulEatingPrompts?.count
        if messageCount != 0 {
            let randomNum = arc4random_uniform(UInt32(messageCount!))
            randomPromptIndex = Int(randomNum)
            prompt.text = mindfulEatingPrompts?[randomPromptIndex]
            mindfulEatingPrompts?.remove(at: randomPromptIndex)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishMeal" {
            if let viewController1 = segue.destination as? PostMealViewController {
                self.postMealViewController = viewController1
                postMealViewController?.currentMeal(mealItem: self.mealItem!)
            }
        }
    }

}
