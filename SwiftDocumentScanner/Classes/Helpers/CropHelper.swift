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

	static func crop(buffer: CVPixelBuffer, quad: Quad, completion: @escaping Completion) {
		DispatchQueue.global(qos: .userInteractive).async {
			let ciImage = CIImage(cvPixelBuffer: buffer)
			let context = CIContext()

			guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
			let image = UIImage(cgImage: cgImage, scale: 1, orientation: .right).fixOrientation()

			let size = ciImage.extent.size
			let width = Int(size.width)
			let height = Int(size.height)

			let points: [CGPoint]
			if #available(iOS 11.0, *) {
				points = quad.points.map { VNImagePointForNormalizedPoint($0, width, height) }
			} else {
				points = quad.points.map { $0.scaledAbsolute(size: size) }
			}
			let converted = points.map { $0.cartesian(height: size.height) }

			let result: Result
			if let quad = Quad(clockwise: converted), let cropped = applyPersperpectiveCorrection(ciImage: ciImage, quad: quad) {
				result = Result(original: image, cropped: cropped, quad: quad)
			} else {
				result = Result(original: image, cropped: nil, quad: nil)
			}

			DispatchQueue.main.async {
				completion(result)
			}
		}
	}

	private static func applyPersperpectiveCorrection(ciImage: CIImage, quad: Quad) -> UIImage? {
		guard let filter = CIFilter(name: "CIPerspectiveCorrection") else { return nil }
		let context = CIContext(options: nil)

		filter.setValue(CIVector(cgPoint: quad.topLeft), forKey: "inputTopLeft")
		filter.setValue(CIVector(cgPoint: quad.topRight), forKey: "inputTopRight")
		filter.setValue(CIVector(cgPoint: quad.bottomLeft), forKey: "inputBottomLeft")
		filter.setValue(CIVector(cgPoint: quad.bottomRight), forKey: "inputBottomRight")
		filter.setValue(ciImage, forKey: kCIInputImageKey)

		guard let correctedImage = filter.outputImage, let cgImage = context.createCGImage(correctedImage, from: correctedImage.extent) else { return nil }
		return UIImage(cgImage: cgImage, scale: 1, orientation: .right)
	}

}
