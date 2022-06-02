// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "XKit",
  platforms: [.macOS(.v11)],
  products: [
    .library(name: "XCore", targets: ["XCore"]),
    .library(name: "XBase64", targets: ["XBase64"]),
    .library(name: "XVapor", targets: ["XVapor"]),
    .library(name: "XGraphQLTest", targets: ["XGraphQLTest"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/vapor/vapor.git",
      from: "4.55.3"
    ),
    .package(
      url: "https://github.com/vapor/fluent-kit.git",
      from: "1.16.0"
    ),
    .package(
      url: "https://github.com/m-barthelemy/vapor-queues-fluent-driver.git",
      from: "1.2.0"
    ),
    .package(
      url: "https://github.com/alexsteinerde/graphql-kit.git",
      from: "2.3.0"
    ),
  ],
  targets: [
    .target(name: "XCore", dependencies: []),
    .target(name: "XBase64", dependencies: []),
    .target(name: "XVapor", dependencies: [
      .product(name: "Vapor", package: "Vapor"),
      .product(name: "FluentSQL", package: "fluent-kit"),
      .product(name: "QueuesFluentDriver", package: "vapor-queues-fluent-driver"),
    ]),
    .target(name: "XGraphQLTest", dependencies: [
      .product(name: "Vapor", package: "Vapor"),
      .product(name: "XCTVapor", package: "Vapor"),
      .product(name: "GraphQLKit", package: "graphql-kit"),
    ]),
    .testTarget(name: "XCoreTests", dependencies: ["XCore"]),
  ]
)
