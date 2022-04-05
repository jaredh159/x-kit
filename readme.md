# XKit

Some core Swift utils, extensions, operator, types etc. that I find useful for personal
and open source Swift projects. Not documented, sorry! YMMV.

## Installation

Use SPM:

```swift
// [...]
// in "DEPENDENCIES"
  .package(url: "https://github.com/jaredh159/x-kit.git", from: "1.0.0")
// [...]
// in "TARGETS"
  .product(name: "XCore", package: "XKit"),
  .product(name: "XBase64", package: "XKit"),
  .product(name: "XVapor", package: "XKit"),
// [...]
```
