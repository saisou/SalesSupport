//
//  Constant.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/11.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreLocation

enum LogType: String {
    case activitySignificantLocationUpdates = "activitySignificantLocationUpdates"
    case activityVisit = "activityVisit"
    case activityStandardLocation = "activityStandardLocation"
    case activityFilling = "activityFilling"
    case hour = "hour"
}

struct SSColor {
    static let SSGrayBlack: UIColor = UIColor(hue: 0.3861, saturation: 0, brightness: 0.29, alpha: 1.0)
    static let SSBlue: UIColor = UIColor.init(red:  42.0 / 255.0, green:  153.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
}

struct LogConstant {
    static let deviceUUID: String = {
        let userDefaults = UserDefaults.standard
        if let registerdIdentifier = userDefaults.string(forKey: UserDefaultsConstant.deviceUUID) {
            return registerdIdentifier
        }
        let createdIdentifier = UUID().uuidString
        userDefaults.set(createdIdentifier, forKey: UserDefaultsConstant.deviceUUID)
        userDefaults.synchronize()
        return createdIdentifier
    }()
    static let randomLength = Int(15)
    //3分１回
    //    static let activityLocationFetchInterval = Double(60*3-10)
    //    static let activityFillingInterval = Double(60*3)
    //1分毎
    static let activityLocationFetchInterval = Double(50)
    static let activityFillingInterval = Double(60)
    
    static let activityIntervalMax = Double(120)
    static let hourLogFetchInterval = Double(60 * 60)
    static let hourLogInterval = Double(60 * 60)
}

struct TreasureDataConstant {
    static let apiEndpoint = "https://in.treasuredata.com"
    static let apiKey = "5488/becacf071ed84b20db10ea00a59676ab6b6aef21"
    static let defaultDatabase: String = {
        return "sales_support_dev"
    }()
    static let storeStatus = "test_store_status"
    static let storeNew = "new_stores_demo"
    static let activityLogTable = "activity_log_demo"
    static let hourLogTable = "hour_log_demo"
    static let sendInterval: Double = {
        return 120
    }()
    
    static let fakeDate = Date(timeIntervalSince1970: 4476651071.0)
}

struct UserDefaultsConstant {
    static let deviceUUID = "deviceUUID"
    static let userGroupIdentifier = "userGroupIdentifier"
    static let userIdentifier = "userIdentifier"
    static let username = "username"
    static let treasureDataLastSentDate = "treasureDataLastSentDate"
    static let authToken = "authToken"
}
