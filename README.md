# Image Frameworks Benchmark

> Updated on May 23, 2021

- [Nuke](https://github.com/kean/Nuke) 10.0.0 · Swift
- [Kingfisher](https://github.com/onevcat/Kingfisher) 6.3.0 · Swift
- [AlamofireImage](https://github.com/Alamofire/AlamofireImage) 4.2.0 · Swift
- [SDWebImage](https://github.com/rs/SDWebImage) 5.11.1 · Objective-C

> Only comparing Swift frameworks, and SDWebImage as an exception because it's still actively maintained and often used even today.

## Main Thread Performance

Image loading frameworks are often used in table and collection views with a large number of cells. They must perform well to achieve smooth scrolling. This benchmark tests method that are used on the main thread.

```swift
Nuke.loadImage(with: url, into: view)
view.kf.setImage(with: url)
view.sd_setImage(with: url)
view.af.setImage(withURL: url)
```

The results (higher is better):

<img src="https://user-images.githubusercontent.com/1567433/61174515-92a33d00-a5a1-11e9-839f-c2a1a1237f52.png" width="800"/>

<img src="https://user-images.githubusercontent.com/1567433/61174516-92a33d00-a5a1-11e9-8915-55cf9ba519a2.png" width="800"/>

> - The reason AlamofireImage is so slow is that it's creating `URLRequest` instances and attaching HTTP headers on the main thread, which is expensive and not needed for memory cache lookup
> - Kingfisher performs disk reads on the main thread making Cache Miss scenario slow 
>
> Measured on iPhone 11 Pro

