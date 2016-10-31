//
//  YNImageAsyncExtensions.swift
//  ImageAsyncTest
//
//  Created by Yury Nechaev on 04.11.14.
//  Copyright (c) 2014 Yury Nechaev. All rights reserved.
//

import UIKit
import ObjectiveC

private var taskAssociationKey: UInt8 = 0

public enum ImageCompletionResult {
    case success(UIImage)
    case failure(Error)
}

public typealias ImageCompletionClosure = ((ImageCompletionResult) -> (Void))

extension UIImageView {
    
    public func cancelPreviousLoading() {
        if let currentTask = self.task {
            currentTask.cancel()
        }
    }
    
    public func setImageWithUrl(_ imageUrl: URL, placeholderImage: UIImage? = nil, progress: LoaderProgressClosure? = nil, completion: ImageCompletionClosure? = nil) {
        cancelPreviousLoading()
        if let placeholder = placeholderImage {
            self.image = placeholder
        }
        ImageLoader.sharedInstance.loadImageWithUrl(imageUrl, progress: { (progress) in
            
            }, completion: { (result: LoaderCompletionResult) -> (Void) in
                switch(result) {
                case .success(let data):
                    let image = UIImage(data: data)
                    self.image = image
                    if let completionClosure = completion, let completionImage = image {
                        completionClosure(.success(completionImage))
                    }
                case .failure(let error):
                    if let completionClosure = completion {
                        completionClosure(.failure(error))
                    }
                case .handler(let task):
                    self.task = task
                }
        })
    }
    
    // MARK: Associated task object
    
    var task: URLSessionTask? {
        get {
            return objc_getAssociatedObject(self, &taskAssociationKey) as? URLSessionTask
        }
        set(newValue) {
            objc_setAssociatedObject(self, &taskAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}
