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
		XCTAssertEqual(asbd.commonFormat, .int16)
		asbd = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger|kAudioFormatFlagsNativeEndian, mBytesPerPacket: 4, mFramesPerPacket: 1, mBytesPerFrame: 4, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
		XCTAssertEqual(asbd.commonFormat, .int16)
		asbd = AudioStreamBasicDescription(mSampleRate: 44100, mFormatID: kAudioFormatLinearPCM, mFormatFlags: kAudioFormatFlagIsSignedInteger|kAudioFormatFlagsNativeEndian, mBytesPerPacket: 8, mFramesPerPacket: 1, mBytesPerFrame: 8, mChannelsPerFrame: 2, mBitsPerChannel: 16, mReserved: 0)
		XCTAssertNil(asbd.commonFormat)
	}

	func testAudioValueRange() {
		let avr = AudioValueRange(mMinimum: 22050, mMaximum: 88200)
		XCTAssertTrue(avr.contains(44100))
		XCTAssertFalse(avr.contains(176400))
	}
}
