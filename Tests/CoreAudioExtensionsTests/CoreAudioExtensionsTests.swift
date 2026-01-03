//
// SPDX-FileCopyrightText: 2021 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/CXXCoreAudio
//

import XCTest
import CoreAudio
@testable import CoreAudioExtensions

final class CoreAudioExtensionsTests: XCTestCase {
	func testAudioStreamBasicDescription() {
		let asbd = AudioStreamBasicDescription(commonFormat: .float32, sampleRate: 44100, channelsPerFrame: 2, isInterleaved: false)
		XCTAssertTrue(asbd.isFloat)
		XCTAssertTrue(!asbd.isInteger)
		XCTAssertTrue(!asbd.isFixedPoint)
		XCTAssertTrue(!asbd.isInterleaved)
		XCTAssertTrue(asbd.isNonInterleaved)
		XCTAssertEqual(asbd.channelCount, 2)
		XCTAssertEqual(asbd.channelStreamCount, 2)
		XCTAssertEqual(asbd.packetDuration, 1/44100)
	}

	func testCommonFormat() {
		var asbd = AudioStreamBasicDescription(commonFormat: .float32, sampleRate: 44100, channelsPerFrame: 2, isInterleaved: false)
		XCTAssertEqual(asbd.commonFormat, .float32)

		asbd = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger|kAudioFormatFlagIsPacked|kAudioFormatFlagsNativeEndian, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
		print("\(asbd.formatDescription)")
		print("\(asbd.formatName)")
		XCTAssertEqual(asbd.commonFormat, .int16)

		asbd = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger|kAudioFormatFlagsNativeEndian, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
		print("\(asbd.formatDescription)")
		XCTAssertEqual(asbd.commonFormat, .int16)

		asbd = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger|kAudioFormatFlagsNativeEndian, mBytesPerPacket: 3, mFramesPerPacket: 1, mBytesPerFrame: 3, mChannelsPerFrame: 1, mBitsPerChannel: 24, mReserved: 0)
		print("\(asbd.formatDescription)")
		XCTAssertNil(asbd.commonFormat)

		asbd = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger|kAudioFormatFlagsNativeEndian, mBytesPerPacket: 8, mFramesPerPacket: 1, mBytesPerFrame: 8, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
		print("\(asbd.formatDescription)")
		XCTAssertNil(asbd.commonFormat)

		asbd = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger|kAudioFormatFlagsNativeEndian|kAudioFormatFlagIsAlignedHigh, mBytesPerPacket: 8, mFramesPerPacket: 1, mBytesPerFrame: 8, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
		print("\(asbd.formatDescription)")
		XCTAssertNil(asbd.commonFormat)

		asbd = AudioStreamBasicDescription(mSampleRate: 8000, mFormatID: kAudioFormatULaw, mFormatFlags: 0, mBytesPerPacket: 1, mFramesPerPacket: 1, mBytesPerFrame: 1, mChannelsPerFrame: 1, mBitsPerChannel: 8, mReserved: 0)
		print("\(asbd.formatDescription)")

		asbd = AudioStreamBasicDescription(mSampleRate: 8000, mFormatID: kAudioFormatULaw, mFormatFlags: kAudioFormatFlagIsBigEndian, mBytesPerPacket: 1, mFramesPerPacket: 1, mBytesPerFrame: 1, mChannelsPerFrame: 1, mBitsPerChannel: 8, mReserved: 0)
		print("\(asbd.formatDescription)")

		asbd = AudioStreamBasicDescription(mSampleRate: 8000, mFormatID: 0x11110020, mFormatFlags: kAudioFormatFlagIsBigEndian, mBytesPerPacket: 1, mFramesPerPacket: 1, mBytesPerFrame: 1, mChannelsPerFrame: 1, mBitsPerChannel: 8, mReserved: 0)
		print("\(asbd.formatDescription)")

		asbd = AudioStreamBasicDescription(mSampleRate: 8000, mFormatID: 0x20304050, mFormatFlags: kAudioFormatFlagIsBigEndian, mBytesPerPacket: 1, mFramesPerPacket: 1, mBytesPerFrame: 1, mChannelsPerFrame: 1, mBitsPerChannel: 8, mReserved: 0)
		print("\(asbd.formatDescription)")

	}

//	func testAudioChannelLayout() {
//		var acl = AudioChannelLayout(mChannelLayoutTag: kAudioChannelLayoutTag_Ogg_5_1, mChannelBitmap: AudioChannelBitmap(rawValue: 0), mNumberChannelDescriptions: 0, mChannelDescriptions: AudioChannelDescription())
//		print("\(acl.layoutName)")
//	}

	func testAudioValueRange() {
		let avr = AudioValueRange(mMinimum: 22050, mMaximum: 88200)
		XCTAssertTrue(avr.contains(44100))
		XCTAssertFalse(avr.contains(176400))
	}
}
