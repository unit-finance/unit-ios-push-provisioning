// swift-tools-version:5.9
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
        .package(url: "https://github.com/unit-finance/unit-ios-sdk.git", branch: "feat/expose-unitcommon-product")
    ],
    targets: [
        .target(
            name: "UnitPushProvisioning",
            dependencies: [
                .product(name: "UnitCommon", package: "unit-ios-sdk")
            ],
            path: "Sources/UnitPushProvisioning"
        )
    ]
)