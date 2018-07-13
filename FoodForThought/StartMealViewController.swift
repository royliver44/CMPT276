//
//  StartMealViewController.swift
//  FoodForThought
//
//  Created by Andy Adams on 7/11/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit

class StartMealViewController: UIViewController {

    @IBOutlet weak var hungerSlider: UISlider!
    
    var preMealHunger: Int = 0
    
    @IBAction func hungerValueChanged(_ sender: UISlider) {
        sender.setValue(Float(lroundf(hungerSlider.value)), animated: true)
        preMealHunger = lroundf(hungerSlider.value)
        print(preMealHunger)
    }
    
    @IBAction func startMeal(_ sender: UIButton) {
        // save pre-meal info to meal journal entry
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let x = hungerSlider.frame.minX
        print(x)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
