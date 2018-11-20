//
//  Observation.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CoreImage

public struct Observation {

    public init(quad: Quad?, buffer: CVPixelBuffer) {
        self.quad = quad
        self.buffer = buffer
    }

	public let quad: Quad?
	public let buffer: CVPixelBuffer

}
