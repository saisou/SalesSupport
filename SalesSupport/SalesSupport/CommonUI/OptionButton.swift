//
//  OptionButton.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/2/17.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class OptionButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        self.setTitleColor(UIColor.gray, for: UIControlState.normal)
        self.setTitleColor(UIColor.white, for: UIControlState.selected)
        self.backgroundColor = UIColor.white
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.SSBlue.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        willSet {
            
        }
        
        didSet {
            self.backgroundColor = isSelected ? UIColor.SSBlue : UIColor.white
            self.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.SSBlue.cgColor
        }
    }

}
