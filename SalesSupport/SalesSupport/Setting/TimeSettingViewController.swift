//
//  TimeSettingViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/04/01.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation

class TimeSettingViewController: UITableViewController {
    
    @IBOutlet weak var isAllow: UISwitch!
    
    let always = UISwitch()
    
    @IBOutlet weak var clearlyTime: UISwitch!
    
    @IBOutlet weak var monday: UISwitch!
    @IBOutlet weak var tuseday: UISwitch!
    @IBOutlet weak var wednesday: UISwitch!
    @IBOutlet weak var thursday: UISwitch!
    @IBOutlet weak var friday: UISwitch!
    @IBOutlet weak var saturday: UISwitch!
    @IBOutlet weak var sunday: UISwitch!
    
    @IBOutlet weak var startTime: UIButton!
    @IBOutlet weak var endTime: UIButton!

    @IBAction func switchChanged(_ sender: UISwitch) {
         let userDefaults = UserDefaults.standard
        if sender == self.isAllow {

            userDefaults.set(sender.isOn, forKey: "isAllow")
            self.tableView.reloadData()
        } else if sender == self.always {
            if sender.isOn {
                self.clearlyTime.setOn(false, animated: true)
                userDefaults.set(false, forKey: "clearlyTime")
            } else {
                self.clearlyTime.setOn(true, animated: true)
                userDefaults.set(true, forKey: "clearlyTime")
            }
            userDefaults.set(sender.isOn, forKey: "always")
            
            
            self.tableView.reloadData()
        } else if sender == clearlyTime {
            if sender.isOn {
                self.always.setOn(false, animated: true)
                userDefaults.set(false, forKey: "always")
            } else {
                self.always.setOn(true, animated: true)
                userDefaults.set(true, forKey: "always")
            }
            userDefaults.set(sender.isOn, forKey: "clearlyTime")
            self.tableView.reloadData()
        }
        else if sender == monday {
            userDefaults.set(sender.isOn, forKey: "monday")
        } else if sender == tuseday {
            userDefaults.set(sender.isOn, forKey: "tuseday")
        } else if sender == wednesday {
            userDefaults.set(sender.isOn, forKey: "wednesday")
        } else if sender == thursday  {
            userDefaults.set(sender.isOn, forKey: "thursday")
        } else if sender == friday {
            userDefaults.set(sender.isOn, forKey: "friday")
        } else if sender == saturday {
            userDefaults.set(sender.isOn, forKey: "saturday")
        } else if sender == sunday {
            userDefaults.set(sender.isOn, forKey: "sunday")
        }
        
        userDefaults.synchronize()
    }

    override func viewDidLoad() {
        self.tableView.allowsSelection = false
        
        isAllow.setOn(UserDefaults.standard.bool(forKey: "isAllow"), animated: false)
        clearlyTime.setOn(UserDefaults.standard.bool(forKey: "clearlyTime"), animated: false)
        monday.setOn(UserDefaults.standard.bool(forKey: "monday"), animated: false)
        tuseday.setOn(UserDefaults.standard.bool(forKey: "tuseday"), animated: false)
        wednesday.setOn(UserDefaults.standard.bool(forKey: "wednesday"), animated: false)
        thursday.setOn(UserDefaults.standard.bool(forKey: "thursday"), animated: false)
        friday.setOn(UserDefaults.standard.bool(forKey: "friday"), animated: false)
        saturday.setOn(UserDefaults.standard.bool(forKey: "saturday"), animated: false)
        sunday.setOn(UserDefaults.standard.bool(forKey: "sunday"), animated: false)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
        let sTime = UserDefaults.standard.string(forKey: "startTime")
        let eTime = UserDefaults.standard.string(forKey: "endTime")
        startTime.setTitle(sTime, for: .normal)
        endTime.setTitle(eTime, for: .normal)
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if !self.isAllow.isOn {
            if section < 1 {
                return tableView.sectionFooterHeight
            } else {
                return 1
            }
        } else if self.always.isOn {
            if section < 2 {
                return tableView.sectionFooterHeight
            } else {
                return 1
            }
        } else {
            return tableView.sectionFooterHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !self.isAllow.isOn {
            if section < 1 {
                return tableView.sectionHeaderHeight
            } else {
                return 1
            }
        } else if self.always.isOn {
            if section < 2 {
                return tableView.sectionHeaderHeight
            } else {
                return 1
            }
        } else {
            return tableView.sectionHeaderHeight
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.isAllow.isOn || self.always.isOn {
            return ""
        } else if section == 2 {
            return "位置情報の送信を許可する曜日"
        } else if section == 3 {
            return "位置情報の送信を許可する時間"
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !self.isAllow.isOn {
            if section == 0 {
                return 1
            } else {
                return 0
            }
        } else if self.always.isOn {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else {
                return 0
            }
        } else {
            if section == 0 {
                return 1
            } else if section == 1 {
                return 1
            } else if section == 2 {
                return 7
            } else {
                return 2
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         let timeViewControll: SetTimeViewController = (segue.destination as? SetTimeViewController)!
        if (segue.identifier == "startTime") {
            timeViewControll.label = "開始時間"
            timeViewControll.timefg = "startTime"
        }else{
            timeViewControll.label = "終了時間"
             timeViewControll.timefg = "endTime"
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func unwindToTimeSettingViewController(_ sender: UIStoryboardSegue) {
        let sTime = UserDefaults.standard.string(forKey: "startTime")
        let eTime = UserDefaults.standard.string(forKey: "endTime")
        startTime.setTitle(sTime, for: .normal)
        endTime.setTitle(eTime, for: .normal)
    }
}
