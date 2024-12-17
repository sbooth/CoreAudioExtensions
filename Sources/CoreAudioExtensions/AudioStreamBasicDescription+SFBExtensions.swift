//
// Copyright © 2006-2024 Stephen F. Booth <me@sbooth.org>
// Part of https://github.com/sbooth/CoreAudioExtensions
// MIT license
//

import Foundation
import CoreAudioTypes

extension AudioStreamBasicDescription {

	// MARK: Common Formats

	/// Common PCM formats
	public enum CommonPCMFormat {
		/// Native endian 32-bit floating point samples
		/// - remark: This corresponds to `Float`
		case float32
		/// Native endian 64-bit floating point samples
		/// - remark: This corresponds to `Double`
		case float64
		/// Native endian signed 16-bit integer samples
		/// - remark: This corresponds to `Int16`
		case int16
		/// Native endian signed 32-bit integer samples
		/// - remark: This corresponds to `Int32`
		case int32
	}

	/// Initializes an `AudioStreamBasicDescription` for a common PCM variant
	/// - parameter format: The desired common PCM variant
	/// - parameter sampleRate: The audio sample rate
	/// - parameter channelsPerFrame: The number of audio channels
	/// - parameter isInterleaved: Whether the audio samples are interleaved
	public init(commonFormat format: CommonPCMFormat, sampleRate: Float64, channelsPerFrame: UInt32, isInterleaved interleaved: Bool) {
		switch format {
		case .float32:
			self = makeASBDForLinearPCM(sampleRate: sampleRate, channelsPerFrame: channelsPerFrame, validBitsPerChannel: 32, totalBitsPerChannel: 32, isFloat: true, isBigEndian: kAudioFormatFlagIsBigEndian == kAudioFormatFlagsNativeEndian, isNonInterleaved: !interleaved)
		case .float64:
			self = makeASBDForLinearPCM(sampleRate: sampleRate, channelsPerFrame: channelsPerFrame, validBitsPerChannel: 64, totalBitsPerChannel: 64, isFloat: true, isBigEndian: kAudioFormatFlagIsBigEndian == kAudioFormatFlagsNativeEndian, isNonInterleaved: !interleaved)
		case .int16:
			self = makeASBDForLinearPCM(sampleRate: sampleRate, channelsPerFrame: channelsPerFrame, validBitsPerChannel: 16, totalBitsPerChannel: 16, isFloat: false, isBigEndian: kAudioFormatFlagIsBigEndian == kAudioFormatFlagsNativeEndian, isNonInterleaved: !interleaved)
		case .int32:
			self = makeASBDForLinearPCM(sampleRate: sampleRate, channelsPerFrame: channelsPerFrame, validBitsPerChannel: 32, totalBitsPerChannel: 32, isFloat: false, isBigEndian: kAudioFormatFlagIsBigEndian == kAudioFormatFlagsNativeEndian, isNonInterleaved: !interleaved)
		}
	}

	/// Returns the common PCM format described by `self` or `nil` if none
	public var commonFormat: CommonPCMFormat? {
		guard isPCM, isNativeEndian else {
			return nil
		}

		if isSignedInteger {
			guard isPacked else {
				return nil
			}

			if mBitsPerChannel == 16 {
				return .int16
			} else if mBitsPerChannel == 32 {
				return .int32
			}
		} else if isFloat {
			if mBitsPerChannel == 32 {
				return .float32
			} else if mBitsPerChannel == 64 {
				return .float64
			}
		}

		return nil
	}

	// MARK: Format Information

	/// Returns `true` if `kAudioFormatFlagIsNonInterleaved` is set
	public var isNonInterleaved: Bool {
		mFormatFlags & kAudioFormatFlagIsNonInterleaved == kAudioFormatFlagIsNonInterleaved
	}

	/// Returns `true` if `kAudioFormatFlagIsNonInterleaved` is clear
	public var isInterleaved: Bool {
		mFormatFlags & kAudioFormatFlagIsNonInterleaved == 0
	}

	/// Returns the number of interleaved channels
	public var interleavedChannelCount: UInt32 {
		isInterleaved ? mChannelsPerFrame : 1
	}

	/// Returns the number of channel streams
	public var channelStreamCount: UInt32 {
		isInterleaved ? 1 : mChannelsPerFrame
	}

	/// Returns the number of channels
	public var channelCount: UInt32 {
		mChannelsPerFrame
	}

	/// Returns `true` if `mFormatID == kAudioFormatLinearPCM`
	public var isPCM: Bool {
		mFormatID == kAudioFormatLinearPCM
	}

