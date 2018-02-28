//
//  AutoDetector.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CoreImage
import CoreGraphics

public protocol AutoDetectorDelegate: class {

	func detector(update: Observation)
	func detector(success: Observation)
	func detector(failed: Observation)

}

public final class AutoDetector {

	public struct Config {

		public var minCorrectFrames: Int // minimum correct frames before update
		public var maxDroppedFrames: Int // maximum frames that can be dropped before tracking is lost
		public var frameBufferSize: Int // frames needed to autodetect

		public var threshold: CGFloat // maximum deviation of points

		public static var `default` = Config(minCorrectFrames: 8, maxDroppedFrames: 5, frameBufferSize: 64, threshold: 0.05)
	}

	public weak var delegate: AutoDetectorDelegate?

	private(set) var finished: Bool = false
	private var droppedFrames: Int = 0
	private var queue = DispatchQueue(label: "AutoDetectionQueue")

	private var quads: [Quad] = []
	private var config: Config

	public init(config: Config = Config.default) {
		self.config = config
	}

	public func feed(observation: Observation) {
		guard !finished else { return }

		queue.async { [weak self] in
			guard let strongSelf = self else { return }
			strongSelf.execute(observation: observation)
		}
	}

	public func reset() {
		droppedFrames = 0
		quads = []
		finished = false
	}

	private func execute(observation: Observation) {
		if let newQuad = observation.quad {
			if quads.count < 1 { quads.append(newQuad); return; }

			let averageQuad = calculateWeightedAverage()
			if newQuad.isInRange(other: averageQuad, threshold: config.threshold) {
				quads.append(newQuad)
				if quads.count > config.frameBufferSize { quads.removeFirst() }
				guard quads.count >= config.minCorrectFrames else { return }

				DispatchQueue.main.async {
					self.delegate?.detector(update: observation)
				}

				guard quads.count >= config.frameBufferSize else { return }
				finished = true

				DispatchQueue.main.async {
					self.delegate?.detector(success: observation)
				}
			} else {
				droppedFrames = 0
				quads = []
				
				DispatchQueue.main.async {
					self.delegate?.detector(failed: observation)
				}
			}
		} else {
			droppedFrames += 1
			guard droppedFrames >= config.maxDroppedFrames else { return }
			droppedFrames = 0
			quads = []

			DispatchQueue.main.async {
				self.delegate?.detector(failed: observation)
			}
		}
	}

	private func calculateWeightedAverage() -> Quad {
		let count = quads.count
		let fixedWeights: [CGFloat] = [1, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20].reversed()
		let weights = fixedWeights + Array<CGFloat>(repeating: 1, count: max(count - fixedWeights.count, 0))
		let totalWeight = weights[0 ..< count].reduce(0, +)

		let combined = zip(quads.reversed(), weights).map { $0.multiply(value: $1).divide(value: totalWeight) }
		let averagePoint = combined.reduce(Quad(), +)

		return averagePoint
	}

}
