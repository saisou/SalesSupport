//
//  VisitLogManager.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/12.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import CoreLocation
import CoreMotion
import CoreTelephony
import Reachability
import SystemConfiguration.CaptiveNetwork
import TreasureData_iOS_SDK

class VisitLogManager : NSObject {
    
    static let shared = VisitLogManager()
    
    var lastVisitFetchAt = Date()
    
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
    
    var altitude: Double?
    var batteryLevel: Float?
    var batteryState: Int64?
    var connectionType: String?
    var courseDegree: Double?
    var deviceModel: String?
    var deviceName: String?
    var existsFloorLevel: Bool?
    var floorLevel: Int64?
    var horizontalAccuracy: Double?
    var isLowPowerModeEnabled: NSNumber?
    var latitude: Double?
    var locationAuthorization: Int64?
    var locationFetchedAt: Date?
    var longitude: Double?
    var motionActivityAuthorization: Int64?
    var motionActivityConfidence: Int64?
    var motionActivityFetchedAt: Date?
    var motionActivityStartedAt: Date?
    var motionActivityType: String?
    var osVersion: String?
    var preferredLanguageFirst: String?
    var preferredLanguages: NSArray?
    var simAllowsVOIP: Bool?
    var simCarrierName: String?
    var simMobileCountryCode: String?
    var simMobileNetworkCode: String?
    var speed: Double?
    var timeZoneIdentifier: String?
    var timeZoneSeconds: Int64?
    var verticalAccuracy: Double?
    var visitEndedAt: Date?
    var visitStartedAt: Date?
    var wifiBSSID: String?
    var wifiSSID: String?
    
    func addVisitLog(visit: CLVisit, motionActivity: CMMotionActivity?, newDate: Date) {
        if !isTimeToFetch() {
            return
        }
        
        let dictionary = getVisitLog(newVisit: visit, newMotionActivity: motionActivity)
        TreasureData.sharedInstance().addEvent(withCallback: dictionary, table: TreasureDataConstant.activityLogTable, onSuccess: {
            print("Add to TS visit event secceed!!!!!")
            self.markNewFetchedTime(newDate)
            TreasureDataSSHelper.shared.treasureDataUploadSync()
        }) { (e1, e2) in
            let errorMsg = "Add to TS visit event faild error1 :\(e1) \n error2:\(e2) "
            print(errorMsg)
        }
    }
    
    func markNewFetchedTime(_ newFetchedTime: Date) {
        self.lastVisitFetchAt = newFetchedTime
    }
    
    func isTimeToFetch() -> Bool {
        return lastVisitFetchAt.timeIntervalSinceNow * -1 > 60
    }
    
    func getVisitLog(newVisit: CLVisit, newMotionActivity: CMMotionActivity?) -> [String: Any] {
        self.logType = "activityVisit"
        self.configureCommonParameters()
        self.configureVisitParameters(visit: newVisit)
        if let motion = newMotionActivity {
            self.configureMotionActivityParameters(motionActivity: motion)
        }
        return treasureDataDictionary()
    }
    
