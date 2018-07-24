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
    var timer = Timer()
    var isTimerRunning = false
    var postMealViewController: PostMealViewController?
    var mealItem: Item?
    
    // MARK: Outlets
    @IBOutlet var timeRemaining: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timeRemaining.text = "\(mealDuration) mins"
        
        timer = Timer.scheduledTimer(timeInterval: 60, target: self,   selector: (#selector(updateTime)), userInfo: nil, repeats: true)
    }

    
    func currentMeal(mealItem: Item) {
        //self.mealName = mealName
        self.mealDuration = Int(mealItem.scheduledDuration)
        self.mealItem = mealItem
    }
    
    func updateTime() {
        mealDuration -= 1
        timeRemaining.text = "\(mealDuration) mins"
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
