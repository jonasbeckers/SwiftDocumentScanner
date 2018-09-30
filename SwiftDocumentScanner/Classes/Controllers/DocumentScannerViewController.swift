//
//  DocumentScannerViewController.swift
//  DocumentScanner
//
//  Created by Jonas Beckers on 25/02/18.
//

import AVFoundation
import UIKit
import Vision

public protocol DocumentScannerViewControllerDelegate: class {

	func documentScanner(result: Result)

}

@available(iOS 10.0, *)
open class DocumentScannerViewController: CameraViewController {

	private var trackView = TrackView()

	public var autoDetector = AutoDetector() {
		didSet {
			autoDetector.delegate = self
		}
	}

	public var rectangleDetector: SequenceRectangleDetector = NoSequenceRectangleDetector() {
		didSet {
			configureDetector()
		}
	}

	public weak var scannerDelegate: DocumentScannerViewControllerDelegate?

	open override func viewDidLoad() {
		super.viewDidLoad()

		if #available(iOS 11.0, *) {
			rectangleDetector = VisionSequenceRectangleDetector()
		}

		view.addSubview(trackView)
		autoDetector.delegate = self
	}

	open override func viewWillDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		autoDetector.reset()
		trackView.update(path: nil)
	}

	open override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		autoDetector.reset()
		trackView.update(path: nil)
	}

	private func configureDetector() {
		rectangleDetector.update = { [weak self] observation in
			guard let strongSelf = self else { return }
			strongSelf.autoDetector.feed(observation: observation)
		}
	}

	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		trackView.frame = view.bounds
		trackView.layoutSubviews()
	}

	public override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
		rectangleDetector.detect(on: pixelBuffer)
	}

}

@available(iOS 10.0, *)
extension DocumentScannerViewController: AutoDetectorDelegate {

	public func detector(update: Observation) {
		guard let points = update.quad?.mirrorUp()?.points else { return }
        let converted = points.compactMap { previewLayer?.layerPointConverted(fromCaptureDevicePoint: $0) }
		let path = converted.quadPath
		trackView.update(path: path)
	}

	public func detector(success: Observation) {
		guard let quad = success.quad, let mirrored = quad.mirrorUp() else { return }

		CropHelper.crop(buffer: success.buffer, quad: mirrored) { result in
			self.scannerDelegate?.documentScanner(result: result)
		}
	}

	public func detector(failed: Observation) {
		trackView.update(path: nil)
	}

}
