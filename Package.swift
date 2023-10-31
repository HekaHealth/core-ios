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
      targets: ["HekaCore"])
  ],
  dependencies: [],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "HekaCore",
      dependencies: [],
      path: "Sources"
    ),
    .testTarget(
      name: "HekaCoreTests",
      dependencies: ["HekaCore"]),
  ],
  swiftLanguageVersions: [.v5]
)