	/// Returns `true` if `kAudioFormatFlagIsBigEndian` is set
	public var isBigEndian: Bool {
		mFormatFlags & kAudioFormatFlagIsBigEndian == kAudioFormatFlagIsBigEndian
	}

	/// Returns `true` if `kAudioFormatFlagIsBigEndian` is clear
	public var isLittleEndian: Bool {
		mFormatFlags & kAudioFormatFlagIsBigEndian == 0
	}

	/// Returns `true` if this format is native-endian
	public var isNativeEndian: Bool {
		mFormatFlags & kAudioFormatFlagIsBigEndian == kAudioFormatFlagsNativeEndian
	}

	/// Returns `true` if this format is linear PCM and `kAudioFormatFlagIsFloat` is set
	public var isFloat: Bool {
		isPCM && mFormatFlags & kAudioFormatFlagIsFloat == kAudioFormatFlagIsFloat
	}

	/// Returns `true` if this format is linear PCM and `kAudioFormatFlagIsFloat` is clear
	public var isInteger: Bool {
		isPCM && mFormatFlags & kAudioFormatFlagIsFloat == 0
	}

	/// Returns `true` if this format is linear PCM and `kAudioFormatFlagIsSignedInteger` is set
	public var isSignedInteger: Bool {
		isPCM && mFormatFlags & kAudioFormatFlagIsSignedInteger == kAudioFormatFlagIsSignedInteger
	}

	/// Returns `true` if `kAudioFormatFlagIsPacked` is set
	public var isPacked: Bool {
		mFormatFlags & kAudioFormatFlagIsPacked == kAudioFormatFlagIsPacked
	}

	/// Returns `true` if this format is implicitly packed
	///
	/// A format is implicitly packed when `((mBitsPerChannel / 8) * mChannelsPerFrame) == mBytesPerFrame`
	public var isImplicitlyPacked: Bool {
		((mBitsPerChannel / 8) * mChannelsPerFrame) == mBytesPerFrame
	}

	/// Returns `true` if `kAudioFormatFlagIsAlignedHigh` is set
	public var isAlignedHigh: Bool {
		mFormatFlags & kAudioFormatFlagIsAlignedHigh == kAudioFormatFlagIsAlignedHigh
	}

	/// Returns the number of fractional bits
	public var fractionalBits: Int {
		Int((mFormatFlags & kLinearPCMFormatFlagsSampleFractionMask) >> kLinearPCMFormatFlagsSampleFractionShift)
	}

	/// Returns `true` if this format is integer fixed-point linear PCM
	public var isFixedPoint: Bool {
		isInteger && fractionalBits > 0
	}

	/// Returns `true` if `kAudioFormatFlagIsNonMixable` is set
	/// - note: This flag is only used when interacting with HAL stream formats
	public var isNonMixable: Bool {
		mFormatFlags & kAudioFormatFlagIsNonMixable == kAudioFormatFlagIsNonMixable
	}

	/// Returns `true` if this format is linear PCM and `kAudioFormatFlagIsNonMixable` is clear
	/// - note: This flag is only used when interacting with HAL stream formats
	public var isMixable: Bool {
		isPCM && mFormatFlags & kAudioFormatFlagIsNonMixable == 0
	}

	/// Returns the sample word size in bytes
	public var sampleWordSize: Int {
		let interleavedChannelCount = self.interleavedChannelCount
//		assert(interleavedChannelCount != 0, "self.interleavedChannelCount == 0 in sampleWordSize")
		if(interleavedChannelCount == 0) {
			return 0
		}
		return Int(mBytesPerFrame / interleavedChannelCount)
	}

	/// Returns the byte size of `frameCount` audio frames
	/// - note: This is equivalent to `frameCount * mBytesPerFrame`
	public func byteSize(forFrameCount frameCount: Int) -> Int {
		frameCount * Int(mBytesPerFrame)
	}

	/// Returns the frame count of `byteSize` bytes
	/// - note: This is equivalent to `byteSize / mBytesPerFrame`
	public func frameCount(forByteSize byteSize: Int) -> Int {
//		assert(mBytesPerFrame != 0, "mBytesPerFrame == 0 in frameCount(forByteSize:)")
		if(mBytesPerFrame == 0) {
			return 0
		}
		return byteSize / Int(mBytesPerFrame)
	}

	/// Returns the duration of a single packet in seconds
	public var packetDuration: TimeInterval {
		(1 / mSampleRate) * Double(mFramesPerPacket)
	}

	// MARK: Format Transformation

