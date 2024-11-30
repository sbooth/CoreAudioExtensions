//
// Copyright © 2006-2024 Stephen F. Booth <me@sbooth.org>
// Part of https://github.com/sbooth/CoreAudioExtensions
// MIT license
//

import Foundation
import CoreAudioTypes

extension AudioChannelLayout {
	/// Returns the number of channels in this channel layout
	public var channelCount: UInt32 {
		if mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelDescriptions {
			return mNumberChannelDescriptions
		} else if mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelBitmap {
			return UInt32(mChannelBitmap.rawValue.nonzeroBitCount)
		} else {
			return AudioChannelLayoutTag_GetNumberOfChannels(mChannelLayoutTag)
		}
	}

	/// Returns a description of `self`
	public var layoutDescription: String {
		if mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelDescriptions {
			let channelCount = mNumberChannelDescriptions
			let channelDescriptions = withUnsafeChannelDescriptions({ $0.map({ $0.channelDescription }).joined(separator: ", ") })
			return "\(channelCount) ch, [\(channelDescriptions)]"
		} else if mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelBitmap {
			let channelCount = mChannelBitmap.rawValue.nonzeroBitCount
			return "\(channelCount) ch, bitmap 0x\(String(mChannelBitmap.rawValue, radix: 16)) [\(mChannelBitmap.bitmapDescription)]"
		} else {
			let channelCount = AudioChannelLayoutTag_GetNumberOfChannels(mChannelLayoutTag)
			return "\(channelCount) ch, tag 0x\(String(mChannelLayoutTag, radix: 16)) \"\(mChannelLayoutTag.channelLayoutTagName)\""
		}
	}

	/// Performs a closure with this channel layout's channel descriptions
	/// - precondition: `mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelDescriptions`
	/// - parameter body: A closure
	/// - returns: Any value returned by `body`
	/// - throws: Any error thrown by `body`
	public func withUnsafeChannelDescriptions<T>(_ body: (UnsafeBufferPointer<AudioChannelDescription>) throws -> T) rethrows -> T {
		precondition(mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelDescriptions, "mChannelDescriptions is not valid unless mChannelLayoutTag == kAudioChannelLayoutTag_UseChannelDescriptions")
		return try withUnsafePointer(to: mChannelDescriptions) { up in
			try body(UnsafeBufferPointer(start: up, count: Int(mNumberChannelDescriptions)))
		}
	}
}

extension AudioChannelDescription {
	/// Returns a description of `self`
	public var channelDescription: String {
		if mChannelLabel == kAudioChannelLabel_UseCoordinates {
			return "\(mChannelFlags.channelFlagsDescription): (\(mCoordinates.0), \(mCoordinates.1), \(mCoordinates.2))"
		} else {
			return mChannelLabel.channelLabelName
		}
	}

	/// Returns true if `self` is equal to `other`
	public func isEqualTo(_ other: AudioChannelDescription) -> Bool {
		if mChannelLabel == kAudioChannelLabel_UseCoordinates {
			return other.mChannelLabel == kAudioChannelLabel_UseCoordinates && mChannelFlags == other.mChannelFlags && mCoordinates == other.mCoordinates
		} else {
			return mChannelLabel == other.mChannelLabel
		}
	}
}

#if false
// Disabled to avoid warning about conformance of imported type to imported protocol
extension AudioChannelDescription: Equatable {
	public static func == (lhs: AudioChannelDescription, rhs: AudioChannelDescription) -> Bool {
		lhs.isEqualTo(rhs)
	}
}
#endif

