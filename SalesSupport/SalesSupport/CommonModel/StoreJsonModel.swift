//
//  StoreJsonModel.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/03/05.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import HandyJSON

class StoreJsonModel: HandyJSON {
    var status : String?
    var visited : String?
    var min_datetime : String?
    var user_id : String!
    var store_id : String!
    
    required init() {}
}
