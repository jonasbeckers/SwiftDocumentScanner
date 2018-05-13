//
//  CGPoint+Extension.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CoreGraphics

extension CGPoint {

	public func cartesian(height: CGFloat) -> CGPoint {
		return CGPoint(x: x, y: height - y)
	}

	public func scaledRelative(size: CGSize) -> CGPoint {
		return CGPoint(x: x / size.width, y: y / size.height)
	}

	public func scaledAbsolute(size: CGSize) -> CGPoint {
		return CGPoint(x: x * size.width, y: y * size.height)
	}

	func isInRange(other: CGPoint, theshold: CGFloat) -> Bool {
		return x - other.x < theshold && y - other.y < theshold
	}

	func multiply(value: CGFloat) -> CGPoint {
		return CGPoint(x: x * value, y: y * value)
	}

	func divide(value: CGFloat) -> CGPoint {
		return CGPoint(x: x / value, y: y / value)
	}

	public static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}

}
