//
//  CacheOptions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 16.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public struct CacheConfiguration {
    public var options : CacheOptions
    public var memoryCacheLimit : Int64
}

public struct CacheOptions : OptionSet {
    
    public let rawValue: Int
    public static let none   = CacheOptions(rawValue: 0)
    public static let memory = CacheOptions(rawValue: 1 << 0)
    public static let disk   = CacheOptions(rawValue: 1 << 1)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
