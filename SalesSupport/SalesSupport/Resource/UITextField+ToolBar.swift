//
//  UITextField+ToolBar.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/18.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    
    func addDoneButtonToKeyboard(width: CGFloat, myAction:Selector?){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: myAction)
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
}
