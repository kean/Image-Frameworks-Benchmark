//
//  CacheProvider.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

public typealias CacheCompletionClosure = ((_ success: Bool) -> (Void))
let maxMemoryCacheSize : Int64 = 10 * 1024 * 1024 // 10Mb

public class CacheProvider {

    internal var memoryCache: [String: CacheEntry] = [:]
    public var configuration: CacheConfiguration
    
    public static let sharedInstance : CacheProvider = {
        let options : CacheOptions = [.memory, .disk]
        let conf = CacheConfiguration(options: options, memoryCacheLimit: maxMemoryCacheSize)
        let instance = CacheProvider(configuration: conf)
        return instance
    }()
    
    public init(configuration: CacheConfiguration) {
        self.configuration = configuration
    }
    
    public func cacheForKey(_ key: String, completion: @escaping ((_ data: Data?) -> Void)) {
        if let memCache = memoryCacheForKey(key) {
            completion(memCache)
        } else {
            diskCacheForKey(key, completion: completion)
        }
    }
    
    public func memoryCacheForKey(_ key: String) -> Data? {
        if configuration.options.contains(.memory) {
            if let cacheHit = memoryCache[key] {
                yn_logInfo("Mem cache hit: \(key)")
                return cacheHit.data
            }
            yn_logInfo("Mem cache miss: \(key)")
        }
        return nil
    }
    
    public func diskCacheForKey(_ key: String, completion: @escaping ((_ data: Data?) -> Void)) {
        if configuration.options.contains(.disk) {
            let filePath = fileInCacheDirectory(filename: key)
            let url = URL(fileURLWithPath: filePath)
            readCache(fileUrl: url, completion: { (data) in
                if let cacheHit = data {
                    yn_logInfo("Disk cache hit: \(key)")
                    self.cacheDataToMemory(key, cacheHit)
                    completion(cacheHit)
                    return
                } else {
                    yn_logInfo("Disk cache miss: \(key)")
                    completion(nil)
                    return
                }
            })
        } else {
            completion(nil)
        }
    }
    
    public func cacheData(_ key: String, _ data: Data, completion: CacheCompletionClosure? = nil) {
        cacheDataToMemory(key, data)
        cacheDataToDisk(key, data, completion: completion)
    }
    
    public func cacheDataToMemory(_ key: String, _ data: Data) {
        if configuration.options.contains(.memory) {
            let entry = CacheEntry(data: data, date: Date())
            yn_logInfo("Cache store: \(key)")
            memoryCache[key] = entry
            cleanMemoryCache()
        }
    }
    
    public func cacheDataToDisk(_ key: String, _ data: Data, completion: CacheCompletionClosure? = nil) {
        if configuration.options.contains(.disk) {
            let filePath = fileInCacheDirectory(filename: key)
            let url = URL(fileURLWithPath: filePath)
            saveCache(cacheData: data, fileUrl: url, completion: completion)
        } else {
            if let completionClosure = completion {
                completionClosure(true)
            }
        }
    }
    
    public func cleanMemoryCache() {
        let sorted = memoryCache.values.sorted { (entry1, entry2) -> Bool in
            return entry1.date > entry2.date
        }
        let maxSize = configuration.memoryCacheLimit
        let memorySize = memoryCacheSize()
        if memorySize > maxSize {
            yn_logInfo("Memory cache \(memoryCacheSize()) > max \(maxSize)")
            var size : Int64 = 0
            var newCache : Array<CacheEntry> = []
            for cacheEntry in sorted {
                size += cacheEntry.data.count
                if size > maxSize {
                    yn_logInfo("Found \(sorted.count - newCache.count) elements exceeding capacity")
                    filterCacheWithArray(array: newCache)
                    break
                }
                newCache.append(cacheEntry)
            }
        }
    }
    
    public func clearMemoryCache() {
        memoryCache.removeAll()
    }
    
    public func diskCacheSize() -> Int64 {
        let files = cacheFolderFiles()
        var folderSize : Int64 = 0
        for file in files {
            do {
                let attributes = try FileManager.default.attributesOfItem(atPath: file)
                let fileSize = attributes[FileAttributeKey.size] as! NSNumber
                folderSize += fileSize.int64Value
            } catch let error {
                yn_logInfo("Cache folder file attribute error: \(error)")
            }
        }
        return folderSize
    }
    
    public func memoryCacheSize() -> Int64 {
        var size: Int64 = 0
        for cacheEntry in memoryCache.values {
            size += cacheEntry.data.count
        }
        return size
    }
    
    public func clearDiskCache() {
        let files = cacheFolderFiles()
        for file in files {
            yn_logInfo("Trying to delete \(file)")
            do {
                try FileManager.default.removeItem(atPath: file)
                yn_logInfo("Deleted disk cache: \(file)")
            } catch let error {
                yn_logInfo("Cache folder read error: \(error)")
            }
        }
    }

    public func clearCache() {
        clearMemoryCache()
        clearDiskCache()
    }
    
    func cacheFolderFiles() -> [String] {
        var returnedValue: [String] = []
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: cachePath())
            for file in files {
                let path = cachePath()
                let fullPath = (path as NSString).appendingPathComponent(file)
                returnedValue.append(fullPath)
            }
        } catch let error {
            yn_logInfo("Cache folder read error: \(error)")
        }
        return returnedValue
    }
    
    func filterCacheWithArray(array: Array <CacheEntry>) {
        let tempCache = memoryCache
        for (key, entry) in tempCache {
            if !array.contains(where: { (filterEntry) -> Bool in
                return entry.udid == filterEntry.udid
            }) {
                memoryCache.removeValue(forKey: key)
                yn_logInfo("Removing \(entry.udid)")
            }
        }
    }
    
    func cacheDirectory() -> String {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        return documentsFolderPath
    }
    
    func cachePath() -> String {
        return (cacheDirectory() as NSString).appendingPathComponent("YNImageAsync")
    }
    
    func fileInCacheDirectory(filename: String) -> String {
        
        let writePath = cachePath()
        
        if (!FileManager.default.fileExists(atPath: writePath)) {
            do {
                try FileManager.default.createDirectory(atPath: writePath, withIntermediateDirectories: false, attributes: nil) }
            catch let error {
                yn_logError("Failed to create directory: \(writePath) - \(error)")
            }
        }
        
        if let escapedFilename = filename.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            return (writePath as NSString).appendingPathComponent(escapedFilename)
        } else {
            return (writePath as NSString).appendingPathComponent(filename)
        }
    }
    
    func readCache(fileUrl: URL, completion: @escaping ((_ data: Data?) -> Void)) {
        executeBackground {
            do {
                let data = try Data(contentsOf: fileUrl)
                yn_logInfo("Disk cache read success: \(fileUrl)")
                completion(data)
            } catch let readError {
                yn_logInfo("Disk cache read error: \(readError)")
                completion(nil)
            }
        }
    }
    
    func saveCache(cacheData: Data, fileUrl: URL, completion: CacheCompletionClosure? = nil) {
        executeBackground {
            do {
                try cacheData.write(to: fileUrl , options: Data.WritingOptions(rawValue: 0))
                yn_logInfo("Disk cache write success: \(fileUrl)")
                if let completionClosure = completion {
                    completionClosure(true)
                }
            } catch let saveError {
                yn_logError("Disk cache write error: \(saveError)")
                if let completionClosure = completion {
                    completionClosure(false)
                }
            }
        }
    }
    
    func executeBackground(_ block:@escaping () -> Void) {
        if (Thread.isMainThread) {
            DispatchQueue.global(qos: .default).async { block() }
        } else { block() }
    }
    
}
