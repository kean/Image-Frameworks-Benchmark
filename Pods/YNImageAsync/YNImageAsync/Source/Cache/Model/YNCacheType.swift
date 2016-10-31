//
//  YNCacheType.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

struct YNCacheType : OptionSet {
    let rawValue: Int
    
    static let memory = YNCacheType(rawValue: 1 << 0)
    static let disk   = YNCacheType(rawValue: 1 << 1)
}
