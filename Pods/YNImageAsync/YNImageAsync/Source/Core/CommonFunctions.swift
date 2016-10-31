//
//  YNCommonFunctions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

func yn_logError(_ items: Any...) {
    yn_log(items, level: .errors)
}

func yn_logDebug(_ items: Any...) {
    yn_log(items, level: .debug)
}

func yn_logInfo(_ items: Any...) {
    yn_log(items, level: .info)
}

func yn_log(_ items: Any..., level: LogLevel) {
    if YNImageAsync.sharedInstance.logLevel.contains(level) {
        print(items)
    }
}

public struct LogLevel : OptionSet {

    public let rawValue: Int
    public static let none   = LogLevel(rawValue: 0)
    public static let errors = LogLevel(rawValue: 1 << 0)
    public static let debug  = LogLevel(rawValue: (1 << 1) | errors.rawValue)
    public static let info   = LogLevel(rawValue: (1 << 2) | debug.rawValue)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

func synced(lock: AnyObject, closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
