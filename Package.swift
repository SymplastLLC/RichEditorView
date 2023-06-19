// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RichEditorView",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RichEditorView",
            targets: ["RichEditorView"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kvyatkovskys/KVKLogger", .upToNextMajor(from: "0.2.8"))
    ],
    targets: [
        .target(
            name: "RichEditorView",
            dependencies: ["KVKLogger"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "RichEditorViewTests",
            dependencies: ["RichEditorView"],
            resources: [.process("Resources")]
        ),
    ]
)
