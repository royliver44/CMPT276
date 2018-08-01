//
//  FirstViewController.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 6/27/18.
//  Copyright © 2018 Food For Thought All rights reserved.
//

import UIKit
import UserNotifications

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

