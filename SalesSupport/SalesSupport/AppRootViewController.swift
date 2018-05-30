//
//  AppRootViewController.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/07.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import CoreData
import AVFoundation
import TreasureData_iOS_SDK
import UserNotifications
import AWSCore
import AWSS3
import SwiftyJSON
struct Notification {
    static let CompleteLoginNotification = "CompleteLoginNotification"             // ログイン完了通知
    static let CompleteLogoutNotification = "CompleteLogoutNotification"          // ログアウト完了通知
    
    static let OpenMainNotification = "OpenMainNotification"
    
    static let LogoutNotification = "LogoutNotification"
}
struct lastLocation {
    static var lastLocationFetchedAt = Date()
    static var lastLatitude = Double(0.1)
    static var lastLongitude = Double(0.1)
    static var countSame = Int(0)
}
class AppRootViewController: UIViewController, CLLocationManagerDelegate{
    var window: UIWindow?
    let motionActivityManager = CMMotionActivityManager()
    private var loginViewController =  LoginViewController()
    private var mapViewController = MapViewController()
    var locationManager : CLLocationManager?
    let updateFlagQueue = DispatchQueue.init(label: "com.ss.updateFlag")
    var lastMotion : CMMotionActivity?
    var motionStatus: String?
    var timecount = 5
    var timeString = "";
    var getLocationCount = 0;
    var StationTimer: Timer!
    var stationCount = 0;
    var motionAllCount = 0;
    var locationManageFun = "standard"
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier?
    var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
    
    let transferUtility = AWSS3TransferUtility.default()
    
    var visitDownloadTimer : Timer?
    var lastVisitJsonTime : Date?
    var appStatus = "";
    static let sharedInstance = AppRootViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector:#selector(changeContentsNotification(notification:)),
                                               name: NSNotification.Name(rawValue: Notification.CompleteLoginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(changeContentsNotification(notification:)),
                                               name: NSNotification.Name(rawValue: Notification.CompleteLogoutNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(AppEnteredBackground(notification:)),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)

        
//        NotificationCenter.default.post(name: NSNotification.Name(Notification.CompleteLogoutNotification), object: self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        saveNewStore()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization
            if error != nil {
                return
            }
            
            if granted {
                debugPrint("通知許可")
            } else {
                debugPrint("通知拒否")
            }
        }
        
