//
//  CalendarViewController.swift
//  FoodForThought
//
//  Created by Russell Wong on 2018-07-30.
//  Copyright © 2018 Food For Thought. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController{
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // dispose of any resources that can be recreated
    }
}
extension ViewController: JTAppleCalendarViewDataSource{

    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let sd = formatter.date(from: "2018 01 01")!
        let ed = formatter.date(from: "2018 12 31")!
        
        let parameters = ConfigurationParameters(startDate: sd, endDate: ed)
        return parameters
    }
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCalendarCell", for: indexPath) as! CustomCalendarCell
        return cell
    }
}

