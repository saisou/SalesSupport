//
//  SSLocationManager.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/2/11.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreLocation
public protocol SSLocationManagerDelegate : NSObjectProtocol {

}
class SSLocationManager {
    static let shared = CLLocationManager.init()
//    var delegate? : SSLocationManagerDelegate
}

