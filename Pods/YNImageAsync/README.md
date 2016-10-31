YNImageAsync
==========
[![Build Status](https://travis-ci.org/ynechaev/YNImageAsync.svg?branch=master)](https://travis-ci.org/ynechaev/YNImageAsync)

#About
YNImageAsync is a lightweight and convenient framework for fetching and caching images.

# Features
- Written on Swift 3.0
- Asynchronous image loading
- Fast
- Supports both memory and drive caching
- Configurable
- Unit test coverage is good
- UIImageView extension for fast and out-of-the-box image loading.

# Install
### Using cocoapods
```
pod 'YNImageAsync', '~> 1.0'
```

# How to
### Set UIImageview image with url
```swift
if let url = URL(string: "https://upload.wikimedia.org/wikipedia/en/5/5f/Original_Doge_meme.jpg") {
    imageView.setImageWithUrl(url)
}
```
### Cancel UIImageview previous loading operation
```swift
imageView.cancelPreviousLoading()
```
### Access cache directly
```swift
// Initialize cache with 30 Mb memory capacity and disk caching
let cacheProvider = CacheProvider(configuration: CacheConfiguration(options: [.memory, .disk], memoryCacheLimit: 30 * 1024 * 1024)) 

// Save cache to memory and disk
cacheProvider.cacheData("key", data) 

// Get cached data for key
provider.cacheForKey(image, completion: { (data) in
    if let cacheData = data {
        print("Cache hit")
    } else {
        print("Cache miss")
    }
})
```
### Change memory cache capacity
You don't need to initialize new instance of cache provider in order to change maximum memory cache capacity.
```swift
// New memory capacity is 10 Mb
let newLimit: Int64 = 10 * 1024 * 1024        
provider.configuration.memoryCacheLimit = newLimit
// Perform memory clean operation if capacity was reduced
provider.cleanMemoryCache()
```
### Configure storage type
You can easily configure storage during initialization and during runtime as well
```swift
provider.configuration.options = .memory
```