	/// Returns the equivalent non-interleaved format of `self`
	/// - note: This returns `nil` for non-PCM formats
	public func nonInterleavedEquivalent() -> AudioStreamBasicDescription? {
		guard isPCM else {
			return nil
		}

		var format = self
		if isInterleaved {
			format.mFormatFlags |= kAudioFormatFlagIsNonInterleaved
			format.mBytesPerPacket /= mChannelsPerFrame
			format.mBytesPerFrame /= mChannelsPerFrame
		}
		return format
	}

	/// Returns the equivalent interleaved format of `self`
	/// - note: This returns `nil` for non-PCM formats
	public func interleavedEquivalent() -> AudioStreamBasicDescription? {
		guard isPCM else {
			return nil
		}

		var format = self
		if !isInterleaved {
			format.mFormatFlags &= ~kAudioFormatFlagIsNonInterleaved;
			format.mBytesPerPacket *= mChannelsPerFrame;
			format.mBytesPerFrame *= mChannelsPerFrame;
		}
		return format
	}

	/// Returns the equivalent standard format of `self`
	/// - note: This returns `nil` for non-PCM formats
	public func standardEquivalent() -> AudioStreamBasicDescription? {
		guard isPCM else {
			return nil
		}
		return makeASBDForLinearPCM(sampleRate: mSampleRate, channelsPerFrame: mChannelsPerFrame, validBitsPerChannel: 32, totalBitsPerChannel: 32, isFloat: true, isBigEndian: kAudioFormatFlagIsBigEndian == kAudioFormatFlagsNativeEndian, isNonInterleaved: true)
	}

	/// Resets `self` to the default state
	public mutating func reset() {
		memset(&self, 0, MemoryLayout<AudioStreamBasicDescription>.stride);
	}

	/// Returns true if `self` is equal to `other`
	public func isEqualTo(_ other: AudioStreamBasicDescription) -> Bool {
		mFormatID == other.mFormatID &&
		mFormatFlags == other.mFormatFlags &&
		mSampleRate == other.mSampleRate &&
		mChannelsPerFrame == other.mChannelsPerFrame &&
		mBitsPerChannel == other.mBitsPerChannel &&
		mBytesPerPacket == other.mBytesPerPacket &&
		mFramesPerPacket == other.mFramesPerPacket &&
		mBytesPerFrame == other.mBytesPerFrame
	}

	/// Returns true if `self` is congruent to `other`
	public func isCongruentTo(_ other: AudioStreamBasicDescription) -> Bool {
		(mFormatID == other.mFormatID || mFormatID == 0 || other.mFormatID == 0) &&
		(mFormatFlags == other.mFormatFlags || mFormatFlags == 0 || other.mFormatFlags == 0) &&
		(mSampleRate == other.mSampleRate || mSampleRate == 0 || other.mSampleRate == 0) &&
		(mChannelsPerFrame == other.mChannelsPerFrame || mChannelsPerFrame == 0 || other.mChannelsPerFrame == 0) &&
		(mBitsPerChannel == other.mBitsPerChannel || mBitsPerChannel == 0 || other.mBitsPerChannel == 0) &&
		(mBytesPerPacket == other.mBytesPerPacket || mBytesPerPacket == 0 || other.mBytesPerPacket == 0) &&
		(mFramesPerPacket == other.mFramesPerPacket || mFramesPerPacket == 0 || other.mFramesPerPacket == 0) &&
		(mBytesPerFrame == other.mBytesPerFrame || mBytesPerFrame == 0 || other.mBytesPerFrame == 0)
	}

