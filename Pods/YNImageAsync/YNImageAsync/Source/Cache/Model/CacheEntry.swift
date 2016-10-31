//
//  CacheEntry.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public struct CacheEntry {
    let udid: String = UUID().uuidString
    var data: Data
    var date: Date
}
