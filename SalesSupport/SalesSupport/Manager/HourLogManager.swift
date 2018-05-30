//
//  HourLogManager.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/12.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import CoreMotion
import CoreLocation
import TreasureData_iOS_SDK

class HourLogManager : NSObject {
    
    let queue = DispatchQueue(label: "hour.log.get.queue")
    
    static let shared = HourLogManager()
    var lastTimeGet = Date()
    
    var appBuildVersion: String?
    var appIdentifier: String?
    var appVersion: String?
    var createdAt: Date?
    var deviceUUID: String?
    var logType: String?
    var random: String?
    var sentAt: Date?
    var userGroupIdentifier: String?
    var userIdentifier: String?
    
    var averageSpeed: Double?
    var currentLocationAuthorization: Int64?
    var currentMotionActivityAuthorization: Int64?
    var distance: Double?
    var endedAt: Date?
    var floorsAscendedCount: Int64?
    var floorsDescendedCount: Int64?
    var pedometerFetchedAt: Date?
    var startedAt: Date?
    var stepCount: Int64?
    
    let pedometer = CMPedometer()
    
    func addHourLogWithQueue() {
        queue.async {
            if self.lastTimeGet.timeIntervalSinceNow * -1 < LogConstant.hourLogFetchInterval {
                return
            }
            
            var newDate = Date()
            
            if HourLogManager.isPedometerFeatureAvailable() {
                self.pedometer.queryPedometerData(from: self.lastTimeGet, to: newDate) {pedometerData, _ in
                    var dictionary = self.createHourLogDictionary(pedometerData: pedometerData, from: self.lastTimeGet, to: newDate)
                    
                    TreasureData.sharedInstance().addEvent(withCallback: dictionary, table: TreasureDataConstant.hourLogTable, onSuccess: {
                        print ("add hour log succeed")
                        self.lastTimeGet = newDate
                    }, onError: { (e1, e2) in
                        let errorMsg = "Add to TS event faild error1 :\(e1) \n error2:\(e2) "
                        print(errorMsg)
                    })
                    print("------pedometerData---\(dictionary)")
                }
            }
            
        }
    }
    
    private func createHourLogDictionary(pedometerData: CMPedometerData?, from startedAt: Date, to endedAt: Date) -> [String: Any] {
        
        self.setHourLogValue(pedometerData: pedometerData, from: startedAt, to: endedAt)
        
        var dictionary = treasureDataFoundamentalDictionary()
        if averageSpeed! >= 0 {
            dictionary["averageSpeed"] = NSNumber(value: averageSpeed!)
        }
        do {
            var locationAuthorizationString = "unknown"
            if let locationAuthorizationType = CLAuthorizationStatus(rawValue: Int32(currentLocationAuthorization!)) {
                switch locationAuthorizationType {
                case .authorizedAlways:
                    locationAuthorizationString = "authorizedAlways"
                case .authorizedWhenInUse:
                    locationAuthorizationString = "authorizedWhenInUse"
                case .denied:
                    locationAuthorizationString = "denied"
                case .notDetermined:
                    locationAuthorizationString = "notDetermined"
                case .restricted:
                    locationAuthorizationString = "restricted"
                }
            }
            dictionary["currentLocationAuthorization"] = locationAuthorizationString
        }
        do {
            var motionActivityAuthorizationString = "unknown"
            if #available(iOS 11.0, *),
                let motionActivityAuthorizationType = CMAuthorizationStatus(rawValue: Int(currentMotionActivityAuthorization!)) {
                switch motionActivityAuthorizationType {
                case .notDetermined:
                    motionActivityAuthorizationString = "notDetermined"
                case .restricted:
                    motionActivityAuthorizationString = "restricted"
                case .denied:
                    motionActivityAuthorizationString = "denied"
                case .authorized:
                    motionActivityAuthorizationString = "authorized"
                }
            }
            dictionary["currentMotionActivityAuthorization"] = motionActivityAuthorizationString
        }
        if distance! >= 0 {
            dictionary["distance"] = NSNumber(value: distance!)
        }
        if let endedAt = self.endedAt {
            dictionary["endedAt"] = NSNumber(value: Int(endedAt.timeIntervalSince1970))
        }
        if floorsAscendedCount! >= 0 {
            dictionary["floorsAscendedCount"] = NSNumber(value: Int(floorsAscendedCount!))
        }
        if floorsDescendedCount! >= 0 {
            dictionary["floorsDescendedCount"] = NSNumber(value: Int(floorsDescendedCount!))
        }
        if let pedometerFetchedAt = pedometerFetchedAt {
            dictionary["pedometerFetchedAt"] = NSNumber(value: Int(pedometerFetchedAt.timeIntervalSince1970))
        }
        if let startedAt = self.startedAt {
            dictionary["startedAt"] = NSNumber(value: Int(startedAt.timeIntervalSince1970))
        }
        if stepCount! >= 0 {
            dictionary["stepCount"] = NSNumber(value: Int(stepCount!))
        }
        
        return dictionary
    }
    
