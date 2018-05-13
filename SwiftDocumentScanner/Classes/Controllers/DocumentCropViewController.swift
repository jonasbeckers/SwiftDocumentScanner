//
//  DocumentCropViewController.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import CropView
import UIKit
import Vision

public protocol DocumentCropViewControllerDelegate: class {

	func documentCropViewController(result: Result)
	func documentCropViewController(failed: Error)

}

open class DocumentCropViewController: UIViewController {

	@IBOutlet public var imageView: UIImageView!
	public private(set) var cropView = SECropView()

	private var points: [CGPoint] = [] {
		didSet {
			updateCropview()
		}
	}

	private var configuredCropView: Bool = false
	private var rectangleDetector: ImageRectangleDetector = CIImageRectangleDetector()

	public var image: UIImage? {
		didSet {
			image = image?.fixOrientation()
		}
	}
	public weak var cropDelegate: DocumentCropViewControllerDelegate?

	open override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 11.0, *) {
			rectangleDetector = VisionImageRectangleDetector()
		}

		SECropView.goodAreaColor = .white
		SECropView.badAreaColor = .red

		configure()
	}

	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		cropView.frame = view.bounds
		cropView.layoutSubviews()

		updateCropview()
	}

	public func configure() {
		image = image?.fixOrientation()
		imageView.transform = CGAffineTransform.identity
		imageView.image = image
		imageView.contentMode = .scaleAspectFit
		points = defaultCropViewCorners()

		guard let image = image else { return }
		rectangleDetector.detect(image: image, completion: handleDetection)
	}

	private func updateCropview() {
		let size = image?.size ?? .zero
		let width = Int(size.width)
		let height = Int(size.height)

		let converted: [CGPoint]

		if #available(iOS 11, *) {
			converted = points.map { VNImagePointForNormalizedPoint($0, width, height) }
		} else {
			converted = points.map { $0.scaledAbsolute(size: size) }
		}

		updateCorners(points: converted.map { $0.cartesian(height: size.height) })
	}

	private func updateCorners(points: [CGPoint]) {
		if configuredCropView {
			cropView.setCorners(newCorners: points)
		} else {
			cropView.configureWithCorners(corners: points, on: imageView)
			configuredCropView = true
		}
	}

	private func handleDetection(quad: Quad?) {
		if let quad = quad {
			points = quad.points
		} else {
			points = defaultCropViewCorners()
		}
	}

	private func defaultCropViewCorners() -> [CGPoint] {
		return [CGPoint(x: 0.2, y: 0.2), CGPoint(x: 0.2, y: 0.8), CGPoint(x: 0.8, y: 0.8), CGPoint(x: 0.8, y: 0.2)]
	}

	public func crop() {
		guard let image = image, let points = cropView.cornerLocations else { return }

		DispatchQueue.global(qos: .userInitiated).async {
			do {
				let croppedImage = try SEQuadrangleHelper.cropImage(with: image, quad: points)
				let result = Result(original: image, cropped: croppedImage, quad: Quad(clockwise: points))

				DispatchQueue.main.async { [weak self] in
					self?.cropDelegate?.documentCropViewController(result: result)
				}
			} catch {
				DispatchQueue.main.async { [weak self] in
					self?.cropDelegate?.documentCropViewController(failed: error)
				}
			}
		}
	}

}