extension AudioChannelLayoutTag {
	/// Returns the name of the `AudioChannelLayoutTag`value of `self`
	public var channelLayoutTagName: String {
		switch self {
		case kAudioChannelLayoutTag_UseChannelDescriptions:
			return "Use Channel Descriptions";
		case kAudioChannelLayoutTag_UseChannelBitmap:
			return "Use Channel Bitmap";
		case kAudioChannelLayoutTag_Mono:
			return "Mono"
		case kAudioChannelLayoutTag_Stereo:
			return "Stereo"
		case kAudioChannelLayoutTag_StereoHeadphones:
			return "Stereo Headphones"
		case kAudioChannelLayoutTag_MatrixStereo:
			return "Matrix Stereo"
		case kAudioChannelLayoutTag_MidSide:
			return "Mid-Side"
		case kAudioChannelLayoutTag_XY:
			return "XY"
		case kAudioChannelLayoutTag_Binaural:
			return "Binaural"
		case kAudioChannelLayoutTag_Ambisonic_B_Format:
			return "Ambisonic B-format"
		case kAudioChannelLayoutTag_Quadraphonic:
			return "Quadraphonic"
		case kAudioChannelLayoutTag_Pentagonal:
			return "Pentagonal"
		case kAudioChannelLayoutTag_Hexagonal:
			return "Hexagonal"
		case kAudioChannelLayoutTag_Octagonal:
			return "Octagonal"
		case kAudioChannelLayoutTag_Cube:
			return "Cube"
		case kAudioChannelLayoutTag_MPEG_3_0_A:
			return "MPEG 3.0 A"
		case kAudioChannelLayoutTag_MPEG_3_0_B:
			return "MPEG 3.0 B"
		case kAudioChannelLayoutTag_MPEG_4_0_A:
			return "MPEG 4.0 A"
		case kAudioChannelLayoutTag_MPEG_4_0_B:
			return "MPEG 4.0 B"
		case kAudioChannelLayoutTag_MPEG_5_0_A:
			return "MPEG 5.0 A"
		case kAudioChannelLayoutTag_MPEG_5_0_B:
			return "MPEG 5.0 B"
		case kAudioChannelLayoutTag_MPEG_5_0_C:
			return "MPEG 5.0 C"
		case kAudioChannelLayoutTag_MPEG_5_0_D:
			return "MPEG 5.0 D"
		case kAudioChannelLayoutTag_MPEG_5_1_A:
			return "MPEG 5.1 A"
		case kAudioChannelLayoutTag_MPEG_5_1_B:
			return "MPEG 5.1 B"
		case kAudioChannelLayoutTag_MPEG_5_1_C:
			return "MPEG 5.1 C"
		case kAudioChannelLayoutTag_MPEG_5_1_D:
			return "MPEG 5.1 D"
		case kAudioChannelLayoutTag_MPEG_6_1_A:
			return "MPEG 6.1 A"
		case kAudioChannelLayoutTag_MPEG_7_1_A:
			return "MPEG 7.1 A"
		case kAudioChannelLayoutTag_MPEG_7_1_B:
			return "MPEG 7.1 B"
		case kAudioChannelLayoutTag_MPEG_7_1_C:
			return "MPEG 7.1 C"
		case kAudioChannelLayoutTag_Emagic_Default_7_1:
			return "Emagic Default 7.1"
		case kAudioChannelLayoutTag_SMPTE_DTV:
			return "SMPTE DTV"
		case kAudioChannelLayoutTag_ITU_2_1:
			return "ITU 2.1"
		case kAudioChannelLayoutTag_ITU_2_2:
			return "ITU 2.2"
		case kAudioChannelLayoutTag_DVD_4:
			return "DVD 4"
		case kAudioChannelLayoutTag_DVD_5:
			return "DVD 5"
		case kAudioChannelLayoutTag_DVD_6:
			return "DVD 6"
		case kAudioChannelLayoutTag_DVD_10:
			return "DVD 10"
		case kAudioChannelLayoutTag_DVD_11:
			return "DVD 11"
		case kAudioChannelLayoutTag_DVD_18:
			return "DVD 18"
		case kAudioChannelLayoutTag_AudioUnit_6_0:
			return "AudioUnit 6.0"
		case kAudioChannelLayoutTag_AudioUnit_7_0:
			return "AudioUnit 7.0"
		case kAudioChannelLayoutTag_AudioUnit_7_0_Front:
			return "AudioUnit 7.0 Front"
		case kAudioChannelLayoutTag_AAC_6_0:
			return "AAC 6.0"
		case kAudioChannelLayoutTag_AAC_6_1:
			return "AAC 6.1"
		case kAudioChannelLayoutTag_AAC_7_0:
			return "AAC 7.0"
		case kAudioChannelLayoutTag_AAC_7_1_B:
			return "AAC 7.1 B"
		case kAudioChannelLayoutTag_AAC_7_1_C:
			return "AAC 7.1 C"
		case kAudioChannelLayoutTag_AAC_Octagonal:
			return "AAC Octagonal"
		case kAudioChannelLayoutTag_TMH_10_2_std:
			return "TMH 10.2 standard"
		case kAudioChannelLayoutTag_TMH_10_2_full:
			return "TMH 10.2 full"
		case kAudioChannelLayoutTag_AC3_1_0_1:
			return "AC3 1.0.1"
		case kAudioChannelLayoutTag_AC3_3_0:
			return "AC3 3.0"
		case kAudioChannelLayoutTag_AC3_3_1:
			return "AC3 3.1"
		case kAudioChannelLayoutTag_AC3_3_0_1:
			return "AC3 3.0.1"
		case kAudioChannelLayoutTag_AC3_2_1_1:
			return "AC3 2.1.1"
		case kAudioChannelLayoutTag_AC3_3_1_1:
			return "AC3 3.1.1"
		case kAudioChannelLayoutTag_EAC_6_0_A:
			return "EAC 6.0 A"
		case kAudioChannelLayoutTag_EAC_7_0_A:
			return "EAC 7.0 A"
		case kAudioChannelLayoutTag_EAC3_6_1_A:
			return "EAC3 6.1 A"
		case kAudioChannelLayoutTag_EAC3_6_1_B:
			return "EAC3 6.1 B"
		case kAudioChannelLayoutTag_EAC3_6_1_C:
			return "EAC3 6.1 C"
		case kAudioChannelLayoutTag_EAC3_7_1_A:
			return "EAC3 7.1 A"
		case kAudioChannelLayoutTag_EAC3_7_1_B:
			return "EAC3 7.1 B"
		case kAudioChannelLayoutTag_EAC3_7_1_C:
			return "EAC3 7.1 C"
		case kAudioChannelLayoutTag_EAC3_7_1_D:
			return "EAC3 7.1 D"
		case kAudioChannelLayoutTag_EAC3_7_1_E:
			return "EAC3 7.1 E"
		case kAudioChannelLayoutTag_EAC3_7_1_F:
			return "EAC3 7.1 F"
		case kAudioChannelLayoutTag_EAC3_7_1_G:
			return "EAC3 7.1 G"
		case kAudioChannelLayoutTag_EAC3_7_1_H:
			return "EAC3 7.1 H"
		case kAudioChannelLayoutTag_DTS_3_1:
			return "DTS 3.1"
		case kAudioChannelLayoutTag_DTS_4_1:
			return "DTS 4.1"
		case kAudioChannelLayoutTag_DTS_6_0_A:
			return "DTS 6.0 A"
		case kAudioChannelLayoutTag_DTS_6_0_B:
			return "DTS 6.0 B"
		case kAudioChannelLayoutTag_DTS_6_0_C:
			return "DTS 6.0 C"
		case kAudioChannelLayoutTag_DTS_6_1_A:
			return "DTS 6.1 A"
		case kAudioChannelLayoutTag_DTS_6_1_B:
			return "DTS 6.1 B"
		case kAudioChannelLayoutTag_DTS_6_1_C:
			return "DTS 6.1 C"
		case kAudioChannelLayoutTag_DTS_7_0:
			return "DTS 7.0"
		case kAudioChannelLayoutTag_DTS_7_1:
			return "DTS 7.1"
		case kAudioChannelLayoutTag_DTS_8_0_A:
			return "DTS 8.0 A"
		case kAudioChannelLayoutTag_DTS_8_0_B:
			return "DTS 8.0 B"
		case kAudioChannelLayoutTag_DTS_8_1_A:
			return "DTS 8.1 A"
		case kAudioChannelLayoutTag_DTS_8_1_B:
			return "DTS 8.1 B"
		case kAudioChannelLayoutTag_DTS_6_1_D:
			return "DTS 6.1 D"
		case kAudioChannelLayoutTag_WAVE_4_0_B:
			return "WAVE 4.0 B"
		case kAudioChannelLayoutTag_WAVE_5_0_B:
			return "WAVE 5.0 B"
		case kAudioChannelLayoutTag_WAVE_5_1_B:
			return "WAVE 5.1 B"
		case kAudioChannelLayoutTag_WAVE_6_1:
			return "WAVE 6.1"
		case kAudioChannelLayoutTag_WAVE_7_1:
			return "WAVE 7.1"
		case kAudioChannelLayoutTag_Atmos_5_1_2:
			return "Atmos 5.1.2"
		case kAudioChannelLayoutTag_Atmos_5_1_4:
			return "Atmos 5.1.4"
		case kAudioChannelLayoutTag_Atmos_7_1_2:
			return "Atmos 7.1.2"
		case kAudioChannelLayoutTag_Atmos_7_1_4:
			return "Atmos 7.1.4"
		case kAudioChannelLayoutTag_Atmos_9_1_6:
			return "Atmos 9.1.6"
		case kAudioChannelLayoutTag_Logic_4_0_C:
			return "Logic 4.0 C";
		case kAudioChannelLayoutTag_Logic_6_0_B:
			return "Logic 6.0 B";
		case kAudioChannelLayoutTag_Logic_6_1_B:
			return "Logic 6.1 B";
		case kAudioChannelLayoutTag_Logic_6_1_D:
			return "Logic 6.1 D";
		case kAudioChannelLayoutTag_Logic_7_1_B:
			return "Logic 7.1 B";
		case kAudioChannelLayoutTag_Logic_Atmos_7_1_4_B:
			return "Logic Atmos 7.1.4 B";
		case kAudioChannelLayoutTag_Logic_Atmos_7_1_6:
			return "Logic Atmos 7.1.6";
		case kAudioChannelLayoutTag_CICP_13:
			return "CICP 13";
		case kAudioChannelLayoutTag_CICP_14:
			return "CICP 14";
		case kAudioChannelLayoutTag_CICP_15:
			return "CICP 15";
		case kAudioChannelLayoutTag_CICP_16:
			return "CICP 16";
		case kAudioChannelLayoutTag_CICP_17:
			return "CICP 17";
		case kAudioChannelLayoutTag_CICP_18:
			return "CICP 18";
		case kAudioChannelLayoutTag_CICP_19:
			return "CICP 19";
		case kAudioChannelLayoutTag_CICP_20:
			return "CICP 20";
		case kAudioChannelLayoutTag_Ogg_5_0:
			return "Ogg 5.0";
		case kAudioChannelLayoutTag_Ogg_5_1:
			return "Ogg 5.1";
		case kAudioChannelLayoutTag_Ogg_6_1:
			return "Ogg 6.1";
		case kAudioChannelLayoutTag_Ogg_7_1:
			return "Ogg 7.1";
		case kAudioChannelLayoutTag_MPEG_5_0_E:
			return "MPEG 5.0 E";
		case kAudioChannelLayoutTag_MPEG_5_1_E:
			return "MPEG 5.1 E";
		case kAudioChannelLayoutTag_MPEG_6_1_B:
			return "MPEG 6.1 B";
		case kAudioChannelLayoutTag_MPEG_7_1_D:
			return "MPEG 7.1 D";

		case kAudioChannelLayoutTag_BeginReserved...kAudioChannelLayoutTag_EndReserved:
			return "Reserved";

		default:
			break
		}

		switch (self & 0xFFFF0000) {
		case kAudioChannelLayoutTag_HOA_ACN_SN3D:
			return "HOA ACN SN3D \(String(self & 0xFFFF))"
		case kAudioChannelLayoutTag_HOA_ACN_N3D:
			return "HOA ACN N3D \(String(self & 0xFFFF))"
		case kAudioChannelLayoutTag_DiscreteInOrder:
			return "Discrete in Order \(String(self & 0xFFFF))"
		case kAudioChannelLayoutTag_Unknown:
			return "Unknown \(String(self & 0xFFFF))"

		default:
			break
		}

		return "0x\(String(self, radix: 16, uppercase: false))"
	}
}

