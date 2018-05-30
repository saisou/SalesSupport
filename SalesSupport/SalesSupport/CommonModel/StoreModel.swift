//
//  Store.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/8.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreData
import HandyJSON
import TreasureData_iOS_SDK

class StoreModel: HandyJSON {
    var userId : String?
    var user_id : String?
    var storeId : String?
    var store_id : String? // json
    var storeName : String?
    var store_name : String? // json
    var industry : String? // json
    var industry_detail : String? // json
    var storeAddress : String?
    var address : String? // json
    var postalCode : String?
    var latitude : Double?
    var longitude : Double?
    var accessed = false
    var visited: String? // json
    var accessedTime : Date?
    var visited_at: String? // json
    var minDatetime: String?
    var phone: String?
    var phone_number: String? // json
    var storePhoneNumber: String? //json
    var openedStatus: String? //json
    var paymentStatus: String? //json
    var mobileTerminal: String? //json
    
    
    var layoutType = StoreListCellLayoutType.normal
    var editStatus : NSInteger?
    var comment: String?
    var ng_reason: String? // = "現在利用中のもので満足" // json
    var charge: String?
    var commission: String? // json
    var yomi: String?
    var status: String? // = "S"// json
    
    var nearest_station: String? // json
    var opened_status: String? // = "未開店" // json
    var payment_status: String? // = "未導入"// json
    var mobile_terminal: String? // = "ios所持"// json
    
    var negotiation_time: Int? // json
    var next_negotiation_date: String? // json
    var called: String? // json
    
    var reported_by: String?
    var is_new: Int? = 0
    
    func feedJsonProperties() {
        if self.userId != nil {
            self.user_id = self.userId
        }
        if self.storeId != nil {
            self.store_id = self.storeId
        }
        if self.storeName != nil {
            self.store_name = self.storeName
        }
        if self.storeAddress != nil {
            self.address = self.storeAddress
        }
        if self.phone != nil && (self.phone_number == nil || self.phone_number!.isEmpty) {
            self.phone_number = self.phone
        }
        if self.storePhoneNumber != nil && (self.phone_number == nil || self.phone_number!.isEmpty) {
            self.phone_number = self.storePhoneNumber
        }
        if self.openedStatus != nil {
            self.opened_status = self.openedStatus
        }
        if self.paymentStatus != nil {
            self.payment_status = self.paymentStatus
        }
        if self.mobileTerminal != nil {
            self.mobile_terminal = self.mobileTerminal
        }
        
        if self.charge != nil {
            self.commission = self.charge
        }
        if self.yomi != nil {
            self.status = self.yomi
        }
        if self.visited_at == nil && self.accessedTime != nil && self.accessedTime != TreasureDataConstant.fakeDate {
            let dateformatter2 = DateFormatter()
            dateformatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.visited_at = dateformatter2.string(from: self.accessedTime!)
        }
    }
    
    func feedCoreProperties() {
        if self.user_id != nil {
            self.userId = self.user_id
        }
        if self.store_id != nil {
            self.storeId = self.store_id
        }
        if self.store_name != nil {
            self.storeName = self.store_name
        }
        if self.address != nil {
            self.storeAddress = self.address
        }
        if self.phone_number != nil {
            self.phone = self.phone_number
        }
        if self.commission != nil {
            self.charge = self.commission
        }
        if self.status != nil {
            self.yomi = self.status
        }
        if self.ng_reason != nil {
            self.comment = self.ng_reason
        }
    }
    
    func notSelectedToNull() {
        let text = "未選択"
        if self.status == text {
            self.status = nil
        }
        if self.ng_reason == text {
            self.ng_reason = nil
        }
        if self.opened_status == text {
            self.opened_status = nil
        }
        if self.payment_status == text {
            self.payment_status = nil
        }
        if self.mobile_terminal == text {
            self.mobile_terminal = nil
        }
    }
    