	/// Returns a description of `self`
	public var streamDescription: String {
		// General description
		var result = String(format: "%u ch, %.2f Hz, '%@' (0x%0.8x) ", mChannelsPerFrame, mSampleRate, mFormatID.fourCC, mFormatFlags)

		if isPCM {
			// Bit depth
			let fractionalBits = (mFormatFlags & kLinearPCMFormatFlagsSampleFractionMask) >> kLinearPCMFormatFlagsSampleFractionShift
			if fractionalBits > 0 {
				result.append(String(format: "%d.%d-bit", mBitsPerChannel - fractionalBits, fractionalBits))
			} else {
				result.append(String(format: "%d-bit", mBitsPerChannel))
			}

			// Endianness
			let sampleSize = mBytesPerFrame > 0 && interleavedChannelCount > 0 ? mBytesPerFrame / interleavedChannelCount : 0
			if sampleSize > 1 {
				result.append(isBigEndian ? " big-endian" : " little-endian")
			}

			// Sign
			if isInteger {
				result.append(isSignedInteger ? " signed" : " unsigned")
			}

			// Integer or floating
			result.append(isInteger ? " integer" : " float")

			// Packedness
			if sampleSize > 0 && ((sampleSize << 3) != mBitsPerChannel) {
				result.append(String(format: isPacked ? ", packed in %d bytes" : ", unpacked in %d bytes", sampleSize))
			}
			// Alignment
			if (sampleSize > 0 && ((sampleSize << 3) != mBitsPerChannel)) || ((mBitsPerChannel & 7) != 0) {
				result.append(isAlignedHigh ? " high-aligned" : " low-aligned")
			}

			if !isInterleaved {
				result.append(", deinterleaved")
			}
		} else if mFormatID == kAudioFormatAppleLossless {
			var sourceBitDepth: UInt32 = 0;
			switch mFormatFlags {
			case kAppleLosslessFormatFlag_16BitSourceData:
				sourceBitDepth = 16
			case kAppleLosslessFormatFlag_20BitSourceData:
				sourceBitDepth = 20
			case kAppleLosslessFormatFlag_24BitSourceData:
				sourceBitDepth = 24
			case kAppleLosslessFormatFlag_32BitSourceData:
				sourceBitDepth = 32
			default:
				break
			}

			if sourceBitDepth != 0 {
				result.append(String(format: "from %d-bit source, ", sourceBitDepth))
			} else {
				result.append("from UNKNOWN source bit depth, ")
			}

			result.append(String(format: " %d frames/packet", mFramesPerPacket))
		} else {
			result.append(String(format: "%u bits/channel, %u bytes/packet, %u frames/packet, %u bytes/frame", mBitsPerChannel, mBytesPerPacket, mFramesPerPacket, mBytesPerFrame))
		}

		return result
	}
}

#if false
// Disabled to avoid warning about conformance of imported type to imported protocol
extension AudioStreamBasicDescription: /*@retroactive*/ Equatable {
	public static func == (lhs: AudioStreamBasicDescription, rhs: AudioStreamBasicDescription) -> Bool {
		lhs.isEqualTo(rhs)
	}
}
#endif

infix operator ~==: ComparisonPrecedence
extension AudioStreamBasicDescription {
	/// Returns `true` if `lhs` and `rhs` are congruent.
	public static func ~== (lhs: AudioStreamBasicDescription, rhs: AudioStreamBasicDescription) -> Bool {
		lhs.isCongruentTo(rhs)
	}
}

private func makeLinearPCMFlags(validBitsPerChannel: UInt32, totalBitsPerChannel: UInt32, isFloat float: Bool, isBigEndian bigEndian: Bool, isNonInterleaved nonInterleaved: Bool) -> AudioFormatFlags
{
	return (float ? kAudioFormatFlagIsFloat : kAudioFormatFlagIsSignedInteger) | (bigEndian ? kAudioFormatFlagIsBigEndian : 0) | ((validBitsPerChannel == totalBitsPerChannel) ? kAudioFormatFlagIsPacked : kAudioFormatFlagIsAlignedHigh) | (nonInterleaved ? kAudioFormatFlagIsNonInterleaved : 0);
}

private func makeASBDForLinearPCM(sampleRate: Float64, channelsPerFrame: UInt32, validBitsPerChannel: UInt32, totalBitsPerChannel: UInt32, isFloat float: Bool, isBigEndian bigEndian: Bool, isNonInterleaved nonInterleaved: Bool) -> AudioStreamBasicDescription
{
	var asbd = AudioStreamBasicDescription()

	asbd.mFormatID = kAudioFormatLinearPCM;
	asbd.mFormatFlags = makeLinearPCMFlags(validBitsPerChannel: validBitsPerChannel, totalBitsPerChannel: totalBitsPerChannel, isFloat: float, isBigEndian: bigEndian, isNonInterleaved: nonInterleaved);

	asbd.mSampleRate = sampleRate;
	asbd.mChannelsPerFrame = channelsPerFrame;
	asbd.mBitsPerChannel = validBitsPerChannel;

	asbd.mBytesPerPacket = (nonInterleaved ? 1 : channelsPerFrame) * (totalBitsPerChannel / 8);
	asbd.mFramesPerPacket = 1;
	asbd.mBytesPerFrame = (nonInterleaved ? 1 : channelsPerFrame) * (totalBitsPerChannel / 8);

	return asbd
}

#if false
// Disabled to avoid warning about conformance of imported type to imported protocol
extension AudioStreamBasicDescription: /*@retroactive*/ CustomDebugStringConvertible {
	// A textual representation of this instance, suitable for debugging.
	public var debugDescription: String {
		streamDescription
	}
}
#endif

extension UInt32 {
	/// Returns the value of `self` as a four character code string.
	var fourCC: String {
		String(cString: [
			UInt8(self >> 24),
			UInt8((self >> 16) & 0xff),
			UInt8((self >> 8) & 0xff),
			UInt8(self & 0xff),
			0
		])
	}
}
