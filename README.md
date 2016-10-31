## Frameworks

Most of the tested frameworks are written in Swift. Couple of Objective-C frameworks were added for comparison.

- [Nuke](https://github.com/kean/Nuke)
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [Haneke](https://github.com/Haneke/HanekeSwift)
- [AlamofireImage](https://github.com/Alamofire/AlamofireImage)
- [SDWebImage](https://github.com/rs/SDWebImage)
- [PINRemoteImage](https://github.com/pinterest/PINRemoteImage)
- [YNImageAsync](https://github.com/ynechaev/YNImageAsync)

## Main Thread Performance

Image loading frameworks are often used in table and collection views with large number of cells. It's important that those frameworks perform well to achieve perfect scrolling performance.

In general `cellForRowAtIndexPath(:)` methods contain a call to `imageView.setImage(with:)` or similar method which does at least two things: check memory cache, and start a request. That's what is tested in this benchmark.

```swift
Nuke.loadImage(with: url, into: view)
view.kf.setImage(with: url)
view.hnk_setImageFromURL(url)
view.sd_setImage(with: url)
view.pin_setImage(from: url)
view.af_setImage(withURL: url)
view.setImageWithUrl(url)
```

Here are the results given as the number of calls that can be made in a second (higher is better):

<img src="https://cloud.githubusercontent.com/assets/1567433/19030480/c8f68f02-8956-11e6-855b-342c60707341.png" width="600"/>

<img src="https://cloud.githubusercontent.com/assets/1567433/19030481/c8f90e1c-8956-11e6-8d7e-0f92031c1dcd.png" width="600"/>

- The results for AlamofireImage are low because they do most of the work on the main thread. It includes creating URLSessionTasks, deduplicating equivalent requests and more.
- Objective-C frameworks are not affected by Whole Module Optimization.
- Nuke is not affected by Whole Module Optimization because it already does most of the optimizations that WMO can do (like marking internal classes final).
