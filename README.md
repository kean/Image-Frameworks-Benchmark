# Image Frameworks Benchmark

> Updated on July 13, 2019

- [Nuke](https://github.com/kean/Nuke) 8.0 · Swift
- [SDWebImage](https://github.com/rs/SDWebImage) 5.0.6 · Objective-C
- [PINRemoteImage](https://github.com/pinterest/PINRemoteImage) 2.1.4 · Objective-C
- [Kingfisher](https://github.com/onevcat/Kingfisher) 5.7.0 · Swift
- [AlamofireImage](https://github.com/Alamofire/AlamofireImage) 3.5.2 · Swift

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

> Please keep in mind that this performance test makes for a very nice looking chart, but in practice, the difference between Nuke and say SDWebImage is not going to be that dramatic. Unless you app drops frames on a table or a collection view rendering, there is no real reason to switch.

<img src="https://user-images.githubusercontent.com/1567433/61174515-92a33d00-a5a1-11e9-839f-c2a1a1237f52.png" width="800"/>
<img src="https://user-images.githubusercontent.com/1567433/61174516-92a33d00-a5a1-11e9-8915-55cf9ba519a2.png" width="800"/>

