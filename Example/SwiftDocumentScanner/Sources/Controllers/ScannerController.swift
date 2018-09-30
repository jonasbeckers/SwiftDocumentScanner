//
//  ScannerController.swift
//  DocumentScanner
//
//  Created by jonasbeckers on 02/28/2018.
//  Copyright (c) 2018 jonasbeckers. All rights reserved.
//

import AVFoundation
import SwiftDocumentScanner
import UIKit

class ScannerController: DocumentScannerViewController {

	@IBOutlet weak var captureButton: UIButton!
	
    override func viewDidLoad() {
		TrackView.fillColor = UIColor.blue.withAlphaComponent(0.4)
		TrackView.lineColor = UIColor.blue

		tapToFocus = true
		lowLightBoost = false
		cameraPosition = .back
		flashMode = .off
		preset = .hd4K3840x2160

		cameraDelegate = self
		scannerDelegate = self

        super.viewDidLoad()

        view.bringSubviewToFront(captureButton)
    }

	@IBAction func takePicture(_ sender: Any) {
		takePhoto()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? CropController {
			vc.image = sender as? UIImage
		} else if let vc = segue.destination as? ResultController {
			vc.image = sender as? UIImage
		}
	}
}

extension ScannerController: DocumentScannerViewControllerDelegate {

	func documentScanner(result: Result) {
		performSegue(withIdentifier: "Result", sender: result.cropped)
	}

}

extension ScannerController: CameraViewControllerDelegate {

	func cameraViewController(didFocus point: CGPoint) {
		print("focused point: \(point)")
	}

	func cameraViewController(update status: AVAuthorizationStatus) {
		print("status changed")
	}

	func cameraViewController(captured image: UIImage) {
		performSegue(withIdentifier: "Crop", sender: image)
	}

}
