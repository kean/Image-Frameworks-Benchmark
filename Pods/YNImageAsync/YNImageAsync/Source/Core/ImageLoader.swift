//
//  ImageLoader.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 15.10.16.
//  Copyright © 2016 Yury Nechaev. All rights reserved.
//

import UIKit

public enum LoaderCompletionResult {
    case success(Data)
    case failure(Error)
    case handler(URLSessionTask)
}

public protocol DataRequestProtocol {
    func loadImageWithUrl(_ imageUrl: String,
                          progress: @escaping LoaderProgressClosure,
                          completion: @escaping LoaderCompletionClosure);
}

public typealias LoaderCompletionClosure = ((LoaderCompletionResult) -> (Void))
public typealias LoaderProgressClosure = ((_ progress: Float) -> Void)

public class ImageLoader : NSObject, URLSessionDataDelegate, URLSessionDelegate, URLSessionTaskDelegate {
    
    var session: URLSession = URLSession(configuration: URLSessionConfiguration.default)
    var completionQueue: [Int: LoaderCompletionClosure] = [:]
    var progressQueue: [Int: LoaderProgressClosure] = [:]
    var responsesQueue: [Int: Data] = [:]
    var expectedSizeQueue: [Int: Int] = [:]
    private let queue = DispatchQueue(label: "com.YNImageAsync.loader")
    
    static let sharedInstance : ImageLoader = {
        let instance = ImageLoader()
        return instance
    }()
    
    init(configuration: URLSessionConfiguration) {
        super.init()
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.session = session
    }
    
    override convenience init() {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringCacheData;
        self.init(configuration: configuration)
    }
    
    public func loadImageWithUrl(_ imageUrl: URL, progress: @escaping LoaderProgressClosure, completion: @escaping LoaderCompletionClosure) {
        assert(Thread.isMainThread)
        queue.async {
            CacheProvider.sharedInstance.cacheForKey(imageUrl.absoluteString) { (data) in
                if let cachedImageData = data {
                    DispatchQueue.main.async {
                        completion(LoaderCompletionResult.success(cachedImageData))
                    }
                } else {
                    let task = self.session.dataTask(with: imageUrl)
                    self.launchTask(task: task, progress: progress, completion: completion)
                    completion(LoaderCompletionResult.handler(task))
                }
            }
        }
    }
    
    func launchTask(task: URLSessionTask, progress: @escaping LoaderProgressClosure, completion: @escaping LoaderCompletionClosure) {
        synced(lock: self) {
            completionQueue[task.taskIdentifier] = completion
            progressQueue[task.taskIdentifier] = progress
        }
        task.resume()
    }
    
    func removeQueuesForTaskId(_ taskId: Int) {
        synced(lock: self) { 
            completionQueue.removeValue(forKey: taskId)
            progressQueue.removeValue(forKey: taskId)
            responsesQueue.removeValue(forKey: taskId)
            expectedSizeQueue.removeValue(forKey: taskId)
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if let existingData = self.responsesQueue[dataTask.taskIdentifier] {
            var mutableData = existingData
            mutableData.append(data)
            notifyProgress(mutableData, dataTask)
            synced(lock: self, closure: { 
                responsesQueue[dataTask.taskIdentifier] = mutableData
            })
        } else {
            synced(lock: self, closure: {
                responsesQueue[dataTask.taskIdentifier] = data
            })
            notifyProgress(data, dataTask)
        }
    }
    
    func notifyProgress(_ data: Data, _ dataTask: URLSessionDataTask) {
        if let bufferSize = expectedSizeQueue[dataTask.taskIdentifier], let progressClosure = progressQueue[dataTask.taskIdentifier] {
            let percentageDownloaded = Float(data.count) / Float(bufferSize)
            DispatchQueue.main.async {
                progressClosure(percentageDownloaded)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        synced(lock: self, closure: {
            expectedSizeQueue[dataTask.taskIdentifier] = Int(response.expectedContentLength)
        })
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let completionClosure = completionQueue[task.taskIdentifier] {
            if let responseError = error {
                DispatchQueue.main.async {
                    completionClosure(.failure(responseError))
                }
            } else {
                if let existingData = responsesQueue[task.taskIdentifier] {
                    DispatchQueue.main.async {
                        completionClosure(.success(existingData))
                    }
                    if let key = task.originalRequest?.url?.absoluteString {
                        CacheProvider.sharedInstance.cacheData(key, existingData)
                    }
                }
            }
        }
        removeQueuesForTaskId(task.taskIdentifier)
    }
    
}

