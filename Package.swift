// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CoreAudioExtensions",
	products: [
		.library(
			name: "CoreAudioExtensions",
			targets: [
				"CoreAudioExtensions",
			]),
	],
	dependencies: [
		.package(url: "https://github.com/sbooth/FourCC", from: "0.1.0"),
	],
	targets: [
		.target(
			name: "CoreAudioExtensions",
			dependencies: [
				.product(name: "FourCC", package: "FourCC"),
			]),
		.testTarget(
			name: "CoreAudioExtensionsTests",
			dependencies: [
				"CoreAudioExtensions",
			]),
	]
)
