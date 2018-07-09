//
//  FirstViewController.swift
//  FoodForThought
//
//  Created by Jordan Ehrenholz on 6/27/18.
//  Copyright © 2018 Jordan Ehrenholz. All rights reserved.
//

import UIKit
import UserNotifications

class FirstViewController: UIViewController {

    var identifier: String = "alarm"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
//        //let center = UNUserNotificationCenter.current()
//
//        let content = UNMutableNotificationContent()
//        content.title = "Title"
//        content.body = "Body"
//        content.sound = UNNotificationSound.default()
//
//        let gregorian = Calendar(identifier: .gregorian)
//        let now = Date()
//        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
//        components.timeZone = .current
//        print(components)
//
//        // Change the time to 7:00:00 in your locale
//
//        components.hour = 7
//        components.minute = 53
//        components.second = 0
//
//        print(components)
//
//        let date = gregorian.date(from: components)!
//        print(date)
//
//        let triggerDaily = Calendar.current.dateComponents([.hour,.minute,.second,], from: date)
//        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
//
//
//        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
//        print("INSIDE NOTIFICATION")
//
//        UNUserNotificationCenter.current().add(request, withCompletionHandler: {(error) in
//            if let error = error {
//                print("SOMETHING WENT WRONG")
//            }
//        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

