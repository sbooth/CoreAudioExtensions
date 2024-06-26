import XCTest
import CoreAudio
@testable import CoreAudioExtensions

final class CoreAudioExtensionsTests: XCTestCase {
	func testAudioStreamBasicDescription() {
		let asbd = AudioStreamBasicDescription(commonFormat: .float32, sampleRate: 44100, channelsPerFrame: 2, isInterleaved: false)
		XCTAssertTrue(asbd.isFloat)
		XCTAssertTrue(!asbd.isInterleaved)
		XCTAssertTrue(asbd.isNonInterleaved)
		XCTAssertTrue(asbd.channelCount == 2)
		XCTAssertTrue(asbd.channelStreamCount == 2)
		XCTAssertTrue(asbd.packetDuration == 1/44100)
	}

	func testAudioValueRange() {
		let avr = AudioValueRange(mMinimum: 22050, mMaximum: 88200)
		XCTAssertTrue(avr.contains(44100))
		XCTAssertFalse(avr.contains(176400))
	}
}
