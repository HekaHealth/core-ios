// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "HekaCore",
  platforms: [.iOS(.v13)],
  products: [
    // Products define the executables and libraries a package produces, and make them visible to other packages.
    .library(
      name: "HekaCore",
      targets: ["heka"])
  ],
  dependencies: [
    .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
    .package(url: "https://github.com/mxcl/PromiseKit", from: "6.8.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "heka",
      dependencies: ["Alamofire", "PromiseKit", .product(name: "Logging", package: "swift-log")],
      path: "Sources",
      resources: [
        .process("Resources")
      ]
    ),
    .testTarget(
      name: "hekaTests",
      dependencies: ["heka"]),
  ],
  swiftLanguageVersions: [.v5]
)
