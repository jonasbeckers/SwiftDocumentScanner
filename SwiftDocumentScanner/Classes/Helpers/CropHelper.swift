//
//  CropHelper.swift
//  CropView
//
//  Created by Jonas Beckers on 28/02/18.
//

import CoreImage
import Vision

public struct CropHelper {

	public typealias Completion = (Result) -> Void

	static func crop(ciImage: CIImage, quad: Quad, completion: @escaping Completion) {
		DispatchQueue.global(qos: .userInteractive).async {
			let size = ciImage.extent.size
			let width = Int(size.width)
			let height = Int(size.height)
			let image = UIImage(ciImage: ciImage)

			let points: [CGPoint]
			if #available(iOS 11.0, *) {
				points = quad.points.map { VNImagePointForNormalizedPoint($0, width, height) }
			} else {
				points = quad.points.map { $0.scaled(size: size) }
			}
			let converted = points.map { $0.cartesian(height: size.height) }

			let result: Result
			if let quad = Quad(clockwise: converted), let cropped = applyPersperpectiveCorrection(image: image, quad: quad) {
				result = Result(original: image, cropped: cropped, quad: quad)
			} else {
				result = Result(original: image, cropped: nil, quad: nil)
			}

			DispatchQueue.main.async {
				completion(result)
			}
		}
	}

	private static func applyPersperpectiveCorrection(image: UIImage, quad: Quad) -> UIImage? {
		guard let ciImage = image.ciImage else { return nil }
		let scale = image.scale
		let orientation: UIImageOrientation = .right

		guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
		let context = CIContext(options: nil)

		filter.setValue(CIVector(cgPoint: quad.topLeft), forKey: "inputTopLeft")
		filter.setValue(CIVector(cgPoint: quad.topRight), forKey: "inputTopRight")
		filter.setValue(CIVector(cgPoint: quad.bottomLeft), forKey: "inputBottomLeft")
		filter.setValue(CIVector(cgPoint: quad.bottomRight), forKey: "inputBottomRight")
		filter.setValue(ciImage, forKey: kCIInputImageKey)

		guard let correctedImage = filter.outputImage, let cgImage = context.createCGImage(correctedImage, from: correctedImage.extent) else { return nil }

		return UIImage(cgImage: cgImage, scale: scale, orientation: orientation).fixOrientation(orientation: .right)
	}

}
