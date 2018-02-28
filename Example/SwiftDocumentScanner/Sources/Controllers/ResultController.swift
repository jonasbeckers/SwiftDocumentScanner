//
//  ResultController.swift
//  DocumentScanner_Example
//
//  Created by Jonas Beckers on 28/02/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class ResultController: UIViewController {

	@IBOutlet weak var imageView: UIImageView!
	var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

		imageView.image = image
    }

}
