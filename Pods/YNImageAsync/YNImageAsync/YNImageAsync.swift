//
//  YNImageAsync.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 16.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import Foundation

public class YNImageAsync {
    
    var logLevel: LogLevel
    
    static let sharedInstance : YNImageAsync = {
        let instance = YNImageAsync(logLevel: LogLevel.none)
        return instance
    }()
    
    init(logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    public static func setLoggingLevel(level: LogLevel) {
        YNImageAsync.sharedInstance.logLevel = level
    }
}
