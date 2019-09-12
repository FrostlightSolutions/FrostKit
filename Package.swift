// swift-tools-version:5.0
//
//  Package.swift
//  FrostKit
//
//  Created by James Barrow on 2019-06-27.
//  Copyright © 2019 James Barrow - Frostlight Solutions. All rights reserved.
//

import PackageDescription

let package = Package(
    name: "FrostKit",
    platforms: [
        .iOS(.v10),
        .watchOS(.v3),
        .tvOS(.v10),
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "FrostKit",
            targets: ["FrostKit"])
    ],
    targets: [
        .target(
            name: "FrostKit",
            path: "FrostKit")
    ],
    swiftLanguageVersions: [.v5]
)