    func updateStoreEditStatus(editStatus : EditStatus){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let str = String.init(format:"storeId == '%@'",self.storeId!)
        fetchRequest.predicate = NSPredicate.init(format: str)
        let newAccessTime = Date()
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for store in results {
                    store.setValue(editStatus.rawValue, forKey: "editStatus")
                    if self.accessedTime == TreasureDataConstant.fakeDate {
                        store.setValue(newAccessTime, forKey: "accessedTime")
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        store.setValue(dateformatter.string(from: newAccessTime), forKey: "minDatetime")
                        self.visited_at = dateformatter.string(from: newAccessTime)
                    } else {
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        self.visited_at = dateformatter.string(from: self.accessedTime!)
                    }
                    
                    store.setValue(self.ng_reason, forKey: "comment")
                    store.setValue(self.status, forKey: "status")
                    if self.address != nil {
                        store.setValue(address, forKey: "storeAddress")
                    } else {
                        store.setValue(storeAddress, forKey: "storeAddress")
                    }
                    
                    store.setValue(industry_detail, forKey: "industry_detail")
                    store.setValue(phone_number, forKey: "phone_number")
                    store.setValue(negotiation_time, forKey: "negotiation_time")
                    store.setValue(next_negotiation_date, forKey: "next_negotiation_date")
                    store.setValue(called, forKey: "called")
                    store.setValue(opened_status, forKey: "opened_status")
                    store.setValue(mobile_terminal, forKey: "mobile_terminal")
                    store.setValue(payment_status, forKey: "payment_status")
                    store.setValue(nearest_station, forKey: "nearest_station")
                    store.setValue(visited_at, forKey: "visited_at")
                }
            }
            try managedObectContext.save()
        } catch  {
            fatalError("失败")
        }
        
        // send to store_new
        var dictionary = [String : Any]()
        dictionary["store_id"] = self.storeId
        dictionary["id"] = self.storeId
        dictionary["user_id"] = self.userId
        dictionary["comment"] = self.comment
        dictionary["name"] = self.storeName
        dictionary["commission"] = self.charge
        dictionary["status"] = self.yomi
        dictionary["latitude"] = self.latitude
        dictionary["longitude"] = self.longitude
        dictionary["address"] = self.storeAddress
        dictionary["industry"] = self.industry
        dictionary["created_by"] = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)
        
        switch editStatus {
        case .edited:
            self.visited = "1"
            dictionary["visited"] = 1
            break
        default:
            self.visited = "0"
            dictionary["visited"] = 0
            break
        }
        if self.accessedTime == TreasureDataConstant.fakeDate {
            dictionary["visit_time"] = Int(newAccessTime.timeIntervalSince1970)
        } else {
            dictionary["visit_time"] = Int(self.accessedTime!.timeIntervalSince1970)
        }
        
        TreasureData.sharedInstance().addEvent(withCallback: dictionary, table: TreasureDataConstant.storeStatus, onSuccess: {
            print("Add to TS event secceed!!!!!")
            TreasureData.sharedInstance().uploadEvents(callback: {
                print("Send to TS event secceed!!!!!")
            }, onError: { (e1, e2) in
                let errorMsg = "Send to TS storeStatus faild error1 :\(e1) \n error2:\(e2) "
                print(errorMsg)
            })
        }, onError: { (e1, e2) in
            let errorMsg = "Add to TS storeStatus faild error1 :\(e1) \n error2:\(e2) "
            print(errorMsg)
        })
        
        SSRequestManager.sendVisitInfo(store: self)
    }
    
    func backToStatus() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let str = String.init(format:"storeId == '%@'",self.storeId!)
        fetchRequest.predicate = NSPredicate.init(format: str)
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for store in results {
                    store.setValue(self.editStatus, forKey: "editStatus")
                    store.setValue(self.accessedTime, forKey: "accessedTime")
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    store.setValue(dateformatter.string(from: self.accessedTime!), forKey: "minDatetime")
                }
            }
            try managedObectContext.save()
        } catch  {
            fatalError("失败")
        }
    }
    
    func updateStoreEditStatusCoreDB(editStatus : EditStatus) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let str = String.init(format:"storeId == '%@'",self.storeId!)
        self.editStatus = editStatus.rawValue
        self.ng_reason = nil
        fetchRequest.predicate = NSPredicate.init(format: str)
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for store in results {
                    store.setValue(editStatus.rawValue, forKey: "editStatus")
                    if self.accessedTime == TreasureDataConstant.fakeDate {
                        let newAccessTime = Date()
                        store.setValue(newAccessTime, forKey: "accessedTime")
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        store.setValue(dateformatter.string(from: newAccessTime), forKey: "minDatetime")
                        self.visited_at = dateformatter.string(from: newAccessTime)
                    } else {
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        self.visited_at = dateformatter.string(from: self.accessedTime!)
                    }
                    
                    if editStatus == .edited {
                        self.visited = "1"
                    } else if editStatus == .notAccessed {
                        self.visited = "0"
                    }
                    
                    store.setValue(self.ng_reason, forKey: "comment")
                    store.setValue(self.status, forKey: "status")
                    if self.address != nil {
                        store.setValue(address, forKey: "storeAddress")
                    } else {
                        store.setValue(storeAddress, forKey: "storeAddress")
                    }
                    
                    store.setValue(industry_detail, forKey: "industry_detail")
                    store.setValue(phone_number, forKey: "phone_number")
                    store.setValue(negotiation_time, forKey: "negotiation_time")
                    store.setValue(next_negotiation_date, forKey: "next_negotiation_date")
                    store.setValue(called, forKey: "called")
                    store.setValue(opened_status, forKey: "opened_status")
                    store.setValue(mobile_terminal, forKey: "mobile_terminal")
                    store.setValue(payment_status, forKey: "payment_status")
                    store.setValue(nearest_station, forKey: "nearest_station")
                    store.setValue(visited_at, forKey: "visited_at")
                }
            }
            try managedObectContext.save()
        } catch  {
            fatalError("失败")
        }
    }
    
    func sendVisitInfo() {
        var dictionary = [String : Any]()
        dictionary["store_id"] = self.storeId
        dictionary["id"] = self.storeId
        dictionary["user_id"] = self.userId
        dictionary["comment"] = self.comment
        dictionary["name"] = self.storeName
        dictionary["commission"] = self.charge
        dictionary["status"] = self.yomi
        dictionary["latitude"] = self.latitude
        dictionary["longitude"] = self.longitude
        dictionary["address"] = self.storeAddress
        dictionary["industry"] = self.industry
        dictionary["created_by"] = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)
        
        switch self.editStatus! {
        case EditStatus.edited.rawValue:
            self.visited = "1"
            dictionary["visited"] = 1
            break
        default:
            self.visited = "0"
            dictionary["visited"] = 0
            break
        }
        
        if self.accessedTime == TreasureDataConstant.fakeDate {
            dictionary["visit_time"] = Int(Date().timeIntervalSince1970)
        } else {
            dictionary["visit_time"] = Int(self.accessedTime!.timeIntervalSince1970)
        }
        
        TreasureData.sharedInstance().addEvent(withCallback: dictionary, table: TreasureDataConstant.storeStatus, onSuccess: {
            print("Add to TS event secceed!!!!!")
            TreasureData.sharedInstance().uploadEvents(callback: {
                print("Send to TS event secceed!!!!!")
            }, onError: { (e1, e2) in
                let errorMsg = "Send to TS storeStatus faild error1 :\(e1) \n error2:\(e2) "
                print(errorMsg)
            })
        }, onError: { (e1, e2) in
            let errorMsg = "Add to TS storeStatus faild error1 :\(e1) \n error2:\(e2) "
            print(errorMsg)
        })
        
        SSRequestManager.sendVisitInfo(store: self)
    }
    
    func addNewStore(editStatus : EditStatus){
        if self.is_new == 1 {
            self.storeId = UUID().uuidString
        }
        
        if store_name == nil || store_name!.isEmpty {
            store_name = "店鋪名不明"
        }
        storeName = store_name
        
        let visitTime = Date()
        
        let userName = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)
        self.userId = userName
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        if is_new == 1 {
            // add to new store
            let entity = NSEntityDescription.entity(forEntityName: "Store", in: managedObectContext)
            
            let storeManagedObject = NSManagedObject(entity: entity!, insertInto: managedObectContext)
            storeManagedObject.setValue(storeId, forKey: "storeId")
            storeManagedObject.setValue(storeName, forKey: "storeName")
            storeManagedObject.setValue(industry, forKey: "storeIndustry")
            storeManagedObject.setValue(storeAddress, forKey: "storeAddress")
            storeManagedObject.setValue(latitude, forKey: "latitude")
            storeManagedObject.setValue(longitude, forKey: "longitude")
            storeManagedObject.setValue(Date(), forKey: "accessedTime")
            storeManagedObject.setValue(comment, forKey: "comment")
            
            // add to exsits store
            let entityExsits = NSEntityDescription.entity(forEntityName: "ExsitsStore", in: managedObectContext)
            let exsitsStoreManagedObject = NSManagedObject(entity: entityExsits!, insertInto: managedObectContext)
            exsitsStoreManagedObject.setValue(storeId, forKey: "storeId")
            exsitsStoreManagedObject.setValue(storeName, forKey: "storeName")
            exsitsStoreManagedObject.setValue(industry, forKey: "storeIndustry")
            exsitsStoreManagedObject.setValue(userName, forKey: "userId")
            exsitsStoreManagedObject.setValue(latitude, forKey: "latitude")
            exsitsStoreManagedObject.setValue(longitude, forKey: "longitude")
            exsitsStoreManagedObject.setValue(comment, forKey: "comment")
            exsitsStoreManagedObject.setValue(editStatus.rawValue, forKey: "editStatus")
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.minDatetime = dateformatter.string(from: visitTime)
            exsitsStoreManagedObject.setValue(minDatetime, forKey: "minDatetime")
            exsitsStoreManagedObject.setValue(visitTime, forKey: "accessedTime")
            exsitsStoreManagedObject.setValue(true, forKey: "accessFlag")
            
            if self.address != nil {
                exsitsStoreManagedObject.setValue(address, forKey: "storeAddress")
            } else {
                exsitsStoreManagedObject.setValue(storeAddress, forKey: "storeAddress")
            }
            
            exsitsStoreManagedObject.setValue(ng_reason, forKey: "comment")
            exsitsStoreManagedObject.setValue(status, forKey: "status")
            exsitsStoreManagedObject.setValue(phone_number, forKey: "phone_number")
            exsitsStoreManagedObject.setValue(industry_detail, forKey: "industry_detail")
            exsitsStoreManagedObject.setValue(negotiation_time, forKey: "negotiation_time")
            exsitsStoreManagedObject.setValue(next_negotiation_date, forKey: "next_negotiation_date")
            exsitsStoreManagedObject.setValue(opened_status, forKey: "opened_status")
            exsitsStoreManagedObject.setValue(mobile_terminal, forKey: "mobile_terminal")
            exsitsStoreManagedObject.setValue(payment_status, forKey: "payment_status")
            exsitsStoreManagedObject.setValue(nearest_station, forKey: "nearest_station")
            exsitsStoreManagedObject.setValue(visited_at, forKey: "visited_at")
            exsitsStoreManagedObject.setValue(called, forKey: "called")
        } else {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
            let str = String.init(format:"storeId == '%@'",self.storeId!)
            fetchRequest.predicate = NSPredicate.init(format: str)
            let newAccessTime = Date()
            do {
                let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
                if let results = fetchedResults {
                    for store in results {
                        store.setValue(editStatus.rawValue, forKey: "editStatus")
                        if self.accessedTime == TreasureDataConstant.fakeDate {
                            store.setValue(newAccessTime, forKey: "accessedTime")
                            let dateformatter = DateFormatter()
                            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            store.setValue(dateformatter.string(from: newAccessTime), forKey: "minDatetime")
                        }
                        
                        store.setValue(self.ng_reason, forKey: "comment")
                        store.setValue(self.status, forKey: "status")
                        if self.address != nil {
                            store.setValue(address, forKey: "storeAddress")
                        } else {
                            store.setValue(storeAddress, forKey: "storeAddress")
                        }
                        
                        store.setValue(industry_detail, forKey: "industry_detail")
                        store.setValue(phone_number, forKey: "phone_number")
                        store.setValue(negotiation_time, forKey: "negotiation_time")
                        store.setValue(next_negotiation_date, forKey: "next_negotiation_date")
                        store.setValue(opened_status, forKey: "opened_status")
                        store.setValue(mobile_terminal, forKey: "mobile_terminal")
                        store.setValue(payment_status, forKey: "payment_status")
                        store.setValue(nearest_station, forKey: "nearest_station")
                        store.setValue(visited_at, forKey: "visited_at")
                    }
                }
            } catch  {
                fatalError("失败")
            }
        }
        
        do {
            try managedObectContext.save()
        } catch  {
            fatalError("保存失敗")
        }
        
        // send to store_new
        var dictionary = [String : Any]()
        
        dictionary["id"] = storeId
        dictionary["name"] = storeName
        dictionary["industry"] = industry
        dictionary["address"] = storeAddress
        dictionary["latitude"] = latitude
        dictionary["longitude"] = longitude
        dictionary["phone_number"] = phone
        dictionary["commission"] = charge
        dictionary["status"] = yomi
        dictionary["comment"] = comment
        dictionary["created_by"] = userName
        
        TreasureData.sharedInstance().addEvent(withCallback: dictionary, table: TreasureDataConstant.storeNew, onSuccess: {
            print("Add to TS event secceed!!!!!")
            TreasureData.sharedInstance().uploadEvents(callback: {
                print("Send to TS event secceed!!!!!")
            }, onError: { (e1, e2) in
                let errorMsg = "Send to TS storeNew faild error1 :\(e1) \n error2:\(e2) "
                print(errorMsg)
            })
        }, onError: { (e1, e2) in
            let errorMsg = "Add to TS storeNew faild error1 :\(e1) \n error2:\(e2) "
            print(errorMsg)
        })
        
        SSRequestManager.sendStoreInfo(store: self)
        
        // send to store_status
        dictionary["store_id"] = storeId
        switch editStatus {
        case .edited:
            self.visited = "1"
            dictionary["visited"] = 1
            break
        default:
            self.visited = "0"
            dictionary["visited"] = 0
            break
        }
        if yomi != nil || charge != nil {
            dictionary["negotiated"] = 1
        } else {
            dictionary["negotiated"] = 0
        }
        
        dictionary["visit_time"] = Int(visitTime.timeIntervalSince1970)
        dictionary["user_id"] = userName
        
        TreasureData.sharedInstance().addEvent(withCallback: dictionary, table: TreasureDataConstant.storeStatus, onSuccess: {
            print("Add to TS event secceed!!!!!")
            TreasureData.sharedInstance().uploadEvents(callback: {
                print("Send to TS event secceed!!!!!")
            }, onError: { (e1, e2) in
                let errorMsg = "Send to TS storeStatus faild error1 :\(e1) \n error2:\(e2) "
                print(errorMsg)
            })
        }, onError: { (e1, e2) in
            let errorMsg = "Add to TS storeStatus faild error1 :\(e1) \n error2:\(e2) "
            print(errorMsg)
        })
        
        SSRequestManager.sendVisitInfo(store: self)
    }
    
    func copyForRollback() -> StoreModel {
        var model = StoreModel()
        model.latitude = self.latitude
        model.longitude = self.longitude
        model.storeId = self.storeId
        model.storeName = self.storeName
        model.userId = self.userId
        model.storeAddress = self.storeAddress
        model.minDatetime = self.minDatetime
        model.industry = self.industry
        model.accessed = self.accessed
        model.accessedTime = self.accessedTime
        model.editStatus = self.editStatus
        model.ng_reason = self.ng_reason
        model.industry_detail = self.industry_detail
        model.status = self.status
        model.phone_number = self.phone_number
        model.next_negotiation_date = self.next_negotiation_date
        model.negotiation_time = self.negotiation_time
        model.opened_status = self.opened_status
        model.mobile_terminal = self.mobile_terminal
        model.payment_status = self.payment_status
        model.nearest_station = self.nearest_station
        model.visited_at = self.visited_at
        model.called = self.called
        return model
    }
    
    required init() {}
}
