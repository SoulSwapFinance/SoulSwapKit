// swift-tools-version:5.5
import PackageDescription

let package = Package(
        name: "SoulSwapKit",
        platforms: [
          .iOS(.v13),
          .macOS(.v10_15)
        ],
        products: [
          .library(
                  name: "SoulSwapKit",
                  targets: ["SoulSwapKit"]
          ),
        ],
        dependencies: [
          .package(url: "https://github.com/attaswift/BigInt.git", .upToNextMajor(from: "5.3.0")),
          .package(url: "https://github.com/horizontalsystems/EvmKit.Swift.git", .upToNextMajor(from: "2.0.7")),
          .package(url: "https://github.com/horizontalsystems/Eip20Kit.Swift.git", .upToNextMajor(from: "2.0.0")),
          .package(url: "https://github.com/horizontalsystems/HsCryptoKit.Swift.git", .upToNextMajor(from: "1.2.1")),
          .package(url: "https://github.com/horizontalsystems/HsExtensions.Swift.git", .upToNextMajor(from: "1.0.6")),
        ],
        targets: [
          .target(
                  name: "SoulSwapKit",
                  dependencies: [
                    "BigInt",
                    .product(name: "EvmKit", package: "EvmKit.Swift"),
                    .product(name: "Eip20Kit", package: "Eip20Kit.Swift"),
                    .product(name: "HsCryptoKit", package: "HsCryptoKit.Swift"),
                    .product(name: "HsExtensions", package: "HsExtensions.Swift"),
                  ]
          )
        ]
)
