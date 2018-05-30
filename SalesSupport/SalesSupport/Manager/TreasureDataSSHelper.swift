//
//  TreasureDataSSHelper.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/11.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import TreasureData_iOS_SDK
import Reachability
import CoreMotion
import CoreTelephony
import SystemConfiguration.CaptiveNetwork

class TreasureDataSSHelper : NSObject {
    
    static let shared = TreasureDataSSHelper()
    
    var sentDate = Date()
    //    let queue = dispatch_queue_create("treasure.data.helper.sent", DISPATCH_QUEUE_SERIAL)!
    let queue = DispatchQueue(label: "treasure.data.helper.sent")
    
    var appBuildVersion : String?
    var appIdentifier : String?
    var appVersion : String?
    var createdAt : Date?
    var deviceUUID : String?
    var random : String?
    
    var sentAt : Date?
    var userGroupIdentifier : String?
    var userIdentifier : String?
    
    var batteryLevel = Float()
    var batteryState = Int64()
    var deviceName : String?
    var osVersion : String?
    var deviceModel : String?
    
    var connectionType : String?
    
    var isLowPowerModeEnabled : NSNumber?
    
    var locationAuthorization = Int64()
    
    var motionActivityAuthorization = Int64()
    
    var preferredLanguageFirst: String?
    var preferredLanguages : NSArray?
    
    var simAllowsVOIP: Bool?
    var simCarrierName: String?
    var simMobileCountryCode: String?
    var simMobileNetworkCode: String?
    
    var timeZoneIdentifier: String?
    var timeZoneSeconds = Int64()
    var wifiBSSID: String?
    var wifiSSID: String?
    
    func treasureDataUploadSync() {
        queue.async {
            if self.sentDate.timeIntervalSinceNow * -1 >= TreasureDataConstant.sendInterval {
                TreasureData.sharedInstance().uploadEvents(callback: {
                    self.sentDate = Date()
                }, onError: { (e1, e2) in
                    let errorMsg = "Send to TS event faild error1 :\(e1) \n error2:\(e2) "
                    print(errorMsg)
                })
            }
        }
    }
    
    func setCommon() {
        let bundle = Bundle.main
        self.appBuildVersion = (bundle.infoDictionary?["CFBundleVersion"] as? String)!
        self.appIdentifier = bundle.bundleIdentifier!
        self.appVersion = (bundle.infoDictionary?["CFBundleShortVersionString"] as? String)!
        self.deviceUUID = LogConstant.deviceUUID
        self.random = String.randomString(length: LogConstant.randomLength)
        self.userGroupIdentifier = UserDefaults.standard.string(forKey: UserDefaultsConstant.userGroupIdentifier)!
        self.userIdentifier = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)!
        
        do {
            let device = UIDevice.current
            self.batteryLevel = device.batteryLevel
            self.batteryState = Int64(device.batteryState.rawValue)
            self.deviceName = device.name
            self.osVersion = device.systemVersion
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
    
    func createCommonDictionary() -> [String : Any] {
        self.setCommon()

        var dictionary = [String: Any]()
        if let appBuildVersion = self.appBuildVersion {
            dictionary["appBuildVersion"] = appBuildVersion
        }
        if let appIdentifier = appIdentifier {
            dictionary["appIdentifier"] = appIdentifier
        }
        if let appVersion = appVersion {
            dictionary["appVersion"] = appVersion
        }
        
        dictionary["createdAt"] = NSNumber(value: Int(Date().timeIntervalSince1970))
        
        if let deviceUUID = deviceUUID {
            dictionary["deviceUUID"] = deviceUUID
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
        
        // common activity
        if self.batteryLevel >= 0 {
            dictionary["batteryLevel"] = NSNumber(value: self.batteryLevel)
        }
        if let value = UIDeviceBatteryState(rawValue: Int(self.batteryState)) {
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
        
        if let connectionType = self.connectionType {
            dictionary["connectionType"] = connectionType
        }
        if let deviceModel = self.deviceModel {
            dictionary["deviceModel"] = deviceModel
        }
        if let deviceName = self.deviceName {
            dictionary["deviceName"] = deviceName
        }
        if let isLowPowerModeEnabled = self.isLowPowerModeEnabled {
            dictionary["isLowPowerModeEnabled"] = isLowPowerModeEnabled.boolValue ? "true" : "false"
        }
        
        do {
            var locationAuthorizationString = "unknown"
            if let locationAuthorizationType = CLAuthorizationStatus(rawValue: Int32(self.locationAuthorization)) {
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
                let motionActivityAuthorizationType = CMAuthorizationStatus(rawValue: Int(self.motionActivityAuthorization)) {
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
        if let preferredLanguageFirst = self.preferredLanguageFirst {
            dictionary["preferredLanguageFirst"] = preferredLanguageFirst
        }
        if let preferredLanguages = self.preferredLanguages, self.preferredLanguages!.count > 0 {
            dictionary["preferredLanguages"] = preferredLanguages
        }
        if self.simCarrierName != nil || self.simMobileCountryCode != nil || self.simMobileNetworkCode != nil {
            dictionary["simAllowsVOIP"] = self.simAllowsVOIP?.description
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
        if let timeZoneIdentifier = self.timeZoneIdentifier {
            dictionary["timeZoneIdentifier"] = timeZoneIdentifier
            dictionary["timeZoneSeconds"] = NSNumber(value: Int(self.timeZoneSeconds))
        }
        if let wifiSSID = self.wifiSSID {
            dictionary["wifiSSID"] = wifiSSID
        }
        if let wifiBSSID = self.wifiBSSID {
            dictionary["wifiBSSID"] = wifiBSSID
        }
        if let osVersion = self.osVersion {
            dictionary["osVersion"] = osVersion
        }
        return dictionary
    }
}
