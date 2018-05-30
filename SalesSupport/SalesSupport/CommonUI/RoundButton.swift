//
//  RoundButton.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/13.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit

class RoundButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame:frame)
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
