// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "AppleSample",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "AppleSample", targets: ["AppleSample"])
    ],
    targets: [
        .target(name: "AppleSample", path: "Sources/")
    ]
)
