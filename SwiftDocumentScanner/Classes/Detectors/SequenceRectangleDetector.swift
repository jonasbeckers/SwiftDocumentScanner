//
//  SequenceRectangleDetector.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import AVFoundation
import Foundation
import Vision

public protocol SequenceRectangleDetector: class {

	typealias Update = (Observation) -> Void

	var update: Update? { get set }
	func detect(on pixelBuffer: CVPixelBuffer)

}
