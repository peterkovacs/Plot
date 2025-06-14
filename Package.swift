// swift-tools-version:6.1

/**
*  Plot
*  Copyright (c) John Sundell 2019
*  MIT license, see LICENSE file for details
*/

import PackageDescription

let package = Package(
    name: "Plot",
    platforms: [
        .macOS(.v15),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "Plot",
            targets: ["Plot"]
        )
    ],
    targets: [
        .target(name: "Plot"),
        .testTarget(
            name: "PlotTests",
            dependencies: ["Plot"]
        )
    ]
)
