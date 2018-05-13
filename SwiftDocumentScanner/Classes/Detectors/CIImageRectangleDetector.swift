//
//  CIImageRectangleDetector.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CoreImage
import UIKit

public final class CIImageRectangleDetector: ImageRectangleDetector {

	public func detect(image: UIImage, completion: @escaping Completion) {
		DispatchQueue.global().async {
			guard let ciImage = CIImage(image: image) else { return }

			guard let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]) else { return }

			let results = detector.features(in: ciImage)
			let sortedBySize = results.sorted { $0.bounds.area > $1.bounds.area }

			if let feature = sortedBySize.first as? CIRectangleFeature {
				let size = ciImage.extent.size
				let points = [feature.topLeft, feature.topRight, feature.bottomRight, feature.bottomLeft]
				let normalized = points.map { $0.scaledRelative(size: size) }

				let quad = Quad(clockwise: normalized)

				DispatchQueue.main.async {
					completion(quad)
				}
			} else {
				DispatchQueue.main.async {
					completion(nil)
				}
			}
		}
	}

}
