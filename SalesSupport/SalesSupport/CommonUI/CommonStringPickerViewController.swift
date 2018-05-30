//
//  CommonStringPickerViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/04/17.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation

class CommonStringPickerViewController:UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    var rows: [String] = [String]()
    
    @IBOutlet weak var picker: UIPickerView!
    
    @IBOutlet weak var titlelbl: UILabel!

    var selectedHandle: ((_ item: String) -> ())?
    
    override func viewDidLoad() {
        self.picker.delegate = self
        self.picker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.picker.reloadAllComponents()
    }
    
    override func didReceiveMemoryWarning() {
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.rows[row]
    }

    func showPicker(mainView: UIViewController, title: String, items: [String], selectedHandle: @escaping (_ item: String)->()) {
        self.rows = items
        self.selectedHandle = selectedHandle
        mainView.addChildViewController(self)
        mainView.view.addSubview(self.view)
        mainView.view.bringSubview(toFront: self.view)
        self.titlelbl.text = title
    }
    
    func showPickerWithY(mainView: UIViewController, yIndex: CGFloat, title: String, items: [String], selectedHandle: @escaping (_ item: String)->()) {
        self.rows = items
        self.selectedHandle = selectedHandle
        mainView.addChildViewController(self)
        mainView.view.addSubview(self.view)
        mainView.view.bringSubview(toFront: self.view)
        self.titlelbl.text = title
        var fabricTopFrame = self.view!.frame
        fabricTopFrame.origin.y = yIndex
        self.view!.frame = fabricTopFrame
    }
    
    @IBAction func clickCancel(_ sender: Any) {
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func clickOK(_ sender: Any) {
        self.selectedHandle!(self.rows[self.picker.selectedRow(inComponent: 0)])
        self.removeFromParentViewController()
        self.view.removeFromSuperview()
        self.dismiss(animated: false, completion: nil)
    }
}