    func configureCommonParameters() {

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
        // ActivityLog
        do {
            let device = UIDevice.current
            self.batteryLevel = device.batteryLevel
            self.batteryState = Int64(device.batteryState.rawValue)
            self.deviceName = device.name
            self.osVersion = device.systemVersion
        }
        do {
            if let connection = Reachability()?.connection {
                switch connection {
                case .cellular:
                    self.connectionType = "cellular"
                case .wifi:
                    self.connectionType = "wifi"
                case .none:
                    self.connectionType = "none"
                }
            } else {
                self.connectionType = "unknown"
            }
        }
        do {
            var systemInfo = utsname()
            uname(&systemInfo)
            let deviceModelString = Mirror(reflecting: systemInfo.machine).children.reduce("") { deviceModelString, element in
                guard let value = element.value as? Int8, value != 0 else {
                    return deviceModelString
                }
                return deviceModelString + String(UnicodeScalar(UInt8(value)))
            }
            self.deviceModel = deviceModelString
        }
        do {
            self.isLowPowerModeEnabled = NSNumber(booleanLiteral: ProcessInfo.processInfo.isLowPowerModeEnabled)
        }
        do {
            self.locationAuthorization = Int64(CLLocationManager.authorizationStatus().rawValue)
        }
        do {
            if #available(iOS 11.0, *) {
                self.motionActivityAuthorization = Int64 (CMMotionActivityManager.authorizationStatus().rawValue)
            } else {
                self.motionActivityAuthorization = -1
            }
        }
        do {
            self.preferredLanguageFirst = Locale.preferredLanguages.first
            self.preferredLanguages = NSArray(array: Locale.preferredLanguages)
        }
        do {
            let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
            self.simAllowsVOIP = carrier?.allowsVOIP ?? false
            self.simCarrierName = carrier?.carrierName
            self.simMobileCountryCode = carrier?.mobileCountryCode
            self.simMobileNetworkCode = carrier?.mobileNetworkCode
        }
        do {
            self.timeZoneIdentifier = TimeZone.ReferenceType.local.identifier
            self.timeZoneSeconds = Int64(TimeZone.ReferenceType.local.secondsFromGMT())
        }
        do {
            if let connectionInterfaces = CNCopySupportedInterfaces() as? [NSString],
                let connectionInterface = connectionInterfaces.first as CFString?,
                let interfaceInfoDictionary = CNCopyCurrentNetworkInfo(connectionInterface) as? [CFString: Any] {
                self.wifiSSID = interfaceInfoDictionary[kCNNetworkInfoKeySSID] as? String
                self.wifiBSSID = interfaceInfoDictionary[kCNNetworkInfoKeyBSSID] as? String
            } else {
                self.wifiSSID = nil
                self.wifiBSSID = nil
            }
        }
    }
    
    func configureVisitParameters(visit: CLVisit) {
        self.horizontalAccuracy = visit.horizontalAccuracy
        self.latitude = visit.coordinate.latitude
        self.longitude = visit.coordinate.longitude
//        self.visitEndedAt = visit.arrivalDate
//        self.visitStartedAt = visit.departureDate
        self.visitEndedAt = visit.departureDate
        self.visitStartedAt =  visit.arrivalDate
        // Set default
        self.altitude = -1
        self.courseDegree = -1
        self.speed = -1
        self.verticalAccuracy = -1
        self.existsFloorLevel = false
        self.floorLevel = -1
    }
    
    func configureMotionActivityParameters(motionActivity: CMMotionActivity) {
        self.motionActivityFetchedAt = Date()
        self.motionActivityConfidence = Int64(motionActivity.confidence.rawValue)
        self.motionActivityStartedAt = motionActivity.startDate
        if motionActivity.unknown {
            self.motionActivityType = "unknown"
        } else if motionActivity.stationary {
            self.motionActivityType = "stationary"
        } else if motionActivity.walking {
            self.motionActivityType = "walking"
        } else if motionActivity.running {
            self.motionActivityType = "running"
        } else if motionActivity.automotive {
            self.motionActivityType = "automotive"
        } else if motionActivity.cycling {
            self.motionActivityType = "cycling"
        } else {
            self.motionActivityType = nil
        }
    }
    
    func configureLocationParameters(location: CLLocation) {
        self.altitude = location.altitude
        self.courseDegree = location.course
        self.horizontalAccuracy = location.horizontalAccuracy
        self.latitude = location.coordinate.latitude
        self.locationFetchedAt = location.timestamp
        self.longitude = location.coordinate.longitude
        self.speed = location.speed
        self.verticalAccuracy = location.verticalAccuracy
        if let floorLevel = location.floor?.level {
            self.existsFloorLevel = true
            self.floorLevel = Int64(floorLevel)
        } else {
            self.existsFloorLevel = false
            self.floorLevel = -1
        }
        // Set default
        self.visitEndedAt = nil
        self.visitStartedAt = nil
    }
    
    func treasureDataDictionary() -> [String: Any] {
        var dictionary = treasureDataFoundamentalDictionary()
        if altitude! >= 0 {
            dictionary["altitude"] = NSNumber(value: altitude!)
        }
        if batteryLevel! >= 0 {
            dictionary["batteryLevel"] = NSNumber(value: batteryLevel!)
        }
        if let value = UIDeviceBatteryState(rawValue: Int(batteryState!)) {
            let key = "batteryState"
            switch value  {
            case .unknown:
                dictionary[key] = "unknown"
            case .unplugged:
                dictionary[key] = "unplugged"
            case .charging:
                dictionary[key] = "charging"
            case .full:
                dictionary[key] = "full"
            }
        }
        if let connectionType = connectionType {
            dictionary["connectionType"] = connectionType
        }
        if courseDegree! >= 0 {
            dictionary["courseDegree"] = NSNumber(value: courseDegree!)
        }
        if let deviceModel = deviceModel {
            dictionary["deviceModel"] = deviceModel
        }
        if let deviceName = deviceName {
            dictionary["deviceName"] = deviceName
        }
        if existsFloorLevel! {
            dictionary["floorLevel"] = NSNumber(value: Int(floorLevel!))
        }
        if horizontalAccuracy! >= 0 {
            dictionary["horizontalAccuracy"] = NSNumber(value: horizontalAccuracy!)
        }
        if let isLowPowerModeEnabled = isLowPowerModeEnabled {
            dictionary["isLowPowerModeEnabled"] = isLowPowerModeEnabled.boolValue ? "true" : "false"
        }
        if latitude! >= 0 {
            dictionary["latitude"] = NSNumber(value: latitude!)
        }
        do {
            var locationAuthorizationString = "unknown"
            if let locationAuthorizationType = CLAuthorizationStatus(rawValue: Int32(locationAuthorization!)) {
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
            dictionary["locationAuthorization"] = locationAuthorizationString
        }
        do {
            var motionActivityAuthorizationString = "unknown"
            if #available(iOS 11.0, *),
                let motionActivityAuthorizationType = CMAuthorizationStatus(rawValue: Int(motionActivityAuthorization!)) {
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
            dictionary["motionActivityAuthorization"] = motionActivityAuthorizationString
        }
        if let locationFetchedAt = locationFetchedAt {
            dictionary["locationFetchedAt"] = NSNumber(value: Int(locationFetchedAt.timeIntervalSince1970))
        }
        if longitude! >= 0 {
            dictionary["longitude"] = NSNumber(value: longitude!)
        }
        if let value = CMMotionActivityConfidence(rawValue: Int(motionActivityConfidence!)) {
            let key = "motionActivityConfidence"
            switch value  {
            case .high:
                dictionary[key] = "high"
            case .medium:
                dictionary[key] = "medium"
            case .low:
                dictionary[key] = "low"
            }
        }
        if let motionActivityFetchedAt = motionActivityFetchedAt {
            dictionary["motionActivityFetchedAt"] = NSNumber(value: Int(motionActivityFetchedAt.timeIntervalSince1970))
        }
        if let motionActivityStartedAt = motionActivityStartedAt {
            dictionary["motionActivityStartedAt"] = NSNumber(value: Int(motionActivityStartedAt.timeIntervalSince1970))
        }
        if let motionActivityType = motionActivityType {
            dictionary["motionActivityType"] = motionActivityType
        }
        if let osVersion = osVersion {
            dictionary["osVersion"] = osVersion
        }
        if let preferredLanguageFirst = preferredLanguageFirst {
            dictionary["preferredLanguageFirst"] = preferredLanguageFirst
        }
        if let preferredLanguages = preferredLanguages, preferredLanguages.count > 0 {
            dictionary["preferredLanguages"] = preferredLanguages
        }
        if simCarrierName != nil || simMobileCountryCode != nil || simMobileNetworkCode != nil {
            dictionary["simAllowsVOIP"] = simAllowsVOIP!.description
        }
        if let simCarrierName = simCarrierName {
            dictionary["simCarrierName"] = simCarrierName
        }
        if let simMobileCountryCode = simMobileCountryCode {
            dictionary["simMobileCountryCode"] = simMobileCountryCode
        }
        if let simMobileNetworkCode = simMobileNetworkCode {
            dictionary["simMobileNetworkCode"] = simMobileNetworkCode
        }
        if speed! >= 0 {
            dictionary["speed"] = NSNumber(value: speed!)
        }
        if let timeZoneIdentifier = timeZoneIdentifier {
            dictionary["timeZoneIdentifier"] = timeZoneIdentifier
            dictionary["timeZoneSeconds"] = NSNumber(value: Int(timeZoneSeconds!))
        }
        if verticalAccuracy! >= 0 {
            dictionary["verticalAccuracy"] = NSNumber(value: verticalAccuracy!)
        }
        if let visitEndedAt = visitEndedAt {
            dictionary["visitEndedAt"] = NSNumber(value: Int(visitEndedAt.timeIntervalSince1970))
        }
        if let visitStartedAt = visitStartedAt {
            dictionary["visitStartedAt"] = NSNumber(value: Int(visitStartedAt.timeIntervalSince1970))
        }
        if let wifiSSID = wifiSSID {
            dictionary["wifiSSID"] = wifiSSID
        }
        if let wifiBSSID = wifiBSSID {
            dictionary["wifiBSSID"] = wifiBSSID
        }
        return dictionary
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
}
