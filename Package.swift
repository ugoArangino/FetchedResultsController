// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FetchedResultsController",
    products: [
        .library(
            name: "FetchedResultsController",
            targets: ["FetchedResultsController"]
        ),
    ],
    targets: [
        .target(
            name: "FetchedResultsController"),
        .testTarget(
            name: "FetchedResultsControllerTests",
            dependencies: ["FetchedResultsController"]
        ),
    ]
)