        self.mapViewController.firstTimeUpdatedLocation = true
        self.addChildViewController(loginViewController)
        self.view.addSubview(loginViewController.view)
        loginViewController.didMove(toParentViewController: self)
        
    }
    @objc func appBecomeActive() {
        print("----------------アプリ再起動--------------")
        DispatchQueue.main.async {
            if(self.StationTimer != nil ){

                self.StationTimer.invalidate()

                self.StationTimer = nil
                self.motionAllCount = 0
                self.stationCount = 0
            }
        if UIApplication.shared.applicationState == UIApplicationState.active{
             self.locationManager?.stopMonitoringSignificantLocationChanges()
             self.locationManager?.startUpdatingLocation()
        }

        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func changeContentsNotification(notification : NSNotification ) {
        
        if notification.name.rawValue == Notification.CompleteLoginNotification{
            DispatchQueue.main.async(execute: {
                self.initLocationManager()
                self.initMotitionManager()
                self.loginViewController.willMove(toParentViewController: nil)
                self.loginViewController.removeFromParentViewController()
                self.loginViewController.usernameTextField.resignFirstResponder()
                self.addChildViewController(self.mapViewController)
                self.view.addSubview(self.mapViewController.view)
                self.mapViewController.didMove(toParentViewController: self)
                guard let userId = self.loginViewController.usernameTextField.text else {
                    return
                }
                UserDefaults.standard.set(userId, forKey: UserDefaultsConstant.userIdentifier)
                UserDefaults.standard.synchronize()
                
                self.checkJsonGetTimer()
                SetTimeViewController.initUserSetting()
            })
        }
        if notification.name.rawValue == Notification.CompleteLogoutNotification{
            stopMotitionManager()
            stopLocationManager()
           
            self.mapViewController.willMove(toParentViewController: nil)
            self.mapViewController.removeFromParentViewController()
            self.mapViewController.firstTimeUpdatedLocation = true
            self.addChildViewController(loginViewController)
            self.view.addSubview(loginViewController.view)
            loginViewController.didMove(toParentViewController: self)
            
            // remove visit list
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObectContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObectContext.execute(deleteRequest)
            } catch let error as NSError {
                NSLog("Failed to remove visit list.")
            }
            
            self.lastVisitJsonTime = nil
            stopJsonGetTimer()
            UserDefaults.standard.set("false", forKey: "setTimeInited")
            UserDefaults.standard.set("", forKey: UserDefaultsConstant.authToken)
            UserDefaults.standard.set("", forKey: UserDefaultsConstant.username)
            UserDefaults.standard.synchronize()
        }

    }
    @objc func AppEnteredBackground(notification : NSNotification ) {
        stopJsonGetTimer()
    }
    @objc func AppEnteredForeground(notification : NSNotification ) {
        checkJsonGetTimer()
    }
    func checkJsonGetTimer() {
        if self.visitDownloadTimer == nil || !self.visitDownloadTimer!.isValid{
            self.visitDownloadTimer = nil
            self.visitDownloadTimer = Timer.scheduledTimer(withTimeInterval: 900.0, repeats: true, block: { (timer) in
                self.getJSONFormAWSS3()
            })
        }

        self.getJSONFormAWSS3()
        
    }
    func startJsonGetTimer() {
        if self.visitDownloadTimer == nil || !self.visitDownloadTimer!.isValid{
            self.visitDownloadTimer = nil
            self.visitDownloadTimer = Timer.scheduledTimer(withTimeInterval: 900.0, repeats: true, block: { (timer) in
                self.getJSONFormAWSS3()
            })
        }
    }
    func stopJsonGetTimer() {
        if self.visitDownloadTimer != nil && self.visitDownloadTimer!.isValid {
            self.visitDownloadTimer?.invalidate()
            self.visitDownloadTimer = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        if let motion = self.lastMotion {
            if visit.departureDate != .distantFuture {
                if scheduleCheck(){
                    VisitLogManager.shared.addVisitLog(visit: visit, motionActivity: motion, newDate: Date())
                }
            }
        } else {
            if visit.departureDate != .distantFuture {
                if scheduleCheck(){
                    VisitLogManager.shared.addVisitLog(visit: visit, motionActivity: nil, newDate: Date())
                }
            }
        }
        
        if visit.departureDate == .distantFuture {
            // User has arrived, but not left, the location
        } else {
            // The visit is complete
        }
        if scheduleCheck(){
            HourLogManager.shared.addHourLogWithQueue()
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        return
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if scheduleCheck(){
            HourLogManager.shared.addHourLogWithQueue()
        }

        let newLocation = locations.last

        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd HH:mm:ss.SSS"
        print("---*****-\(df.string(from: Date()))--緯度:\(newLocation?.coordinate.latitude) 経度:\(newLocation?.coordinate.longitude) 取得時刻:\(newLocation?.timestamp.description)")
        if (lastLocation.lastLocationFetchedAt.timeIntervalSinceNow) * -1 > 60 {
            lastLocation.lastLocationFetchedAt = Date()
            if (lastLocation.lastLatitude == newLocation?.coordinate.latitude &&
                lastLocation.lastLongitude == newLocation?.coordinate.longitude
                ) {
                lastLocation.countSame += 1
            } else {
                lastLocation.countSame = 0
            }

            lastLocation.lastLatitude = (newLocation?.coordinate.latitude)!
            lastLocation.lastLongitude = (newLocation?.coordinate.longitude)!
            //            print(locations)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            
            let managedObectContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "Log", in: managedObectContext)
            
            let log = NSManagedObject(entity: entity!, insertInto: managedObectContext)
            log.setValue(newLocation?.coordinate.latitude, forKey: "latitude")
            log.setValue(newLocation?.coordinate.longitude, forKey: "longitude")
            log.setValue(lastLocation.lastLocationFetchedAt, forKey: "createdAt")
            log.setValue(self.motionStatus, forKey: "motion")
            do {
                try managedObectContext.save()
            } catch  {
                print("Save log Failed")
            }
            var dictionary = TreasureDataSSHelper.shared.createCommonDictionary()
            self.setupLocationParam(dictionary: &dictionary, location: newLocation!)
            self.setupMotionActivityParam(dictionary: &dictionary)
            
            dictionary["locationFetchedAt"] = NSNumber(value: Int(Date().timeIntervalSince1970))
            dictionary["logType"] = "activityStandardLocation"
            
            let formatter = DateFormatter()
            
            formatter.timeZone = TimeZone.current
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: newLocation!.timestamp)
            self.timeString = "緯度:\(newLocation!.coordinate.latitude) 経度:\(newLocation!.coordinate.longitude) 取得時刻:\(dateString)"
            self.getLocationCount += 1;
            
            self.fetchDataBygetLocation()
            if scheduleCheck(){
                TreasureData.sharedInstance().addEvent(withCallback: dictionary, table: TreasureDataConstant.activityLogTable, onSuccess: {
                    print("Add to TS event secceed!!!!!")
                    TreasureDataSSHelper.shared.treasureDataUploadSync()
                }, onError: { (e1, e2) in
                    let errorMsg = "Add to TS event faild error1 :\(e1) \n error2:\(e2) "
                    print(errorMsg)
                })
                startJsonGetTimer()
            }else{
                stopJsonGetTimer()
            }
            
        }
        if (lastLocation.lastLocationFetchedAt.timeIntervalSinceNow) * -1 > 20 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObectContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
            let str = String.init(format:"latitude BETWEEN{\(newLocation!.coordinate.latitude - 0.01)  ,\(newLocation!.coordinate.latitude + 0.01 )} AND longitude BETWEEN{\((newLocation!.coordinate.longitude - 0.01) as CDouble), \(newLocation!.coordinate.longitude + 0.01)}")
            fetchRequest.predicate = NSPredicate.init(format: str)
            do {
                let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
                if let results = fetchedResults {
                    for store in results {
                        let distance = newLocation?.distance(from: CLLocation.init(latitude: store.value(forKey: "latitude") as! CLLocationDegrees, longitude: store.value(forKey: "longitude") as! CLLocationDegrees))
                        if distance! < 1000{
                            store.setValue(true, forKey: "accessFlag")
                        }
                    }
                    try managedObectContext.save()
                }
                
            } catch  {
                fatalError("失败")
            }
        }
        
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startUpdatingLocation()

        locationManager?.startMonitoringVisits()
    }
    func stopLocationManager() {
        locationManager?.stopUpdatingLocation()
        locationManager?.stopMonitoringVisits()
        locationManager?.stopMonitoringSignificantLocationChanges()
        if( self.StationTimer != nil){
            self.StationTimer.invalidate()
        }
    }
    func stopMotitionManager() {
        motionActivityManager.stopActivityUpdates()
    }
    func initMotitionManager() {
        motionActivityManager.startActivityUpdates(to: OperationQueue()) {
            // Guard
            guard let motionActivity = $0 else {
                return
            }
            self.lastMotion = motionActivity

            if motionActivity.unknown {
                self.motionStatus = "unknown"
                print("Motion status unknown Time: \(Date())")
            } else if motionActivity.stationary {
                if(self.motionStatus == "stationary"){
                    self.startStationTimer()
                }else{
                    self.motionStatus = "stationary"
                }
                print("Motion status stationary Time: \(Date())")
            } else if motionActivity.walking {
                 if (self.motionStatus == "walking" || self.motionStatus == "running"||self.motionStatus == "automotive"){
                    self.startWalking()
                }
                    self.motionStatus = "walking"
                
                print("Motion status walking Time: \(Date())")

            } else if motionActivity.running {
                 if (self.motionStatus == "walking" || self.motionStatus == "running"||self.motionStatus == "automotive"){
                    self.startWalking()
                }
                self.motionStatus = "running"
                print("Motion status running Time: \(Date())")

            } else if motionActivity.automotive {
                if (self.motionStatus == "walking" || self.motionStatus == "running"||self.motionStatus == "automotive"){
                    self.startWalking()
                }
                self.motionStatus = "automotive"
                print("Motion status automotive Time: \(Date())")

            } else if motionActivity.cycling {
                self.motionStatus = "cycling"
                print("Motion status cycling Time: \(Date())")

            } else {
                self.motionStatus = "nil"
                print("Motion status nil Time: \(Date())")
            }
            print("----***----\(self.motionStatus)---***---")
        }
    }

    func fetchDataBygetLocation(){
        let content = UNMutableNotificationContent()
        content.title = "位置情報確認"
        content.subtitle = "位置情報を取りました" // 新登場！
        content.body = self.timeString
        content.sound = UNNotificationSound.default()
        
        // 5秒後に発火
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "getchLOcation",
                                            content: content,
                                            trigger: trigger)
        
    }

    func saveNewStore(){
        let oneTime = UserDefaults.standard.string(forKey: "oneTimeSaveStore")
        if oneTime == "OK" {
            return
        } else {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObectContext = appDelegate.persistentContainer.viewContext
        // clean all
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedObectContext.execute(deleteRequest)
        } catch let error as NSError {
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "ExsitsStore", in: managedObectContext)
        
        let storeManagedObject = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        storeManagedObject.setValue("1", forKey: "storeId")
        storeManagedObject.setValue("Tomod's Kayabacho", forKey: "storeName")
        storeManagedObject.setValue("その他", forKey: "storeIndustry")
        storeManagedObject.setValue("东京都中央区 Nihonbashikayabacho, 2 Chome, 茅場町駅前ビル", forKey: "storeAddress")
        storeManagedObject.setValue(35.6785415, forKey: "latitude")
        storeManagedObject.setValue(139.778816, forKey: "longitude")
        storeManagedObject.setValue("", forKey: "comment")
        storeManagedObject.setValue("2018-03-09 14:22:22", forKey: "minDatetime")
        let dateformatter = DateFormatter()
        let string1 = "2018-01-05"
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date1 = dateformatter.date(from: string1)
        storeManagedObject.setValue(date1!, forKey: "accessedTime")
        
        let storeManagedObject2 = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        storeManagedObject2.setValue("2", forKey: "storeId")
        storeManagedObject2.setValue("PMOビル", forKey: "storeName")
        storeManagedObject2.setValue("美容", forKey: "storeIndustry")
        storeManagedObject2.setValue("東京都中央区 日本橋茅場町3-11-10, PMOビル", forKey: "storeAddress")
        storeManagedObject2.setValue(35.4040, forKey: "latitude")
        storeManagedObject2.setValue(139.4645, forKey: "longitude")
        storeManagedObject2.setValue("", forKey: "comment")
        storeManagedObject2.setValue("2018-03-09 14:23:22", forKey: "minDatetime")
        let string2 = "2016-10-05"
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date2 = dateformatter.date(from: string2)
        storeManagedObject2.setValue(date2!, forKey: "accessedTime")
        
        let storeManagedObject3 = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        storeManagedObject3.setValue("3", forKey: "storeId")
        storeManagedObject3.setValue("株式会社T", forKey: "storeName")
        storeManagedObject3.setValue("飲食", forKey: "storeIndustry")
        storeManagedObject3.setValue("东京都北区赤羽駅前ビル", forKey: "storeAddress")
        storeManagedObject3.setValue(35.765527, forKey: "latitude")
        storeManagedObject3.setValue(139.696093, forKey: "longitude")
        storeManagedObject3.setValue("", forKey: "comment")
        storeManagedObject3.setValue("2018-03-09 15:22:22", forKey: "minDatetime")
        let string3 = "2016-10-06"
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date3 = dateformatter.date(from: string3)
        storeManagedObject3.setValue(date3!, forKey: "accessedTime")
        
        let storeManagedObject4 = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        storeManagedObject4.setValue("4", forKey: "storeId")
        storeManagedObject4.setValue("株式会社S", forKey: "storeName")
        storeManagedObject4.setValue("美容", forKey: "storeIndustry")
        storeManagedObject4.setValue("东京都渋谷区渋谷駅前ビル", forKey: "storeAddress")
        storeManagedObject4.setValue(35.765527, forKey: "latitude")
        storeManagedObject4.setValue(139.696093, forKey: "longitude")
        storeManagedObject4.setValue("", forKey: "comment")
        storeManagedObject4.setValue("2018-03-09 20:22:22", forKey: "minDatetime")
        let string4 = "2016-12-17"
        dateformatter.dateFormat = "yyyy-MM-dd"
        let date4 = dateformatter.date(from: string4)
        storeManagedObject4.setValue(date4!, forKey: "accessedTime")
        do {
            try managedObectContext.save()
        } catch  {
            fatalError("保存失敗")
        }
        
        UserDefaults.standard.set("OK", forKey: "oneTimeSaveStore")
        UserDefaults.standard.synchronize()
    }
    func setupMotionActivityParam( dictionary : inout[String:Any]){
        
        if lastMotion != nil {
            dictionary["motionActivityFetchedAt"] = NSNumber(value: Int(Date().timeIntervalSince1970))
            if let value = CMMotionActivityConfidence(rawValue: Int(self.lastMotion!.confidence.rawValue)) {
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
            dictionary["motionActivityStartedAt"] = NSNumber(value: Int(self.lastMotion!.startDate.timeIntervalSince1970))
            if (self.lastMotion!.unknown) {
                dictionary["motionActivityType"] = "unknown"
            } else if lastMotion!.stationary {
                dictionary["motionActivityType"] = "stationary"
            } else if lastMotion!.walking {
                dictionary["motionActivityType"] = "walking"
                
            } else if lastMotion!.running {
                dictionary["motionActivityType"] = "running"
            } else if lastMotion!.automotive {
                dictionary["motionActivityType"] = "automotive"
            } else if lastMotion!.cycling {
                dictionary["motionActivityType"] = "cycling"
            } else {
                //            dictionary["motionActivityType"] = nil
            }
        }
    }
    
    func setupLocationParam(dictionary: inout [String : Any],location: CLLocation){
        
        dictionary["altitude"] = location.altitude
        dictionary["course"] = location.course
        dictionary["horizontalAccuracy"] = location.horizontalAccuracy
        dictionary["latitude"] = location.coordinate.latitude
        dictionary["timestamp"] = location.timestamp
        dictionary["longitude"] = location.coordinate.longitude
        dictionary["speed"] = location.speed
        dictionary["verticalAccuracy"] = location.verticalAccuracy
        if let floorLevel = location.floor?.level {
            dictionary["floorLevel"] = Int64(floorLevel)
            
        } else {
            dictionary["floorLevel"] = Int(-1)
        }
        // Set default
        dictionary["visitEndedAt"] = nil
        dictionary["visitStartedAt"] = nil
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func startStationTimer(){
        
        if( self.locationManageFun == "standard"){
            if(self.StationTimer != nil && self.StationTimer.isValid){

                return;
            }
            
            DispatchQueue.main.async {
                if UIApplication.shared.applicationState == UIApplicationState.active{
                    return
                }
                self.StationTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true, block: { (timer) in
                    self.motionAllCount += 1;
                    if(self.motionStatus == "stationary"){
                        self.stationCount += 1;
                    }
                    
                    print("-----Timer--\(self.motionAllCount)------\(self.stationCount)----")
                    if(self.motionAllCount > 40 && self.stationCount > 30){
                        DispatchQueue.main.async {
                            if(self.locationManageFun != "standard"){
                                self.locationManager?.requestLocation()
                                return
                            }
                            
                            self.locationManager?.stopUpdatingLocation()
                            self.locationManager?.startMonitoringSignificantLocationChanges()
                            
                            print("------大幅位置情報-に切り替えた------------")
                            
                            self.locationManageFun = "Significant"
                        }
                    }
                })
            }
        }
    }
    func startWalking(){
        if(self.StationTimer != nil ){
            
            self.StationTimer.invalidate()
            
            self.StationTimer = nil
            self.motionAllCount = 0
            self.stationCount = 0
        }

        if( self.locationManageFun != "standard"){
        
            DispatchQueue.main.async {
                self.locationManager?.stopMonitoringSignificantLocationChanges()
                self.locationManager?.startUpdatingLocation()
                print("------標準位置情報に切り替えた------------")
                self.locationManageFun = "standard"

            }
        }
        
        
    }
    // 画面を自動で回転させるか
    override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    // 画面の向きを指定
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    func getJSONFormAWSS3() {
        if self.lastVisitJsonTime != nil && (self.lastVisitJsonTime!.timeIntervalSinceNow) * -1 < 900 {
            return
        }
        self.lastVisitJsonTime = Date()
        guard var userId = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier) else {
            return
        }
        userId = userId + ".json"
        
        NSLog("get json get json get json \(Date())")
        
        let S3BucketName: String = "pp-sales-test"   // Update this to your bucket name
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        self.completionHandler = { (task, location, data, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    NSLog("Failed with error: \(error)")
                } else {
                    // update time
                    let json = JSON(data!)
                    NSLog("getJsonFileuser_id: \(json)")
                    
                    let jsons = json.array
                    if jsons != nil && jsons!.count > 0 {
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        
                        let managedObectContext = appDelegate.persistentContainer.viewContext
                        
                        let entity = NSEntityDescription.entity(forEntityName: "ExsitsStore", in: managedObectContext)
                        for sjs in jsons! {
                            let storeJson = StoreModel.deserialize(from: sjs.rawString())
                            
                            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
                            let str = String.init(format:"storeId == '%@'", storeJson!.storeId!)
                            fetchRequest.predicate = NSPredicate.init(format: str)
                            do {
                                let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
                                if fetchedResults != nil && fetchedResults!.count > 0 {
                                    continue
                                }
                            } catch  {
                                fatalError("get store failed")
                            }
                            
                            let storeManagedObject = NSManagedObject(entity: entity!, insertInto: managedObectContext)
                            storeManagedObject.setValue(storeJson!.storeId, forKey: "storeId")
                            storeManagedObject.setValue(storeJson!.storeName, forKey: "storeName")
                            storeManagedObject.setValue(storeJson!.storePhoneNumber, forKey: "phone_number")
                            storeManagedObject.setValue(storeJson!.industry, forKey: "storeIndustry")
                            storeManagedObject.setValue(storeJson!.storeAddress, forKey: "storeAddress")
                            storeManagedObject.setValue(storeJson!.openedStatus, forKey: "opened_status")
                            storeManagedObject.setValue(storeJson!.paymentStatus, forKey: "payment_status")
                            storeManagedObject.setValue(storeJson!.mobileTerminal, forKey: "mobile_terminal")
                            storeManagedObject.setValue(storeJson!.userId, forKey: "userId")
                            storeManagedObject.setValue(storeJson!.latitude, forKey: "latitude")
                            storeManagedObject.setValue(storeJson!.longitude, forKey: "longitude")
                            storeManagedObject.setValue(storeJson!.minDatetime, forKey: "minDatetime")
                            storeManagedObject.setValue("", forKey: "comment")
                            let dateformatter = DateFormatter()
                            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let date1 = dateformatter.date(from: storeJson!.minDatetime!)
                            storeManagedObject.setValue(date1!, forKey: "accessedTime")
                            storeManagedObject.setValue(true, forKey: "accessFlag")
                            
                        }
                        
                        do {
                            try managedObectContext.save()
                        } catch  {
                            fatalError("保存失敗")
                        }
                    }
                }
            })
        }
        
        transferUtility.downloadData(
            fromBucket: S3BucketName,
            key: userId,
            expression: expression,
            completionHandler: completionHandler).continueWith { (task) -> AnyObject? in
                if let error = task.error {
                    NSLog("Error: %@",error.localizedDescription);
//                    self.statusLabel.text = "Failed"
                }
                
                if let _ = task.result {
//                    self.statusLabel.text = "Starting Download"
                    NSLog("Download Starting!")
                    // Do something with uploadTask.
                }
                return nil;
        }
    }
    func  scheduleCheck() -> Bool{
        let userDefaults = UserDefaults.standard
        let isAllow = userDefaults.bool(forKey: "isAllow")
        let always = userDefaults.bool(forKey: "always")
        let clearlyTime = userDefaults.bool(forKey: "clearlyTime")
        
        if isAllow && always {
            return true
        } else if isAllow && clearlyTime {
            let cal = NSCalendar.current
            let weeks = ["sunday","monday","tuseday","wednesday","thursday","friday","saturday"]
            let comp = cal.component(.weekday, from: Date())
            let time_format = DateFormatter()
            time_format.dateFormat = "HH:mm"
            let str_from_date = time_format.string(from:Date())
            let nowTime = time_format.date(from: str_from_date)
            let week = weeks[(comp - 1)]
            if userDefaults.bool(forKey: week) {
                let sTime = UserDefaults.standard.string(forKey: "startTime")
                let eTime = UserDefaults.standard.string(forKey: "endTime")

                let start_time = time_format.date(from:sTime!)
                let end_time = time_format.date(from:eTime!)
                if(nowTime! > start_time! && nowTime! < end_time!){
                   return true
                }else{
                   return false
                }
            } else {
                return false
            }
        }
    
        return false
    }
    
}
