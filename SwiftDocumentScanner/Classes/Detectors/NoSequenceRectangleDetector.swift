//
//  NoSequenceRectangleDetector.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CoreImage

public final class NoSequenceRectangleDetector: SequenceRectangleDetector {

	public var update: SequenceRectangleDetector.Update?
	public func detect(on pixelBuffer: CVPixelBuffer) { }

}
