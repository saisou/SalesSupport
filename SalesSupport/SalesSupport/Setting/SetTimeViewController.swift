//
//  SetTimeViewController.swift
//  SalesSupport
//
//  Created by BWP102 on 2018/04/05.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class SetTimeViewController: UIViewController {
    var label:String?
    var timefg:String?
    var time: Data?
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    override func viewDidLoad() {
        super.viewDidLoad()
        idLabel.text = label

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startTimeDiveChanged(_ sender: UIDatePicker) {
        let date = DateFormatter()
        date.dateFormat = "HH:mm"
        let time = date.string(from: sender.date)
        UserDefaults.standard.set(time, forKey: timefg!)
        UserDefaults.standard.synchronize()
    }
    
    static func initUserSetting() {
        let inited = UserDefaults.standard.string(forKey: "setTimeInited")
        if inited == nil || inited != "true" {
            UserDefaults.standard.set(true, forKey: "isAllow")
            UserDefaults.standard.set(true, forKey: "clearlyTime")
            UserDefaults.standard.set(true, forKey: "monday")
            UserDefaults.standard.set(true, forKey: "tuseday")
            UserDefaults.standard.set(true, forKey: "wednesday")
            UserDefaults.standard.set(true, forKey: "thursday")
            UserDefaults.standard.set(true, forKey: "friday")
            UserDefaults.standard.set(false, forKey: "saturday")
            UserDefaults.standard.set(false, forKey: "sunday")
            UserDefaults.standard.set("10:00" ,forKey: "startTime")
            UserDefaults.standard.set("19:00" ,forKey: "endTime")
            UserDefaults.standard.set("true", forKey: "setTimeInited")
            UserDefaults.standard.synchronize()
        }
    }
}
