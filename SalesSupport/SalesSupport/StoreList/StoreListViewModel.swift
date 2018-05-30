//
//  StoreListViewModel.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/2/12.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreData
class StoreListViewModel: NSObject {

    var willEditStoreArray : [StoreModel] = []
    var editedStoreArray : [StoreModel] = []
    var notAccessedStoreArray : [StoreModel] = []
    
    func loadWillEditStoreModel(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let str = String.init(format:"editStatus == %@",NSNumber.init(value: 0))
        fetchRequest.predicate = NSPredicate.init(format: str)
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            var tempList = [StoreModel]()
            if let results = fetchedResults {
                for store in results {
                    let model = StoreModel()
                    self.feedStoreModel(store, model)
                    tempList.append(model)
                }
                self.willEditStoreArray = tempList.sorted(by: { $0.accessedTime! > $1.accessedTime! })
            }
            
        } catch  {
            fatalError("失败")
        }
    }
    func loadEditedStoreModel(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let str = String.init(format:"editStatus == %@",NSNumber.init(value: 1))
        var tempList = [StoreModel]()
        fetchRequest.predicate = NSPredicate.init(format: str)
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for store in results {
                    let model = StoreModel()
                    self.feedStoreModel(store, model)
                    tempList.append(model)
                }
                self.editedStoreArray = tempList.sorted(by: { $0.accessedTime! > $1.accessedTime! })
            }
            
        } catch  {
            fatalError("失败")
        }
    }
    func loadNotAccessedStoreModel(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let str = String.init(format:"editStatus == %@",NSNumber.init(value: 2))
        fetchRequest.predicate = NSPredicate.init(format: str)
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            var tempList = [StoreModel]()
            if let results = fetchedResults {
                for store in results {
                    let model = StoreModel()
                    self.feedStoreModel(store, model)
                    tempList.append(model)
                }
                self.notAccessedStoreArray = tempList.sorted(by: { $0.accessedTime! > $1.accessedTime! })
            }
            
        } catch  {
            fatalError("失败")
        }
    }
    
    func feedStoreModel(_ store: NSManagedObject, _ model: StoreModel) {
        model.latitude =  store.value(forKey: "latitude") as? Double
        model.longitude = store.value(forKey: "longitude") as? Double
        model.storeId = store.value(forKey: "storeId") as? String
        model.storeName = store.value(forKey: "storeName") as? String
        model.userId = store.value(forKey: "userId") as? String
        model.storeAddress = store.value(forKey: "storeAddress") as? String
        model.minDatetime = store.value(forKey: "minDatetime") as? String
        model.industry = store.value(forKey: "storeIndustry") as? String
        if let accessed = store.value(forKey: "accessFlag") {
            model.accessed = accessed as! Bool
        } else {
            model.accessed = false
        }
        model.accessedTime = store.value(forKey: "accessedTime") as? Date
        model.editStatus = store.value(forKey: "editStatus") as? NSInteger
        
        model.ng_reason = store.value(forKey: "comment") as? String
        model.industry_detail = store.value(forKey: "industry_detail") as? String
        model.status = store.value(forKey: "status") as? String
        model.phone_number = store.value(forKey: "phone_number") as? String
        model.next_negotiation_date = store.value(forKey: "next_negotiation_date") as? String
        model.negotiation_time = store.value(forKey: "negotiation_time") as? NSInteger
        model.opened_status = store.value(forKey: "opened_status") as? String
        model.mobile_terminal = store.value(forKey: "mobile_terminal") as? String
        model.payment_status = store.value(forKey: "payment_status") as? String
        model.nearest_station = store.value(forKey: "nearest_station") as? String
        model.visited_at = store.value(forKey: "visited_at") as? String
        model.called = store.value(forKey: "called") as? String
    }
    
    func reloadNotAccessedStoreModel(){
        self.notAccessedStoreArray = []
        loadNotAccessedStoreModel()
    }
    func reloadWillEditStoreModel(){
        self.willEditStoreArray = []
        loadWillEditStoreModel()
    }
    func reloadEditedStoreModel(){
        self.editedStoreArray = []
        loadEditedStoreModel()
    }
    func cleanSearchModels() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExsitsStore")
        let str = String.init(format:"editStatus == %@",NSNumber.init(value: 0))
        fetchRequest.predicate = NSPredicate.init(format: str)
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for store in results {
                    if store.value(forKey: "accessedTime") as! Date == TreasureDataConstant.fakeDate {
                        managedObectContext.delete(store)
                    }
                }
            }
            
        } catch  {
            fatalError("失败")
        }
    }
    
}
