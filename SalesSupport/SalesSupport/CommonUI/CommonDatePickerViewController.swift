//
//  CommonDatePickerViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/04/19.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation

class CommonDatePickerViewController: UIViewController {
 
    var selectedHandle: ((_ date: Date) -> ())?
    
    @IBOutlet weak var titleLbl: UILabel!

    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func clickCancel(_ sender: Any) {
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func clickOK(_ sender: Any) {
        self.selectedHandle!(datePicker.date)
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.datePicker.backgroundColor = UIColor.white
    }
    
    func showPickerWithY(mainView: UIViewController, pickerMode: UIDatePickerMode, yIndex: CGFloat, title: String, selectedHandle: @escaping (_ date: Date)->()) {
        self.selectedHandle = selectedHandle
        mainView.addChildViewController(self)
        mainView.view.addSubview(self.view)
        mainView.view.bringSubview(toFront: self.view)
        self.titleLbl.text = title
        var fabricTopFrame = self.view!.frame
        fabricTopFrame.origin.y = yIndex
        self.view!.frame = fabricTopFrame
        self.datePicker.datePickerMode = pickerMode
    }
}
