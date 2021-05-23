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

// MARK: - Main-Thread Performance

class CustomImageView: UIImageView {
    override var image: UIImage? {
        get { nil }
        set { /* Do nothing removing display from the equation */ }
    }
}

/// These tests cover the main-thread performance for the scenario where the
/// fetched image is availalbe in the memory cache (cache hit).
class CacheHitPerformanceTests: XCTestCase {
    let view = CustomImageView()
    let image = UIImage(named: "fixture")! // same image so that it gets decoded once
    // 10_000 iterations, but 100 unique URLs
    let urls: [URL] = (0..<25_000).map { _ in URL(string: "http://test.com/\(arc4random_uniform(100)).jpeg")! }

    func testNuke() {
        for url in urls {
            Nuke.ImageCache.shared[url] = ImageContainer(image: image)
        }

        measure {
            for url in urls {
                Nuke.loadImage(with: url, into: view)
            }
        }
    }

    func testAlamofireImage() {
        for url in urls {
            UIImageView.af.sharedImageDownloader.imageCache?.add(image, for: URLRequest(url: url), withIdentifier: nil)
        }

        measure {
            for url in urls {
                view.af.setImage(withURL: url)
            }
        }
    }

    func testKingfisher() {
        for url in urls {
            KingfisherManager.shared.cache.store(image, original: nil, forKey: url.absoluteString, processorIdentifier: "", cacheSerializer: DefaultCacheSerializer.default, toDisk: false, completionHandler: nil)
        }

        measure {
            for url in urls {
                view.kf.setImage(with: url)
            }
        }
    }

    func testSDWebImage() {
        for url in urls {
            SDImageCache.shared.store(image, imageData: nil, forKey: url.absoluteString, toDisk: false, completion: nil)
        }

        measure {
            for url in urls {
                view.sd_setImage(with: url)
            }
        }
    }

    func testAppleSample() {
        let urls = urls.map { $0 as NSURL }

        for url in urls {
            AppleSample.ImageCache.publicCache.storeImage(image, for: url)
        }

        let items = urls.map {
            Item(image: nil, url: NSURL(string: $0.absoluteString!)!)
        }

        let allItems = zip(urls, items)

        measure {
            for (url, item) in allItems {
                AppleSample.ImageCache.publicCache.load(url: url, item: item) { item, image in
                    // Techincally we update the item in this callback and reload
                    // the view that is currenltly displaying it.
                    self.view.image = image
                }
            }
        }
    }
}

/// These tests cover the main-thread performance for the scenario where the
/// fetched image is not availalbe in the memory cache and the request needs
/// to be sent (cache miss).
class CacheMissPerformanceTests: XCTestCase {
    let view = CustomImageView()
    let urls: [URL] = (0..<20_000).map { _ in URL(string: "http://test.com/\(arc4random()).jpeg")! }


    func testNuke() {
        measure {
            for url in urls {
                Nuke.loadImage(with: url, into: view)
            }
        }
    }

     func testAlamofireImage() {
        measure {
            for url in urls {
                view.af.setImage(withURL: url)
            }
        }
     }

    func testKingfisher() {
        measure {
            for url in urls {
                view.kf.setImage(with: url)
            }
        }
    }

    func testSDWebImage() {
        measure {
            for url in urls {
                view.sd_setImage(with: url)
            }
        }
    }

    func testAppleSample() {
        let urls = urls.map { $0 as NSURL }

        let items = urls.map {
            Item(image: nil, url: $0)
        }

        let allItems = zip(urls, items)

        measure {
            for (url, item) in allItems {
                AppleSample.ImageCache.publicCache.load(url: url, item: item) { item, image in
                    // Techincally we update the item in this callback and reload
                    // the view that is currenltly displaying it.
                    self.view.image = image
                }
            }
        }
    }
}