    private func setHourLogValue(pedometerData: CMPedometerData?, from startedAt: Date, to endedAt: Date) {
        // LogType
        self.logType = LogType.hour.rawValue
        // Log
        do {
            let bundle = Bundle.main
            self.appBuildVersion = bundle.infoDictionary?["CFBundleVersion"] as? String
            self.appIdentifier = bundle.bundleIdentifier
            self.appVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
            self.createdAt = Date()
            self.deviceUUID = LogConstant.deviceUUID
            self.random = String.randomString(length: LogConstant.randomLength)
            self.sentAt = nil
            self.userGroupIdentifier = UserDefaults.standard.string(forKey: UserDefaultsConstant.userGroupIdentifier)
            self.userIdentifier = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)
        }
        // DateRange
        do {
            self.endedAt = endedAt
            self.startedAt = startedAt
        }
        // Current status
        do {
            self.currentLocationAuthorization = Int64(CLLocationManager.authorizationStatus().rawValue)
        }
        do {
            if #available(iOS 11.0, *) {
                self.currentMotionActivityAuthorization = Int64 (CMMotionActivityManager.authorizationStatus().rawValue)
            } else {
                self.currentMotionActivityAuthorization = -1
            }
        }
        // Pedometer
        do {
            self.pedometerFetchedAt = pedometerData != nil ? Date() : nil
            if let averageActivePace = pedometerData?.averageActivePace?.doubleValue,
                averageActivePace >= 0 {
                self.averageSpeed = averageActivePace
            } else {
                self.averageSpeed = -1
            }
            if let distance = pedometerData?.distance?.doubleValue,
                distance >= 0 {
                self.distance = distance
            } else {
                self.distance = -1
            }
            if let floorsAscended = pedometerData?.floorsAscended?.intValue,
                floorsAscended >= 0 {
                self.floorsAscendedCount = Int64(floorsAscended)
            } else {
                self.floorsAscendedCount = -1
            }
            if let floorsDescended = pedometerData?.floorsDescended?.intValue,
                floorsDescended >= 0 {
                self.floorsDescendedCount = Int64(floorsDescended)
            } else {
                self.floorsDescendedCount = -1
            }
            if let stepCount = pedometerData?.numberOfSteps.intValue, stepCount >= 0 {
                self.stepCount = Int64(stepCount)
            } else {
                self.stepCount = -1
            }
        }
    }
    
    private func treasureDataFoundamentalDictionary() -> [String: Any] {
        var dictionary = [String: Any]()
        if let appBuildVersion = appBuildVersion {
            dictionary["appBuildVersion"] = appBuildVersion
        }
        if let appIdentifier = appIdentifier {
            dictionary["appIdentifier"] = appIdentifier
        }
        if let appVersion = appVersion {
            dictionary["appVersion"] = appVersion
        }
        if let createdAt = createdAt {
            dictionary["createdAt"] = NSNumber(value: Int(createdAt.timeIntervalSince1970))
        }
        if let deviceUUID = deviceUUID {
            dictionary["deviceUUID"] = deviceUUID
        }
        if let logType = logType {
            dictionary["logType"] = logType
        }
        if let random = random {
            dictionary["random"] = random
        }
        if let userGroupIdentifier = userGroupIdentifier {
            dictionary["userGroupIdentifier"] = userGroupIdentifier
        } else if let userGroupIdentifier = UserDefaults.standard.string(forKey: UserDefaultsConstant.userGroupIdentifier) {
            dictionary["userGroupIdentifier"] = userGroupIdentifier
        }
        if let userIdentifier = userIdentifier {
            dictionary["userIdentifier"] = userIdentifier
        } else if let userIdentifier = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier) {
            dictionary["userIdentifier"] = userIdentifier
        }
        return dictionary
    }
    
    static func isPedometerFeatureAvailable() -> Bool {
        if #available(iOS 11.0, *), CMPedometer.authorizationStatus() != .authorized  {
            return false
        }
        return (CMPedometer.isStepCountingAvailable() ||
            CMPedometer.isDistanceAvailable() ||
            CMPedometer.isFloorCountingAvailable() ||
            CMPedometer.isPaceAvailable())
    }
    
}
