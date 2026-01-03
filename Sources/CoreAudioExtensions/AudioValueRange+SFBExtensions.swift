//
// SPDX-FileCopyrightText: 2024 Stephen F. Booth <contact@sbooth.dev>
// SPDX-License-Identifier: MIT
//
// Part of https://github.com/sbooth/CoreAudioExtensions
//

import Foundation
import CoreAudioTypes

extension AudioValueRange {
	/// Returns true if `self` contains `value`
	public func contains(_ value: Float64) -> Bool {
		value >= mMinimum && value <= mMaximum
	}

	/// Returns true if `self` is equal to `other`
	public func isEqualTo(_ other: AudioValueRange) -> Bool {
		mMinimum == other.mMinimum && mMaximum == other.mMaximum
	}
}

#if false
// Disabled to avoid warning about conformance of imported type to imported protocol
extension AudioValueRange: /*@retroactive*/ Equatable {
	public static func == (lhs: AudioValueRange, rhs: AudioValueRange) -> Bool {
		lhs.isEqualTo(rhs)
	}
}
#endif
