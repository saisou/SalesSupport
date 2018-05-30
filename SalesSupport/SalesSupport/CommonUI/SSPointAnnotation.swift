//
//  SSPointAnnotation.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/2/12.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//
enum StoreAccessStatus{
    case
    none,
    accessed
}
import UIKit
import MapKit
class SSPointAnnotation: MKPointAnnotation {
    var accessed = false
}
