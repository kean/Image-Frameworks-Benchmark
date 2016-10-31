//
//  PerformanceTests_Tests.swift
//  PerformanceTests Tests
//
//  Created by Alexander Grebenyuk on 29/09/16.
//  Copyright © 2016 Alexander Grebenyuk. All rights reserved.
//

import XCTest
import Nuke
import AlamofireImage
import Kingfisher
import Haneke
import SDWebImage
import PINRemoteImage
import YNImageAsync

class PerformanceTests: XCTestCase {
    
    // we need to make image view size > 0 in order to avoid Haneke assert
    let view = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1.0, height: 1.0)))
    let urls: [URL] = {
        return (0..<10_000).map { _ in return URL(string: "http://test.com/\(arc4random()).jpeg")! }
    }()
    
    //    AlamofreImage and PINRemoteImage are rather slow and doesn't seem to
    //    handle as much as 10_000 requests. You might want to limit the requests
    //    count before uncommenting.
    //
    //    func testPINRemoteImage() {
    //        measure {
    //            for url in self.urls {
    //                self.view.pin_setImage(from: url)
    //            }
    //        }
    //    }
    //
    //     func testAlamofireImage() {
    //        measure {
    //            for url in self.urls {
    //                self.view.af_setImage(withURL: url)
    //            }
    //        }
    //     }
    
    func testNuke() {
        measure {
            for url in self.urls {
                Nuke.loadImage(with: url, into: self.view)
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
    
    func testHaneke() {
        measure {
            for url in self.urls {
                self.view.hnk_setImageFromURL(url)
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
    
    func testYNImageAsync() {
        measure {
            for url in self.urls {
                self.view.setImageWithUrl(url)
            }
        }
    }
}
