// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let dateParsing: Self = "DateParsing"
    static let unixEpoch: Self = "UnixEpochParsing"
}

extension Target.Dependency {
    static var dateParsing: Self { .target(name: .dateParsing) }
    static var unixEpoch: Self { .target(name: .unixEpoch) }
}

extension Target.Dependency {
    static var parsing: Self { .product(name: "Parsing", package: "swift-parsing") }
    static var rfc2822: Self { .product(name: "RFC_2822", package: "swift-rfc-2822") }
    static var rfc5322: Self { .product(name: "RFC_5322", package: "swift-rfc-5322") }
}

let package = Package(
    name: "swift-date-parsing",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(name: .dateParsing, targets: [.dateParsing]),
        .library(name: .unixEpoch, targets: [.unixEpoch])
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.14.1"),
        .package(url: "https://github.com/swift-web-standards/swift-rfc-2822.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-web-standards/swift-rfc-5322.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: .dateParsing,
            dependencies: [
                .rfc2822,
                .rfc5322,
                .parsing
            ]
        ),
        .testTarget(
            name: .dateParsing.tests,
            dependencies: [
                .dateParsing,
                .rfc2822,
                .rfc5322
            ]
        ),
        .target(
            name: .unixEpoch,
            dependencies: [
                .rfc2822,
                .rfc5322,
                .parsing
            ]
        ),
        .testTarget(
            name: .unixEpoch.tests,
            dependencies: [
                .unixEpoch,
                .rfc2822,
                .rfc5322
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { self + " Tests" } }
