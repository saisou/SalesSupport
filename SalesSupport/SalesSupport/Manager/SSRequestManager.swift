//
//  SSRequestManager.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/04/19.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation
import SwiftyJSON

class SSRequestManager: NSObject {
    
    static let oldbaseUrl = "http://ec2-52-197-219-9.ap-northeast-1.compute.amazonaws.com:8000"
    static let baseUrl = "http://ec2-52-197-219-9.ap-northeast-1.compute.amazonaws.com:8000"
    static let testAuthInfo = ["username": "user1", "password": "user1_password"]
    
    static func sendVisitInfo(store: StoreModel) {
        let url = URL(string: baseUrl + "/api/sales_support/status/")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        let token = "JWT " + UserDefaults.standard.string(forKey: UserDefaultsConstant.authToken)!
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        store.reported_by = UserDefaults.standard.string(forKey: UserDefaultsConstant.username)
        store.feedJsonProperties()
        if store.status == nil || store.status != "N" {
            store.ng_reason = nil
        }
        if store.visited == "0" {
            store.negotiation_time = nil
            store.visited_at = nil
            store.status = nil
            store.ng_reason = nil
            store.next_negotiation_date = nil
            store.called = nil
        }
        store.notSelectedToNull()

        var jsonbody = store.toJSON()
        jsonbody?.removeValue(forKey: "accessedTime")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonbody, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                print(error?.localizedDescription)
                networkErrorAlert()
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                }
            } catch let error {
                networkErrorAlert()
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    static func sendStoreInfo(store: StoreModel) {
        let url = URL(string: baseUrl + "/api/sales_support/new_store/")!
        let session = URLSession.shared
        
        var request = URLRequest(url: url)
        let token = "JWT " + UserDefaults.standard.string(forKey: UserDefaultsConstant.authToken)!
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        request.httpMethod = "POST"
        
        store.reported_by = UserDefaults.standard.string(forKey: UserDefaultsConstant.username)
        store.feedJsonProperties()
        store.notSelectedToNull()
        var jsonbody = store.toJSON()
        jsonbody?.removeValue(forKey: "accessedTime")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: jsonbody, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    static func searchStores(_ searchKey: String, _ searchedHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) {
        let urlStr = baseUrl + "/api/sales_support/stores/?store_name=" + searchKey
        let strencode = urlStr.addingPercentEncoding( withAllowedCharacters: .urlQueryAllowed)!
        let url = URL(string: strencode)
        var request = URLRequest(url: url!)
        let token = "JWT " + UserDefaults.standard.string(forKey: UserDefaultsConstant.authToken)!
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            let json = JSON(data!)
            if let detail = json.dictionaryValue["detail"]?.string {
                if detail == "Error decoding signature." {
                    
                }
            }
            
            searchedHandler(data, response, error)
        }).resume()
    }
    
    static func getAuthToken() {
        let url = URL(string: baseUrl + "/user/auth/")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        let boundary = "---------------------------\(uniqueId)"
        
        // Headerの設定
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Bodyの設定
        var body = Data()
        var bodyText = String()
        
        for element in testAuthInfo {
            switch element.value {
            case let image as UIImage:
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\"; filename=\"\(element.key).jpg\"\r\n"
                bodyText += "Content-Type: image/jpeg\r\n\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(imageData!)
            case let int as Int:
                bodyText = String()
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(String(int).data(using: String.Encoding.utf8)!)
            case let string as String:
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(string.data(using: String.Encoding.utf8)!)
            default:
                break
            }
        }
        
        // Footerの設定
        var footerText = String()
        footerText += "\r\n"
        footerText += "\r\n--\(boundary)--\r\n"
        
        body.append(footerText.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response {
                print(response)
                
                do {
                    let json = JSON(data)
                    NSLog("getJsonFileuser_id: \(json)")
                    
                    UserDefaults.standard.set(json["token"].stringValue, forKey: UserDefaultsConstant.authToken)
                    UserDefaults.standard.synchronize()
                    
                    print(json["token"])
                    
                } catch {
                    print("Serialize Error")
                }
            } else {
                print(error ?? "Error")
            }
        }
        
        task.resume()
    }
    
    static func refreshToken() {
        guard let userId = UserDefaults.standard.string(forKey: UserDefaultsConstant.username) else {
            return
        }
        var userIdArray = userId.components(separatedBy: "@")
        var authInfo = ["username": userIdArray[0], "password": "7MmTwzp_flpfW411"]
        let url = URL(string: baseUrl + "/user/auth/")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        let boundary = "---------------------------\(uniqueId)"
        
        // Headerの設定
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Bodyの設定
        var body = Data()
        var bodyText = String()
        
        for element in authInfo {
            switch element.value {
            case let image as UIImage:
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\"; filename=\"\(element.key).jpg\"\r\n"
                bodyText += "Content-Type: image/jpeg\r\n\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(imageData!)
            case let int as Int:
                bodyText = String()
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(String(int).data(using: String.Encoding.utf8)!)
            case let string as String:
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(string.data(using: String.Encoding.utf8)!)
            default:
                break
            }
        }
        
        // Footerの設定
        var footerText = String()
        footerText += "\r\n"
        footerText += "\r\n--\(boundary)--\r\n"
        
        body.append(footerText.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response {
                print(response)
                
                do {
                    let json = JSON(data)
                    NSLog("getJsonFileuser_id: \(json)")
                    
                    if json["token"] == JSON.null || json["token"].stringValue.isEmpty {
                        return
                    }
                    
                    UserDefaults.standard.set(userIdArray[0], forKey: UserDefaultsConstant.username)
                    UserDefaults.standard.set(json["token"].stringValue, forKey: UserDefaultsConstant.authToken)
                    UserDefaults.standard.synchronize()
                    
                    print(json["token"])
                } catch {
                    print("Serialize Error")
                }
            } else {
                print(error ?? "Error")
            }
        }
        
        task.resume()
    }
    
    static func getLoginAuthToken(_ userId: String, _ successHandler:@escaping () -> Void, _ failedHandler:@escaping (_ error: String) -> Void) {
        var userIdArray = userId.components(separatedBy: "@")
        var authInfo = ["username": userIdArray[0], "password": "7MmTwzp_flpfW411"]
        let url = URL(string: baseUrl + "/user/auth/")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        let boundary = "---------------------------\(uniqueId)"
        
        // Headerの設定
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Bodyの設定
        var body = Data()
        var bodyText = String()
        
        for element in authInfo {
            switch element.value {
            case let image as UIImage:
                let imageData = UIImageJPEGRepresentation(image, 1.0)
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\"; filename=\"\(element.key).jpg\"\r\n"
                bodyText += "Content-Type: image/jpeg\r\n\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(imageData!)
            case let int as Int:
                bodyText = String()
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(String(int).data(using: String.Encoding.utf8)!)
            case let string as String:
                bodyText += "--\(boundary)\r\n"
                bodyText += "Content-Disposition: form-data; name=\"\(element.key)\";\r\n"
                bodyText += "\r\n"
                
                body.append(bodyText.data(using: String.Encoding.utf8)!)
                body.append(string.data(using: String.Encoding.utf8)!)
            default:
                break
            }
        }
        
        // Footerの設定
        var footerText = String()
        footerText += "\r\n"
        footerText += "\r\n--\(boundary)--\r\n"
        
        body.append(footerText.data(using: String.Encoding.utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = response {
                print(response)
                
                do {
                    let json = JSON(data)
                    NSLog("getJsonFileuser_id: \(json)")
                    
                    if json["token"] == JSON.null || json["token"].stringValue.isEmpty {
                        failedHandler("メールが正しくではありません")
                        return
                    }

                    UserDefaults.standard.set(userIdArray[0], forKey: UserDefaultsConstant.username)
                    UserDefaults.standard.set(json["token"].stringValue, forKey: UserDefaultsConstant.authToken)
                    UserDefaults.standard.synchronize()
                    
                    print(json["token"])
                    successHandler()
                } catch {
                    print("Serialize Error")
                    failedHandler("ネットワーク通信エラー")
                }
            } else {
                print(error ?? "Error")
                failedHandler("ネットワーク通信エラー")
            }
        }
        
        task.resume()
    }
    
    static func networkErrorAlert() {
        DispatchQueue.main.async(execute: {
            var alertController = UIAlertController(title: "ネットワーク通信エラー", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                action in
            })
            alertController.addAction(okAction)
            alertController.show()
        })
    }
}
