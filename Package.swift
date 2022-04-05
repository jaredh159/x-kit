// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "XKit",
  platforms: [.macOS(.v12)],
  products: [
    .library(name: "XCore", targets: ["XCore"]),
    .library(name: "XBase64", targets: ["XBase64"]),
    .library(name: "XVapor", targets: ["XVapor"]),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.55.3"),
    .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.16.0"),
  ],
  targets: [
    .target(name: "XCore", dependencies: []),
    .target(name: "XBase64", dependencies: []),
    .target(name: "XVapor", dependencies: [
      .product(name: "Vapor", package: "Vapor"),
      .product(name: "FluentSQL", package: "fluent-kit"),
    ]),
    .testTarget(name: "XCoreTests", dependencies: ["XCore"]),
  ]
)
