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
	targets: [
		.target(
			name: "CoreAudioExtensions"),
		.testTarget(
			name: "CoreAudioExtensionsTests",
			dependencies: [
				"CoreAudioExtensions",
			]),
	]
)
