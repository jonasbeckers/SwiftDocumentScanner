//
//  RectangleImageDetector.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CoreImage
import UIKit
import Vision

public protocol ImageRectangleDetector: class {

	typealias Completion = (Quad?) -> Void

	func detect(image: UIImage, completion: @escaping Completion)

}
