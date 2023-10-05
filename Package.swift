// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FetchedResultsController",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "FetchedResultsController",
            targets: ["FetchedResultsController"]
        ),
    ],
    targets: [
        .target(
            name: "FetchedResultsController"
        ),
    ]
)
