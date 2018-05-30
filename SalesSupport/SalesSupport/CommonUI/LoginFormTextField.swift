//
//  LoginFormTextField.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/08.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class LoginFormTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame:frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draw(_ rect: CGRect) {
        // Drawing code
        let context = UIGraphicsGetCurrentContext();
        context!.setFillColor(UIColor.SSGray.cgColor);
        context!.fill(CGRect(x:0, y:self.frame.height - 1,width: self.frame.width, height:1));
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 14, 0, 0));
    }
        
        
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(0, 14, 0, 0));
    }
    
}
    

