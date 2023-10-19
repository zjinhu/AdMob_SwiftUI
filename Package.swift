// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AdMob_SwiftUI",
    platforms: [
      .iOS(.v15)
    ],
    products: [
        .library(
            name: "AdMob_SwiftUI",
            targets: ["AdMob_SwiftUI"]),
    ],
    dependencies: [
 
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", .upToNextMajor(from: "10.0.0")),
    ],
    targets: [
 
        .target(
            name: "AdMob_SwiftUI",
            dependencies: [
                .product(name: "GoogleMobileAds", package: "swift-package-manager-google-mobile-ads"),
            ]),
    ]
)
