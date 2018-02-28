//
//  Array+extension.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import UIKit

public extension Array where Element == CGPoint {

	public var quadPath: UIBezierPath {
		let path = UIBezierPath()

		guard count == 4 else { return path }
		path.move(to: self[0])

		for i in 1 ..< 4 {
			path.addLine(to: self[i])
		}
		path.close()

		return path
	}

}
