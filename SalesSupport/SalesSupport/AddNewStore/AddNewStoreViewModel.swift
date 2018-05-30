//
//  AddNewStoreViewModel.swift
//  SalesSupport
//
//  Created by Apple on 2018/2/7.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreData
import TreasureData_iOS_SDK

class AddNewStoreViewModel: NSObject {
    var storeInfoArray : [StoreInfo] = []
    let store = StoreModel()
    
    class StoreInfo: NSObject {
        var title : String?
        var dataType : NSInteger = 0
        var dataId : NSNumber?
        var data : String?
    }
    func loadViewModel(){
        
        let titleArray = ["会社名称","住所","郵便番号","TEL","手数料","ヨミ","業種","NG理由"]
        let dataTapeArray = [0,0,0,0,0,0,0,1]
        for i in 0...7 {
            let storeInfo = StoreInfo()
            storeInfo.dataId = NSNumber.init(value: i)
            storeInfo.title = titleArray[i] as String
            storeInfo.dataType = dataTapeArray[i]
            storeInfoArray.append(storeInfo)
        }
    }
    func saveNewStore(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Store", in: managedObectContext)
        
        let storeManagedObject = NSManagedObject(entity: entity!, insertInto: managedObectContext)
        storeManagedObject.setValue(store.storeId, forKey: "storeId")
        storeManagedObject.setValue(store.storeName, forKey: "storeName")
        storeManagedObject.setValue(store.industry, forKey: "storeIndustry")
        storeManagedObject.setValue(store.storeAddress, forKey: "storeAddress")
        storeManagedObject.setValue(store.latitude, forKey: "latitude")
        storeManagedObject.setValue(store.longitude, forKey: "longitude")
        storeManagedObject.setValue(Date(), forKey: "accessedTime")
        storeManagedObject.setValue("", forKey: "comment")
        do {
            try managedObectContext.save()
        } catch  {
            fatalError("保存失敗")
        }
        
        // send to store_new
        var dictionary = [String : Any]()
        let storeId = UUID().uuidString
        dictionary["id"] = storeId
        dictionary["name"] = store.storeName
        dictionary["industry"] = store.industry
        dictionary["address"] = store.storeAddress
        dictionary["latitude"] = store.latitude
        dictionary["longitude"] = store.longitude
        dictionary["phone_number"] = store.phone
        dictionary["commission"] = store.charge
        dictionary["status"] = store.yomi
        dictionary["comment"] = store.comment
        dictionary["created_by"] = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)

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
        
        // send to store_status

        dictionary["store_id"] = storeId
        dictionary["visited"] = 1
        if store.yomi != nil || store.charge != nil {
            dictionary["negotiated"] = 1
        } else {
            dictionary["negotiated"] = 0
        }
        if store.charge != nil {
            dictionary["commission"] = Int(store.charge!)
        }
        dictionary["status"] = store.yomi
        dictionary["visit_time"] = Int(Date().timeIntervalSince1970)
        dictionary["user_id"] = UserDefaults.standard.string(forKey: UserDefaultsConstant.userIdentifier)
        
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
    }
    
}
