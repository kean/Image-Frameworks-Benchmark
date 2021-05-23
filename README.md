# Image Frameworks Benchmark

> Updated on May 23, 2021

- [Nuke](https://github.com/kean/Nuke) 10.0.0 · Swift
- [Kingfisher](https://github.com/onevcat/Kingfisher) 6.3.0 · Swift
- [AlamofireImage](https://github.com/Alamofire/AlamofireImage) 4.2.0 · Swift
- [SDWebImage](https://github.com/rs/SDWebImage) 5.11.1 · Objective-C

> Only comparing Swift frameworks and SDWebImage as an exception because it's still actively maintained and often used even today.

## Main Thread Performance

Image loading frameworks are often used in table and collection views with a large number of cells. They must perform well to achieve smooth scrolling. This benchmark tests method that are used on the main thread.

```swift
Nuke.loadImage(with: url, into: view)
view.kf.setImage(with: url)
view.sd_setImage(with: url)
view.af.setImage(withURL: url)
```

The results (higher is better):

<img width="700" src="https://user-images.githubusercontent.com/1567433/119271801-10d6be80-bbd1-11eb-8b09-5ef856e379f0.png">

<img width="700" src="https://user-images.githubusercontent.com/1567433/119271802-10d6be80-bbd1-11eb-996e-84a4eef0ebfa.png">

> - The reason AlamofireImage is so slow is that it's creating `URLRequest` instances and attaching HTTP headers on the main thread, which is expensive and not needed for memory cache lookup
> - Kingfisher performs disk reads on the main thread making Cache Miss scenario slow 
>
> Measured on iPhone 11 Pro

