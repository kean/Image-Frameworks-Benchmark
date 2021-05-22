// The MIT License (MIT)
//
// Copyright (c) 2015-2018 Alexander Grebenyuk (github.com/kean).

import XCTest
import Nuke
import Alamofire
import AlamofireImage
import Kingfisher
import SDWebImage
import AppleSample

/// These tests cover the main-thread performance for the scenario where the
/// fetched image is availalbe in the memory cache (cache hit).
class CacheHitPerformanceTests: XCTestCase {
    let view = UIImageView()
    let image = UIImage(named: "fixture")! // same image so that it gets decoded once
    let urls: [URL] = {
        // 10_000 iterations, but only 100 unique URLs
        return (0..<25_000).map { _ in return URL(string: "http://test.com/\(arc4random_uniform(100)).jpeg")! }
    }()

    func testNuke() {
        for url in self.urls {
            Nuke.ImageCache.shared[url] = ImageContainer(image: image)
        }

        measure {
            for url in self.urls {
                Nuke.loadImage(with: url, into: self.view)
            }
        }
    }

    func testAlamofireImage() {
        for url in self.urls {
            UIImageView.af.sharedImageDownloader.imageCache?.add(image, for: URLRequest(url: url), withIdentifier: nil)
        }

        measure {
            for url in self.urls {
                self.view.af.setImage(withURL: url)
            }
        }
    }

    func testKingfisher() {
        for url in self.urls {
            KingfisherManager.shared.cache.store(image, original: nil, forKey: url.absoluteString, processorIdentifier: "", cacheSerializer: DefaultCacheSerializer.default, toDisk: false, completionHandler: nil)
        }

        measure {
            for url in self.urls {
                self.view.kf.setImage(with: url)
            }
        }
    }

    func testSDWebImage() {
        for url in self.urls {
            SDImageCache.shared.store(image, imageData: nil, forKey: url.absoluteString, toDisk: false, completion: nil)
        }

        measure {
            for url in self.urls {
                self.view.sd_setImage(with: url)
            }
        }
    }
}

/// These tests cover the main-thread performance for the scenario where the
/// fetched image is not availalbe in the memory cache and the request needs
/// to be sent (cache miss).
class CacheMissPerformanceTests: XCTestCase {
    let view = UIImageView()
    let urls: [URL] = {
        return (0..<20_000).map { _ in return URL(string: "http://test.com/\(arc4random()).jpeg")! }
    }()

    func testNuke() {
        measure {
            for url in self.urls {
                Nuke.loadImage(with: url, into: self.view)
            }
        }
    }

     func testAlamofireImage() {
        measure {
            for url in self.urls {
                self.view.af.setImage(withURL: url)
            }
        }
     }

    func testKingfisher() {
        measure {
            for url in self.urls {
                self.view.kf.setImage(with: url)
            }
        }
    }

    func testSDWebImage() {
        measure {
            for url in self.urls {
                self.view.sd_setImage(with: url)
            }
        }
    }
}
