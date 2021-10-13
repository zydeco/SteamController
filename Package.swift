// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let cxxSettings: [CXXSetting] = [
	.define("STEAMCONTROLLER_NO_PRIVATE_API", .when(platforms: [.macOS])),
	.define("STEAMCONTROLLER_NO_SWIZZLING")
]

let cSettings: [CSetting] = [
	.define("STEAMCONTROLLER_NO_PRIVATE_API", .when(platforms: [.macOS])),
	.define("STEAMCONTROLLER_NO_SWIZZLING")
]

let package = Package(
	name: "SteamController",
	platforms: [
		.iOS(.v10),
		.tvOS(.v10),
		.macOS(.v10_13)
	],
	products: [
		// Products define the executables and libraries produced by a package, and make them visible to other packages.
		.library(
			name: "SteamController",
			targets: ["SteamController"])
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(name: "SteamController",
				exclude: ["Supporting Files/Info-tvOS.plist", "Supporting Files/Info-iOS.plist"],
				publicHeadersPath: "include",
				cSettings: cSettings,
				cxxSettings: cxxSettings),
	]
)
