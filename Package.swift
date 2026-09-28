// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "UnitPushProvisioning",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "UnitPushProvisioning", targets: ["UnitPushProvisioning"])
    ],
    dependencies: [
        .package(url: "https://github.com/unit-finance/unit-ios-sdk.git", branch: "main")
    ],
    targets: [
        .target(
            name: "UnitPushProvisioning",
            dependencies: [
                .product(name: "UnitCommon", package: "unit-ios-sdk")
            ],
            path: "Sources/UnitPushProvisioning"
        )
    ],
    swiftLanguageModes: [.v5]
)