extension AudioChannelLabel {
	/// Returns the name of the `AudioChannelLabel`value of `self`
	public var channelLabelName: String {
		switch self {
		case kAudioChannelLabel_Unknown:
			return "Unknown"
		case kAudioChannelLabel_Unused:
			return "Unused"
		case kAudioChannelLabel_UseCoordinates:
			return "Use Coordinates"
		case kAudioChannelLabel_Left:
			return "Left"
		case kAudioChannelLabel_Right:
			return "Right"
		case kAudioChannelLabel_Center:
			return "Center"
		case kAudioChannelLabel_LFEScreen:
			return "LFE Screen"
		case kAudioChannelLabel_LeftSurround:
			return "Left Surround"
		case kAudioChannelLabel_RightSurround:
			return "Right Surround"
		case kAudioChannelLabel_LeftCenter:
			return "Left Center"
		case kAudioChannelLabel_RightCenter:
			return "Right Center"
		case kAudioChannelLabel_CenterSurround:
			return "Center Surround"
		case kAudioChannelLabel_LeftSurroundDirect:
			return "Left Surround Direct"
		case kAudioChannelLabel_RightSurroundDirect:
			return "Right Surround Direct"
		case kAudioChannelLabel_TopCenterSurround:
			return "Top Center Surround"
		case kAudioChannelLabel_VerticalHeightLeft:
			return "Vertical Height Left"
		case kAudioChannelLabel_VerticalHeightCenter:
			return "Vertical Height Center"
		case kAudioChannelLabel_VerticalHeightRight:
			return "Vertical Height Right"
		case kAudioChannelLabel_TopBackLeft:
			return "Top Back Left"
		case kAudioChannelLabel_TopBackCenter:
			return "Top Back Center"
		case kAudioChannelLabel_TopBackRight:
			return "Top Back Right"
		case kAudioChannelLabel_RearSurroundLeft:
			return "Rear Surround Left"
		case kAudioChannelLabel_RearSurroundRight:
			return "Rear Surround Right"
		case kAudioChannelLabel_LeftWide:
			return "Left Wide"
		case kAudioChannelLabel_RightWide:
			return "Right Wide"
		case kAudioChannelLabel_LFE2:
			return "LFE2"
		case kAudioChannelLabel_LeftTotal:
			return "Left Total"
		case kAudioChannelLabel_RightTotal:
			return "Right Total"
		case kAudioChannelLabel_HearingImpaired:
			return "Hearing Impaired"
		case kAudioChannelLabel_Narration:
			return "Narration"
		case kAudioChannelLabel_Mono:
			return "Mono"
		case kAudioChannelLabel_DialogCentricMix:
			return "Dialog Centric Mix"
		case kAudioChannelLabel_CenterSurroundDirect:
			return "Center Surround Direct"
		case kAudioChannelLabel_Haptic:
			return "Haptic"
		case kAudioChannelLabel_LeftTopMiddle:
			return "Left Top Middle"
		case kAudioChannelLabel_RightTopMiddle:
			return "Right Top Middle"
		case kAudioChannelLabel_LeftTopRear:
			return "Left Top Rear"
		case kAudioChannelLabel_CenterTopRear:
			return "Center Top Rear"
		case kAudioChannelLabel_RightTopRear:
			return "Right Top Rear"
		case kAudioChannelLabel_LeftSideSurround:
			return "Left Side Surround";
		case kAudioChannelLabel_RightSideSurround:
			return "Right Side Surround";
		case kAudioChannelLabel_LeftBottom:
			return "Left Bottom";
		case kAudioChannelLabel_RightBottom:
			return "Right Bottom";
		case kAudioChannelLabel_CenterBottom:
			return "Center Bottom";
		case kAudioChannelLabel_LeftTopSurround:
			return "Left Top Surround";
		case kAudioChannelLabel_RightTopSurround:
			return "Right Top Surround";
		case kAudioChannelLabel_LFE3:
			return "LFE3";
		case kAudioChannelLabel_LeftBackSurround:
			return "Left Back Surround";
		case kAudioChannelLabel_RightBackSurround:
			return "Right Back Surround";
		case kAudioChannelLabel_LeftEdgeOfScreen:
			return "Left Edge of Screen";
		case kAudioChannelLabel_RightEdgeOfScreen:
			return "Right Edge of Screen";
		case kAudioChannelLabel_Ambisonic_W:
			return "Ambisonic W"
		case kAudioChannelLabel_Ambisonic_X:
			return "Ambisonic X"
		case kAudioChannelLabel_Ambisonic_Y:
			return "Ambisonic Y"
		case kAudioChannelLabel_Ambisonic_Z:
			return "Ambisonic Z"
		case kAudioChannelLabel_MS_Mid:
			return "MS Mid"
		case kAudioChannelLabel_MS_Side:
			return "MS Side"
		case kAudioChannelLabel_XY_X:
			return "XY X"
		case kAudioChannelLabel_XY_Y:
			return "XY Y"
		case kAudioChannelLabel_BinauralLeft:
			return "Binaural Left"
		case kAudioChannelLabel_BinauralRight:
			return "Binaural Right"
		case kAudioChannelLabel_HeadphonesLeft:
			return "Headphones Left"
		case kAudioChannelLabel_HeadphonesRight:
			return "Headphones Right"
		case kAudioChannelLabel_ClickTrack:
			return "Click Track"
		case kAudioChannelLabel_ForeignLanguage:
			return "Foreign Language"
		case kAudioChannelLabel_Discrete:
			return "Discrete"
		case kAudioChannelLabel_Discrete_0:
			return "Discrete 0"
		case kAudioChannelLabel_Discrete_1:
			return "Discrete 1"
		case kAudioChannelLabel_Discrete_2:
			return "Discrete 2"
		case kAudioChannelLabel_Discrete_3:
			return "Discrete 3"
		case kAudioChannelLabel_Discrete_4:
			return "Discrete 4"
		case kAudioChannelLabel_Discrete_5:
			return "Discrete 5"
		case kAudioChannelLabel_Discrete_6:
			return "Discrete 6"
		case kAudioChannelLabel_Discrete_7:
			return "Discrete 7"
		case kAudioChannelLabel_Discrete_8:
			return "Discrete 8"
		case kAudioChannelLabel_Discrete_9:
			return "Discrete 9"
		case kAudioChannelLabel_Discrete_10:
			return "Discrete 10"
		case kAudioChannelLabel_Discrete_11:
			return "Discrete 11"
		case kAudioChannelLabel_Discrete_12:
			return "Discrete 12"
		case kAudioChannelLabel_Discrete_13:
			return "Discrete 13"
		case kAudioChannelLabel_Discrete_14:
			return "Discrete 14"
		case kAudioChannelLabel_Discrete_15:
			return "Discrete 15"
		case kAudioChannelLabel_Discrete_65535:
			return "Discrete 65535"
		case kAudioChannelLabel_HOA_ACN:
			return "HOA ACN"
		case kAudioChannelLabel_HOA_ACN_0:
			return "HOA ACN 0"
		case kAudioChannelLabel_HOA_ACN_1:
			return "HOA ACN 1"
		case kAudioChannelLabel_HOA_ACN_2:
			return "HOA ACN 2"
		case kAudioChannelLabel_HOA_ACN_3:
			return "HOA ACN 3"
		case kAudioChannelLabel_HOA_ACN_4:
			return "HOA ACN 4"
		case kAudioChannelLabel_HOA_ACN_5:
			return "HOA ACN 5"
		case kAudioChannelLabel_HOA_ACN_6:
			return "HOA ACN 6"
		case kAudioChannelLabel_HOA_ACN_7:
			return "HOA ACN 7"
		case kAudioChannelLabel_HOA_ACN_8:
			return "HOA ACN 8"
		case kAudioChannelLabel_HOA_ACN_9:
			return "HOA ACN 9"
		case kAudioChannelLabel_HOA_ACN_10:
			return "HOA ACN 10"
		case kAudioChannelLabel_HOA_ACN_11:
			return "HOA ACN 11"
		case kAudioChannelLabel_HOA_ACN_12:
			return "HOA ACN 12"
		case kAudioChannelLabel_HOA_ACN_13:
			return "HOA ACN 13"
		case kAudioChannelLabel_HOA_ACN_14:
			return "HOA ACN 14"
		case kAudioChannelLabel_HOA_ACN_15:
			return "HOA ACN 15"
		case kAudioChannelLabel_HOA_ACN_65024:
			return "HOA ACN 65024"

		case kAudioChannelLabel_BeginReserved...kAudioChannelLabel_EndReserved:
			return "Reserved";

		default:
			break
		}

		switch (self & 0xFFFF0000) {
		case kAudioChannelLabel_HOA_N3D:
			return "HOA N3D \(String(self & 0xFFFF))";
		case kAudioChannelLabel_Object:
			return "Object \(String(self & 0xFFFF))";

		default:
			break
		}

		return "0x\(String(self, radix: 16, uppercase: false))"
	}
}

