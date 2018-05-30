//
//  Validator.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/24.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation

class SSValidator: NSObject {
    static func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
}
