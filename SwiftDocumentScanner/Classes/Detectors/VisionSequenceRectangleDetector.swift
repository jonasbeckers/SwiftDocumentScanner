//
//  VisionSequenceRectangleDetector.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import Foundation


import CoreImage
import Vision

@available(iOS 11.0, *)
public final class VisionSequenceRectangleDetector: SequenceRectangleDetector {
	private var data: [NSObject: CVPixelBuffer] = [:]
	public var update: Update?

	private lazy var visionRequestHandler = VNSequenceRequestHandler()

	public func detect(on pixelBuffer: CVPixelBuffer) {
		let request = VNDetectRectanglesRequest(completionHandler: handle)
		request.minimumConfidence = 0.5
		request.maximumObservations = 4
		request.minimumSize = 0.2
		request.minimumAspectRatio = 0.2
		request.maximumAspectRatio = 1
		request.quadratureTolerance = 45
		request.preferBackgroundProcessing = true

		execute(request: request, buffer: pixelBuffer)
	}

	private func execute(request: VNRequest, buffer: CVPixelBuffer) {
		do {
			data[request] = buffer
			try visionRequestHandler.perform([request], on: buffer)
		} catch {
			complete(buffer: buffer)
		}
	}

	private func handle(request: VNRequest, error: Error?) {
		guard let buffer = data.removeValue(forKey: request) else { return }
		guard let observations = request.results as? [VNRectangleObservation] else { return }
		let sorted = observations.sorted { $0.confidence > $1.confidence }

		if let result = sorted.first {
			complete(observation: result, buffer: buffer)
		} else {
			complete(buffer: buffer)
		}
	}

	private func complete(observation: VNRectangleObservation? = nil, buffer: CVPixelBuffer) {
		let result: Observation
		if let observation = observation {
			result = Observation(quad: Quad(obvservation: observation), buffer: buffer)
		} else {
			result = Observation(quad: nil, buffer: buffer)
		}

		DispatchQueue.main.async { [weak self] in
			self?.update?(result)
		}
	}

}
