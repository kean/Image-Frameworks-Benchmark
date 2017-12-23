# Image Frameworks Benchmark

- [Nuke](https://github.com/kean/Nuke) · Swift
- [Kingfisher](https://github.com/onevcat/Kingfisher) · Swift
- [AlamofireImage](https://github.com/Alamofire/AlamofireImage) · Swift
- [SDWebImage](https://github.com/rs/SDWebImage) · Objective-C
- [PINRemoteImage](https://github.com/pinterest/PINRemoteImage) · Objective-C

## Main Thread Performance

Image loading frameworks are often used in table and collection views with large number of cells. It's important that they perform well to achieve butterly smooth scrolling. This benchmark tests methods which are used on the main thread when cells are created:

```swift
Nuke.loadImage(with: url, into: view)
view.kf.setImage(with: url)
view.sd_setImage(with: url)
view.pin_setImage(from: url)
view.af_setImage(withURL: url)
```

The results (higher is better):

<img src="https://user-images.githubusercontent.com/1567433/34312349-7b2b0bf4-e774-11e7-891d-a5f056874ff5.png" width="800"/>

Please keep in mind that this performance test makes for a very nice looking chart, but in practice, the difference between Nuke and say SDWebImage is not going to be that dramatic. Unless you app drops frames on a table or a collection view rendering, there is no real reason to switch.
