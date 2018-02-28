//
//  CropController.swift
//  DocumentScanner_Example
//
//  Created by Jonas Beckers on 28/02/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import DocumentScanner
import UIKit

class CropController: DocumentCropViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		cropDelegate = self
    }
	@IBAction func cropImage(_ sender: Any) {
		crop()
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? ResultController {
			vc.image = sender as? UIImage
		}
	}

}

extension CropController: DocumentCropViewControllerDelegate {

	func documentCropViewController(result: Result) {
		performSegue(withIdentifier: "Result", sender: result.cropped)
	}

	func documentCropViewController(failed: Error) {
		print(failed)
	}

}
