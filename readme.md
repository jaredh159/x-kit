# XKit

Some core Swift utils, extensions, operator, types, vapor/graphql utils etc. that I find
useful for personal and open source Swift projects. Not documented, sorry! YMMV.

## Installation

Use SPM:

```diff
// swift-tools-version:5.5
import PackageDescription

let package = Package(
  name: "RadProject",
  products: [
    .library(name: "RadProject", targets: ["RadProject"]),
  ],
  dependencies: [
+   .package(url: "https://github.com/jaredh159/x-kit.git", from: "1.0.1")
  ],
  targets: [
    .target(name: "RadProject", dependencies: [
+     .product(name: "XCore", package: "x-kit"),
+     .product(name: "XBase64", package: "x-kit"),
+     .product(name: "XVapor", package: "x-kit"),
+     .product(name: "XGraphQLTest", package: "x-kit"),
    ]),
  ]
)
```
