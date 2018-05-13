//
//  Quad.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CoreImage
import Vision
import UIKit

public struct Quad {

	public var topLeft: CGPoint
	public var topRight: CGPoint
	public var bottomLeft: CGPoint
	public var bottomRight: CGPoint

	public init(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) {
		self.topLeft = topLeft
		self.topRight = topRight
		self.bottomLeft = bottomLeft
		self.bottomRight = bottomRight
	}

	public init() {
		self.init(topLeft: .zero, topRight: .zero, bottomLeft: .zero, bottomRight: .zero)
	}

	public init?(clockwise points: [CGPoint]) {
		guard points.count == 4 else { return nil }
		self.init(topLeft: points[0], topRight: points[1], bottomLeft: points[3], bottomRight: points[2])
	}

	@available(iOS 11.0, *)
	public init(obvservation: VNRectangleObservation) {
		self.init(topLeft: obvservation.topLeft, topRight: obvservation.topRight, bottomLeft: obvservation.bottomLeft, bottomRight: obvservation.bottomRight)
	}
}

extension Quad {

	public var isEmpty: Bool {
		return topLeft == .zero && topRight == .zero && bottomRight == .zero && bottomLeft == .zero
	}

	public var points: [CGPoint] {
		return [topLeft, topRight, bottomRight, bottomLeft]
	}

}

extension Quad {

	func absolute(size: CGSize) -> Quad {
		return Quad(topLeft: topLeft.scaledAbsolute(size: size), topRight: topLeft.scaledAbsolute(size: size), bottomLeft: bottomLeft.scaledAbsolute(size: size), bottomRight: bottomRight.scaledAbsolute(size: size))
	}

	func mirrorUp() -> Quad? {
		let converted = points.map { CGPoint(x: $0.x, y: 1 - $0.y) }
		return Quad(clockwise: converted)
	}

	func multiply(value: CGFloat) -> Quad {
		return Quad(topLeft: topRight.multiply(value: value), topRight: topRight.multiply(value: value), bottomLeft: bottomRight.multiply(value: value), bottomRight: bottomRight.multiply(value: value))
	}

	func divide(value: CGFloat) -> Quad {
		return Quad(topLeft: topRight.divide(value: value), topRight: topRight.divide(value: value), bottomLeft: bottomRight.divide(value: value), bottomRight: bottomRight.divide(value: value))
	}

	func isInRange(other: Quad, threshold: CGFloat) -> Bool {
		return topRight.isInRange(other: other.topRight, theshold: threshold) &&  topLeft.isInRange(other: other.topLeft, theshold: threshold) &&  bottomRight.isInRange(other: other.bottomRight, theshold: threshold) &&  bottomLeft.isInRange(other: other.bottomLeft, theshold: threshold)
	}

	static func +(lhs: Quad, rhs: Quad) -> Quad {
		return Quad(topLeft: lhs.topLeft + rhs.topLeft, topRight: lhs.topRight + rhs.topRight, bottomLeft: lhs.bottomLeft + rhs.bottomLeft, bottomRight: lhs.bottomRight + rhs.bottomRight)
	}

}
