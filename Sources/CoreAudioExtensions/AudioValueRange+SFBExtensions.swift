//
// Copyright (c) 2024 Stephen F. Booth <me@sbooth.org>
// Part of https://github.com/sbooth/CoreAudioExtensions
// MIT license
//

import Foundation
import CoreAudioTypes

extension AudioValueRange {
	/// Returns true if `self` contains `value`
	public func contains(_ value: Float64) -> Bool {
		value >= mMinimum && value <= mMaximum
	}
}
