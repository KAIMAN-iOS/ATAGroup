// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ATAGroup",
    defaultLocalization: "en",
    platforms: [.iOS("13.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ATAGroup",
            targets: ["ATAGroup"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/jerometonnelier/KExtensions", .branch("master")),
        .package(url: "https://github.com/jerometonnelier/ATAConfiguration", .branch("master")),
        .package(url: "https://github.com/jerometonnelier/ActionButton", .branch("master")),
        .package(url: "https://github.com/jerometonnelier/KCoordinatorKit", .branch("master")),
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.0"),
        .package(url: "https://github.com/jerometonnelier/TextFieldEffects", .branch("master")),
        .package(url: "https://github.com/gordontucker/FittedSheets", from: "2.0.0"),
        .package(url: "https://github.com/mxcl/PromiseKit", from: "6.13.2"),
        .package(url: "https://github.com/jerometonnelier/KStorage", .branch("master")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ATAGroup",
            dependencies: ["KExtensions", "ATAConfiguration", "ActionButton", "KCoordinatorKit", "SnapKit", "TextFieldEffects", "FittedSheets", "PromiseKit", "KStorage"]),
    ]
)
