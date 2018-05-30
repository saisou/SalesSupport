//
//  RoundButton.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/13.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class SelectionsButton: UIButton {
    
    var selectionValue: String?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        self.setTitleColor(UIColor.white, for: .selected)
    }

}
