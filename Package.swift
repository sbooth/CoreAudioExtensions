// swift-tools-version: 5.6
//
// SPDX-FileCopyrightText: 2025 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/CoreAudioExtensions
//

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
