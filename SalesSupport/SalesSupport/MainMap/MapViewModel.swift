//
//  MapViewModel.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/02/08.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import UIKit
import CoreData
class MapViewModel: NSObject {
    var storeArray : [StoreModel] = []
    
    func reloadViewModel(){
        self.storeArray = [StoreModel]()
        self.loadViewModel()
    }
    func loadViewModel(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Store")
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            if let results = fetchedResults {
                for store in results {
                    let model = StoreModel()
                    model.latitude =  store.value(forKey: "latitude") as? Double
                    model.longitude = store.value(forKey: "longitude") as? Double
                    model.storeId = store.value(forKey: "storeId") as? String
                    model.storeName = store.value(forKey: "storeName") as? String
                    model.storeAddress = store.value(forKey: "storeAddress") as? String
                    model.industry = store.value(forKey: "latitude") as? String
                    model.accessedTime = store.value(forKey: "accessedTime") as? Date
                    model.editStatus = store.value(forKey: "editStatus") as? NSInteger
                    if let accessed = store.value(forKey: "accessFlag"){
                        model.accessed = accessed as! Bool
                    }else{
                        model.accessed = false
                    }
                    
                    storeArray.append(model)
                }
            }
            
        } catch  {
            fatalError("失败")
        }
    }
}
