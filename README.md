# Image Frameworks Benchmark

> Udpated on April 27th 2018

- [Nuke](https://github.com/kean/Nuke) 7.0 · Swift
- [Kingfisher](https://github.com/onevcat/Kingfisher) 4.7.0 · Swift
- [AlamofireImage](https://github.com/Alamofire/AlamofireImage) 3.3.1 · Swift
- [SDWebImage](https://github.com/rs/SDWebImage) 4.3.3 · Objective-C
- [PINRemoteImage](https://github.com/pinterest/PINRemoteImage) 2.1.4 · Objective-C

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

<img src="https://user-images.githubusercontent.com/1567433/39393415-495915f8-4ac5-11e8-82c9-71403c9c492d.png" width="800"/>
<img src="https://user-images.githubusercontent.com/1567433/39393416-49754c5a-4ac5-11e8-9bb1-db564b414ec5.png" width="800"/>

