//
// Copyright © 2006-2024 Stephen F. Booth <me@sbooth.org>
// Part of https://github.com/sbooth/CoreAudioExtensions
// MIT license
//

import Foundation
import CoreAudioTypes
import AudioToolbox

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
		guard mFramesPerPacket == 1, mBytesPerFrame == mBytesPerPacket, mChannelsPerFrame > 0 else {
			return nil
		}

		guard isPCM, isNativeEndian, isImplicitlyPacked else {
			return nil
		}

		if isSignedInteger {
			guard !isFixedPoint else {
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
	/// A format is implicitly packed when `((mBitsPerChannel / 8) * interleavedChannelCount) == mBytesPerFrame`
	public var isImplicitlyPacked: Bool {
		((mBitsPerChannel / 8) * interleavedChannelCount) == mBytesPerFrame
	}

	/// Returns `true` if this format is linear PCM and the sample bits do not occupy the entire channel
	public var isUnpackedPCM: Bool {
		isPCM && (sampleWordSize << 3) != mBitsPerChannel
	}

	/// Returns `true` if `kAudioFormatFlagIsAlignedHigh` is set
	public var isAlignedHigh: Bool {
		mFormatFlags & kAudioFormatFlagIsAlignedHigh == kAudioFormatFlagIsAlignedHigh
	}

	/// Returns `true` if this format is unpacked linear PCM or if `mBitsPerChannel` is not a multiple of 8
	public var isUnaligned: Bool {
		isUnpackedPCM || (mBitsPerChannel & 7) != 0
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
//		assert(mBytesPerFrame % interleavedChannelCount == 0, "mBytesPerFrame % interleavedChannelCount != 0 in sampleWordSize")
		if(interleavedChannelCount == 0 || mBytesPerFrame % interleavedChannelCount != 0) {
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

	/// Returns the name of `self`
	///
	/// This is the value of `kAudioFormatProperty_FormatName`
	public var formatName: String
	{
		var value: Unmanaged<CFString>?
		var dataSize: UInt32 = UInt32(MemoryLayout<CFString>.stride)
		let result = withUnsafePointer(to: self) {
			AudioFormatGetProperty(kAudioFormatProperty_FormatName, UInt32(MemoryLayout<Self>.stride), $0, &dataSize, &value)
		}
		if result == noErr, let name = value?.takeUnretainedValue() {
			return name as String
		} else {
			return ""
		}
	}

	/// Returns a description of `self`
	public var formatDescription: String {
		var result: String

		// Channels and sample rate
		if(rint(mSampleRate) == mSampleRate) {
			result = "\(mChannelsPerFrame) ch @ \(Int64(mSampleRate)) Hz, "
		} else {
			result = String(format: "\(mChannelsPerFrame) ch @ %.2f Hz, ", mSampleRate)
		}

		// Shorter description for common formats
		if let commonFormat {
			switch commonFormat {
			case .int16:
				result.append("Int16, ")
			case .int32:
				result.append("Int32, ")
			case .float32:
				result.append("Float32, ")
			case .float64:
				result.append("Float64, ")
			}

			if isNonInterleaved {
				result.append("deinterleaved")
			} else {
				result.append("interleaved")
			}

			return result
		}

		if isPCM {
			// Bit depth
			let fractionalBits = self.fractionalBits
			if fractionalBits > 0 {
				result.append(String(format: "%d.%d-bit", Int(mBitsPerChannel) - fractionalBits, fractionalBits))
			} else {
				result.append("\(mBitsPerChannel)-bit")
			}

			// Endianness
			let sampleWordSize = self.sampleWordSize
			if sampleWordSize > 1 {
				result.append(isBigEndian ? " big-endian" : " little-endian")
			}

			// Sign
			let isInteger = self.isInteger
			if isInteger {
				result.append(isSignedInteger ? " signed" : " unsigned")
			}

			// Integer or floating
			result.append(isInteger ? " integer" : " float")

			// Packedness and alignment
			if sampleWordSize > 0 {
				if isImplicitlyPacked {
					result.append(", packed")
				} else if isUnaligned {
					result.append(isAlignedHigh ? ", high-aligned" : ", low-aligned")
				}

				result.append(" in \(sampleWordSize) bytes")
			}

			if isNonInterleaved {
				result.append(", deinterleaved")
			}
		} else if mFormatID == kAudioFormatAppleLossless || mFormatID == kAudioFormatFLAC {
			result.append("\(formatIDName(mFormatID)), ")

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
				result.append("from \(sourceBitDepth))-bit source, ")
			} else {
				result.append("from UNKNOWN source bit depth, ")
			}

			result.append("\(mFramesPerPacket) frames/packet")
		} else {
			result.append("\(formatIDName(mFormatID))")

			if mFormatFlags != 0 {
				result.append(String(format: " (0x%.08x)", mFormatFlags))
			}

			result.append(", \(mBitsPerChannel) bits/channel, \(mBytesPerPacket) bytes/packet, \(mFramesPerPacket) frames/packet, \(mBytesPerFrame) bytes/frame")
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

/// Returns a descriptive format name for `formatID`
private func formatIDName(_ formatID: AudioFormatID) -> String {
	switch formatID {
	case kAudioFormatLinearPCM: 			return "Linear PCM"
	case kAudioFormatAC3: 					return "AC-3"
	case kAudioFormat60958AC3: 				return "AC-3 over IEC 60958"
	case kAudioFormatAppleIMA4: 			return "IMA 4:1 ADPCM"
	case kAudioFormatMPEG4AAC: 				return "MPEG-4 Low Complexity AAC"
	case kAudioFormatMPEG4CELP: 			return "MPEG-4 CELP"
	case kAudioFormatMPEG4HVXC: 			return "MPEG-4 HVXC"
	case kAudioFormatMPEG4TwinVQ: 			return "MPEG-4 TwinVQ"
	case kAudioFormatMACE3: 				return "MACE 3:1"
	case kAudioFormatMACE6: 				return "MACE 6:1"
	case kAudioFormatULaw: 					return "µ-law 2:1"
	case kAudioFormatALaw: 					return "A-law 2:1"
	case kAudioFormatQDesign: 				return "QDesign music"
	case kAudioFormatQDesign2: 				return "QDesign2 music"
	case kAudioFormatQUALCOMM :				return "QUALCOMM PureVoice"
	case kAudioFormatMPEGLayer1: 			return "MPEG-1/2 Layer I"
	case kAudioFormatMPEGLayer2: 			return "MPEG-1/2 Layer II"
	case kAudioFormatMPEGLayer3: 			return "MPEG-1/2 Layer III"
	case kAudioFormatTimeCode: 				return "Stream of IOAudioTimeStamps"
	case kAudioFormatMIDIStream: 			return "Stream of MIDIPacketLists"
	case kAudioFormatParameterValueStream: 	return "Float32 side-chain"
	case kAudioFormatAppleLossless: 		return "Apple Lossless"
	case kAudioFormatMPEG4AAC_HE: 			return "MPEG-4 High Efficiency AAC"
	case kAudioFormatMPEG4AAC_LD: 			return "MPEG-4 AAC Low Delay"
	case kAudioFormatMPEG4AAC_ELD: 			return "MPEG-4 AAC Enhanced Low Delay"
	case kAudioFormatMPEG4AAC_ELD_SBR: 		return "MPEG-4 AAC Enhanced Low Delay with SBR extension"
	case kAudioFormatMPEG4AAC_ELD_V2: 		return "MPEG-4 AAC Enhanced Low Delay Version 2"
	case kAudioFormatMPEG4AAC_HE_V2: 		return "MPEG-4 High Efficiency AAC Version 2"
	case kAudioFormatMPEG4AAC_Spatial: 		return "MPEG-4 Spatial Audio"
	case kAudioFormatMPEGD_USAC: 			return "MPEG-D Unified Speech and Audio Coding"
	case kAudioFormatAMR: 					return "AMR Narrow Band"
	case kAudioFormatAMR_WB: 				return "AMR Wide Band"
	case kAudioFormatAudible: 				return "Audible"
	case kAudioFormatiLBC: 					return "iLBC narrow band"
	case kAudioFormatDVIIntelIMA: 			return "DVI/Intel IMA ADPCM"
	case kAudioFormatMicrosoftGSM: 			return "Microsoft GSM 6.10"
	case kAudioFormatAES3: 					return "AES3-2003"
	case kAudioFormatEnhancedAC3: 			return "Enhanced AC-3"
	case kAudioFormatFLAC: 					return "Free Lossless Audio Codec"
	case kAudioFormatOpus: 					return "Opus"
	case kAudioFormatAPAC: 					return "Apple Positional Audio Codec"

	default:
		if formatID.isPrintable {
			return "'\(formatID.fourCC)'"
		} else {
			return String(format: "0x%.02x%.02x%.02x%.02x", UInt8(formatID >> 24), UInt8((formatID >> 16) & 0xff), UInt8((formatID >> 8) & 0xff), UInt8(formatID & 0xff))
		}
	}
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

private extension UInt32 {
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

	/// Returns `true` if `self` consists of four printable ASCII characters
	var isPrintable: Bool {
		func isPrint(_ c: UInt8) -> Bool {
			c > 0x1f && c < 0x7f
		}
		return isPrint(UInt8(self >> 24)) && isPrint(UInt8((self >> 16) & 0xff)) && isPrint(UInt8((self >> 8) & 0xff)) && isPrint(UInt8(self & 0xff))
	}
}
