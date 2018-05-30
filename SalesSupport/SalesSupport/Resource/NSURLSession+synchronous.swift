//
//  NSURLSession+synchronous.swift
//  SalesSupport
//
//  Created by appzcapple on 2018/03/28.
//  Copyright © 2018年 com.zc.EducationApps. All rights reserved.
//

import Foundation

extension URLSession {
    func synchronousDataTask(with req: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: req) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        dataTask.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}
