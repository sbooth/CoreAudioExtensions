//
// SPDX-FileCopyrightText: 2025 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/CoreAudioExtensions
//

import Foundation
import CoreAudioTypes

extension AudioTimeStamp {
	/// `true` if this time stamp contains at least one valid time
	public var isValid: Bool {
		!mFlags.isEmpty
	}

	/// `true` if this time stamp contains a valid sample time
	public var sampleTimeIsValid: Bool {
		mFlags.contains(.sampleTimeValid)
	}

	/// `true` if this time stamp contains a valid host time
	public var hostTimeIsValid: Bool {
		mFlags.contains(.hostTimeValid)
	}

	/// `true` if this time stamp contains a valid rate scalar
	public var rateScalarIsValid: Bool {
		mFlags.contains(.rateScalarValid)
	}

	/// `true` if this time stamp contains a valid word clock time
	public var wordClockTimeIsValid: Bool {
		mFlags.contains(.wordClockTimeValid)
	}

	/// `true` if this time stamp contains a valid SMPTE time
	public var smpteTimeIsValid: Bool {
		mFlags.contains(.smpteTimeValid)
	}

	/// Returns `true` if `self` is equal to `other`
	public func isEqualTo(_ other: AudioTimeStamp) -> Bool {
		if sampleTimeIsValid && other.sampleTimeIsValid {
			return mSampleTime == other.mSampleTime
		}

		if hostTimeIsValid && other.hostTimeIsValid {
			return mHostTime == other.mHostTime
		}

		if wordClockTimeIsValid && other.wordClockTimeIsValid {
			return mWordClockTime == other.mWordClockTime
		}

		return false
	}

	/// Returns `true` if `self` is greater than `other`
	public func isGreaterThan(_ other: AudioTimeStamp) -> Bool {
		if sampleTimeIsValid && other.sampleTimeIsValid {
			return mSampleTime > other.mSampleTime
		}

		if hostTimeIsValid && other.hostTimeIsValid {
			return mHostTime > other.mHostTime
		}

		if wordClockTimeIsValid && other.wordClockTimeIsValid {
			return mWordClockTime > other.mWordClockTime
		}

		return false
	}

	/// Returns `true` if `self` is less than `other`
	public func isLessThan(_ other: AudioTimeStamp) -> Bool {
		if sampleTimeIsValid && other.sampleTimeIsValid {
			return mSampleTime < other.mSampleTime
		}

		if hostTimeIsValid && other.hostTimeIsValid {
			return mHostTime < other.mHostTime
		}

		if wordClockTimeIsValid && other.wordClockTimeIsValid {
			return mWordClockTime < other.mWordClockTime
		}

		return false
	}

	/// Returns a description of `self`
	public var timeStampDescription: String {
		var elements: [String] = []

		if sampleTimeIsValid {
			elements.append(String(format: "sample time %g", mSampleTime))
		}

		if hostTimeIsValid {
			elements.append("host time \(mHostTime)")
		}

		if rateScalarIsValid {
			elements.append(String(format: "rate scalar %g", mRateScalar))
		}

		if wordClockTimeIsValid {
			elements.append("word clock time \(mWordClockTime)")
		}

#if false
		if smpteTimeIsValid {
			elements.append("SMPTE time \(mSMPTETime)")
		}
#endif

		return elements.joined(separator: ", ")
	}
}
