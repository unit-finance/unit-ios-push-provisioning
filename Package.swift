// swift-tools-version:5.9
import PackageDescription

// The app loader has an Objective-C file next to its Swift half. A package target can't mix languages,
// so the .m is built as its own target and both targets ship in the one library product.
let loaderPath = "Helper/UNPushProvisioningAppLoader"
let loaderBridge = "UNPushProvisioningAppLoaderBridge.m"

let package = Package(
    name: "UnitPushProvisioning",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "UnitPushProvisioning", type: .dynamic, targets: ["UnitPushProvisioning", "UnitPushProvisioningLoader"])
    ],
    dependencies: [
        .package(url: "https://github.com/unit-finance/unit-ios-sdk.git", branch: "release/1.2.0")
    ],
    targets: [
        .target(
            name: "UnitPushProvisioning",
            dependencies: [
                .product(name: "UnitCommon", package: "unit-ios-sdk")
            ],
            path: "Sources/UnitPushProvisioning",
            exclude: ["\(loaderPath)/\(loaderBridge)"]
        ),
        .target(
            name: "UnitPushProvisioningLoader",
            path: "Sources/UnitPushProvisioning/\(loaderPath)",
            exclude: ["UNPushProvisioningAppLoader.swift"],
            sources: [loaderBridge],
            publicHeadersPath: "."
        )
    ]
)