// From https://stackoverflow.com/questions/32102936/how-do-you-enumerate-optionsettype-in-swift
extension OptionSet where RawValue: FixedWidthInteger {
	/// Returns a sequence containing the individual bits of `self`
	func elements() -> AnySequence<Self> {
		var remainingBits = rawValue
		var bitMask: RawValue = 1
		return AnySequence {
			return AnyIterator {
				while remainingBits != 0 {
					defer {
						bitMask = bitMask << 1
					}
					if remainingBits & bitMask != 0 {
						remainingBits = remainingBits & ~bitMask
						return Self(rawValue: bitMask)
					}
				}
				return nil
			}
		}
	}
}

extension AudioChannelBitmap {
	/// Returns the names of the channel bits in `self`
	public var bitmapDescription: String {
		var result = [String]()
		for bit in elements() {
			switch bit {
			case .bit_Left:
				result.append("Left")
			case .bit_Right:
				result.append("Right")
			case .bit_Center:
				result.append("Center")
			case .bit_LFEScreen:
				result.append("LFE Screen")
			case .bit_LeftSurround:
				result.append("Left Surround")
			case .bit_RightSurround:
				result.append("Right Surround")
			case .bit_LeftCenter:
				result.append("Left Center")
			case .bit_RightCenter:
				result.append("Right Center")
			case .bit_CenterSurround:
				result.append("Center Surround")
			case .bit_LeftSurroundDirect:
				result.append("Left Surround Direct")
			case .bit_RightSurroundDirect:
				result.append("Right Surround Direct")
			case .bit_TopCenterSurround:
				result.append("Top Center Surround")
			case .bit_VerticalHeightLeft:
				result.append("Vertical Height Left")
			case .bit_VerticalHeightCenter:
				result.append("Vertical Height Center")
			case .bit_VerticalHeightRight:
				result.append("Vertical Height Right")
			case .bit_TopBackLeft:
				result.append("Top Back Left")
			case .bit_TopBackCenter:
				result.append("Top Back Center")
			case .bit_TopBackRight:
				result.append("Top Back Right")
			case .bit_LeftTopFront:
				result.append("Left Top Front")
			case .bit_CenterTopFront:
				result.append("Center Top Front")
			case .bit_RightTopFront:
				result.append("Right Top Front")
			case .bit_LeftTopMiddle:
				result.append("Left Top Middle")
			case .bit_CenterTopMiddle:
				result.append("Center Top Middle")
			case .bit_RightTopMiddle:
				result.append("Right Top Middle")
			case .bit_LeftTopRear:
				result.append("Left Top Rear")
			case .bit_CenterTopRear:
				result.append("Center Top Rear")
			case .bit_RightTopRear:
				result.append("Right Top Rear")

			default:
				result.append("0x\(String(bit.rawValue, radix: 16, uppercase: false))")
			}
		}
		return result.joined(separator: " | ")
	}
}

extension AudioChannelFlags {
	/// Returns the names of the flags in `self`
	public var channelFlagsDescription: String {
		var result = [String]()
		for bit in elements() {
			switch bit {
			case .rectangularCoordinates:
				result.append("Rectangular Coordinates")
			case .sphericalCoordinates:
				result.append("Spherical Coordinates")
			case .meters:
				result.append("Meters")

			default:
				result.append("0x\(String(bit.rawValue, radix: 16, uppercase: false))")
			}
		}
		return result.joined(separator: " | ")
	}
}
