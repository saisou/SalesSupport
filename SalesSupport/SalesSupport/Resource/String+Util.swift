//
//  String+Util.swift
//  SalesSupport
//
//  Created by 倉岡昭一 on 2017/11/16.
//  Copyright © 2017年 BlogWatcher. All rights reserved.
//

import Foundation

extension String {
    static func randomString(length: Int) -> String {
        let alphabet = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.count)
        return String((0..<length).map {_ -> Character in
            return alphabet[alphabet.index(alphabet.startIndex, offsetBy: Int(arc4random_uniform(upperBound)))]
        })
    }
}
